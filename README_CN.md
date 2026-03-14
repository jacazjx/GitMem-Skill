# GitMem 安全编辑

一个专为 AI 代码代理设计的技能，使用独立的 `.gitmem` 仓库作为编辑安全层，提供安全、可追溯、可逆的文件编辑能力。

## 问题背景

AI 代码代理（Claude、ChatGPT、Cursor 等）经常陷入破坏性的编辑循环：

```
编辑 → 破坏 → 修复 → 破坏 → 修复 → 破坏 → ...
```

每次编辑都会覆盖之前的状态，导致无法：
- 查看何时改了什么
- 回滚到正常工作的版本
- 对比不同版本的差异
- 从累积的破坏中恢复

## 解决方案

GitMem 创建一个**独立的 git 仓库**（`.gitmem/`），独立于主项目的 git 历史，追踪每一次 AI 代理的编辑。

```
your-project/
├── .git/          # 主仓库（不受影响）
├── .gitmem/       # AI 编辑安全层
│   └── .git/
├── src/
└── ...
```

**核心优势：**
- 🔄 **每次编辑自动提交** - 完整的代理变更历史
- ⏪ **轻松回滚** - 将任意文件恢复到任意历史状态
- 🔍 **差异对比** - 精确查看版本间的变化
- 🏷️ **检查点** - 在风险操作前标记稳定状态
- 🚫 **零污染** - 主 git 历史保持干净
- 📦 **零依赖** - 纯 git 实现，无需数据库或外部服务

## 安装方法

### Claude Code

1. **克隆或下载**本仓库：
   ```bash
   git clone https://github.com/YOUR_USERNAME/gitmem-safe-editing.git
   ```

2. **安装到 Claude Code**：
   ```bash
   # 方式一：复制到 Claude 技能目录
   cp -r gitmem-safe-editing ~/.claude/skills/

   # 方式二：创建符号链接（推荐，便于更新）
   ln -s $(pwd)/gitmem-safe-editing ~/.claude/skills/gitmem-safe-editing
   ```

3. **重启 Claude Code** 或开启新会话。

### Codex / OpenAI

1. **克隆或下载**本仓库。

2. **复制到 Codex 技能目录**：
   ```bash
   cp -r gitmem-safe-editing ~/.codex/skills/
   ```

3. **或使用提供的代理配置**：
   `agents/openai.yaml` 文件包含适用于 OpenAI 兼容代理的配置。

### 安装 CLI 工具（可选）

如需命令行访问 GitMem 操作：

```bash
cd gitmem-safe-editing/scripts
./install.sh

# 如需要，添加到 PATH
export PATH="$HOME/.local/bin:$PATH"
```

## 使用方法

### 基本工作流

当你让 AI 编辑文件时，GitMem 会自动：
1. 在 `.gitmem` 中记录每次编辑
2. 使变更可追溯、可回滚
3. 对编辑循环发出警告

**触发 GitMem 的示例提示：**
- "修改 config.yaml，确保出问题能撤销"
- "重构认证模块，但保留检查点"
- "上次编辑搞坏了测试，给我看看改了什么"
- "回到 3 次编辑前的版本"

### CLI 命令

| 命令 | 说明 |
|------|------|
| `gitmem init` | 初始化 .gitmem 仓库 |
| `gitmem commit <文件> [原因]` | 提交单个文件 |
| `gitmem history [文件]` | 查看编辑历史 |
| `gitmem diff <文件>` | 对比最近两个版本 |
| `gitmem rollback <文件> [提交]` | 回滚文件 |
| `gitmem undo` | 撤销最近一次更改 |
| `gitmem checkpoint <名称>` | 创建检查点标签 |
| `gitmem status` | 查看 gitmem 状态 |
| `gitmem watch` | 自动监控文件变化 |
| `gitmem check-loop <文件>` | 检查编辑循环警告 |

### 自动监控模式

自动将每次文件变更提交到 GitMem：

```bash
gitmem watch
```

选项：
- `--debounce 秒数` - 提交前等待时间（默认：2）
- `--exclude 模式` - 额外的排除模式
- `--dry-run` - 仅显示将要提交的内容

## 项目结构

```
gitmem-safe-editing/
├── SKILL.md                 # 主技能定义
├── agents/
│   └── openai.yaml          # OpenAI/Codex 代理配置
├── scripts/
│   ├── gitmem               # 主 CLI 命令
│   ├── gitmem-init          # 初始化助手
│   ├── gitmem-watch         # 自动监控文件变更
│   └── install.sh           # 安装脚本
├── references/
│   └── command-recipes.md   # Git 命令参考
├── evals/
│   └── evals.json           # 行为测试用例
└── README.md                # 本文件
```

## 核心操作

### 1. 编辑并自动提交
编辑任意文件后，立即提交到 GitMem：
```bash
git --git-dir=.gitmem/.git --work-tree=. add -- <文件>
git --git-dir=.gitmem/.git --work-tree=. commit -m "agent(edit): <文件>

reason: <原因>"
```

### 2. 查看文件历史
```bash
git --git-dir=.gitmem/.git --work-tree=. log -- <文件>
```

### 3. 对比版本
```bash
git --git-dir=.gitmem/.git --work-tree=. diff <提交a> <提交b> -- <文件>
```

### 4. 回滚文件
```bash
git --git-dir=.gitmem/.git --work-tree=. checkout <提交> -- <文件>
```

### 5. 创建检查点
```bash
git --git-dir=.gitmem/.git --work-tree=. tag gitmem-checkpoint-<名称>
```

### 6. 撤销最近更改
```bash
git --git-dir=.gitmem/.git --work-tree=. reset --hard HEAD~1
```

## 循环保护

GitMem 能检测文件在未达到稳定状态时被反复编辑的情况：

- 当文件在最近 5 次提交中反复出现且无检查点时发出警告
- 建议回滚或创建检查点
- 防止无限的编辑-修复-破坏循环

## 错误处理

本技能包含完善的错误处理，涵盖：
- GitMem 未初始化
- 仓库损坏
- .git 与 .gitmem 之间的文件冲突
- 文件无历史记录
- 合并冲突
- 磁盘空间问题

详细恢复流程请参见 `SKILL.md`。

## 贡献

欢迎贡献！请随时提交 issue 或 pull request。

## 许可证

MIT 许可证 - 详见 LICENSE 文件。

---

**用 ❤️ 打造更安全的 AI 辅助编程体验**