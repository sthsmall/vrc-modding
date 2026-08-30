# VRChat Model Modding Skill (vrc-modding)

一个用于 OpenCode 的 VRChat 头像改模 Skill，基于 Modular Avatar。合并自 `vrc-model-modding`（改模习惯）和 `modular-avatar`（MA 组件规范），并通过原生 `unityMCP_*` 工具操作 Unity。

## 功能

- 套装/发型容器组织：`Clothes/<outfit>/`、`Hair/<outfit>/`
- 互斥开关：共享 `cloth` / `hair` Int 参数，`automaticValue=false` + 手动值，`isDefault` 驱动默认穿着
- MA 组件操作规范：MergeArmature / BoneProxy / MenuItem / ObjectToggle / ShapeChanger / BlendshapeSync / MeshCutter / Parameters / MergeAnimator
- 商业 MA/NDMF 模块集成（Nova、RBS_Suimin、LightController 等）
- 构建验证：`AvatarProcessor.ProcessAvatar()` 克隆预览 + Console 检查

## 环境要求

- OpenCode
- Unity + VRCSDK + Modular Avatar 项目
- 原生 `unityMCP_*` 工具（Unity MCP）已注入

## 安装

将仓库克隆/解压到 OpenCode 的 Skills 目录，确保根目录直接包含 `SKILL.md`：

```powershell
git clone https://github.com/sthsmall/vrc-modding.git `
  "$env:USERPROFILE\.config\opencode\skills\vrc-modding"
```

安装后新开一个 OpenCode 会话。

## 目录结构

```text
vrc-modding/
├── SKILL.md
├── find-ma-symbol.ps1 / find_ma_symbol.py       # 本地包检查辅助脚本
├── inspect-modular-avatar.ps1 / _modular_avatar.py
└── references/
    ├── habits.md               # 套装化/互斥/菜单/参数/编码习惯
    ├── gotchas.md              # 常见坑（EditorOnly、automaticValue、骨骼绑定等）
    ├── component-guide.md      # MA 组件决策指南
    ├── source-policy.md        # 版本纪律与信息权威顺序
    ├── safety-validation.md    # 批准边界/回滚/验证清单
    ├── workflows.md            # 任务工作流
    ├── unity-mcp-playbook.md   # Unity MCP 读写序列
    ├── version-notes.md        # MA 版本快照
    └── official-sources.md     # MA 官方文档链接
```

## 许可

MIT License