#!/usr/bin/env node
/**
 * gen-manifest.mjs —— 全站说明文档的「清单」生成器
 *
 * 作用：
 *   1. 扫描仓库里所有带 `<!-- MANIFEST:BEGIN -->` 标记的说明文件
 *      （README.md 或 _README.md），把标记之间的内容重写成该目录的实时文件清单。
 *   2. 重新生成 docs/MANIFEST.md（全站统计 + 目录索引 + 文章索引）。
 *
 * 用法：
 *   node tools/gen-manifest.mjs       # 或在项目根执行 npm run manifest
 *
 * 约定：
 *   - 标记之间的内容全部由本脚本覆盖，手改会在下次运行后被冲掉。
 *   - 标记之外的手写说明不会被改动。
 *   - 自动跳过依赖、构建产物、部署目录与维护脚本的快照目录。
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..');

/** 不参与扫描的目录（生成物 / 依赖 / 版本控制元数据） */
const SKIP_DIRS = new Set([
  'node_modules',
  'public',
  '.deploy_git',
  '.git',
  '_audit',
  '_acl-recovery',
  'incoming',
]);

/** 不参与扫描的单个文件（Hexo 缓存，已被 .gitignore 排除） */
const SKIP_FILES = new Set(['db.json']);

/** 说明文件的两套命名：src 内必须用下划线前缀，否则会被 Hexo 当成页面渲染 */
const README_NAMES = ['README.md', '_README.md'];

const BEGIN = '<!-- MANIFEST:BEGIN -->';
const END = '<!-- MANIFEST:END -->';

const toPosix = (p) => p.split(path.sep).join('/');
const relOf = (abs) => toPosix(path.relative(ROOT, abs));
const relFrom = (fromDir, target) => toPosix(path.relative(fromDir, target)) || '.';

const EXT_LABEL = {
  '.md': 'Markdown',
  '.ejs': 'EJS 模板',
  '.js': 'JavaScript',
  '.mjs': 'JavaScript',
  '.json': 'JSON',
  '.yml': 'YAML',
  '.yaml': 'YAML',
  '.css': '样式表',
  '.styl': 'Stylus',
  '.html': 'HTML',
  '.xml': 'XML',
  '.txt': '文本',
  '.png': '图片',
  '.jpg': '图片',
  '.jpeg': '图片',
  '.gif': '图片',
  '.svg': '矢量图',
  '.ico': '图标',
  '.ttf': '字体',
  '.woff': '字体',
  '.woff2': '字体',
  '.eot': '字体',
  '.pdf': 'PDF',
};

function humanSize(bytes) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1024 / 1024).toFixed(2)} MB`;
}

function fmtTime(d) {
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`;
}

