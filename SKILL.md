---
name: vrc-modding
description: Unified VRChat avatar modding workflow built on Modular Avatar — integrate new clothes/hair/outfits/accessories into an avatar (Clothes/Hair container grouping, mutual-exclusion cloth/hair parameters, per-outfit menus, part toggles, MA module integration), plus safe MA component selection, configuration, and build validation. Use when adding or reorganizing outfits, hair, accessories, building Cloth/Hair menus, fixing mutual-exclusion toggles, automaticValue issues, wiring MA/NDMF components, or validating an avatar build. Works exclusively through native unityMCP_* tools for Unity operations.
license: MIT
compatibility: OpenCode v2; Unity + VRCSDK + Modular Avatar projects; requires native unityMCP_* tools
metadata:
  opencode/slash: "true"
  opencode/autoinvoke: "true"
  version: "2.0.0"
  captured: "2026-08-30"
---

# VRChat model modding workflow (改模习惯 + MA 规范)

Battle-tested workflow for MA-ifying and extending a VRChat avatar (originally distilled from the Milfy project), merged with the Modular Avatar component-operation rules. Read this skill whenever the task touches outfit/hair organization, mutual-exclusion toggles, the avatar menu tree, MA component selection, or build validation.

## When to use

- Adding a new outfit, hair, or accessory to an avatar.
- Regrouping avatar nodes into `Clothes/` / `Hair/` / accessories containers.
- Building or fixing the Cloth Menu / Hair Menu tree (per-outfit submenus, `all` toggles, part groups).
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

1. **Outfit-grouped organization**: clothes/hair live in category containers under the avatar root — `Clothes/<outfit>/`, `Hair/<outfit>/`. New outfits are sibling folders, never nested inside an existing outfit.
2. **Mutual exclusion via shared params**: all outfits share one `cloth` Int param, each with a distinct value (Default=1, next=2, ...). Hair uses `hair`. Only one outfit / one hair is on at a time.
3. **Default worn outfit is driven by MA, not by scene state**: every outfit container is `active=False` in the editor. The menu item marked `isDefault=True` decides what is worn on load. isDefault points to "the initial look the user wants" — not necessarily a container named `Default`.
4. **Keep system nodes at root**: `Armature`, `Body`, `Body_base`, `Ground`, `AutoAnchorObject`, `VRCHeadChop` are never moved.
5. **Switch vs slider split**: on/off switches → MA ObjectToggle; continuous blendshape sliders → stay in the FX layer.
6. **Never touch commercial assets**: fix commercial module path issues via MA config (e.g. MergeAnimator `relativePathRoot`), not by editing the asset's controllers/animations.
7. **Respect the source of truth**: MA components and source prefabs are declarations; NDMF preview, build clones, merged controllers, and generated assets are outputs. Never repair an output when the source component can be repaired.

## Source and version discipline

1. Information authority order: `Packages/manifest.json` → `packages-lock.json` → installed package `package.json` → installed C# source/inspectors/docs → official docs matching the installed version → official release notes.
2. Before using a feature introduced recently, state: `Installed MA version: X` / `Docs version consulted: Y` / `Compatibility: supported | unsupported | uncertain`. If uncertain, do not write until the type/field is found in the installed package.
3. Never guess class names, serialized fields, paths, or GUIDs. Verify exact types via `unityMCP_unity_reflect` and read serialized fields via `SerializedObject`/`FindProperty` (check for null before reading).
4. Never edit files under `Library/PackageCache/` or immutable package sources. Do not modify imported BOOTH content in place.

## Standard workflow (add an outfit/hair)

