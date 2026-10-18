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
| 刷新文档清单 | `npm run manifest` | 重写各目录 README 的「清单」段与 `docs/MANIFEST.md` |
| 换文章封面 | `npm run covers` | 从必应 / Picsum 抓 4K 壁纸，自动裁剪并替换（见 [tools/README.md](tools/README.md)） |
| 压缩配图 | `npm run optimize -- -DryRun` | 先看能省多少；去掉 `-DryRun` 才真正压（原图可从 git 还原） |

> **本机提示**：`npm` 可能不在 PATH 中，此时用 Node 直接调用即可，例如
> `node node_modules/hexo-cli/bin/hexo generate`。

---

## 二、目录地图

| 路径 | 作用 | 主要文件类型 | 说明文档 |
| :--- | :--- | :--- | :--- |
| `_config.yml` | 站点主配置（标题、链接格式、插件、部署） | YAML | 见下方「配置要点」 |
| `package.json` / `package-lock.json` | 依赖与命令定义 | JSON | 本文件 |
| `docs/MANIFEST.md` | 全站统计、目录索引、文章索引 | Markdown | 自动生成 |
| `docs/ARCHITECTURE.md` | **架构说明**：站点由哪些组件构成、数据怎么流动、改动该动哪个文件 | Markdown | [docs/README.md](docs/README.md) |
| `docs/GIT-GUIDE.md` | **Git 速查手册**：常用命令、撤销回退、报错处理、多电脑同步方案 | Markdown | [docs/README.md](docs/README.md) |
| `source/` | 站点内容根目录 | Markdown / 图片 / XML | [source/_README.md](source/_README.md) |
| `source/_posts/` | 文章正文，按 `年份/分类/` 归档 | Markdown + 图片 | [source/_posts/_README.md](source/_posts/_README.md) |
| `source/_data/` | 页面引用的结构化数据（友链等） | JSON | [source/_data/_README.md](source/_data/_README.md) |
| `source/about/` 等 | 6 个独立页面：关于、留言、友链、标签、分类、404 | Markdown | [source/_README.md](source/_README.md) |
| `themes/hexo-theme-matery/` | 当前启用的主题（已本地定制，纯 CSS 无 Stylus） | EJS / CSS / JS / 图片 | [themes/README.md](themes/README.md) |
| `scaffolds/` | 新建文章/页面的 front-matter 模板 | Markdown 模板 | [scaffolds/README.md](scaffolds/README.md) |
| `tools/` | 维护脚本：清单生成、壁纸抓取、封面裁剪、logo 替换 | Node.js / PowerShell | [tools/README.md](tools/README.md) |
| `assets/` | 封面/背景**原始素材**（不发布，仅作生成输入） | 图片 | [assets/README.md](assets/README.md) |
| `docs/` | **全部文档**：架构说明、Git 速查、全站清单、专题手册 | Markdown | [docs/README.md](docs/README.md) |
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

