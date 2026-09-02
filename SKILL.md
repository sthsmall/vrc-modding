---
name: vrc-modding
description: Unified VRChat avatar modding workflow built on Modular Avatar — integrate new clothes/hair/outfits/accessories into an avatar (Clothes/Hairs container grouping, mutual-exclusion cloth/hair parameters, per-outfit menus, part toggles, MA module integration), plus safe MA component selection, configuration, and build validation. Use when adding or reorganizing outfits, hair, accessories, building Clothes/Hairs menus, fixing mutual-exclusion toggles, automaticValue issues, wiring MA/NDMF components, or validating an avatar build. Works exclusively through native unityMCP_* tools for Unity operations.
license: MIT
compatibility: OpenCode v2; Unity + VRCSDK + Modular Avatar projects; requires native unityMCP_* tools
metadata:
  opencode/slash: "true"
  opencode/autoinvoke: "true"
  version: "2.5.0"
  captured: "2026-09-02"
---

# VRChat model modding workflow (改模习惯 + MA 规范)

Battle-tested workflow for MA-ifying and extending a VRChat avatar (originally distilled from the Milfy project), merged with the Modular Avatar component-operation rules. Read this skill whenever the task touches outfit/hair organization, mutual-exclusion toggles, the avatar menu tree, MA component selection, or build validation.

## When to use

- Adding a new outfit, hair, or accessory to an avatar.
- Regrouping avatar nodes into `Clothes/` / `Hairs/` / accessories containers.
- Building or fixing the Clothes/Hairs Menu tree (per-outfit submenus, `all` toggles, part groups).
- Debugging mutual-exclusion (two outfits on at once, wrong default outfit, nothing worn on load).
- Integrating commercial MA/NDMF modules (Nova, RBS_Suimin, LightController, etc.).
- Selecting, configuring, or validating MA components (MergeArmature, BoneProxy, MenuItem, ObjectToggle, ShapeChanger, BlendshapeSync, MeshCutter, Parameters, MergeAnimator...).
- Validating a build with `AvatarProcessor.ProcessAvatar()` / `ProcessAvatarUI()`.

## Native tool policy (non-negotiable)

- **Use ONLY native `unityMCP_*` tools** for live Unity inspection, component changes, scene operations, and Console reads. They are injected into this Agent.
- Do **not** write Python, JavaScript, PowerShell, curl, or raw JSON-RPC to call the MCP endpoint. Shell is for local package/file inspection only, never for controlling Unity or bypassing MCP permissions.
- If `unityMCP_*` tools are unavailable, stop live-Editor work and report that the tools were not injected; do not silently fall back to raw HTTP or batch mode.
- C# code through `unityMCP_execute_code` runs as a method body with `UnityEngine`/`UnityEditor` access. Use `return <string>` to send data back. CodeDom/C#6 limits apply (no local `void` functions — use lambdas).

## Core principles (non-negotiable)

