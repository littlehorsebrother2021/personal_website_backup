# 小马哥个人博客 · 站点源码

> **技术栈**：Hexo 6.3 + hexo-theme-matery ｜ **线上地址**：<https://blog.556106.xyz/>
> **部署目标**：`littlehorsebrother2021/littlehorsebrother2021.github.io` 仓库的 `main` 分支（GitHub Pages）

这里保存博客的**源码与内容**。`public/`、`node_modules/`、`.deploy_git/`、`db.json` 都是可再生成的产物，已由 `.gitignore` 排除，**不要提交**。

---

## 一、快速开始

| 目的 | 命令 | 备注 |
| :--- | :--- | :--- |
| 新建文章 | `npm run new -- "标题"` | 默认生成到 `source/_posts/`，建议加 `--path 2026/学习类/标题` 直接归档 |
| 本地预览 | `npm run server` | 打开 <http://localhost:4000>，支持热更新 |
| 构建静态站点 | `npm run build` | 输出到 `public/` |
| 清理缓存 | `npm run clean` | 改过配置/主题后建议先清理 |
| 部署 | `npm run deploy` | 会自动提交并推送到 GitHub Pages 仓库 |
| 刷新文档清单 | `npm run manifest` | 重写各目录 README 的「清单」段与根目录 `MANIFEST.md` |
| 换文章封面 | `npm run covers` | 从必应 / Picsum 抓 4K 壁纸，自动裁剪并替换（见 [tools/README.md](tools/README.md)） |

> **本机提示**：`npm` 可能不在 PATH 中，此时用 Node 直接调用即可，例如
> `node node_modules/hexo-cli/bin/hexo generate`。

---

## 二、目录地图

| 路径 | 作用 | 主要文件类型 | 说明文档 |
| :--- | :--- | :--- | :--- |
| `_config.yml` | 站点主配置（标题、链接格式、插件、部署） | YAML | 见下方「配置要点」 |
| `package.json` / `package-lock.json` | 依赖与命令定义 | JSON | 本文件 |
| `MANIFEST.md` | 全站统计、目录索引、文章索引 | Markdown | 自动生成 |
| `GIT-GUIDE.md` | **Git 速查手册**：常用命令、撤销回退、报错处理、多电脑同步方案 | Markdown | 本文件 |
| `source/` | 站点内容根目录 | Markdown / 图片 / XML | [source/_README.md](source/_README.md) |
| `source/_posts/` | 文章正文，按 `年份/分类/` 归档 | Markdown + 图片 | [source/_posts/_README.md](source/_posts/_README.md) |
| `source/_data/` | 页面引用的结构化数据（友链等） | JSON | [source/_data/_README.md](source/_data/_README.md) |
| `source/about/` 等 | 6 个独立页面：关于、留言、友链、标签、分类、404 | Markdown | [source/_README.md](source/_README.md) |
| `themes/hexo-theme-matery/` | 当前启用的主题（已本地定制） | EJS / Stylus / JS / 图片 | [themes/README.md](themes/README.md) |
| `scaffolds/` | 新建文章/页面的 front-matter 模板 | Markdown 模板 | [scaffolds/README.md](scaffolds/README.md) |
| `scripts/` | 文档维护脚本 | Node.js (ESM) | [scripts/README.md](scripts/README.md) |
| `assets/` | 封面/背景**原始素材**（不发布，仅作生成输入） | 图片 | [assets/README.md](assets/README.md) |
| `tools/` | 封面裁剪、logo 替换脚本 | PowerShell | [tools/README.md](tools/README.md) |
| `docs/` | 专题操作手册（评论系统、封面配置） | Markdown | [docs/README.md](docs/README.md) |
| `.github/` | Dependabot 依赖自动升级配置 | YAML | [.github/README.md](.github/README.md) |
| `.vscode/` | 编辑器设置 | JSON | — |
| `public/` | **构建产物**（不入库） | HTML / CSS / JS / 图片 | — |
| `node_modules/` | **依赖**（不入库，`npm install` 还原） | — | — |
| `.deploy_git/` | **部署工作目录**（不入库，`hexo deploy` 重建） | — | — |
| `db.json` | **Hexo 缓存**（不入库，`hexo clean` 可删） | JSON | — |

