# Task workflows

## A. Install a compatible outfit

1. Detect avatar root and outfit prefab instance.
2. Confirm the outfit is intended for the target avatar/version.
3. Record prefab and scene state; do not alter imported source prefab.
4. Put custom wrapper/module objects under a user-owned folder/hierarchy.
5. Inspect outfit armature, renderer bones, rootBone, materials, blendshapes, PhysBones, contacts, and constraints.
6. Add/configure Merge Armature on the correct source armature root after resolving exact fields.
7. Verify merge target, prefix/suffix, position-lock options, and name-collision behavior.
8. Add Blendshape Sync entries only where source and target shapes both exist.
9. Add Shape Changer or Mesh Cutter only for actual clipping regions; prefer non-destructive body changes.
10. Add menu/parameter controls for outfit visibility if requested.
11. Preview in edit/play mode, test several body poses, inspect Console, and run build validation.

Stop if bone names, rest pose, or weight mapping show that the outfit needs Blender work.

## B. Attach a rigid accessory

1. Identify the desired humanoid bone or stable target path.
2. Create a module object/prefab outside imported content.
3. Position the accessory and establish intended world/local pose.
4. Add Bone Proxy and select appropriate attachment and scale behavior.
5. Test avatar bone movement, scale changes, and mirror/left-right assumptions.
6. If toggleable, add a hierarchy menu control and verify parameter declaration.

## C. Add an object toggle

1. Identify the exact target object(s) and desired default state.
2. Choose a unique parameter name and determine Bool/Int semantics.
3. Prefer Menu Item plus reactive object behavior when sufficient.
4. Use Parameters for explicit saved/synced/default/rename behavior.
5. Verify no existing animator, parent active state, or build plugin overrides the target.
6. Test on/off/default states and menu installation path.

## D. Add a material variant

1. Duplicate materials into a custom asset directory; preserve originals.
2. Verify shader and texture dependencies.
3. Choose Material Swap/Setter or an animator-based module according to installed support.
4. Map each renderer/material slot explicitly.
5. Verify fallback behavior and mobile/platform shader differences.
6. Test all variants and inspect generated animation/material references.

## E. Synchronize body and outfit blendshapes

1. Enumerate source/target renderer blendshape names and indices.
2. Build an explicit mapping table.
3. Reject mappings that rely only on similar names without visual verification.
4. Add Blendshape Sync entries.
5. Check whether values are copied directly or remapped by a curve in the installed version.
6. Test representative values: 0, 50, 100, and any negative/over-100 values used by the avatar.
7. Verify visemes, blink/eye-look, and animated shapes separately.

## F. Hide body clipping

Decision order:

1. Entire body renderer covered → object toggle.
2. Existing body hide blendshape → Shape Changer.
3. Precise permanent/dynamic polygon region → Mesh Cutter with suitable filters.
4. Topology/weights fundamentally wrong → Blender edit rather than increasingly complex MA rules.

Always test extreme poses and body customization blendshapes.

## G. Merge an animator/gimmick

1. Inspect controller layers, parameters, animation bindings, state behaviors, masks, and Write Defaults.
2. Ensure every custom parameter is declared intentionally.
3. Select correct playable layer and path mode.
4. Add Merge Animator to a self-contained module.
5. Validate layer ordering and references after build.
6. Test parameter defaults, transitions, interruption, and reset behavior.

## H. Troubleshoot build errors

1. Save the exact pre-existing Console baseline.
2. Reproduce with the smallest module enabled.
3. Use stack trace and NDMF build report to identify plugin/pass/component.
4. Inspect references for missing objects, prefab-stage paths, unsupported component combinations, and version mismatches.
5. Compare installed MA/NDMF/VRCSDK/VRCFury versions with official compatibility notes.
6. Disable or duplicate the suspect module; do not delete original assets.
7. Rebuild and compare new errors.
8. Report root cause, evidence, and reversible fix.