1. **Outfit-grouped organization**: clothes/hair live in category containers under the avatar root — `Clothes/<outfit>/`, `Hairs/<outfit>/`. New outfits are sibling folders, never nested inside an existing outfit.
2. **Mutual exclusion via shared params**: all outfits share one `cloth` param (single outfit → auto Bool; 2+ outfits → Int, each with a distinct value Default=1, next=2...). Hair uses `hair`. Only one outfit / one hair is on at a time.
3. **Default worn outfit is driven by MA, not by scene state**: every outfit container is `active=False` in the editor. The menu item marked `isDefault=True` decides what is worn on load. isDefault points to "the initial look the user wants" — not necessarily a container named `Default`.
4. **Keep system nodes at root**: `Armature`, `Body`, `Body_base`, `Ground`, `AutoAnchorObject`, `VRCHeadChop` are never moved.
5. **Switch vs slider split**: on/off switches → MA ObjectToggle; continuous blendshape sliders → stay in the FX layer.
6. **Never touch commercial assets**: fix commercial module path issues via MA config (e.g. MergeAnimator `relativePathRoot`), not by editing the asset's controllers/animations.
7. **Respect the source of truth**: MA components and source prefabs are declarations; NDMF preview, build clones, merged controllers, and generated assets are outputs. Never repair an output when the source component can be repaired.
8. **Parameters auto-first (v2.3)**: let MA auto-generate params (empty `param` + `automaticValue=true`) whenever possible. Reuse the avatar's original Parameters file (back it up as `.bk` first); do NOT create a `ModularAvatarParameters` component unless mutual exclusion needs explicit Int values, or a specific saved/synced/rename semantic is required. `cloth` stays Bool for a single outfit; promote to Int only when a second outfit arrives.
9. **Menu file strategy (v2.3)**: create a NEW empty menu asset as the root (e.g. `_MA_Root`), back up the original root menu (`.bk`), and point the AvatarDescriptor `expressionsMenu` at the empty root (MA fills it at build). Original menu content: rebuild with `ModularAvatarMenuItem` where feasible (re-make = clean MA controls); otherwise move the item under an `原有菜单` submenu by referencing the original menu asset unchanged.
10. **3-group root menu layout (v2.3)**: `_MA_Menu` root splits into `原有菜单` / `Clothes` / `装饰` top-level submenus, each `Control.type=SubMenu` + `MenuSource=Children` + `menuSource_otherObjectChildren=null` (use own children). Put loose decorative props (kemo, etc.) in a `Deco/` container under the avatar root with a `装饰` submenu.

## Lock the target before working

Before inspecting or changing anything, record the exact:

- project path and Unity version;
- selected Unity MCP instance and its proven project path/Unity version;
- active scene and whether it is saved or dirty, Play Mode, compilation/update state;
- avatar hierarchy path, including whitespace and duplicate-name risks;
- the exact feature or change requested, and whether any mutation is authorized.

Do not infer the target from object recency, active state, a Pipeline Manager ID,
structural similarity, or a previous session's editor instance. In multi-avatar
scenes, locate the intended avatar dynamically (e.g. by exact hierarchy path) —
never hard-code avatar names that can change on rename.

## Evidence and verification

Label every material conclusion with the narrowest evidence layer actually run — `STATIC_SOURCE` → `UNITY_RESOLVED` → `PROVIDER_PREVIEW` → `NDMF_BUILT` → `SDK_BUILD` → `CLIENT_RUNTIME` → `UPLOAD_CONFIRMED`. Never promote one layer into another (raw YAML/preview/clone ≠ final player behavior). Status language (`PASS` only for an executed layer; else `NOT_RUN` / `BUILD_REQUIRED` / `MCP_REQUIRED` / `BLOCKED` / `STALE` / `AMBIGUOUS_TARGET`), proportional validation, the authorization matrix, and shared/generated ownership rules are all detailed in `references/evidence-and-authorization.md` — consult it before conclusions cross into previews/builds/runtime or before changing shared/generated assets.

## Gesture Manager and Avatar Optimizer rules

### Gesture Manager (preview only, not an authoring provider)

- Treat Gesture Manager as a Unity editor preview and diagnostics tool, not an authoring provider. Record whether the run used Play Mode, a clone, radial menu/parameter emulation, clickable Contacts, gesture weights, Animator debugging, or OSC.
- Label the result exactly `CLIENT_RUNTIME (Unity/Gesture Manager preview)`; never promote it to VRChat desktop, VR, multiplayer, SDK build, or upload proof.

### Avatar Optimizer (settings and originals are source; optimized output is build output)

- Treat optimizer settings and original assets as sources; treat optimized meshes, materials, components, paths, and clones as NDMF/build outputs.
- When a claim depends on it, check menu, animation, BlendShape, PhysBone, Contact, material, and renderer routes against the optimized result.
- Do not recommend optimization merely because the package is installed or a metric is near a limit. Enter optimization only on user request, confirmed hard overflow, or a measured performance target.
- Preserve exact before/after build evidence and do not edit optimized output as the durable fix.

## Source and version discipline

