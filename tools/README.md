# tools —— 维护脚本

> 所有「跑一次就行」的维护脚本都放这里：清单生成、壁纸抓取、封面裁剪、logo 替换。

## 说明

### ⚠️ 为什么不放在 `scripts/`

Hexo 会把项目根的 `scripts/` 目录当作**插件目录**，启动时逐个 `require` 里面的文件。
把 `README.md`、`*.mjs` 放进去会直接抛 `SyntaxError`（虽然站点还能跑，但每次 `hexo s` / `hexo g`
都刷一堆 ERROR）。所以维护脚本统一放 `tools/`。

### 脚本一览

| 脚本 | 语言 | 作用 |
| :--- | :--- | :--- |
| `gen-manifest.mjs` | Node.js | 重新生成各目录 README 的「清单」段与根目录 `MANIFEST.md` |
| `optimize-images.ps1` | PowerShell | **压缩文章配图**：超过 1920px / 300KB 的图等比缩小并重新编码，默认只处理 jpg |
| `fetch-covers.ps1` | PowerShell | **从网络抓取高清壁纸**：下载 → 校验 → 调用 update-covers 裁剪 → 清理多余编号，一条龙 |
| `update-covers.ps1` | PowerShell | 把原始图片居中裁剪、缩放到标准尺寸，重编号后写入主题的 `medias/banner/` 与 `medias/featureimages/`，并同步主题 `_config.yml` 的 `featureImages` 列表 |
| `replace-logo.ps1` | PowerShell | 把 `assets/logo.png` 原样复制为主题站点的 favicon 与 logo（不缩放、不裁剪） |

### 图片压缩：optimize-images.ps1

```powershell
# 先看会改什么、能省多少（不动文件）
npm run optimize -- -DryRun

# 真正执行
npm run optimize

# 更激进
tools\optimize-images.ps1 -MaxWidth 1600 -Quality 80
```

规则：宽度超过 `-MaxWidth`（默认 1920）才缩放；体积超过 `-MinBytes`（默认 300KB）才重编码；
重编码后没省下 5% 以上就保持原样；PNG 默认跳过（截图本来就小），加 `-IncludePng` 才处理。

**原图不另存** —— git 历史就是备份，压坏了随时还原：

```bash
git checkout <压缩前的提交> -- 图片路径
```

### 文档清单生成器：gen-manifest.mjs

```bash
npm run manifest          # 等价于 node tools/gen-manifest.mjs
```

零第三方依赖，只用 Node 内置 `fs` / `path`。它做两件事：

1. 遍历所有说明文件（`README.md` 或 `_README.md`），把标记 `MANIFEST:BEGIN` 与 `MANIFEST:END`
   之间的内容重写成该目录的实时清单（文件/子目录、类型、大小、标题、最后修改时间，
   并附带指向总览与上级目录的链接）。
2. 重新生成 `docs/MANIFEST.md`：全站统计、文件类型分布、目录索引、文章索引。

**规则**

- 标记**之外**的文字完全不动，手写的「说明」不会被覆盖。
- 标记**之间**的内容全由脚本覆盖，手改无效。
- `.md` 文件的「说明」列自动取 front-matter 的 `title`，没有则取正文第一个 `#` 标题。
- 自动跳过 `node_modules/`、`public/`、`.deploy_git/`、`.git/`、`_audit/`、`db.json`。

**新增一个目录说明的步骤**

1. 在该目录新建 `README.md`（`source/` 内必须用 `_README.md`）。
2. 写标题与「说明」内容，末尾加：

   ```
   ## 清单
   <!-- MANIFEST:BEGIN -->
   <!-- MANIFEST:END -->
   ```

3. 执行 `npm run manifest`，清单自动填充。

### 一键换封面（推荐先看这个）

```powershell
npm run covers
```

依次问三个问题（来源 / 用途 / 张数），然后自动完成下载 → 裁剪 → 替换 → 构建。
想先看效果不落盘，选「试跑」即可。

想跳过菜单直接带参数，要用 `--` 把参数转交给脚本（注意脚本名是 **covers**，不是 cover）：

```powershell
npm run covers -- -Source bing -Count 7 -Target banner -DryRun
npm run covers -- -Source picsum -Count 12 -Keep -Build
```

等价的原生命令行：

```powershell
# 必应 4K，换 9 张文章封面并构建
powershell -ExecutionPolicy Bypass -File tools\fetch-covers.ps1 -Source bing -Count 9 -Target feature -Build

# Picsum（Unsplash 图库），换 12 张并保留旧图
powershell -ExecutionPolicy Bypass -File tools\fetch-covers.ps1 -Source picsum -Count 12 -Keep -Build

# 站点背景（固定 7 张，对应周日→周六）
powershell -ExecutionPolicy Bypass -File tools\fetch-covers.ps1 -Source bing -Target banner -Build

# 只下载校验，不改站点
powershell -ExecutionPolicy Bypass -File tools\fetch-covers.ps1 -Source picsum -Count 3 -DryRun
```

