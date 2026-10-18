# scaffolds —— 新建文件模板

> `hexo new` 生成新文件时套用的 front-matter 模板。改这里就等于改所有新文章的默认字段。

## 说明

| 模板 | 对应命令 | 生成位置 |
| :--- | :--- | :--- |
| `post.md` | `hexo new post "标题"` / `npm run new -- "标题"` | `source/_posts/`（可加 `--path` 指定子目录） |
| `page.md` | `hexo new page "名称"` | `source/名称/index.md` |
| `draft.md` | `hexo new draft "标题"` | `source/_drafts/`（默认不参与构建，需 `hexo publish` 转正） |

### 字段约定

- `title`：标题，会参与「中文转拼音」生成永久链接。
- `date`：发布时间，决定归档年份与首页排序。
- `tags`：数组，对应 `/tags/标签名/` 页面。
- `category`：分类，对应 `/categories/分类名/` 页面；建议按现有习惯写 `学习记录` / `我的生活` 等。
- 若使用 Typora 插图，可在头部补 `typora-root-url: ./文章名`，让本地预览与站点路径一致。

### 注意

- `scaffolds/` 不会被 Hexo 渲染，放在这里的 `.md` 只是模板，不会变成文章。
- 模板里的 `layout:` 字段决定用哪个布局（`post` / `page` / `draft`），不要随手改。

## 清单

<!-- MANIFEST:BEGIN -->

> **路径**：`scaffolds` ｜ **直属文件** 4 ｜ **直属子目录** 0 ｜ **本目录合计** 4 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../docs/MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [draft.md](<draft.md>) | Markdown | 33 B | {{ title }} | 2023-10-20 21:29 |
| [page.md](<page.md>) | Markdown | 44 B | {{ title }} | 2023-10-20 21:29 |
| [post.md](<post.md>) | Markdown | 50 B | {{ title }} | 2023-10-20 21:29 |
| [README.md](<README.md>) | Markdown | 1.9 KB | scaffolds —— 新建文件模板 | 2026-10-18 18:39 |

<!-- MANIFEST:END -->
