/* global hexo */
/**
 * lazy-images.js —— 给正文图片加懒加载与宽高标注
 *
 * ⚠️ 本文件是「Hexo 脚本」而不是普通 CommonJS 模块：
 *    Hexo 会把 scripts/ 下的源码整体包成
 *    (function(exports, require, module, __filename, __dirname, hexo){ ... }) 直接执行，
 *    **不会调用 module.exports**。所以必须用注入的全局 `hexo`。
 *
 * 两个过滤器：
 *   1. after_render:html  给所有页面里首屏之外的图片加 loading="lazy" decoding="async"
 *   2. after_post_render  给文章正文的图片补 width/height（+ 内联 height:auto），减少 CLS
 *
 * 为什么尺寸在 after_post_render 里算、而不是等生成完再改 public：
 *   after_generate 触发时 public/ 还没落盘（hexo clean 后尤其明显），读磁盘会拿到空目录；
 *   而 after_post_render 阶段可以直接按「文章文件名 → 同名资源目录」到 source/ 里读原图，
 *   既准确又不受构建顺序影响，hexo s / hexo g 都生效。
 */

'use strict';

const fs = require('fs');
const path = require('path');

/* ---------- 读取图片尺寸（解析文件头，不引入第三方库） ---------- */

function pngSize(buf) {
  if (buf.length < 24 || buf.readUInt32BE(0) !== 0x89504e47) return null;
  return { width: buf.readUInt32BE(16), height: buf.readUInt32BE(20) };
}

function jpegSize(buf) {
  if (buf.length < 4 || buf[0] !== 0xff || buf[1] !== 0xd8) return null;
  let i = 2;
  while (i + 9 < buf.length) {
    if (buf[i] !== 0xff) {
      i += 1;
      continue;
    }
    const marker = buf[i + 1];
    const len = buf.readUInt16BE(i + 2);
    if (
      (marker >= 0xc0 && marker <= 0xc3) ||
      (marker >= 0xc5 && marker <= 0xc7) ||
      (marker >= 0xc9 && marker <= 0xcb) ||
      (marker >= 0xcd && marker <= 0xcf)
    ) {
      return { height: buf.readUInt16BE(i + 5), width: buf.readUInt16BE(i + 7) };
    }
    if (len < 2) return null;
    i += 2 + len;
  }
  return null;
}

function gifSize(buf) {
  if (buf.length < 10 || buf.toString('ascii', 0, 3) !== 'GIF') return null;
  return { width: buf.readUInt16LE(6), height: buf.readUInt16LE(8) };
}

const sizeCache = new Map();

function imageSize(file) {
  if (sizeCache.has(file)) return sizeCache.get(file);
  let fd;
  let result = null;
  try {
    fd = fs.openSync(file, 'r');
    const buf = Buffer.alloc(64 * 1024);
    const read = fs.readSync(fd, buf, 0, buf.length, 0);
    const head = buf.subarray(0, read);
    result = pngSize(head) || jpegSize(head) || gifSize(head);
  } catch {
    result = null;
  } finally {
    if (fd !== undefined) {
      try {
        fs.closeSync(fd);
      } catch {
        /* ignore */
      }
    }
  }
  sizeCache.set(file, result);
  return result;
}

function findInDir(dir, fileName, depth) {
  if (depth > 2) return null;
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return null;
  }
  for (const e of entries) {
    if (e.isDirectory()) {
      const found = findInDir(path.join(dir, e.name), fileName, depth + 1);
      if (found) return found;
    } else if (e.name === fileName) {
      return path.join(dir, e.name);
    }
  }
  return null;
}

/* ---------- 跳过规则 ---------- */

const SKIP_CLASS = /(logo|avatar|profile|nav-|icon|emoji)/i;

function isChromeImage(tag, src) {
  if (SKIP_CLASS.test(tag)) return true;
  if (/^\/medias\/logo|^\/favicon|^\/medias\/banner/.test(src)) return true;
  return false;
}

/* ---------- 1. 懒加载（所有页面） ---------- */

hexo.extend.filter.register('after_render:html', (str) =>
  str.replace(/<img\b([^>]*)>/gi, (tag, attrs) => {
    const m = attrs.match(/\bsrc=["']([^"']+)["']/i);
    if (!m) return tag;
    const src = m[1];
    if (/\bloading=/.test(tag)) return tag;
    if (isChromeImage(tag, src)) return tag;
    if (!src.startsWith('/')) return tag; // 外链 / data: / 协议相对
    return '<img' + attrs.replace(/\/\s*$/, '') + ' loading="lazy" decoding="async">';
  })
);

/* ---------- 2. 宽高标注（文章正文） ---------- */

hexo.extend.filter.register('after_post_render', (data) => {
  if (!data.content || !data.source) return data;

  const sourceDir = hexo.source_dir;
  const relDir = path.dirname(data.source); // _posts/2026/STM32N6
  const postName = path.basename(data.source).replace(/\.md$/i, '');
  const assetDir = path.join(sourceDir, relDir, postName); // 同名资源目录

  data.content = data.content.replace(/<img\b([^>]*)>/gi, (tag, attrs) => {
    if (/\bwidth=/i.test(attrs) || /\bheight=/i.test(attrs)) return tag;

    const m = attrs.match(/\bsrc=["']([^"']+)["']/i);
    if (!m) return tag;
    const src = m[1].split('?')[0].split('#')[0];
    if (!src.startsWith('/')) return tag; // 只处理本站图片
    if (isChromeImage(tag, src)) return tag;

    const fileName = decodeURIComponent(src.split('/').pop());
    if (!fileName) return tag;

    let size = null;
    const direct = path.join(assetDir, fileName);
    if (fs.existsSync(direct)) size = imageSize(direct);

    // 兜底：资源目录下再找两层（兼容历史上 image/子目录 的遗留结构）
    if (!size && fs.existsSync(assetDir)) {
      const found = findInDir(assetDir, fileName, 0);
      if (found) size = imageSize(found);
    }
    if (!size || !size.width || !size.height) return tag;

    const clean = attrs.replace(/\/\s*$/, '');
    const dims = ' width="' + size.width + '" height="' + size.height + '"';
    if (/\bstyle=["']/i.test(clean)) {
      const merged = clean.replace(/(\bstyle=["'])([^"']*)(["'])/i, '$1$2;height:auto$3');
      return '<img' + merged + dims + '>';
    }
    return '<img' + clean + dims + ' style="height:auto">';
  });

  return data;
});
