# .github —— GitHub 自动化配置

> 目前只有 Dependabot：定期检查 `package.json` 的依赖更新并自动提 PR。

## 说明

| 文件 | 作用 |
| :--- | :--- |
| `dependabot.yml` | 配置依赖自动升级策略（频率、PR 上限、忽略规则等） |

### 当前策略

| 项 | 值 | 理由 |
| :--- | :--- | :--- |
| 检查频率 | 每周一次 | 每天检查会攒一堆长期不处理的 PR |
| 同时开启上限 | 5 个 | 够用，不会淹没 Issues |
| 忽略规则 | `hexo` 与 `hexo-renderer-*` 的 **major** 升级 | 见下 |

**为什么屏蔽 hexo 的大版本**：2026-10-18 实测过 hexo 6.3 → 8.1.2，虽然能构建，
但 Hexo 8 把语法高亮改成了插件注册制、默认 `highlight.js`，而本主题仍按
`config.prismjs.enable` 加载 Prism 资源、CSS 也没有 highlight.js 规则，
升级后代码块样式会错乱；且 Hexo 8 要求 Node ≥ 20.19。
这类升级必须人工评估，不能让机器人自动提。

> 小版本 / 补丁仍会自动提 PR，例如 `hexo-generator-index` 3 → 4 这种，评估成本低。

### 注意

- 本仓库的**源码分支**与**部署分支**是两回事：部署由 `hexo deploy` 推送到
  `littlehorsebrother2021.github.io` 仓库的 `main` 分支，Dependabot 只作用于本仓库的源码。
- 合并任何依赖 PR 前，本地跑一遍 `npm run clean && npm run build`，确认 `0 ERROR / 0 WARN`。

## 清单

<!-- MANIFEST:BEGIN -->

> **路径**：`.github` ｜ **直属文件** 2 ｜ **直属子目录** 0 ｜ **本目录合计** 2 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../docs/MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [dependabot.yml](<dependabot.yml>) | YAML | 625 B | 配置 / 数据 | 2026-10-18 18:31 |
| [README.md](<README.md>) | Markdown | 2.0 KB | .github —— GitHub 自动化配置 | 2026-10-18 19:18 |

<!-- MANIFEST:END -->
