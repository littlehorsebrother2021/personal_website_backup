# tools —— 封面 / 图标生成脚本

> 两个 PowerShell 脚本，负责把 `assets/` 里的原始图片处理成主题需要的尺寸和编号。

## 说明

| 脚本 | 作用 |
| :--- | :--- |
| `fetch-covers.ps1` | **从网络抓取高清壁纸**：下载 → 校验 → 调用 update-covers 裁剪 → 清理多余编号，一条龙 |
| `update-covers.ps1` | 把原始图片居中裁剪、缩放到标准尺寸，重编号后写入主题的 `medias/banner/` 与 `medias/featureimages/`，并同步主题 `_config.yml` 的 `featureImages` 列表 |
| `replace-logo.ps1` | 把项目根的 `logo.png` 原样复制为主题站点的 favicon 与 logo（不缩放、不裁剪） |

### 一键换封面（推荐先看这个）

```powershell
npm run covers
```

依次问三个问题（来源 / 用途 / 张数），然后自动完成下载 → 裁剪 → 替换 → 构建。
想先看效果不落盘，选「试跑」即可。等价命令行：

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

**三点注意**

- 原始大图只落在 `assets/incoming/`（已 gitignore，4K 每张 3~4 MB），入库的只有裁剪后的小图。
- 替换是整体替换：新图更少时多余的旧编号会被删掉；加 `-Keep` 则保留旧图并追加。
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

# 换站点图标 / logo（读取项目根的 logo.png）
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

> **路径**：`tools` ｜ **直属文件** 4 ｜ **直属子目录** 0 ｜ **本目录合计** 4 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [fetch-covers.ps1](<fetch-covers.ps1>) | PS1 | 15.8 KB | — | 2026-10-17 21:02 |
| [README.md](<README.md>) | Markdown | 4.5 KB | tools —— 封面 / 图标生成脚本 | 2026-10-17 21:04 |
| [replace-logo.ps1](<replace-logo.ps1>) | PS1 | 2.0 KB | — | 2026-10-17 20:40 |
| [update-covers.ps1](<update-covers.ps1>) | PS1 | 6.5 KB | — | 2026-10-17 20:40 |

<!-- MANIFEST:END -->
