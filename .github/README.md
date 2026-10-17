# .github —— GitHub 自动化配置

> 目前只有 Dependabot：定期检查 `package.json` 的依赖更新并自动提 PR。

## 说明

| 文件 | 作用 |
| :--- | :--- |
| `dependabot.yml` | 配置依赖自动升级策略（检查频率、目标分支、PR 数量上限等） |

### 注意

- 本仓库的**源码分支**与**部署分支**是两回事：部署由 `hexo deploy` 推送到 `littlehorsebrother2021.github.io` 仓库的 `main` 分支，而 Dependabot 只作用于本仓库的源码。
- 升级 `hexo` 主版本后请务必本地 `npm run clean && npm run build` 验证，主题对 Hexo 大版本较敏感。

## 清单

<!-- MANIFEST:BEGIN -->

> **路径**：`.github` ｜ **直属文件** 2 ｜ **直属子目录** 0 ｜ **本目录合计** 2 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [dependabot.yml](<dependabot.yml>) | YAML | 125 B | 配置 / 数据 | 2023-10-20 21:29 |
| [README.md](<README.md>) | Markdown | 1.2 KB | .github —— GitHub 自动化配置 | 2026-10-17 20:56 |

<!-- MANIFEST:END -->
