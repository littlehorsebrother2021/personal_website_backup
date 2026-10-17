# source —— 站点内容根目录

> Hexo 会把这里除「下划线/点号开头」以外的每个文件渲染成页面，或原样复制进 `public/`。

## 说明

### 子目录

| 目录 | 作用 | 产出页面 |
| :--- | :--- | :--- |
| `_posts/` | **文章正文**，按 `年份/分类/` 两级归档 | `/post/<时间戳>.html` |
| `_data/` | 页面引用的结构化数据（友链等） | 不产出页面 |
| `about/` | 「关于」独立页面 | `/about/` |
| `contact/` | 「留言板」独立页面（评论组件挂载点） | `/contact/` |
| `friends/` | 「友情链接」页面，数据来自 `_data/friends.json` | `/friends/` |
| `tags/` | 标签聚合页 | `/tags/` |
| `categories/` | 分类聚合页 | `/categories/` |
| `404/` | 自定义 404 页面（GitHub Pages 直接读取 `404.html`） | `/404.html` |

### 根级文件

| 文件 | 作用 |
| :--- | :--- |
| `CNAME` | 自定义域名 `blog.556106.xyz`，部署时原样带到站点根 |
| `robots.txt` | 搜索引擎抓取规则 |
| `BingSiteAuth.xml` | Bing 站长验证文件 |
| `baidu_verify_codeva-*.html` | 百度站长验证文件 |
| `google*.html` | Google 站长验证文件 |
| `.nojekyll` | 空文件，告诉 GitHub Pages 不要用 Jekyll 处理站点（否则 `_` 开头的资源会 404） |

> `_config.yml` 的 `skip_render` 里列了 `google*.html`、`bing*.html`，这些验证文件会原样拷贝而不是被渲染；
> `.nojekyll` 则通过 `include:` 白名单被强制包含（否则会被隐藏文件规则忽略）。

### 约定

- **本站的说明文件统一用下划线前缀**（`_README.md`），因为 `source/` 下任何 `README.md` 都会被当成页面渲染。
- 图片资源请放进文章的同名目录（`post_asset_folder: true`），不要堆在 `source/` 根。
- 独立页面都是 `目录/index.md` 的形式，`layout: page`，改动内容即可，不要改目录名。

## 清单

<!-- MANIFEST:BEGIN -->

> **路径**：`source` ｜ **直属文件** 7 ｜ **直属子目录** 8 ｜ **本目录合计** 197 个文件
>
> [站点总览](../README.md) ｜ [全站清单](../MANIFEST.md) ｜ [上级目录](../README.md)

| 名称 | 类型 | 大小 / 内容 | 说明 | 最后修改 |
| :--- | :--- | :--- | :--- | :--- |
| [_data/](<_data/_README.md>) | 目录 | 2 个文件 | — | 2026-10-17 20:30 |
| [_posts/](<_posts/_README.md>) | 目录 | 176 个文件 | — | 2026-10-17 20:30 |
| [404/](<404/_README.md>) | 目录 | 2 个文件 | — | 2026-10-17 20:30 |
| [about/](<about/_README.md>) | 目录 | 2 个文件 | — | 2026-10-17 20:30 |
| [categories/](<categories/_README.md>) | 目录 | 2 个文件 | — | 2026-10-17 20:30 |
| [contact/](<contact/_README.md>) | 目录 | 2 个文件 | — | 2026-10-17 20:30 |
| [friends/](<friends/_README.md>) | 目录 | 2 个文件 | — | 2026-10-17 20:30 |
| [tags/](<tags/_README.md>) | 目录 | 2 个文件 | — | 2026-10-17 20:30 |
| [_README.md](<_README.md>) | Markdown | 3.5 KB | source —— 站点内容根目录 | 2026-10-17 20:56 |
| [.nojekyll](<.nojekyll>) | 无扩展名 | 0 B | — | 2026-10-17 19:50 |
| [baidu_verify_codeva-LmYTVPmMHf.html](<baidu_verify_codeva-LmYTVPmMHf.html>) | HTML | 57 B | — | 2026-03-18 21:16 |
| [BingSiteAuth.xml](<BingSiteAuth.xml>) | XML | 85 B | — | 2026-06-09 11:53 |
| [CNAME](<CNAME>) | 无扩展名 | 17 B | — | 2026-03-18 19:40 |
| [googlec1bc612a8b26d5e6.html](<googlec1bc612a8b26d5e6.html>) | HTML | 53 B | — | 2026-06-09 12:02 |
| [robots.txt](<robots.txt>) | 文本 | 231 B | — | 2026-06-09 14:27 |

<!-- MANIFEST:END -->
