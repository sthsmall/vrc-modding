# Version notes snapshot

This is a discovery aid, not a permanent source of truth.

Checked 2026-08-02:

- Latest stable release observed: **1.17.1**.
- Pre-release observed: **1.18.0-alpha.0**.

Notable recent features/changes observed in official release notes:

- 1.17.0 added Floor Adjuster.
- 1.17.0 added a Match scale option to Bone Proxy.
- 1.17.0 added multi-select in relevant blendshape pickers.
- 1.17.0 added VRCRaycast component/parameter support to Parameters.
- 1.17.1 adjusted Floor Adjuster execution order relative to TexTransTool and some NDMF plugins.
- 1.18.0-alpha.0 added curve-based remapping for Blendshape Sync and improved Mesh Cutter performance.

Do not assume any of these features exist unless the installed package version/source confirms them. Pre-release APIs and behavior may change incompatibly.

## Verified in this project (catlee.kuuta, 2026-09-02)

Installed: **Modular Avatar 1.18.7** (embedded), NDMF 1.14.8, VRCSDK 3.10.4, Unity 2022.3.22f1.

Behavior confirmed against the installed source (`unityMCP_unity_reflect` + serialized fields):

- `ModularAvatarMenuItem`: `Control.type` enum values are `Button=101 / Toggle=102 / SubMenu=103` — `SerializedProperty.enumValueIndex` is 0-based (0/1/2), NOT the raw value. Set via `SerializedObject.FindProperty("Control.*")`.
- `MenuSource`: `MenuAsset=0 / Children=1`; `menuSource_otherObjectChildren` overrides the children source.
- `ModularAvatarObjectToggle`: field `m_objects` = `ToggledObject{Object(AvatarObjectReference), Active}`. `AvatarObjectReference` serializes as `referencePath` + `targetObject` (private); write `Object.targetObject` / `Object.referencePath` via SerializedProperty.
- `ModularAvatarShapeChanger`: `m_shapes` = `ChangedShape{Object, ShapeName, ChangeType, Value}`, `m_threshold` (~0.01 default).
- Empty-param MenuItem + `automaticValue=true` → MA auto-creates Bool `__MA/AutoParam/<name>$hash` (saved+synced). A `cloth` param on a Toggle auto-generates as **Bool** — adequate for one outfit; must become Int (via Parameters or explicit) before adding a second.
- **Mutual exclusion with `automaticValue=true` works when `cloth` is explicitly declared Int**: with `ModularAvatarParameters` declaring `cloth` (Int, defaultValue=1) and each outfit's `all` MenuItem holding a manual `Control.value` (1/2/...), MA builds `cloth` as Int def=1 and toggles the correct container — `automaticValue` may stay `true`, it does not break exclusion (verified on 2-outfit avatar).
- **MA auto-promotes an un-declared param to Int at ≥3 distinct auto values**: with NO explicit declaration, 2 auto toggles on `cloth` build as Bool (values forced to 0/1); adding a 3rd auto value promotes `cloth` to Int, but values are auto-assigned from 0 (0/1/2) and defaultValue binds to the FIRST declared toggle — not the manual values, and def may not be the intended default outfit. Explicit Int declaration via MA Parameters is still the more controlled route for multi-outfit exclusion.
- **Commercial module part toggles**: binding the module's own Bool params (`coat_off` etc.) via MenuItem (`automaticValue=false`, fixed param name) works without re-declaring them; the module's controller drives them. Removing the module's own `ModularAvatarMenuInstaller` stops its menu from installing at the avatar top level.
- `AvatarProcessor.ProcessAvatar(GameObject)` (nadena.dev.modular_avatar.core.editor) runs the full build on the given object — use on an `Instantiate`d clone for PROVIDER_PREVIEW validation.
