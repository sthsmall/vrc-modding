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
├── Hairs/
│   └── default/                     默认发型（容器）
├── Deco/                            独立装饰容器（kemo 等 loose props）
│   └── kemo
├── _MA_Menu/                        菜单树根（挂 MA 组件）
└── ...                              独立系统模块平铺根层
```

- Outfit containers are **empty group nodes** at identity transform.
- Underwear belongs **inside** the outfit (can be removed via part toggle). Chiffon reference keeps a root-level always-on underwear instead — pick one and stay consistent.
- System modules (RBS_Suimin, LightController, SPS, games...) sit flat at the root, each as its own MA module.
- Loose decorative props that aren't part of any outfit (kemo, pins, standalone accessories) go in `Deco/` — a category container, not an outfit, so they toggle independently of `cloth`.

## 2. Menu organization

```
Root (_MA_Root, empty asset; MA fills at build)
├── 原有菜单（原模型菜单，SubMenu, Children）
│   ├── 設定 → kuuta_JP_Settings（MenuAsset 引用原资产）
│   ├── 表情セット → kuuta_JP_FaceEmote_PatternSwitchin_表情セット
│   ├── 表情固定 → kuuta_JP_FaceEmote_FixedEmote_表情固定
│   ├── ハンドサイン → kuuta_JP_HandsignPattern_ハンドサイン切り替え
│   ├── しゃがみポーズ → kuuta_CrouchingChange
│   └── 視線制御 → kuuta_JP_EyeControl
├── Clothes（SubMenu, Children）
│   ├── all（cloth, isDefault=True）
│   ├── Shoes / Socks（自动参数）
│   ├── clothes01 OFF / clothes02 OFF / clothes03 OFF（部件开关, 自动参数）
│   └── <NewOutfit>（新增套装子菜单）
└── 装饰（SubMenu, Children）
    └── kemo OFF（自动参数, OT→Deco/kemo）
```

Rules:
- Each outfit = one submenu = one `all` master toggle + part toggles.
- Group part toggles by 上装/下装/饰品/鞋 when > 8 controls, to avoid VRChat's auto `More` page.
- Part toggle naming: `<part> OFF` (activating the item hides the part).
- Outfit master uses shared `cloth`, hair uses shared `hair`.
- Top-level menus: `Control.type=SubMenu`, `MenuSource=Children`, `menuSource_otherObjectChildren=null` (use own children).
- **Prefer re-making original menu content with MA MenuItem where clean**; otherwise reference the original menu asset unchanged under 原有菜单 (never edit commercial menu assets).

## 2b. Menu & parameter asset backup habit

Before MA-ifying a stock avatar, duplicate the original root menu and Parameters assets as `.bk` siblings (e.g. `kuuta_JP__Root.bk.asset`, `kuuta_Param .bk.asset`). Then:
- AvatarDescriptor `expressionsMenu` → new empty `_MA_Root.asset` (MA fills it at build).
- AvatarDescriptor `expressionParameters` → the ORIGINAL Parameters asset (kept, backed up). Do not create a MA Parameters component unless required (see §4).

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
- **Single outfit**: `cloth` auto-generates as Bool — fine.
- **2+ outfits**: `cloth` must be Int with `automaticValue=false` + manual distinct values on EVERY `all` (default included), and declared via a MA Parameters component (or explicit param) — otherwise mutual exclusion silently breaks.

## 4. Parameter naming

| Category | Naming |
|---|---|
| Outfit master | `cloth` (Bool single / Int multi-outfit) |
| Hair master | `hair` (Bool single / Int multi) |
| Part toggles | MA auto param `__MA/AutoParam/<name>$hash` (empty `param` on MenuItem) |
| Sliders | original FX param names (BreastSize/Sleeve/BLength...) |
| System/gadgets | namespaced prefix (`RNW/Nade/`, `ABT/`, `SoundPad/`...) |

- **Auto-first policy**: let MA create parameters automatically (`param` empty + `automaticValue=true`) unless a param needs explicit saved/synced/default/Int semantics. Reuse the original Parameters file; avoid `ModularAvatarParameters` unless unavoidable.
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

1. Place the module in the right category (`Hairs/`, `Clothes/`, root...).
2. Keep its built-in MA config intact (author-designed features).
3. Its root MenuItem auto-installs its own submenu — don't be surprised by menu duplication; fold it under your main menu as a submenu child.
4. Add a master `all` toggle with shared param + `automaticValue=false` + manual value.
5. Module container `active=False`; `isDefault` controls startup state.

### Animation path fix after reparenting
If a module's controller binds paths starting at the module name (`Nova/~Wing`) and you moved the module into a subfolder (`Hairs/Nova`), the paths break. Fix by setting the module **MergeAnimator `relativePathRoot`** to the module's parent folder — MA prefixes the missing path so bindings resolve. Prefer this over editing the commercial animations.

## 7. NDMF plugins (LightController pattern)

Some assets are NDMF plugins (`Editor/NDMFPlugin.cs`, `ExportsPlugin`) that generate menus/params/animators at build time. Do **not** hand-wire their menus. Confirm the generated menu doesn't collide; set `installTargetMenu` only to relocate it.

## 8. Independent accessories (elf ears pattern)

Rigid accessory with its own small bone system → **BoneProxy** on the accessory root pointing at the target avatar bone (e.g. Head). Do **not** use OutfitRoot for plain accessories — it marks them as an independent outfit and can make the containing outfit container fail to activate at build.