- Information authority order (manifest → lock → installed package → official docs → release notes) and web-access policy are detailed in `references/source-policy.md`.
- Before using a feature introduced recently, state: `Installed MA version: X` / `Docs version consulted: Y` / `Compatibility: supported | unsupported | uncertain`. If uncertain, do not write until the type/field is found in the installed package.
- Never guess class names, serialized fields, paths, or GUIDs. Verify exact types via `unityMCP_unity_reflect` and read serialized fields via `SerializedObject`/`FindProperty` (check for null before reading).
- Never edit files under `Library/PackageCache/` or immutable package sources. Do not modify imported BOOTH content in place.

## Standard workflow (MA-ify an existing avatar)

Full step-by-step: `references/workflows.md` (A0). Summary — back up original menu+Parameters as `.bk`; create an empty `_MA_Root` menu asset and point AvatarDescriptor at it (`_MA_Menu` = MenuInstaller+MenuGroup, `menuToAppend=null`); rebuild original top-level controls with `ModularAvatarMenuItem` or fold them under `原有菜单` referencing the original assets unchanged; keep AvatarDescriptor `expressionParameters` on the original (backed-up) asset; regroup wearables into `Clothes/Default/` and loose props into `Deco/` (unpack prefab instance first if reparenting is blocked); rebuild broken stock FX logic with ObjectToggle/ShapeChanger; then build-verify on a clone.

### Add a new outfit/hair (existing MA-ified avatar)

