# 站点架构与组件说明

> 一页看懂这个博客由哪些部分组成、每样东西在哪、坏了该改哪个文件。
> 实时文件清单见 [MANIFEST.md](MANIFEST.md)，命令速查见 [README.md](README.md)，Git 操作见 [GIT-GUIDE.md](GIT-GUIDE.md)。

---

## 一、一句话概括

**Hexo 6.3.0** 把 `source/` 下的 Markdown 与 **hexo-theme-matery** 主题模板一起渲染成静态 HTML，
输出到 `public/`，再用 `hexo deploy` 推到 GitHub Pages 仓库的 `main` 分支对外提供访问。

```
source/*.md  ──┐
               ├─►  hexo generate  ──►  public/  ──►  hexo deploy  ──►  <用户>.github.io (main)
themes/…/*.ejs ┘        (本地可预览)        静态站点           git push        GitHub Pages
```

---

## 二、顶层目录职责

| 路径 | 类型 | 作用 | 会不会发布 |
| :--- | :--- | :--- | :--- |
| `_config.yml` | 配置 | **站点级**配置：标题、URL 规则、插件、部署目标 | 读取，不发布 |
| `package.json` / `package-lock.json` | 配置 | 依赖与命令定义 | 不发布 |
| `source/` | 内容 | 所有文章、页面、站点级静态文件 | ✅ 渲染后发布 |
| `themes/hexo-theme-matery/` | 主题 | 模板、样式、脚本、图片 | ✅ 资源随站点发布 |
| `scaffolds/` | 模板 | `hexo new` 生成文件时套用的 front-matter 骨架 | 不发布 |
| `tools/` | 工具 | 维护脚本（清单、壁纸、压缩、logo） | 不发布 |
| `assets/` | 素材 | 封面/背景的**原始图**，仅供生成用 | 不发布 |
| `docs/` | 文档 | 专题操作手册 | 不发布 |
| `scripts/` | ⚠️ 禁止 | Hexo 会把它当插件目录逐个 `require` | — |
| `public/` | 产物 | `hexo generate` 的输出 | ✅ 实际部署内容 |
| `node_modules/` | 依赖 | `npm install` 还原 | 不发布 |
| `.deploy_git/` | 产物 | 部署用工作目录，`hexo deploy` 重建 | — |

> `public/`、`node_modules/`、`.deploy_git/`、`db.json`、`assets/incoming/` 都在 `.gitignore` 里。

---

## 三、配置层（三层，优先级从低到高）

| 文件 | 管什么 | 什么时候改 |
| :--- | :--- | :--- |
| `_config.yml` | 站点：标题、作者、URL、永久链接、分页、Markdown 渲染、插件参数、部署目标 | 改站点名、换域名、调分页、改部署仓库 |
| `themes/hexo-theme-matery/_config.yml` | 主题：菜单、社交链接、评论、音乐、公告、封面列表、代码块样式 | 改外观、加菜单、接评论系统 |
| `package.json` | 依赖版本 + `npm run` 命令 | 加插件、加脚本 |

关键站点配置（`_config.yml`）：

| 键 | 当前值 | 含义 |
| :--- | :--- | :--- |
| `url` | `https://blog.556106.xyz/` | 站点根地址 |
| `permalink` | `:layout/:year:month:day:hour:minute:second.html` | 文章 URL 形如 `post/20260319163436.html` |
| `permalink_pinyin` | `enable: true` | 中文标题自动转拼音，URL 不出现中文 |
| `post_asset_folder` | `true` | 每篇文章自动配一个同名图片目录 |
| `deploy` | `type: git` → Pages 仓库 `main` | `hexo deploy` 的推送目标 |

---

## 四、内容层（`source/`）

### 4.1 目录结构

```
source/
├── _posts/              ← 文章，按「年份/分类/」两级归档（37 篇）
│   ├── 2023/  2 篇（无分类）
│   ├── 2024/  22 篇 → 周总结 / 学习类 / 生活 / 阶段总结
│   ├── 2025/   7 篇 → 学习类 / 阶段总结
│   └── 2026/   6 篇 → STM32N6 / 生活
├── _data/friends.json   ← 友链数据，供 friends 页读取
├── about/ contact/ friends/ tags/ categories/ 404/   ← 6 个独立页面
├── CNAME                ← 自定义域名 blog.556106.xyz
├── robots.txt           ← 爬虫规则
├── .nojekyll            ← 空文件，禁止 GitHub Pages 用 Jekyll 处理
└── BingSiteAuth.xml / baidu_verify_*.html / google*.html   ← 搜索引擎验证
```

### 4.2 一篇文章由什么组成

```
source/_posts/2026/STM32N6/01_STM32N6开发板初探.md   ← 正文（front-matter + Markdown）
source/_posts/2026/STM32N6/01_STM32N6开发板初探/     ← 同名图片目录（post_asset_folder）
        └── RAM_M55.png 等 8 张
```

front-matter 字段：

| 字段 | 作用 |
| :--- | :--- |
| `title` | 标题，同时参与拼音 URL 生成 |
| `date` | 发布时间，决定归档与首页排序 |
| `tags: ["a","b"]` | 标签，生成 `/tags/标签名/` |
| `category: ["我的生活"]` | 分类，生成 `/categories/分类名/` |
| `typora-root-url` | 仅供 Typora 本地预览，构建时忽略 |

### 4.3 独立页面（`layout` 决定长相）

