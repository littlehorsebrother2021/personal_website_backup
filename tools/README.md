# tools —— 封面 / 图标生成脚本

> 两个 PowerShell 脚本，负责把 `assets/` 里的原始图片处理成主题需要的尺寸和编号。

## 说明

| 脚本 | 作用 |
| :--- | :--- |
| `update-covers.ps1` | 把原始图片居中裁剪、缩放到标准尺寸，重编号后写入主题的 `medias/banner/` 与 `medias/featureimages/`，并同步主题 `_config.yml` 的 `featureImages` 列表 |
| `replace-logo.ps1` | 把项目根的 `logo.png` 原样复制为主题站点的 favicon 与 logo（不缩放、不裁剪） |

### 常见用法

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

> **路径**：`tools` ｜ **直属文件** 3 ｜ **直属子目录** 0 ｜ **本目录合计** 3 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [README.md](<README.md>) | Markdown | 2.0 KB | tools —— 封面 / 图标生成脚本 | 2026-10-17 20:41 |
| [replace-logo.ps1](<replace-logo.ps1>) | PS1 | 2.0 KB | — | 2026-10-17 20:40 |
| [update-covers.ps1](<update-covers.ps1>) | PS1 | 6.5 KB | — | 2026-10-17 20:40 |

<!-- MANIFEST:END -->
