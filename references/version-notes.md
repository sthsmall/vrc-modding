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
- `AvatarProcessor.ProcessAvatar(GameObject)` (nadena.dev.modular_avatar.core.editor) runs the full build on the given object — use on an `Instantiate`d clone for PROVIDER_PREVIEW validation.