---

## 三、文档体系（怎么看、怎么维护）

本仓库的每个目录都带一份说明文件，统一包含 **「说明」** 与 **「清单」** 两节：

```
# 目录名
## 说明      ← 手写：这个目录放什么、命名约定、注意事项
## 清单      ← 自动生成：目录内每个文件/子目录的类型、大小、说明、最后修改时间
   <!-- MANIFEST:BEGIN -->

> **路径**：`.` ｜ **直属文件** 9 ｜ **直属子目录** 9 ｜ **本目录合计** 451 个文件
>
> [站点总览](README.md) ｜ [全站清单](MANIFEST.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [.github/](<.github/README.md>) | 目录 | 2 个文件 | — | 2026-10-17 20:30 |
| [.vscode/](<.vscode>) | 目录 | 1 个文件 | — | 2026-10-17 19:50 |
| [assets/](<assets/README.md>) | 目录 | 11 个文件 | — | 2026-10-17 21:04 |
| [docs/](<docs/README.md>) | 目录 | 2 个文件 | — | 2026-10-17 20:41 |
| [scaffolds/](<scaffolds/README.md>) | 目录 | 4 个文件 | — | 2026-10-17 20:30 |
| [scripts/](<scripts/README.md>) | 目录 | 2 个文件 | — | 2026-10-17 20:30 |
| [source/](<source/_README.md>) | 目录 | 197 个文件 | — | 2026-10-17 20:30 |
| [themes/](<themes/README.md>) | 目录 | 219 个文件 | — | 2026-10-17 20:30 |
| [tools/](<tools/README.md>) | 目录 | 4 个文件 | — | 2026-10-17 21:04 |
| [_config.yml](<_config.yml>) | YAML | 3.4 KB | 配置 / 数据 | 2026-10-17 20:56 |
| [.gitattributes](<.gitattributes>) | 无扩展名 | 592 B | — | 2026-10-17 21:01 |
| [.gitignore](<.gitignore>) | 无扩展名 | 866 B | — | 2026-10-17 21:01 |
| [GIT-GUIDE.md](<GIT-GUIDE.md>) | Markdown | 13.5 KB | Git 使用说明（本站专用速查） | 2026-10-17 20:56 |
| [logo.png](<logo.png>) | 图片 | 2.49 MB | — | 2026-10-17 20:40 |
| [MANIFEST.md](<MANIFEST.md>) | Markdown | 10.7 KB | 全站文件清单 | 2026-10-17 20:56 |
| [package-lock.json](<package-lock.json>) | JSON | 211.6 KB | 配置 / 数据 | 2026-10-17 19:52 |
| [package.json](<package.json>) | JSON | 979 B | 配置 / 数据 | 2026-10-17 21:01 |
| [README.md](<README.md>) | Markdown | 9.8 KB | 小马哥个人博客 · 站点源码 | 2026-10-17 21:05 |

<!-- MANIFEST:END -->
```

- 根目录：`README.md`（本文件，总览）+ `MANIFEST.md`（全站清单）。
- `source/` **以外**的目录用 `README.md`。
- `source/` **以内**的目录必须用 `_README.md` —— 下划线开头的文件会被 Hexo 的隐藏文件规则忽略，不会渲染成页面、也不会被复制进 `public/`。
- 清单由 `scripts/gen-manifest.mjs` 扫描生成，**手改会在下次运行后被覆盖**；增删文件后执行 `npm run manifest` 即可。

---

## 四、写作流程

1. **新建**：`npm run new -- "标题" --path 2026/学习类/标题`
   —— 会在 `source/_posts/2026/学习类/` 下生成 `标题.md` 和同名图片目录。