> **路径**：`.` ｜ **直属文件** 6 ｜ **直属子目录** 7 ｜ **本目录合计** 446 个文件
>
> [站点总览](README.md) ｜ [全站清单](docs/MANIFEST.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [.github/](<.github/README.md>) | 目录 | 2 个文件 | — | 2026-10-18 18:31 |
| [assets/](<assets/README.md>) | 目录 | 11 个文件 | — | 2026-10-18 18:36 |
| [docs/](<docs/README.md>) | 目录 | 5 个文件 | — | 2026-10-18 18:37 |
| [scaffolds/](<scaffolds/README.md>) | 目录 | 4 个文件 | — | 2026-10-17 20:30 |
| [source/](<source/_README.md>) | 目录 | 197 个文件 | — | 2026-10-17 20:30 |
| [themes/](<themes/README.md>) | 目录 | 215 个文件 | — | 2026-10-17 20:30 |
| [tools/](<tools/README.md>) | 目录 | 6 个文件 | — | 2026-10-18 18:38 |
| [_config.yml](<_config.yml>) | YAML | 3.4 KB | 配置 / 数据 | 2026-10-17 20:56 |
| [.gitattributes](<.gitattributes>) | 无扩展名 | 592 B | — | 2026-10-17 21:01 |
| [.gitignore](<.gitignore>) | 无扩展名 | 866 B | — | 2026-10-17 21:01 |
| [package-lock.json](<package-lock.json>) | JSON | 207.4 KB | 配置 / 数据 | 2026-10-18 08:48 |
| [package.json](<package.json>) | JSON | 1012 B | 配置 / 数据 | 2026-10-18 18:26 |
| [README.md](<README.md>) | Markdown | 12.4 KB | 小马哥个人博客 · 站点源码 | 2026-10-18 18:38 |

<!-- MANIFEST:END -->
```

- 根目录只留 `README.md`（本文件，总览）；其余文档统一放 `docs/`：
  `MANIFEST.md`（全站清单）、`ARCHITECTURE.md`（组件与数据流）、`GIT-GUIDE.md`（git 速查）、专题手册。
- `source/` **以外**的目录用 `README.md`。
- `source/` **以内**的目录必须用 `_README.md` —— 下划线开头的文件会被 Hexo 的隐藏文件规则忽略，不会渲染成页面、也不会被复制进 `public/`。
- 清单由 `tools/gen-manifest.mjs` 扫描生成，**手改会在下次运行后被覆盖**；增删文件后执行 `npm run manifest` 即可。
- ⚠️ **不要新建 `scripts/` 目录**：Hexo 会把它当成插件目录，逐个 `require` 其中的文件，`README.md` 之类会直接报语法错误。所有维护脚本都放 `tools/`。

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
| 2026-10-18 | **回滚图标子集化**：`subset.css` 是个新文件名，部署或 CDN 缓存只要有一环没同步，页面引用了它、文件却 404，全站图标（搜索、翻页箭头、回到顶部、暗色模式、社交）会同时消失。已恢复 `all.min.css` + 完整字体，并删除 `subset.css` 与 `tools/subset-fontawesome.mjs`。其余三项性能优化（关音乐、去 Prism 脚本、图片懒加载）保留。 |
| 2026-10-18 | **首屏性能优化（建议文档 §4.2 的四项全部落地）**：① 关闭音乐播放器（`music.enable: false`，省 58 KB）；② 移除客户端 `prism.min.js`（568 KB）——代码在构建时已由 `prismjs.preprocess` 预高亮，浏览器端再跑一遍毫无作用，样式表保留；③ Font Awesome 子集化，`all.min.css` 99 KB → 11 KB，字体只留 woff2（共省约 720 KB），新增 `tools/subset-fontawesome.mjs` + `npm run fonts`；④ 新增主题插件 `scripts/lazy-images.js`，给正文图片加 `loading="lazy"` 并按图片文件头补 `width/height`（减少 CLS）。实测：**首页 JS/CSS 919 KB → 756 KB，文章页 1574 KB → 846 KB（−46%）**。 |
| 2026-10-18 | **精简主目录**：把 `ARCHITECTURE.md`、`GIT-GUIDE.md`、`MANIFEST.md` 全部移入 `docs/`，`logo.png` 移入 `assets/`（`replace-logo.ps1` 默认路径同步修改），删除已无意义的 `.vscode/`（唯一设置 `git.ignoreLimitWarning` 是因仓库过大而加的，现已不需要）。根目录现在只剩 `README.md` 一个文档 + 若干必需配置。`gen-manifest.mjs` 已适配新位置。 |
| 2026-10-18 | 继续瘦身：删除主题里**零引用**的库存图 `themes/…/source/medias/images/`（3 张 / 1 MB）；`Dependabot` 改为每周检查、PR 上限 5，并**屏蔽 `hexo` 与 `hexo-renderer-*` 的大版本自动 PR**；新增根目录 `ARCHITECTURE.md`（组件构成与数据流），并重新生成全部目录索引。禁用的 mermaid / gitalk / twikoo 三个库（6.1 MB）按你的要求保持原样。 |
| 2026-10-18 | **体积优化与功能性修复**：① 自定义 404 页面此前从未生效（输出在 `404/index.html`，而 GitHub Pages 只认根目录 `404.html`），已用 `permalink: 404.html` 修正；② favicon / logo 三份相同的 2048×2048 PNG 各 2.5 MB，已分别缩到 192 / 256 / 512，共省 7.2 MB；③ 新增 `tools/optimize-images.ps1` + `npm run optimize`，把 9 张 3000~4600px 的照片压到 1920px、质量 85，**25.6 MB → 4.0 MB**；站点产物体积 **54.8 MB → 28.4 MB**。 |
| 2026-10-18 | 处理 Dependabot 的 4 个升级 PR：**合并** `hexo-generator-index` 3.0.0 → 4.0.0（产物零差异）；**移除** `hexo-renderer-stylus`（项目里没有任何 `.styl` 文件，纯死重量，连带去掉 stylus/nib 共 11 个包）；**驳回** `hexo` 8.1.2 与 `hexo-renderer-marked` 7.0.1。原因：Hexo 8 把语法高亮改成插件注册制、默认 highlight.js，而主题模板仍按 `config.prismjs.enable` 加载 Prism 资源、主题 CSS 也没有 highlight.js 规则，升级会导致代码块样式错乱；且 hexo 8 要求 Node ≥ 20.19。实测详见会话记录。 |
| 2026-10-17 | 用 `npm run covers` 换入新的文章封面（8 张）与站点背景（7 张）。同时修掉脚本 bug：`banner` 场景下 `-Keep` 会把新图排到 7 号之后永不显示，现已忽略该组合并强制背景只留 7 张；替换成功后自动清理下载的原始大图（`-KeepOriginals` 可保留）。 |
| 2026-10-17 | **新增 `tools/fetch-covers.ps1` + `npm run covers`**：可从必应（4K）或 Picsum 抓取壁纸，交互式选来源/用途/张数，自动下载校验、裁剪替换、清理多余编号、可选构建；原图存 `assets/incoming/` 且不入库。同时清理 17 张孤儿图（featureimages 9-23、banner 7-8，主题只用到 0-8 与 0-6）、补 `.gitattributes` 统一换行符。 |
| 2026-10-17 | **合并远程 `main`（2026-08-01 备份）**：取回封面/背景定制图（banner 0-8、featureimages 0-8、logo、favicon）、`assets/nature` 素材、`tools/` 两个生成脚本、`docs/评论区与封面配置.md`、根 `logo.png`；修正 3 篇文章的图片引用（原 `./image/...` 写法渲染后是死链），并把 `2025/阶段总结/image/除夕，2024一年总结/` 迁到标准位置 `2025/阶段总结/除夕，2024一年总结/`；主题 `_config.yml` 采用远程版本（`githubLink` 修正、`tcaptcha` 关闭）、`contact.ejs` 采用远程版本（去掉不存在的 `/css/style.css`、恢复 valine 条件加载）。仍保留本地的精简结构、文档体系与 `hexo-generator-search`；未恢复已删除的 `cyanstyle` 主题与重复副本。 |
| 2026-10-17 | 结构整理：删除重复主题副本（约 36MB）与未启用的 `cyanstyle` 主题；新增 `.gitignore` 并重建仓库索引（6513 → 419 个受控文件）；修复站内搜索（补装 `hexo-generator-search`）；修复 `source/.nojekyll`（原为空目录）；精简 `_config.yml` 无效配置；补齐各目录说明与清单。详见 [themes/README.md](themes/README.md) 的「已移除主题」一节。 |
