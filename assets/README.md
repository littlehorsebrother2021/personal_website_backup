# assets —— 封面 / 背景素材库

> 存放**原始图片素材**。这里不是 Hexo 的 `source/` 目录，内容**不会发布到网站**，只作为生成封面时的输入。

## 说明

| 子目录 | 内容 | 用途 |
| :--- | :--- | :--- |
| `nature/` | 9 张自然风光摄影（1920px 宽） | 站点背景轮播 + 文章默认封面 |

### 工作流

```
assets/nature/*.jpg
      │
      │  tools/update-covers.ps1  （居中裁剪 + 缩放 + 重命名编号 + 同步主题配置）
      ▼
themes/hexo-theme-matery/source/medias/banner/0-6.jpg      （站点背景，按星期轮换）
themes/hexo-theme-matery/source/medias/featureimages/*.jpg （文章默认封面）
```

具体命令见 [tools/README.md](../tools/README.md)。

### 注意事项

- **文件名只影响排序**：脚本会按文件名排序后统一重编号成 `0.jpg`、`1.jpg`…，原名不会保留。
- 背景图建议只放 **7 张**（周一到周日各一张），多出的不参与轮播。
- 大图直接放这里没关系，脚本会压缩到标准尺寸；但不要把处理后的图再丢回来，会造成重复。
- 新增图片后记得同时更新本目录的清单：在项目根执行 `npm run manifest`。

## 清单

<!-- MANIFEST:BEGIN -->

> **路径**：`assets` ｜ **直属文件** 1 ｜ **直属子目录** 1 ｜ **本目录合计** 10 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [nature/](<nature>) | 目录 | 9 个文件 | — | 2026-10-17 20:40 |
| [README.md](<README.md>) | Markdown | 1.3 KB | assets —— 封面 / 背景素材库 | 2026-10-17 20:41 |

<!-- MANIFEST:END -->
