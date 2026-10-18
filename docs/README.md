# docs —— 全部文档

> 仓库里**除根 `README.md` 之外的所有文档**都放在这里：架构说明、Git 速查、全站清单、专题手册。
> 根目录因此只保留一个入口文件，看起来清爽。

## 说明

| 文档 | 内容 | 类型 |
| :--- | :--- | :--- |
| [ARCHITECTURE.md](ARCHITECTURE.md) | **架构说明**：组件构成、数据流、改动该动哪个文件 | 手写 |
| [GIT-GUIDE.md](GIT-GUIDE.md) | **Git 速查**：常用命令、撤销回退、报错处理、多电脑同步 | 手写 |
| [MANIFEST.md](MANIFEST.md) | **全站清单**：统计、目录索引、37 篇文章索引 | 🤖 自动生成 |
| [评论区与封面配置.md](评论区与封面配置.md) | 专题：评论系统怎么接、封面/背景怎么换 | 手写 |
| `README.md` | 本文件，文档目录的说明 | 手写 |

### 文档分工

| 文件 | 定位 | 什么时候看 |
| :--- | :--- | :--- |
| 根 `README.md` | 项目总览、命令速查、目录地图 | 刚开始用这个项目 |
| `docs/ARCHITECTURE.md` | 站点由什么组成 | 想知道某段功能在哪实现 |
| `docs/GIT-GUIDE.md` | git 怎么用 | 忘了命令、出错了、换电脑 |
| `docs/MANIFEST.md` | 全站文件与文章索引 | 找某个文件或某篇文章 |
| `docs/专题*.md` | 具体功能的操作手册 | 配评论、换封面 |
| 各目录的 `README.md` / `_README.md` | 该目录放什么 | 在某个目录里干活 |

### 新增一篇专题文档

1. 在 `docs/` 下新建 `某个主题.md`，第一行写 `# 标题`。
2. 在本文件的「说明」表格里加一行，说明它解决什么问题。
3. 执行 `npm run manifest` 刷新清单。

### 注意

- `docs/` 不在 `source/` 下，**不会被 Hexo 发布**，可以放心写内部笔记。
- `MANIFEST.md` 由 `tools/gen-manifest.mjs` 生成，**手改会被覆盖**。
- 这里的文档不会被自动编号，靠文件名和本表格检索。

## 清单

<!-- MANIFEST:BEGIN -->

> **路径**：`docs` ｜ **直属文件** 5 ｜ **直属子目录** 0 ｜ **本目录合计** 5 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../docs/MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [评论区与封面配置.md](<评论区与封面配置.md>) | Markdown | 3.6 KB | 评论区与封面/背景配置 | 2026-10-17 20:40 |
| [ARCHITECTURE.md](<ARCHITECTURE.md>) | Markdown | 9.3 KB | 站点架构与组件说明 | 2026-10-18 18:40 |
| [GIT-GUIDE.md](<GIT-GUIDE.md>) | Markdown | 13.5 KB | Git 使用说明（本站专用速查） | 2026-10-17 20:56 |
| [MANIFEST.md](<MANIFEST.md>) | Markdown | 10.8 KB | 全站文件清单 | 2026-10-18 18:39 |
| [README.md](<README.md>) | Markdown | 2.8 KB | docs —— 全部文档 | 2026-10-18 18:38 |

<!-- MANIFEST:END -->