**图源（2026-10-17 实测）**

| 值 | 图源 | 实测 | 分辨率 | 授权 |
| :--- | :--- | :--- | :--- | :--- |
| `bing` | 必应每日壁纸 | ✅ 0.6s | 3840×2160 | 摄影师版权，个人欣赏可用 |
| `picsum` | Lorem Picsum（Unsplash） | ✅ 3.3s | 任意，约 1000 张 | Unsplash 授权，可商用 |
| `loliapi` | Loliapi 二次元/风景 | ✅ 3.3s | 不定 | 来源不明，仅建议试玩 |

> 必应一次只给最近 8 天，`-Count` 超过 8 会自动跳过；
> Picsum 会记录用过的 id（`assets/incoming/used-picsum.json`）避免重复。

**几点注意**

- 原始大图只落在 `assets/incoming/`（已 gitignore，4K 每张 3~4 MB），入库的只有裁剪后的小图。
- **替换成功后自动删除这批原始大图**，只留 `sources.json`；想保留原图加 `-KeepOriginals`。
- 替换是整体替换：新图更少时多余的旧编号会被删掉；`-Keep` 可保留旧图并追加新图。
- **站点背景是例外**：主题按星期只读 `0-6.jpg` 共 7 张，所以 `banner` / `both` 会**忽略 `-Keep`**
  （否则新图被排到 7 号之后永不显示），且完成后强制只留 7 张。
- 每批会在暂存目录写 `sources.json`，记录 URL / 作者 / 日期，方便核对授权。

### 手动指定图片（原有用法）

```powershell
# 只换站点背景（7 张，对应周日到周六）
powershell -ExecutionPolicy Bypass -File tools\update-covers.ps1 -BannerFolder .\assets\nature -Build

# 只换文章默认封面
powershell -ExecutionPolicy Bypass -File tools\update-covers.ps1 -FeatureFolder .\assets\nature -Build

# 背景 + 封面一起换
powershell -ExecutionPolicy Bypass -File tools\update-covers.ps1 `
    -FeatureFolder .\assets\nature -BannerFolder .\assets\nature -Build

# 换站点图标 / logo（读取 assets/logo.png）
powershell -ExecutionPolicy Bypass -File tools\replace-logo.ps1 -Build
```

### 参数要点

| 参数 | 说明 | 默认值 |
| :--- | :--- | :--- |
| `-BannerFolder` | 背景图来源目录 | 无 |
| `-FeatureFolder` | 封面图来源目录 | 无 |
| `-BannerWidth` / `-BannerHeight` | 背景输出尺寸 | 1280 × 720 |
| `-FeatureWidth` / `-FeatureHeight` | 封面输出尺寸 | 640 × 426 |
| `-NoResize` | 不缩放，原样复制 | 关闭 |
| `-Build` | 处理完自动执行 `hexo clean && hexo generate` | 关闭 |

### 注意

- 运行 `-Build` 会**先删除 `public/` 再重建**，耗时约 4 秒，属正常现象。
- 脚本会**改写** `themes/hexo-theme-matery/_config.yml` 里的 `featureImages` 列表，
  如果手工在里面加过条目，会被覆盖。
- 这两个脚本属于一次性维护工具，不参与网站构建；`tools/` 不在 `source/` 下，不会被打包发布。

## 清单

<!-- MANIFEST:BEGIN -->

> **路径**：`tools` ｜ **直属文件** 6 ｜ **直属子目录** 0 ｜ **本目录合计** 6 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../docs/MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [fetch-covers.ps1](<fetch-covers.ps1>) | PS1 | 17.0 KB | — | 2026-10-17 21:26 |
| [gen-manifest.mjs](<gen-manifest.mjs>) | JavaScript | 14.3 KB | — | 2026-10-18 18:39 |
| [optimize-images.ps1](<optimize-images.ps1>) | PS1 | 6.1 KB | — | 2026-10-18 18:26 |
| [README.md](<README.md>) | Markdown | 7.8 KB | tools —— 维护脚本 | 2026-10-18 18:39 |
| [replace-logo.ps1](<replace-logo.ps1>) | PS1 | 2.0 KB | — | 2026-10-18 18:38 |
| [update-covers.ps1](<update-covers.ps1>) | PS1 | 6.5 KB | — | 2026-10-17 20:40 |

<!-- MANIFEST:END -->