1. Put the model under `Clothes/<outfit>/` (or `Hairs/<outfit>/`).
2. Independent armature? → add the MA set: **MergeArmature** on its armature (`mergeTarget` = avatar main Armature) + **MeshSettings** (RootBone/ProbeAnchor to main armature). Verify bone mapping resolves. Rigid accessory with its own small bone system → **BoneProxy** on the accessory root pointing at the target avatar bone. Do not use OutfitRoot for plain accessories.
3. In `_MA_Menu/Clothes`, create the outfit submenu with `ModularAvatarMenuItem` `Control.type=SubMenu`, `MenuSource=Children`. Every outfit gets its own submenu under Clothes (default outfit = lowercase `default`); part toggles live INSIDE the submenu, not flattened under Clothes.
4. Add the **`all`** master toggle:
   - MenuItem Toggle, `param=cloth`, manual distinct `value` per outfit (Default=1, next=2...). Single outfit: no Parameters needed (auto Bool fine). 2+ outfits: declare `cloth` as **Int** via a MA Parameters component (`defaultValue` = default outfit's value); `automaticValue` may stay `true` (with explicit Int declaration MA respects the manual value).
   - MA ObjectToggle → references the outfit root container, `Active=true`.
5. Part toggles: group into 上装/下装/饰品/鞋 (or per hair part) submenus to stay under VRChat's 8-control limit. Each part toggle: MenuItem Toggle (param empty → MA auto param) + ObjectToggle with `Active=false` (activating the toggle hides the part). For a commercial module's parts, bind the module's OWN params directly (`Control.parameter.name` = e.g. `coat_off`, `automaticValue=false`) instead of referencing its menu asset — and remove/disable the module's own MenuInstaller so it doesn't install to the avatar top level.
6. Default outfit's `all` gets `isDefault=True`.
7. Container stays `active=False` in the scene.
8. Chinese menu names written via Unicode escapes when using codegen (raw Chinese becomes `?`).
9. Validate with `AvatarProcessor.ProcessAvatar()` on a clone (PROVIDER_PREVIEW) or `ProcessAvatarUI()`, check Console, save scene.

## MA component decision guide (quick)

- Skinned outfit with its own armature → **MergeArmature** (+ MeshSettings for RootBone/ProbeAnchor).
- Rigid accessory attached to a bone (glasses, hats, props, contacts) → **BoneProxy**.
- Hierarchy expression control → **Menu Item** (+ Menu Installer / parent MenuSource=Children).
- Custom animator/expression parameters → **auto-generate first**; add **Parameters** only for mutual-exclusion Int values or saved/synced/rename semantics. Reuse the original Parameters asset when possible.
- Merge a controller into a playable layer → **Merge Animator**.
- Body/outfit blendshapes stay aligned → **Blendshape Sync**.
- Set body blendshapes while a module is active → **Shape Changer**.
- Hide/delete body polygons → **Mesh Cutter** + vertex filters. If the whole renderer should disappear, use **Object Toggle** instead.
- Swap/set materials reactively → **Material Swap / Material Setter** (create copies of user-editable materials).
- Mesh bounds/anchor consistency → **Mesh Settings**.
- Full detail: `references/component-guide.md`.

## Safe execution loop (every modification)

1. **Observe**: query current objects, components, paths, asset refs, and Console baseline via `unityMCP_*` tools.
2. **Plan**: name the exact objects/assets to create or modify and state the rollback method (Unity Undo / delete new object / remove new component / restore copy / discard overrides).
3. **Approve**: request approval for destructive or externally consequential actions (delete assets, Apply overrides, modify imported prefabs, save when only inspection was asked, upgrade packages, upload avatar).
4. **Apply minimally**: perform one coherent change through native `unityMCP_*` tools.
5. **Re-read**: inspect the resulting component and references rather than assuming success.
6. **Preview**: use MA/NDMF preview, play mode, or build validation appropriate to the change.
7. **Check Console**: compare new errors/warnings against the pre-change baseline.
8. **Report**: list changed GameObjects, files, components, parameters, and unresolved warnings.

## Validation checklist (run after every change)

This is the run-after-every-change checklist. `references/safety-validation.md` has a categorized version (object/reference, armature/mesh, animator/menu/parameters, build pipeline) plus approval and rollback requirements — consult it for deeper checks.

- [ ] Target locked: exact avatar path, instance, scene dirty state recorded.
- [ ] Outfit containers `active=False` in scene; default outfit enabled via `isDefault=True` on the built clone (`PROVIDER_PREVIEW`).
- [ ] Single-outfit `cloth` may be auto Bool; with 2+ outfits `cloth`/`hair` are **Int** (via MA Parameters) with default value = default outfit's value (not 0).
- [ ] All `all` toggles in a mutual-exclusion group have distinct manual values; no two outfits share a value (automaticValue may stay true when the param is explicitly declared Int).
- [ ] Submenus ≤ 8 controls each (no accidental `More` overflow).
- [ ] ObjectToggle `referencePath` set to full avatar-relative path (e.g. `Clothes/Default/Cardigan`) and `targetObject` set; resolved target is not null.
- [ ] Target nodes are `Untagged`, not `EditorOnly` (EditorOnly nodes are stripped by the build).
- [ ] Commercial module anim bindings resolve (0 broken paths).
- [ ] SMR bones point at the main Armature (not an old prefab armature).
- [ ] Parameter names/types/defaults/saved/synced are intentional; no duplicate/conflicting declarations.
- [ ] Console has no new errors/warnings vs. baseline.
- [ ] Evidence layers actually run are labeled; unrun layers reported as `NOT_RUN`/`BUILD_REQUIRED`.
- [ ] Scene saved.

## Full detail references

- `references/habits.md` — 套装化/互斥/菜单/参数/编码 habits, the complete add-outfit runbook, commercial module integration, BoneProxy accessories, Chinese naming rules.
- `references/gotchas.md` — every known pitfall: EditorOnly stripping, ObjectToggle `referencePath`, automaticValue mutual-exclusion trap, SMR bone rebinding after moves, animation path breakage after reparenting, multi-avatar scenes, shared asset behavior.
- `references/component-guide.md` — MA component decision guide (MergeArmature / BoneProxy / Menu / Parameters / MergeAnimator / BlendshapeSync / reactive / MeshSettings / platform filters).
- `references/evidence-and-authorization.md` — evidence ladder, status language, validation proportionality, authorization matrix, shared/generated ownership.
- `references/source-policy.md` — version discipline and authority order.
- `references/safety-validation.md` — approval boundaries, rollback, validation checklist, evidence standard.
- `references/workflows.md` — task workflows (MA-ify an existing avatar, install outfit, attach accessory, add toggle, material variant, blendshape sync, hide clipping, merge animator, troubleshoot build).
- `references/unity-mcp-playbook.md` — read-only discovery and safe-write sequences through Unity MCP.
- `references/version-notes.md` — MA version snapshot (check installed version before trusting).
- `references/official-sources.md` — official MA documentation links.
- `scripts/` — local package inspection helpers (inspect-modular-avatar, find-ma-symbol). For local files only.