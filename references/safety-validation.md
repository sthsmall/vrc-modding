# Safety, approval, and validation

## Always require explicit approval before

- deleting GameObjects or assets;
- applying/reverting prefab overrides broadly;
- modifying imported source prefabs, controllers, textures, materials, or meshes;
- saving a scene/prefab when the user asked only for inspection;
- upgrading packages or Unity;
- running destructive mesh/bone conversion;
- publishing, uploading, or overwriting a VRChat avatar;
- changing Blueprint IDs or pipeline settings;
- running unknown code from downloaded assets.

## Usually safe as read-only

- reading manifests, lock files, package source, docs, and changelogs;
- listing hierarchy, components, materials, animator layers, and parameters;
- reading Console and build reports;
- capturing Scene/Game view;
- calculating parameter cost and mapping tables.

## Rollback requirements

Before a write, identify at least one rollback method:

- Unity Undo;
- delete a newly created module object;
- remove a newly added MA component;
- restore a copied asset from version control;
- discard un-applied prefab overrides;
- restore a project backup.

## Validation checklist

### Object/reference integrity

- No missing scripts or object references.
- Target objects still exist after prefab/build transformation.
- Component references point to intended avatar/module objects.
- Prefab overrides are limited and understandable.

### Armature and mesh

- Correct rootBone and bone mappings.
- No unexpected duplicate bones.
- Scale and pose are consistent.
- No new severe clipping in representative poses.
- Bounds and probe anchors are reasonable.

### Animator/menu/parameters

- Unique parameter names and matching types.
- Saved/synced/default flags are intentional.
- Parameter budget remains acceptable.
- Menu items are installed and reachable.
- Default and reset behavior works.
- Write Defaults and layer ordering match project policy.

### Build pipeline

- MA/NDMF preview produces expected result.
- No new Console errors relative to baseline.
- Build report has no unresolved fatal items.
- Desktop/mobile/per-platform variants are validated when applicable.
- VRChat SDK Build & Test is performed before upload when requested.

## Evidence standard

Do not claim success only because a tool returned `success`. Verify by re-reading state, previewing/building, and checking Console.
