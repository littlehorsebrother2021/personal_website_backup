# 我的博客

基于 Hexo + hexo-theme-matery 的静态博客，生成结果在 `public/`，部署到 GitHub Pages。

## 更换站点背景 / 文章封面

新增的图片统一放在根目录 `assets/` 下（例如本次的自然风光图在 `assets/nature`），
然后运行 `tools/update-covers.ps1`。脚本会按文件名排序，把图片居中裁剪成站点
标准尺寸，并自动重命名为 `0.jpg`、`1.jpg`...，再同步主题配置。

### 站点背景（banner）

```powershell
powershell -ExecutionPolicy Bypass -File tools\update-covers.ps1 -BannerFolder .\assets\nature -Build
```

banner 每天切换一张，主题按星期读取 7 张（`0.jpg` = 周日，`6.jpg` = 周六）；
多于 7 张的部分不会参与轮播，建议只放 7 张。

### 文章默认封面（featureimages）

```powershell
powershell -ExecutionPolicy Bypass -File tools\update-covers.ps1 -FeatureFolder .\assets\nature -Build
```

文章没有单独指定封面时，会从 `featureImages` 列表取一张，数量不限。
脚本会同步更新 `themes/hexo-theme-matery/_config.yml` 的 `featureImages` 列表。

### 两个一起更新

```powershell
powershell -ExecutionPolicy Bypass -File tools\update-covers.ps1 `
    -FeatureFolder .\assets\feature -BannerFolder .\assets\nature -Build
```

### 参数说明

| 参数 | 说明 | 默认值 |
| --- | --- | --- |
| `-BannerFolder` | 站点背景图文件夹（建议 7 张 jpg/jpeg） | 无 |
| `-FeatureFolder` | 文章默认封面图文件夹（数量不限） | 无 |
| `-BannerWidth` / `-BannerHeight` | banner 输出尺寸 | 1280 / 720 |
| `-FeatureWidth` / `-FeatureHeight` | 封面输出尺寸 | 640 / 426 |
| `-NoResize` | 不缩放，原图直接拷贝 | 关闭 |
| `-Build` | 自动执行 `hexo clean && hexo generate` | 关闭 |

### 部署到云端

本地生成确认无误后：

```powershell
hexo d
```

`hexo d` 会把 `public/` 推送到 `_config.yml` 里配置的 GitHub Pages 仓库。

## 其他

- 图片只支持 `.jpg/.jpeg`，顺序按文件名排序。
- 评论区与单篇文章自定义封面等更多配置见 [docs/评论区与封面配置.md](docs/评论区与封面配置.md)。
