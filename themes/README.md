# themes —— 主题目录

> 当前启用：**hexo-theme-matery**（`_config.yml` 中 `theme: hexo-theme-matery`）。

## 说明

### 目录构成

| 路径 | 作用 |
| :--- | :--- |
| `hexo-theme-matery/_config.yml` | 主题外观与功能开关（菜单、社交链接、评论、音乐、公告等） |
| `hexo-theme-matery/layout/` | EJS 模板：`layout.ejs` 为主骨架，`_partial/` 放头部/导航/搜索/页脚等片段 |
| `hexo-theme-matery/source/` | 主题自带的 CSS / JS / 字体 / 图片（构建时会合并进 `public/`） |
| `hexo-theme-matery/scripts/` | 主题的 Hexo 脚本钩子（标签插件等） |
| `hexo-theme-matery/languages/` | 多语言文案，`zh-CN.yml` 为中文 |
| `hexo-theme-matery/README.md`、`README_CN.md`、`CHANGELOG.md` | 主题上游文档 |

### 重要约定

1. **本主题已本地定制**，且其内嵌的 `.git` 已于 2026-10-17 移除 —— 主题源码现在作为普通文件由博客仓库直接托管。
   这样做的原因：内嵌 `.git` 会让外层仓库把主题当成子模块（gitlink），推送到 GitHub 后主题内容会整体丢失。
2. 修改主题的两种做法：
   - 直接改 `themes/hexo-theme-matery/` 下的文件（改动进主仓库，推荐）；
   - 或在项目根新建 `_config.hexo-theme-matery.yml` 覆盖主题配置，保持主题文件干净（Hexo 支持主题配置的站点级覆盖）。
3. 换主题：把新主题目录放进 `themes/`，再改 `_config.yml` 的 `theme:` 字段，重新 `npm run build`。

### 已移除的主题

| 主题 | 移除日期 | 原因 | 恢复方式 |
| :--- | :--- | :--- | :--- |
| `themes/cyanstyle/` | **2026-10-17** | 备份用的备用主题，`_config.yml` 从未启用，长期无改动；为精简目录体积而删除 | 从上游仓库重新克隆到 `themes/cyanstyle/`，再把 `_config.yml` 的 `theme:` 改为 `cyanstyle` |
| `themes/cyanstyle - 副本/` | 2026-10-17 | 与 `cyanstyle` 逐文件完全一致的重复副本 | 同上（或直接从 `cyanstyle` 复制一份） |
| `themes/hexo-theme-matery - 副本/` | 2026-10-17 | 与正本逐文件比对仅差 2 个文件，属无意义备份（约 35MB） | 从上游重新克隆，或直接复制当前正本 |

> 若日后需要恢复 `cyanstyle`，请同时确认 `_config.yml` 里的 `theme:` 与 `themes/` 目录名完全一致（含大小写）。

## 清单

<!-- MANIFEST:BEGIN -->

> **路径**：`themes` ｜ **直属文件** 2 ｜ **直属子目录** 1 ｜ **本目录合计** 236 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [hexo-theme-matery/](<hexo-theme-matery/README.md>) | 目录 | 234 个文件 | — | 2026-10-17 20:40 |
| [.gitkeep](<.gitkeep>) | 无扩展名 | 0 B | — | 2023-10-20 21:29 |
| [README.md](<README.md>) | Markdown | 3.0 KB | themes —— 主题目录 | 2026-10-17 20:50 |

<!-- MANIFEST:END -->
