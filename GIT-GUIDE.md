# Git 使用说明（本站专用速查）

> 给「记不住 git」的自己用。**只需要记住第 1 节的 6 条命令**，其余当字典查。
> 本仓库：Hexo 博客源码 ｜ 本地分支：`main` ｜ 远程：`origin` = `personal_website_backup`
> ⚠️ **源码在远程分支 `cleanup-2026-10-17` 上；远程默认分支 `main` 仍是另一条历史。**
> 2026-10-17 已把 `main` 的内容**合并进** `cleanup-2026-10-17`（提交 `d0def91`），但 `main` 分支本身未改动。

---

## 1. 一分钟版本（90% 的场景只用这 6 条）

```bash
git status                 # 我现在改了什么？（先看这个，永远没错）
git add -A                 # 把所有改动加入暂存区
git commit -m "说明"        # 存成一个快照
git push                   # 推到 GitHub
git pull                   # 从 GitHub 拉最新
git log --oneline -8       # 看最近 8 次提交
```

**口诀**：改完 → `status` 看一眼 → `add -A` → `commit -m` → `push`。

---

## 2. 一台新电脑，只做一次

```bash
# 1) 身份（必须，否则 commit 会报错）
git config --global user.name  "littlehorsebrother"
git config --global user.email "2403618853@qq.com"

# 2) 中文文件名不乱码（Windows 必配）
git config --global core.quotepath false

# 3) 换行符（Windows 建议 true，避免每次都提示 LF/CRLF）
git config --global core.autocrlf true

# 4) 默认分支名（可选，与 GitHub 保持一致）
git config --global init.defaultBranch main

# 5) 查看当前所有配置
git config --global --list
```

---

## 3. 本项目的三个固定流程

### 3.1 写完文章要备份

```bash
npm run manifest           # 顺手刷新文档清单
git status                 # 确认只改了该改的文件
git add -A
git commit -m "post: 新增《STM32N6 开发实战5》"
git push
```

### 3.2 发布到网站（和源码备份是两件事）

```bash
npm run clean              # 可选，改过配置/主题后建议跑
npm run build              # 构建到 public/，确认 0 error
npm run deploy             # 等价于 hexo deploy，把 public/ 推到 Pages 仓库
```

> `deploy` 只推送**静态文件**到 `<用户名>.github.io` 仓库的 `main` 分支；
> 源码备份走的是 `git push`，两条线互不影响。

### 3.3 换电脑前后

```bash
# 换到另一台电脑之前（当前这台）
git status                 # 必须干净：没有未提交的改动
git push

# 在新电脑上
git pull                   # 先拉最新，再动手
npm install                # 只有第一次或 package.json 变过才需要
npm run server             # 本地预览
```

**黄金规则**：**动手写之前先 `git pull`，收工之后 `git push`**。
两台电脑同时改同一篇文章，一定会冲突，别这么干。

---

## 4. 查看与对比

```bash
git status                       # 工作区 + 暂存区状态
git status -s                    # 精简输出
git diff                         # 未暂存的改动（逐行）
git diff --staged                # 已暂存的改动
git diff HEAD~1                  # 和上一次提交比
git log --oneline --graph -15    # 图形化看历史
git log --stat -3                # 最近 3 次提交改了哪些文件
git show <提交号>                 # 看某次提交的完整内容
git log --follow -p -- 文件路径    # 看某个文件的完整变更史
```

---

## 5. 撤销与回退（先看清危险等级再敲）

| 我想… | 命令 | 危险度 |
| :--- | :--- | :--- |
| 丢弃**未暂存**的某个文件改动 | `git restore 文件路径` | 🟡 改动没了 |
| 把文件从暂存区拿回来（不改内容） | `git restore --staged 文件路径` | 🟢 安全 |
| 改掉**最后一次**提交的说明 | `git commit --amend -m "新说明"` | 🟡 别对已推送的用 |
| 撤销某次**已推送**的提交（推荐） | `git revert <提交号>` | 🟢 安全，会新增一次反向提交 |
| 回退到某次提交，**保留**改动 | `git reset --soft <提交号>` | 🟡 需重新 commit |
| 回退到某次提交，**丢弃**改动 | `git reset --hard <提交号>` | 🔴 改动彻底消失 |
| 临时把手上的改动藏起来 | `git stash` / `git stash pop` | 🟢 安全 |
| 看所有 stash | `git stash list` | 🟢 安全 |

> 🔴 危险命令执行前，先 `git status` + `git log --oneline` 确认自己在哪，
> 必要时先 `git branch backup-tmp` 打一个保险分支。

---

## 6. 分支