1. Put the model under `Clothes/<outfit>/` (or `Hair/<outfit>/`).
2. Independent armature? → add the MA set: **MergeArmature** on its armature (`mergeTarget` = avatar main Armature) + **MeshSettings** (RootBone/ProbeAnchor to main armature). Verify bone mapping resolves. Rigid accessory with its own small bone system → **BoneProxy** on the accessory root pointing at the target avatar bone. Do not use OutfitRoot for plain accessories.
3. In `_MA_Menu/<Clothes|Hair Menu>`, create the outfit submenu with `ModularAvatarMenuItem` `Control.type=SubMenu`, `MenuSource=Children`.
4. Add the **`all`** master toggle:
   - MenuItem Toggle, `param=cloth` (or `hair`), distinct `value`.
   - MA ObjectToggle → references the outfit root container, `Active=true`.
   - **`automaticValue=false` + manual value on every outfit (including default)** — otherwise mutual exclusion silently breaks (see gotchas).
5. Part toggles: group into 上装/下装/饰品/鞋 (or per hair part) submenus to stay under VRChat's 8-control limit. Each part toggle: MenuItem Toggle (param empty → MA auto param) + ObjectToggle with `Active=false` (activating the toggle hides the part).
6. Default outfit's `all` gets `isDefault=True`.
7. Container stays `active=False` in the scene.
8. Chinese menu names written via Unicode escapes when using codegen (raw Chinese becomes `?`).
9. Validate with `AvatarProcessor.ProcessAvatar()` on a clone (PROVIDER_PREVIEW) or `ProcessAvatarUI()`, check Console, save scene.

## MA component decision guide (quick)

- Skinned outfit with its own armature → **MergeArmature** (+ MeshSettings for RootBone/ProbeAnchor).
- Rigid accessory attached to a bone (glasses, hats, props, contacts) → **BoneProxy**.
- Hierarchy expression control → **Menu Item** (+ Menu Installer / parent MenuSource=Children).
- Custom animator/expression parameters → **Parameters**.
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

- [ ] Outfit containers `active=False` in scene; default outfit enabled via `isDefault=True` on the built clone.
- [ ] `cloth`/`hair` params are **Int** with default value = default outfit's value (not 0).
- [ ] All `all` toggles: `automaticValue=false`, distinct values; no two outfits share a value.
- [ ] Submenus ≤ 8 controls each (no accidental `More` overflow).
- [ ] ObjectToggle `referencePath` set to full avatar-relative path (e.g. `Clothes/Default/Cardigan`) and `targetObject` set; resolved target is not null.
- [ ] Target nodes are `Untagged`, not `EditorOnly` (EditorOnly nodes are stripped by the build).
- [ ] Commercial module anim bindings resolve (0 broken paths).
- [ ] SMR bones point at the main Armature (not an old prefab armature).
- [ ] Parameter names/types/defaults/saved/synced are intentional; no duplicate/conflicting declarations.
- [ ] Console has no new errors/warnings vs. baseline.
- [ ] Scene saved.

## Full detail references

- `references/habits.md` — 套装化/互斥/菜单/参数/编码 habits, the complete add-outfit runbook, commercial module integration, BoneProxy accessories, Chinese naming rules.
- `references/gotchas.md` — every known pitfall: EditorOnly stripping, ObjectToggle `referencePath`, automaticValue mutual-exclusion trap, SMR bone rebinding after moves, animation path breakage after reparenting, multi-avatar scenes, shared asset behavior.
- `references/component-guide.md` — MA component decision guide (MergeArmature / BoneProxy / Menu / Parameters / MergeAnimator / BlendshapeSync / reactive / MeshSettings / platform filters).
- `references/source-policy.md` — version discipline and authority order.
- `references/safety-validation.md` — approval boundaries, rollback, validation checklist, evidence standard.
- `references/workflows.md` — task workflows (install outfit, attach accessory, add toggle, material variant, blendshape sync, hide clipping, merge animator, troubleshoot build).
- `references/unity-mcp-playbook.md` — read-only discovery and safe-write sequences through Unity MCP.
- `references/version-notes.md` — MA version snapshot (check installed version before trusting).
- `references/official-sources.md` — official MA documentation links.
- `scripts/` — local package inspection helpers (inspect-modular-avatar, find-ma-symbol). For local files only.