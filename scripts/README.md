# scripts —— 文档维护脚本

> 只有一个脚本：`gen-manifest.mjs`，负责自动生成所有目录的「清单」和根目录的 `MANIFEST.md`。

## 说明

### gen-manifest.mjs

| 项目 | 内容 |
| :--- | :--- |
| 运行方式 | `npm run manifest`（等价于 `node scripts/gen-manifest.mjs`） |
| 依赖 | 无第三方依赖，只用 Node 内置 `fs` / `path` |
| 作用范围 | 全仓库，自动跳过 `node_modules/`、`public/`、`.deploy_git/`、`.git/`、`_audit/` |

**它做两件事：**

1. 遍历所有说明文件（`README.md` 或 `_README.md`），把其中
   `<!-- MANIFEST:BEGIN -->

> **路径**：`scripts` ｜ **直属文件** 2 ｜ **直属子目录** 0 ｜ **本目录合计** 2 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [gen-manifest.mjs](<gen-manifest.mjs>) | JavaScript | 13.1 KB | — | 2026-10-17 19:56 |
| [README.md](<README.md>) | Markdown | 2.0 KB | scripts —— 文档维护脚本 | 2026-10-17 19:55 |

<!-- MANIFEST:END -->` 之间的内容重写成该目录的实时清单
   （文件/子目录、类型、大小、标题、最后修改时间，并附带指向总览与上级目录的链接）。
2. 重新生成根目录 `MANIFEST.md`：全站统计、文件类型分布、目录索引、文章索引。

**规则：**

- 标记**之外**的文字完全不动，手写的「说明」不会被覆盖。
- 标记**之间**的内容全由脚本覆盖，手改无效。
- `.md` 文件的「说明」列会自动取 front-matter 的 `title`，没有则取正文第一个 `#` 标题，再没有就留空。

### 新增一个目录说明的步骤

1. 在该目录新建 `README.md`（`source/` 内用 `_README.md`）。
2. 写上标题与「说明」内容，末尾加：

   ```
   ## 清单
   <!-- MANIFEST:BEGIN -->
   <!-- MANIFEST:END -->
   ```

3. 执行 `npm run manifest`，清单会自动填充。

## 清单

<!-- MANIFEST:BEGIN -->
<!-- MANIFEST:END -->