```bash
git branch                    # 列出本地分支（* 是当前分支）
git branch -a                 # 含远程分支
git switch -c 新分支名         # 新建并切过去
git switch 分支名              # 切换
git merge 分支名               # 把某分支合并进当前分支
git branch -d 分支名           # 删除已合并的分支
git branch -D 分支名           # 强制删除（未合并也能删）
```

> 本博客**不需要**复杂的多分支操作：源码一条线，静态文件由 `hexo deploy` 自己管理。

---

## 7. 远程仓库

```bash
git remote -v                                   # 看现有远程（本项目目前为空）
git remote add origin <仓库地址>                 # 添加名为 origin 的远程
git remote set-url origin <新地址>               # 改地址
git remote remove origin                        # 删远程
git push -u origin main                         # 首次推送并建立跟踪
git push                                        # 之后直接 push
git fetch --all                                 # 只下载不合并
git pull --rebase                               # 拉取并把自己的提交放到最后（推荐）
```

---

## 8. `.gitignore`（哪些东西不该进仓库）

本仓库已在根目录配置 `.gitignore`，当前忽略：

```
node_modules/     依赖，用 npm install 还原
public/           构建产物，用 hexo generate 还原
.deploy_git/      部署工作目录，用 hexo deploy 重建
db.json           Hexo 缓存，hexo clean 可删
_audit/           维护脚本临时快照
*.log .DS_Store Thumbs.db .idea/
```

**新增忽略项**：直接编辑 `.gitignore`，一行一个。已经被误提交的文件要这样移除：

```bash
git rm -r --cached 路径        # 只从 git 索引里删，磁盘文件保留
git commit -m "chore: 从版本库移除 xxx"
```

**查某个文件为什么被忽略**：

```bash
git check-ignore -v 文件路径
```

---

## 9. 常见报错与处理

| 报错 | 原因 | 处理 |
| :--- | :--- | :--- |
| `fatal: not a git repository` | 不在仓库目录里 | `cd` 到含 `.git` 的目录 |
| `Updates were rejected…` | 远程有你本地没有的提交 | `git pull --rebase` 后再 `push` |
| `fatal: refusing to merge unrelated histories` | 两边历史不相关（常见于新建远程仓库时勾了 README） | `git pull --rebase --allow-unrelated-histories` |
| `Permission denied (publickey)` / 弹窗要求登录 | 没配 SSH / 凭证失效 | 用 HTTPS + PAT，或配 SSH key |
| `warning: LF will be replaced by CRLF` | Windows 换行符提示 | 无害，可忽略；或 `core.autocrlf true` |
| 中文文件名显示成 `\346\226\207` | `quotepath` 开着 | `git config --global core.quotepath false` |
| `detached HEAD` | 切到了某个提交而不是分支 | `git switch -` 或 `git switch main` |
| 文件太大推不上去 | 单文件 >100MB（GitHub 限制） | 图片压缩，或改用图床 |
| `Your branch is ahead of 'origin/main' by N commits` | 本地有未推送提交 | `git push` |

---

## 10. 安全红线（别做这几件事）

1. ❌ 不要 `git add node_modules` —— 已在 `.gitignore` 里，别手贱 `-f`。
2. ❌ 不要对 `main`（或 `master`）执行 `git push --force` —— 会覆盖远程历史。
3. ❌ 不要在 `public/` 或 `.deploy_git/` 里单独 `git init` —— 部署目录由 Hexo 管理。
4. ❌ 不要把 `themes/` 里的主题再变成子模块或嵌套 `.git` —— 主题内容会丢。
5. ✅ 提交前永远先 `git status`，看清「要提交的东西是不是你以为的那些」。

---

## 11. 多电脑同步（方案速查）

完整方案见下面第 12 节；这里只给日常要用的三条：

```bash
# 另一台电脑上有更新，先同步
git pull --rebase

# 这台电脑改完
git add -A && git commit -m "说明" && git push
```

---

## 12. 多电脑同步方案

### 12.0 本仓库当前的实际配置（2026-10-17 已落地）

```
远程 origin = https://github.com/littlehorsebrother2021/personal_website_backup.git

远端分支：
  main                  ← 另一条历史（2026-08-01 备份；内容已于 d0def91 合并进本分支）
  lagacy-backup         ← AI 修改前的原始版本
  cleanup-2026-10-17    ← ★ 当前源码主线（已含 main 的封面/工具/文档）
```

**因为这个仓库的默认分支是 `main`，而源码在 `cleanup-2026-10-17` 上，所以：**

| 场景 | 命令 |
| :--- | :--- |
| 日常提交 | `git add -A && git commit -m "说明" && git push`（当前分支已跟踪 `origin/cleanup-2026-10-17`） |
| 日常拉取 | `git pull` |
| **新电脑克隆** | `git clone -b cleanup-2026-10-17 https://github.com/littlehorsebrother2021/personal_website_backup.git` ← **必须带 `-b`**，否则拿到的是另一条历史的 main |
| 查看差异 | `git diff origin/main origin/cleanup-2026-10-17 --stat`（应只差本分支新增的内容） |