| 页面 | 文件 | layout | 产出 |
| :--- | :--- | :--- | :--- |
| 关于 | `about/index.md` | `page` | `/about/` |
| 留言 | `contact/index.md` | `page` | `/contact/` |
| 友链 | `friends/index.md` | `page` | `/friends/` |
| 标签 | `tags/index.md` | `tags` | `/tags/` + 各标签页 |
| 分类 | `categories/index.md` | `categories` | `/categories/` + 各分类页 |
| 404 | `404/index.md` | `404` | **`/404.html`**（靠 `permalink: 404.html`） |

---

## 五、主题层（`themes/hexo-theme-matery/`）

| 子目录 | 内容 | 说明 |
| :--- | :--- | :--- |
| `layout/` | 17 个页面模板 + `_partial/`（39 个碎片）+ `_widget/`（16 个部件） | `layout.ejs` 是总骨架，`index/post/archive/...` 各管一类页面 |
| `source/css/` | 28 个 CSS | `matery.css` 主样式，`my.css` 自定义覆盖，`post.css` 正文 |
| `source/js/` | 主题脚本 | 回到顶部、目录、背景切换等 |
| `source/libs/` | 第三方前端库（83 个文件 / 10.4 MB） | Prism（代码高亮）、echarts（文章日历）、jQuery、AOS 等 |
| `source/medias/` | banner 7 张、featureimages 8 张、logo | 背景与文章封面 |
| `scripts/` | 主题自带的 Hexo 标签插件 | 提供自定义 tag（如 `{% btn %}`） |
| `languages/` | 多语言文案 | `zh-CN.yml` 为中文 |

> 主题**已本地定制**且移除了内嵌 `.git`，改动直接进主仓库；不要再把它变成子模块。

---

## 六、构建层：装了哪些 Hexo 插件

| 插件 | 作用 | 产出 |
| :--- | :--- | :--- |
| `hexo` | 核心 | — |
| `hexo-renderer-marked` | Markdown → HTML | 正文 |
| `hexo-renderer-ejs` | EJS 模板渲染 | 主题页面 |
| `hexo-generator-index` | 首页 + 分页 | `/` `/page/2/` |
| `hexo-generator-archive` | 归档 | `/archives/` |
| `hexo-generator-category` | 分类页 | `/categories/xxx/` |
| `hexo-generator-tag` | 标签页 | `/tags/xxx/` |
| `hexo-generator-search` | 站内搜索索引 | `search.xml`（316 KB） |
| `hexo-generator-sitemap` | 站点地图 | `sitemap.xml` |
| `hexo-generator-baidu-sitemap` | 百度专用地图 | `baidusitemap.xml` |
| `hexo-permalink-pinyin` | 标题转拼音 | 影响 URL |
| `hexo-wordcount` | 字数 / 阅读时长 | 文章页角标 |
| `hexo-deployer-git` | 一键部署 | 推送到 Pages 仓库 |
| `hexo-server` | 本地预览 | `http://localhost:4000` |

---

## 七、部署层

```
hexo deploy
   ↓ 生成 .deploy_git/（一份干净的 public 副本 + git 仓库）
   ↓ git push -f 到 https://github.com/littlehorsebrother2021/littlehorsebrother2021.github.io.git
   ↓ 分支 main
GitHub Pages  →  https://blog.556106.xyz/（CNAME 指向自定义域名）
```

**源码备份与部署是两条独立的线**：源码 `git push` 到 `personal_website_backup` 仓库，
部署由 `hexo deploy` 推到 Pages 仓库。两者互不影响。

---

## 八、维护工具层（`tools/`）

| 脚本 | 命令 | 作用 |
| :--- | :--- | :--- |
| `gen-manifest.mjs` | `npm run manifest` | 重写所有 README 的「清单」段 + 根 `MANIFEST.md` |
| `optimize-images.ps1` | `npm run optimize` | 压缩超过 1920px / 300KB 的配图 |
| `fetch-covers.ps1` | `npm run covers` | 从必应 / Picsum 抓壁纸换封面 |
| `update-covers.ps1` | — | 裁剪、重编号并同步主题封面配置 |
| `replace-logo.ps1` | — | 用根目录 `logo.png` 覆盖站点图标 |

---

## 九、常见改动去哪儿

| 我想… | 改这里 |
| :--- | :--- |
| 写新文章 | `npm run new -- "标题" --path 2026/学习类/标题` |
| 改站点标题 / 域名 / 分页 | 根 `_config.yml` |
| 改导航菜单 / 社交链接 / 评论 | `themes/hexo-theme-matery/_config.yml` |
| 换文章封面 / 站点背景 | `npm run covers`（或 `tools/update-covers.ps1`） |
| 换站点图标 | 替换根 `logo.png` → `tools/replace-logo.ps1` |
| 改页面结构或样式 | `themes/hexo-theme-matery/layout/` 或 `source/css/my.css` |
| 加友链 | `source/_data/friends.json` |
| 改 404 页文案 | `source/404/index.md` |
| 换主题 | 新主题放进 `themes/`，改 `_config.yml` 的 `theme:` |
| 发布上线 | `npm run build && npm run deploy` |

---

## 十、文档地图

| 文件 | 回答什么问题 |
| :--- | :--- |
| `README.md` | 命令有哪些、项目怎么用、目录各自干嘛 |
| `ARCHITECTURE.md`（本文） | 站点由哪些组件构成、数据怎么流动 |
| `MANIFEST.md` | 全站有哪些文件、有哪些文章（自动生成） |
| `GIT-GUIDE.md` | git 怎么用、出错了怎么办、换电脑怎么同步 |
| `tools/README.md` | 每个维护脚本的参数与注意事项 |
| `docs/评论区与封面配置.md` | 评论系统怎么接、封面怎么换 |
| 各目录的 `README.md` / `_README.md` | 这个目录放什么、文件清单 |
