#!/usr/bin/env node
/**
 * subset-fontawesome.mjs —— 按站点实际用到的图标，裁剪 Font Awesome 的 CSS
 *
 * 为什么要做：
 *   主题引用的 all.min.css 有 99 KB / 1967 条规则，而本站只用了几十个图标。
 *   裁剪后约 10 KB，且不影响功能。
 *
 * 用法：
 *   1. 先构建一次（子集化会扫描 public/ 里真实出现的图标类）
 *        npm run build
 *   2. 再生成子集
 *        npm run fonts
 *        # 等价于 node tools/subset-fontawesome.mjs
 *
 * 注意：
 *   - 图标类来源 = public/ 里的 HTML ∪ 主题源码（ejs/js/yml）里出现的 fa-*
 *     （JS 动态切换的图标如暗色模式的太阳/月亮不会出现在静态 HTML，所以要看源码）
 *   - 生成后如果某个图标变成方块，说明它的类没被收集到：
 *     检查是不是拼写不同，或从 all.min.css 手动补回对应规则
 *   - 字族只保留实际用到的（solid / brands / regular）+ v4 兼容层（仅 5 KB）
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..');
const PUBLIC = path.join(ROOT, 'public');
const THEME = path.join(ROOT, 'themes', 'hexo-theme-matery');
const SRC_CSS = path.join(THEME, 'source', 'libs', 'awesome', 'css', 'all.min.css');
const OUT_CSS = path.join(THEME, 'source', 'libs', 'awesome', 'css', 'subset.css');

if (!fs.existsSync(SRC_CSS)) {
  console.error(`找不到 ${path.relative(ROOT, SRC_CSS)}，主题结构可能变了。`);
  process.exit(1);
}
if (!fs.existsSync(PUBLIC)) {
  console.error('public/ 不存在，请先执行 npm run build 再运行本脚本。');
  process.exit(1);
}

/* ---------- 1. 收集用到的图标类 ---------- */

const used = new Set();

function collectFromHtml(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) collectFromHtml(p);
    else if (e.name.endsWith('.html')) {
      const html = fs.readFileSync(p, 'utf8');
      for (const m of html.matchAll(/class="([^"]*)"/g)) {
        for (const c of m[1].split(/\s+/)) {
          if (/^fa[srbl]?(-[a-z0-9-]+)?$/.test(c)) used.add(c);
        }
      }
    }
  }
}
collectFromHtml(PUBLIC);

function collectFromSource(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (['libs', 'webfonts', 'css', 'node_modules'].includes(e.name)) continue;
      collectFromSource(p);
    } else if (/\.(ejs|js|yml|json)$/.test(e.name)) {
      const t = fs.readFileSync(p, 'utf8');
      for (const m of t.matchAll(/\bfa[srbl]?-[a-z0-9]+(?:-[a-z0-9]+)*\b/g)) {
        if (/^fa[srbl]?-\d+x$/.test(m[0])) continue; // fa-2x 这类尺寸类
        used.add(m[0]);
      }
    }
  }
}
collectFromSource(THEME);

/* ---------- 2. 切分并筛选 CSS 规则 ---------- */

const css = fs.readFileSync(SRC_CSS, 'utf8');
const rules = [];
for (const chunk of css.split('}')) {
  const i = chunk.lastIndexOf('{');
  if (i < 0) continue;
  const sel = chunk.slice(0, i).trim();
  if (sel) rules.push({ sel, body: chunk.slice(i + 1) });
}

const families = new Set();
if (used.has('fas')) families.add('solid');
if (used.has('fab')) families.add('brands');
if (used.has('far')) families.add('regular');

const kept = [];
const dropped = [];

for (const r of rules) {
  const classes = [...r.sel.matchAll(/\.(fa[srbl]?(?:-[a-z0-9-]+)?)/g)].map((m) => m[1]);

  if (/^@font-face/.test(r.sel)) {
    /* FA6 的 solid 与 regular 共用族名 "Font Awesome 6 Free"，只能靠字体文件名区分 */
    const src = r.body;
    const need =
      (/fa-solid-900/.test(src) && families.has('solid')) ||
      (/fa-brands-400/.test(src) && families.has('brands')) ||
      (/fa-regular-400/.test(src) && families.has('regular')) ||
      /fa-v4compatibility/.test(src);

    if (need) {
      // 仓库里只保留 woff2，去掉 ttf 回退
      r.body = r.body.replace(/,url\(\.\.\/webfonts\/[a-z0-9-]+\.ttf\) format\("truetype"\)/g, '');
      kept.push(r);
    } else {
      dropped.push(r);
    }
    continue;
  }

  if (classes.length === 0) {
    kept.push(r); // :root / @keyframes / 通用工具类，一律保留
    continue;
  }
  if (classes.some((c) => used.has(c))) kept.push(r);
  else dropped.push(r);
}

const out =
  '/* Font Awesome 子集：只保留本站实际用到的图标。\n' +
  ` * 由 tools/subset-fontawesome.mjs 生成于 ${new Date().toISOString().slice(0, 10)}\n` +
  ` * 保留 ${kept.length} 条规则，裁掉 ${dropped.length} 条。请勿手改。\n` +
  ' */\n' +
  kept.map((r) => `${r.sel}{${r.body}}`).join('\n') +
  '\n';

fs.writeFileSync(OUT_CSS, out);

const missing = [...used].filter((c) => !out.includes(`.${c}`));

console.log(`图标类 ${used.size} 个｜字族 ${[...families].join(', ')}`);
console.log(`规则 ${rules.length} → ${kept.length}（裁掉 ${dropped.length}）`);
console.log(
  `体积 ${(fs.statSync(SRC_CSS).size / 1024).toFixed(1)} KB → ${(fs.statSync(OUT_CSS).size / 1024).toFixed(1)} KB`
);
if (missing.length) {
  console.log(`⚠ 这些类在子集中找不到（可能是拼接产物或拼写问题）：${missing.join(', ')}`);
}