> **合并已完成（2026-10-17，提交 `d0def91`）**：`main` 里的定制封面图、`assets/`、`tools/`、`docs/`、
> 以及 3 篇文章修复后的图片路径，都已并入本分支；`main` 分支本身保持原样未动。
> 若要让 GitHub 首页默认显示源码，可到 Settings → Default branch 改成 `cleanup-2026-10-17`。

### 方案 A（推荐）：源码放独立仓库，Pages 仓库只收静态文件

```
GitHub 仓库① <用户名>.github.io   ← 只放 public/ 构建结果（hexo deploy 自动推）
GitHub 仓库② blog-source（建议私有） ← 放全部源码与文章（git push 手动推）
```

**优点**：两条线彻底分离，永远不会把静态文件历史覆盖到源码上；仓库②可以设为私有。

**一次性配置：**

```bash
# 1) 本地分支改名为 main（与 GitHub 默认一致）
git branch -M main

# 2) 关联远程（换成你自己的仓库地址）
git remote add origin https://github.com/<用户名>/<源码仓库名>.git

# 3) 首次推送
git push -u origin main
```

**新电脑：**

```bash
git clone https://github.com/<用户名>/<源码仓库名>.git
cd <源码仓库名>
npm install
npm run server
```

### 方案 B（你提到的方法）：同一仓库双分支

```
仓库 <用户名>.github.io
├── main    ← 静态文件（hexo deploy 强推，不要手工改）
└── hexo    ← 源码（git push 手动推，设为默认分支）
```

**一次性配置：**

```bash
# 1) 把当前源码放到 hexo 分支
git switch -c hexo

# 2) 关联远程
git remote add origin https://github.com/<用户名>/<用户名>.github.io.git

# 3) 推送源码分支
git push -u origin hexo

# 4) 到 GitHub → Settings → Default branch 改为 hexo
# 5) 确认 Pages 设置仍是 main 分支 /(root) —— 默认分支变了不影响 Pages
```

**新电脑：** `git clone` 下来拿到的就是 `hexo` 分支的源码，再 `npm install`。

**方案 B 的三个坑：**

1. `hexo deploy` 会**强制覆盖** `main`，所以那个分支上不要留任何手工修改。
2. 两台电脑都在 `hexo` 分支上工作时，`git pull` 前先 `git status` 确认没有半成品改动。
3. 仓库默认分支一旦设为 `hexo`，别人（或未来的你）打开仓库首页看到的是一堆源码，
   静态文件在另一个分支 —— 容易误以为「网站坏了」。

> **本项目已完成的前置工作**（两方案都需要）：
> `.gitignore` 已就绪、`themes/` 下无嵌套 `.git`、`public/` 与 `db.json` 已排除、
> 仓库已整理为 4 个干净提交，并已推送到远程 `cleanup-2026-10-17` 分支。

---

## 13. 推送被 GitHub 密钥扫描拦住怎么办

### 症状

```
remote: error: GH013: Repository rule violations found for refs/heads/xxx
remote: - GITHUB PUSH PROTECTION
remote:   Push cannot contain secrets
remote:        —— Tencent Cloud Secret ID ——
remote:          path: themes/hexo-theme-matery/source/libs/twikoo/twikoo.all.min.js:2
```

### 先判断是不是误报

第三方 JS 库里经常有「示例字符串」被误判。本次遇到的 `AKIDBgZD...` 出现在
`ADMIN_CONFIG_EXAMPLE` 后面，是 Twikoo 后台的**占位符示例**，不是真实凭据。

### 处理办法（按推荐顺序）

| 办法 | 适用 | 操作 |
| :--- | :--- | :--- |
| **① 放行（推荐）** | 确认是误报 | 终端提示里会给出 `https://github.com/<用户>/<仓库>/security/secret-scanning/unblock-secret/<id>` 链接，用仓库所有者账号打开 → 选择理由 → **Allow secret** → 重新 `git push` |
| ② 排除路径 | 整个目录都是第三方库 | 在**默认分支**加 `.github/secret_scanning.yml`：`paths-ignore: ["themes/**/libs/**"]`（注意：该配置只从默认分支读取，对当前分支的推送不一定立即生效） |
| ③ 移除文件 | 该库根本没启用 | 删除文件 → 修改引用指向 CDN → 用 `git filter-branch` 从历史中彻底删除 |

> 遇到时**不要**用 `git push --force` 硬试，密钥扫描是服务端规则，force 也会被拦。