/** 极简 front-matter 解析：只取本脚本用得到的字段 */
function readFrontMatter(absFile) {
  let text = '';
  try {
    text = fs.readFileSync(absFile, 'utf8');
  } catch {
    return {};
  }
  const m = text.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) return {};

  const data = {};
  let key = null;
  for (const raw of m[1].split(/\r?\n/)) {
    if (!raw.trim()) continue;
    const kv = raw.match(/^([A-Za-z_][\w-]*)\s*:\s*(.*)$/);
    if (kv) {
      key = kv[1];
      data[key] = kv[2].trim();
    } else if (key && /^\s*-\s+/.test(raw)) {
      data[key] = `${data[key] === '' ? '' : data[key]},${raw.replace(/^\s*-\s+/, '').trim()}`;
    }
  }
  for (const k of ['tags', 'category', 'categories']) {
    if (typeof data[k] === 'string') {
      data[k] = data[k]
        .replace(/^\[|\]$/g, '')
        .split(',')
        .map((s) => s.trim().replace(/^["']|["']$/g, ''))
        .filter(Boolean);
    }
  }
  return data;
}

/** 文章/页面的可读标题：front-matter title → 一级标题 → 文件名 */
function displayTitle(absFile) {
  const fm = readFrontMatter(absFile);
  if (fm.title && typeof fm.title === 'string') return fm.title;
  if (Array.isArray(fm.title)) return fm.title.join(' / ');
  try {
    const text = fs.readFileSync(absFile, 'utf8');
    const h = text.match(/^#\s+(.+)$/m);
    if (h) return h[1].trim();
  } catch {
    /* ignore */
  }
  return '';
}

function listDir(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];
  const dirs = [];
  for (const e of entries) {
    if (e.isDirectory()) {
      if (SKIP_DIRS.has(e.name)) continue;
      dirs.push(e.name);
    } else {
      if (SKIP_FILES.has(e.name)) continue;
      files.push(e.name);
    }
  }
  files.sort((a, b) => a.localeCompare(b, 'zh-CN'));
  dirs.sort((a, b) => a.localeCompare(b, 'zh-CN'));
  return { files, dirs };
}

function countFiles(dir) {
  let n = 0;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (e.isDirectory()) {
      if (SKIP_DIRS.has(e.name)) continue;
      n += countFiles(path.join(dir, e.name));
    } else if (!SKIP_FILES.has(e.name)) n += 1;
  }
  return n;
}

function findReadme(dir) {
  for (const name of README_NAMES) {
    const p = path.join(dir, name);
    if (fs.existsSync(p)) return p;
  }
  return null;
}

const cell = (s) => String(s).replace(/\|/g, '\\|').replace(/\r?\n/g, ' ').trim();

/** 生成某个目录的清单块 */
function buildBlock(dir) {
  const { files, dirs } = listDir(dir);
  const depthUp = relFrom(dir, ROOT);
  const rootLink = depthUp === '.' ? 'README.md' : `${depthUp}/README.md`;
  const manifestLink = depthUp === '.' ? 'docs/MANIFEST.md' : `${depthUp}/docs/MANIFEST.md`;
  const parentDir = path.dirname(dir);
  const parentReadme = parentDir === dir ? null : findReadme(parentDir);
  const nav = [`[站点总览](${rootLink})`, `[全站清单](${manifestLink})`];
  if (parentReadme) {
    nav.push(`[上级目录](${relFrom(dir, parentReadme)})`);
  }

  const total = countFiles(dir);
  const lines = [BEGIN, ''];
  lines.push(
    `> **路径**：\`${relOf(dir) || '.'}\` ｜ **直属文件** ${files.length} ｜ **直属子目录** ${dirs.length} ｜ **本目录合计** ${total} 个文件`
  );
  lines.push('>');
  lines.push(`> ${nav.join(' ｜ ')}`);
  lines.push('');
  lines.push('| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |');
  lines.push('| :--- | :--- | :--- | :--- | :--- |');

  for (const name of dirs) {
    const abs = path.join(dir, name);
    const st = fs.statSync(abs);
    const childReadme = findReadme(abs);
    const link = childReadme ? relFrom(dir, childReadme) : relFrom(dir, abs);
    const inner = countFiles(abs);
    lines.push(
      `| [${cell(name)}/](<${link}>) | 目录 | ${inner} 个文件 | — | ${fmtTime(st.mtime)} |`
    );
  }

  for (const name of files) {
    const abs = path.join(dir, name);
    const st = fs.statSync(abs);
    const ext = path.extname(name).toLowerCase();
    const label = EXT_LABEL[ext] || (ext ? ext.replace('.', '').toUpperCase() : '无扩展名');
    let desc = '';
    if (ext === '.md') desc = displayTitle(abs);
    else if (ext === '.json' || ext === '.yml' || ext === '.yaml') desc = '配置 / 数据';
    lines.push(
      `| [${cell(name)}](<${name}>) | ${label} | ${humanSize(st.size)} | ${cell(desc) || '—'} | ${fmtTime(st.mtime)} |`
    );
  }

  if (!files.length && !dirs.length) {
    lines.push('| （空目录） | — | — | — | — |');
  }

  lines.push('');
  lines.push(END);
  return lines.join('\n');
}

/** 把清单块写回说明文件 */
function updateReadme(readme) {
  const dir = path.dirname(readme);
  const content = fs.readFileSync(readme, 'utf8');
  const eol = content.includes('\r\n') ? '\r\n' : '\n';
  const lines = content.split(/\r?\n/);

  /* 只认「独占一行」的标记，并且跳过 ``` / ~~~ 围栏代码块。
     原因：文档正文里常把标记写成行内代码（`<!-- MANIFEST:BEGIN -->`）或放在
     代码示例里，早期用 indexOf 直接搜索会把正文替换掉（2026-10-18 踩过）。
     若有多个候选，取最后一对 —— 真正的清单块总在文件末尾。 */
  let inFence = false;
  let beginIdx = -1;
  let endIdx = -1;
  for (let i = 0; i < lines.length; i++) {
    const t = lines[i].trim();
    if (/^(```|~~~)/.test(t)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    if (t === BEGIN) beginIdx = i;
    else if (t === END && beginIdx !== -1) endIdx = i;
  }

  if (beginIdx === -1 || endIdx === -1 || endIdx < beginIdx) {
    console.warn(`  跳过（无标记）：${relOf(readme)}`);
    return false;
  }

  const block = buildBlock(dir).split('\n');
  const next = [...lines.slice(0, beginIdx), ...block, ...lines.slice(endIdx + 1)].join(eol);
  if (next !== content) fs.writeFileSync(readme, next);
  return next !== content;
}

/** 递归找出所有需要更新的说明文件 */
function collectReadmes(dir, found = []) {
  const readme = findReadme(dir);
  if (readme) found.push(readme);
  for (const name of listDir(dir).dirs) {
    collectReadmes(path.join(dir, name), found);
  }
  return found;
}

/** 收集全站文章（按日期倒序） */
function collectPosts(dir = path.join(ROOT, 'source', '_posts'), acc = []) {
  if (!fs.existsSync(dir)) return acc;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const abs = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (!SKIP_DIRS.has(e.name)) collectPosts(abs, acc);
    } else if (e.name.toLowerCase().endsWith('.md') && !e.name.startsWith('_')) {
      const fm = readFrontMatter(abs);
      const st = fs.statSync(abs);
      acc.push({
        file: relOf(abs),
        title: displayTitle(abs) || e.name.replace(/\.md$/, ''),
        date: (Array.isArray(fm.date) ? fm.date[0] : fm.date) || fmtTime(st.mtime),
        category: (fm.categories || fm.category || []).join(' / ') || '未分类',
        tags: (fm.tags || []).join(', '),
      });
    }
  }
  return acc;
}

/** 生成根目录 MANIFEST.md */
function buildRootManifest() {
  const posts = collectPosts().sort((a, b) => String(b.date).localeCompare(String(a.date)));

  /* 只把「有意义」的目录列进索引：顶层目录、带说明文档的目录、直接含 .md 的目录。
     更深的图片资源目录、主题第三方库目录 = 由上级目录自己的「清单」覆盖。 */
  const meaningful = (dir) => {
    const rel = relOf(dir);
    if (rel === '') return true;
    if (rel.split('/').length === 1) return true;
    if (findReadme(dir)) return true;
    return listDir(dir).files.some((f) => f.toLowerCase().endsWith('.md'));
  };

  const allDirs = [];
  (function walk(dir) {
    allDirs.push(dir);
    for (const name of listDir(dir).dirs) walk(path.join(dir, name));
  })(ROOT);
  const dirs = allDirs
    .filter(meaningful)
    .sort((a, b) => relOf(a).localeCompare(relOf(b), 'zh-CN'));

  let totalFiles = 0;
  let totalBytes = 0;
  const extStat = new Map();
  (function scan(dir) {
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      if (e.isDirectory()) {
        if (!SKIP_DIRS.has(e.name)) scan(path.join(dir, e.name));
      } else if (!SKIP_FILES.has(e.name)) {
        const st = fs.statSync(path.join(dir, e.name));
        totalFiles += 1;
        totalBytes += st.size;
        const ext = path.extname(e.name).toLowerCase() || '(无)';
        const cur = extStat.get(ext) || { n: 0, b: 0 };
        cur.n += 1;
        cur.b += st.size;
        extStat.set(ext, cur);
      }
    }
  })(ROOT);

  const out = [];
  out.push('# 全站文件清单');
  out.push('');
  out.push(
    `> 本文件由 \`tools/gen-manifest.mjs\` 自动生成，**请勿手改**；需要刷新时在项目根执行 \`npm run manifest\`。`
  );
  out.push(
    '> 统计范围：纳入版本控制的文件（自动排除 `node_modules/`、`public/`、`.deploy_git/`、`db.json`、`_audit/`、`assets/incoming/`）。'
  );
  out.push(`> 生成时间：${fmtTime(new Date())}`);
  out.push('');

  out.push('## 一、全站统计');
  out.push('');
  out.push('| 指标 | 数值 |');
  out.push('| :--- | :--- |');
  out.push(`| 受控文件总数 | ${totalFiles} |`);
  out.push(`| 文件总体积 | ${humanSize(totalBytes)} |`);
  out.push(`| 目录总数 | ${allDirs.length} |`);
  out.push(`| 索引中列出 | ${dirs.length} 个（有说明文档或有文章的目录） |`);
  out.push(`| 文章总数 | ${posts.length} |`);
  out.push(`| 带说明文档的目录 | ${dirs.filter((d) => findReadme(d)).length} |`);
  out.push('');

  out.push('## 二、文件类型分布');
  out.push('');
  out.push('| 扩展名 | 类型 | 文件数 | 体积 |');
  out.push('| :--- | :--- | ---: | ---: |');
  for (const [ext, v] of [...extStat.entries()].sort((a, b) => b[1].n - a[1].n)) {
    out.push(`| \`${ext}\` | ${EXT_LABEL[ext] || '—'} | ${v.n} | ${humanSize(v.b)} |`);
  }
  out.push('');

  out.push('## 三、目录索引');
  out.push('');
  out.push(
    '> 只列出顶层目录、带说明文档的目录、以及直接存放文章的目录；图片资源目录与主题第三方库目录请到其上级目录的说明文件里查看。'
  );
  out.push('');
  out.push(
    '| 目录 | 说明文档 | 直属文件 | 直属子目录 | 合计文件 | 最后修改 |'
  );
  out.push('| :--- | :--- | ---: | ---: | ---: | :--- |');
  for (const dir of dirs) {
    const { files, dirs: sub } = listDir(dir);
    const readme = findReadme(dir);
    const name = relOf(dir) || '.';
    const link = readme ? `[说明](${relFrom(path.join(ROOT, 'docs'), readme)})` : '—';
    const st = fs.statSync(dir);
    out.push(
      `| \`${name}\` | ${link} | ${files.length} | ${sub.length} | ${countFiles(dir)} | ${fmtTime(st.mtime)} |`
    );
  }
  out.push('');

  out.push('## 四、文章索引');
  out.push('');
  out.push('| 日期 | 分类 | 标签 | 标题 | 文件 |');
  out.push('| :--- | :--- | :--- | :--- | :--- |');
  for (const p of posts) {
    out.push(
      `| ${cell(String(p.date).slice(0, 16))} | ${cell(p.category)} | ${cell(p.tags) || '—'} | ${cell(p.title)} | [${cell(path.basename(p.file))}](<../${p.file}>) |`
    );
  }
  out.push('');

  const docsDir = path.join(ROOT, 'docs');
  fs.mkdirSync(docsDir, { recursive: true });
  fs.writeFileSync(path.join(docsDir, 'MANIFEST.md'), `${out.join('\n')}\n`);
  return { totalFiles, totalBytes, dirs: dirs.length, posts: posts.length };
}

/* ------------------------------------------------------------------ */
const readmes = collectReadmes(ROOT);
let changed = 0;
for (const r of readmes) {
  if (updateReadme(r)) changed += 1;
}
const stat = buildRootManifest();

console.log(`说明文档：${readmes.length} 个，其中 ${changed} 个清单已更新`);
console.log(
  `MANIFEST.md：${stat.totalFiles} 个文件 / ${humanSize(stat.totalBytes)} / ${stat.dirs} 个目录 / ${stat.posts} 篇文章`
);