2. **写正文**：front-matter 字段见 [scaffolds/README.md](scaffolds/README.md)；
   图片放同名目录，正文用相对路径引用（如 `![说明](图片名.png)`）。
3. **预览**：`npm run server`，确认排版与图片正常。
4. **构建**：`npm run build`，确认 0 error。
5. **部署**：`npm run deploy`。
6. **收尾**：`npm run manifest` 刷新清单 → 提交源码。

---

## 五、配置要点（`_config.yml`）

| 配置 | 当前值 | 说明 |
| :--- | :--- | :--- |
| `permalink` | `:layout/:year:month:day:hour:minute:second.html` | 文章链接即 `post/20260319163436/xxx.html` 形式 |
| `permalink_pinyin.enable` | `true` | 中文标题自动转拼音，避免 URL 出现中文 |
| `post_asset_folder` | `true` | 每篇文章自动配一个同名图片目录 |
| `theme` | `hexo-theme-matery` | 主题名与 `themes/` 下的目录一致 |
| `search` | `search.xml` | 依赖 `hexo-generator-search`，供导航栏搜索框使用 |
| `deploy` | git → `main` | 推送到 GitHub Pages 仓库根 |

---

## 六、约定与禁忌

- **文章归档**：一律 `年份/分类/文件名.md`，不要直接把文章丢在 `source/_posts/` 根下。
- **分类字段**：用 `category`（单数，可写数组），标签用 `tags: ["a","b"]`。
- **图片**：只放文章同名目录；不要塞进 `source/` 根或 `themes/`。
- **不要提交**：`public/`、`node_modules/`、`db.json`、`.deploy_git/`（已在 `.gitignore` 中）。
- **主题**：`themes/hexo-theme-matery/` 已本地定制，且**已移除其内嵌 `.git`**，改动直接进本仓库；不要再把主题变成子模块。
- **`source/` 内的说明文件**：必须命名为 `_README.md`，否则会出现在网站上。

---

## 七、维护记录

| 日期 | 变更 |
| :--- | :--- |
| 2026-10-17 | **新增 `tools/fetch-covers.ps1` + `npm run covers`**：可从必应（4K）或 Picsum 抓取壁纸，交互式选来源/用途/张数，自动下载校验、裁剪替换、清理多余编号、可选构建；原图存 `assets/incoming/` 且不入库。同时清理 17 张孤儿图（featureimages 9-23、banner 7-8，主题只用到 0-8 与 0-6）、补 `.gitattributes` 统一换行符。 |
| 2026-10-17 | **合并远程 `main`（2026-08-01 备份）**：取回封面/背景定制图（banner 0-8、featureimages 0-8、logo、favicon）、`assets/nature` 素材、`tools/` 两个生成脚本、`docs/评论区与封面配置.md`、根 `logo.png`；修正 3 篇文章的图片引用（原 `./image/...` 写法渲染后是死链），并把 `2025/阶段总结/image/除夕，2024一年总结/` 迁到标准位置 `2025/阶段总结/除夕，2024一年总结/`；主题 `_config.yml` 采用远程版本（`githubLink` 修正、`tcaptcha` 关闭）、`contact.ejs` 采用远程版本（去掉不存在的 `/css/style.css`、恢复 valine 条件加载）。仍保留本地的精简结构、文档体系与 `hexo-generator-search`；未恢复已删除的 `cyanstyle` 主题与重复副本。 |
| 2026-10-17 | 结构整理：删除重复主题副本（约 36MB）与未启用的 `cyanstyle` 主题；新增 `.gitignore` 并重建仓库索引（6513 → 419 个受控文件）；修复站内搜索（补装 `hexo-generator-search`）；修复 `source/.nojekyll`（原为空目录）；精简 `_config.yml` 无效配置；补齐各目录说明与清单。详见 [themes/README.md](themes/README.md) 的「已移除主题」一节。 |
