# 改模习惯详细版（habits）

Detailed operational habits for the VRChat model modding workflow. Read `../SKILL.md` first.

## 1. Hierarchy organization

```
avatar root
├── Armature / Body / Body_base      base (never move)
├── Ground / AutoAnchorObject        physics/anchor (never move)
├── VRCHeadChop                      VRC component (never move)
├── Clothes/
│   ├── Default/                     默认套装（容器，含各衣物节点 + 内衣）
│   └── GLEIPNIR_Milfy/              新套装（并列添加）
├── Hair/
│   └── Default/                     默认发型（容器）
├── _MA_Menu/                        菜单树根（挂 MA 组件）
└── ...                              独立系统模块平铺根层
```

- Outfit containers are **empty group nodes** at identity transform.
- Underwear belongs **inside** the outfit (can be removed via part toggle). Chiffon reference keeps a root-level always-on underwear instead — pick one and stay consistent.
- System modules (RBS_Suimin, LightController, SPS, games...) sit flat at the root, each as its own MA module.

## 2. Menu organization

```
Cloth Menu
├── Default（套装子菜单）
│   ├── Cardigan Sleeve / Baretop Length（滑杆）
│   ├── all（整体开关, cloth=1, isDefault=True）
│   └── 上装 / 下装 / 饰品（部件分组子菜单）
│       ├── Cardigan OFF / Baretop OFF / Bra OFF
│       ├── Bottoms OFF / Underwear OFF
│       └── Crown OFF / Slippers OFF
└── <NewOutfit> Toggles（套装子菜单）
    ├── all（整体开关, cloth=2）
    └── 上装 / 饰品 / 鞋（部件分组子菜单）

Hair Menu
└── Default（发型子菜单）
    ├── all（整体开关, hair, isDefault=True）
    └── Front Length / Twintail Length / 调节控件
```

Rules:
- Each outfit = one submenu = one `all` master toggle + part toggles.
- Group part toggles by 上装/下装/饰品/鞋 when > 8 controls, to avoid VRChat's auto `More` page.
- Part toggle naming: `<part> OFF` (activating the item hides the part).
- Outfit master uses shared `cloth`, hair uses shared `hair`.

## 3. Toggle configuration

### Master toggle (outfit)
- 1 MA ObjectToggle on the menu-item node.
- `Objects` references the **outfit root container**, `Active=true`.
- MenuItem: `param=cloth`, distinct value per outfit, `isDefault` marks the default outfit.

### Part toggle
- MenuItem (Toggle) + MA ObjectToggle with `Active=false` (toggle ON = hide part).
- `Objects` references the concrete part node.

### Mutual exclusion
- All outfits share `cloth`; clicking an outfit sets `cloth` to its value; only matching outfit activates.

## 4. Parameter naming

| Category | Naming |
|---|---|
| Outfit master | `cloth` (Int, distinct values) |
| Hair master | `hair` (Int) |
| Part toggles | MA auto param `__MA/AutoParam/<name>$hash` |
| Sliders | original FX param names (BreastSize/Sleeve/BLength...) |
| System/gadgets | namespaced prefix (`RNW/Nade/`, `ABT/`, `SoundPad/`...) |

- RadialPuppet wheel params go in `subParameters`; leave `parameter` empty.
- Part-toggle and empty-param nodes: **renaming the GameObject changes the auto param** — do not rename them. Display-only names with fixed params (Nail/Face/FHSharp, `all`, KumaPhone) are safe to rename.

## 5. Codegen / writing conventions (Unity MCP execute_code, C#6)

- **Chinese in Unicode escapes** (`\u4E0A\u88C5` = 上装). Raw Chinese becomes `?`/garbled.
- Local functions (`void Foo()`) are unsupported — use lambdas (`Action<...>`/`Func<...>`).
- `SetParent` uses Transform args; mind `var` type inference.
- Never modify a collection inside a `foreach` over it (missed/mistaken moves).
- Verify actual names via base64: `Convert.ToBase64String(UTF8.GetBytes(name))` (terminal mojibake is normal).

## 6. Commercial MA module integration (Nova pattern)

Full MA modules ship their own MenuItem/Parameters/MenuInstaller/MergeAnimator/MergeArmature/MeshSettings/BlendshapeSync.

1. Place the module in the right category (`Hair/`, `Clothes/`, root...).
2. Keep its built-in MA config intact (author-designed features).
3. Its root MenuItem auto-installs its own submenu — don't be surprised by menu duplication; fold it under your main menu as a submenu child.
4. Add a master `all` toggle with shared param + `automaticValue=false` + manual value.
5. Module container `active=False`; `isDefault` controls startup state.

### Animation path fix after reparenting
If a module's controller binds paths starting at the module name (`Nova/~Wing`) and you moved the module into a subfolder (`Hair/Nova`), the paths break. Fix by setting the module **MergeAnimator `relativePathRoot`** to the module's parent folder — MA prefixes the missing path so bindings resolve. Prefer this over editing the commercial animations.

## 7. NDMF plugins (LightController pattern)

Some assets are NDMF plugins (`Editor/NDMFPlugin.cs`, `ExportsPlugin`) that generate menus/params/animators at build time. Do **not** hand-wire their menus. Confirm the generated menu doesn't collide; set `installTargetMenu` only to relocate it.

## 8. Independent accessories (elf ears pattern)

Rigid accessory with its own small bone system → **BoneProxy** on the accessory root pointing at the target avatar bone (e.g. Head). Do **not** use OutfitRoot for plain accessories — it marks them as an independent outfit and can make the containing outfit container fail to activate at build.
