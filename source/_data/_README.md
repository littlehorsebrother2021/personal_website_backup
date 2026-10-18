# source/_data —— 站点数据文件

> 存放页面用到的结构化数据，Hexo 不会把它们渲染成页面，而是以 `site.data.*` 的形式供模板读取。

## 说明

| 文件 | 被谁使用 | 结构 |
| :--- | :--- | :--- |
| `friends.json` | 友链页 `source/friends/index.md` | 数组，每项含 `name`（站点名）、`url`（链接）、`avatar`（头像地址）、`description`（简介） |

### 修改方式

- 直接在 `friends.json` 的数组里增删条目，保持 JSON 合法（注意最后一项后面不要多加逗号）。
- 头像建议用外链或放到 `source/medias/` 下再写相对路径，避免大图拖慢页面。
- 改完 `npm run server` 预览确认。

### 注意

- 目录名以下划线开头，因此不会生成页面；新增的数据文件命名同理（`xxx.json` 或 `xxx.yml`），用英文小写。
- 数据文件里的 `//` 注释不合法，JSON 不能写注释。

## 清单

<!-- MANIFEST:BEGIN -->

> **路径**：`source/_data` ｜ **直属文件** 2 ｜ **直属子目录** 0 ｜ **本目录合计** 2 个文件
>
> [站点总览](../../README.md) ｜ [全站清单](../../docs/MANIFEST.md) ｜ [上级目录](../_README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [_README.md](<_README.md>) | Markdown | 1.5 KB | source/_data —— 站点数据文件 | 2026-10-18 19:17 |
| [friends.json](<friends.json>) | JSON | 740 B | 配置 / 数据 | 2024-02-14 17:07 |

<!-- MANIFEST:END -->
