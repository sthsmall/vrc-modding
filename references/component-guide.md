# Modular Avatar component decision guide

Names below are inspector/display names. Resolve exact C# type and serialized fields from the installed package.

## Merge Armature

Use for a skinned outfit or asset with its own armature that should merge into the avatar's armature.

Inspect first:

- outfit armature root and avatar merge target;
- matching bone names, prefixes, and suffixes;
- root transform, scale, and pose differences;
- SkinnedMeshRenderer bones/rootBone references;
- PhysBone, Contact, Constraint, and animation references;
- existing nested Merge Armature components.

Do not use for a rigid one-bone accessory. Do not assume clothes made for a different avatar will fit merely because bones can be matched.

## Bone Proxy

Use when a rigid module object should move under an existing avatar object/bone while retaining portable references.

Typical uses:

- glasses, hats, earrings, props;
- contacts/colliders attached to hands or body bones;
- avatar-agnostic accessories using humanoid-bone targets.

Check attachment mode, position/rotation preservation, and scale behavior. Do not use as a replacement for Merge Armature on skinned clothing.

## Menu Item, Menu Installer, Menu Group

Use hierarchy objects to define expression controls and install them into an avatar menu.

**Binding rules**: MenuItems are only installed when they are (a) on the same node as a Menu Installer, (b) a direct child of a Menu Group (usually on the Installer node), or (c) children of a parent MenuItem in `MenuSource=Children` mode. A MenuItem with no Installer/MenuGroup/parent chain is **unbound** and silently ignored — check binding when a built menu is missing items.

Menu Installer default installs at the avatar expressions-menu top level. To let MA fully own the root menu: create an empty `VRCExpressionsMenu` asset, point AvatarDescriptor `expressionsMenu` at it, and set the Installer `menuToAppend` to null. The stock menu must then be folded in manually (原有菜单 submenu referencing original assets) or it is lost.

Check:

- whether the item is actually bound to a target menu;
- control type and value;
- submenu source (`Children` versus menu asset);
- parameter name/type/default;
- duplicate defaults and menu-page overflow;
- icon asset compatibility.

A Menu Item may automatically create a parameter when one is not otherwise declared. Auto-created params (`__MA/AutoParam/...`) are preferred; use an explicit Parameters component only when saved/synced/default/Int semantics matter.

## Parameters

Use for custom animator/expression parameters with explicit semantics — but only when auto-generation is insufficient. **Auto-first**: an empty `param` + `automaticValue=true` MenuItem makes MA create `__MA/AutoParam/<name>$hash` automatically; reuse the avatar's original Parameters asset where possible. Prefer `ModularAvatarParameters` when:
- mutual exclusion needs explicit Int values (2+ outfits sharing `cloth`/`hair`);
- a reusable module must ship its own saved/synced/default/rename semantics;
- a param must be local-only, prefixed, or animator-only.

Check:

- Bool/Int/Float/Animator Only/Prefix semantics in the installed version;
- saved and synced flags;
- default and animator-default override behavior;
- auto-rename/local-only behavior;
- duplicate names and parameter budget;
- PhysBone/contact/raycast prefix usage where supported.

Never infer parameter type from a menu control alone; inspect all animations and drivers that reference it. Remember: single-outfit `cloth` auto-generating as Bool is fine; promote to Int via Parameters when a second outfit arrives.

## Merge Animator

Use to merge a controller into an avatar playable layer without editing the original controller directly.

Check:

- target playable layer;
- path mode and animation-binding paths;
- parameter declarations;
- Write Defaults policy;
- layer control/state behavior references;
- animator masks and default states;
- ordering relative to other modules.

## Merge Motion / Merge Blend Tree

Use for simple motion/blend-tree merging when it accurately represents the behavior. Verify the installed component name and restrictions. Avoid forcing complex state-machine behavior into a blend tree.

## Blendshape Sync

Use when a target renderer's blendshape should follow a source renderer's corresponding blendshape.

Check:

- exact source and target renderers;
- exact blendshape names and existence;
- direction of sync;
- chains (avoid A→B→C unless supported);
- whether eye-look or viseme behavior can be represented accurately;
- curve/remapping support in the installed version.

## Reactive components

Reactive components respond to an object's active state or associated menu state. Inspect the current Reactive Component rules and use the Reaction Debugger where available.

### Shape Changer

Use to set body blendshapes while an outfit/module is active, commonly to shrink or hide body regions under clothing.

Do not use it to fight other animations that continuously animate the same blendshape. Validate threshold/delete behavior and preview the result.

### Mesh Cutter

Use to delete or hide selected polygons, with one or more vertex filters.

Filter choices may include:

- mask texture;
- axis/plane;
- bone weights;
- blendshape movement.

Prefer a mask for precise cuts. Axis filters are better for rough sides/regions. If the entire renderer should disappear, use an object toggle instead.

### Object Toggle

Prefer for enabling/disabling complete objects or renderers. It is cheaper and easier to validate than processing an entire mesh through Mesh Cutter.

### Material Swap / Material Setter

Use to replace whole materials or set renderer material slots reactively. Verify exact semantics and material-slot matching against the installed version. Create copies of user-editable materials instead of modifying imported originals.

## Mesh Settings

Use for shared renderer settings such as bounds and probe-anchor consistency. Inspect whether settings are inherited through the object hierarchy and whether another avatar optimizer/build plugin modifies the same properties.

## Scale/Floor adjustment

Use Scale Adjuster or Floor Adjuster only after checking the installed version and plugin execution order. Validate viewpoint, feet/floor alignment, PhysBones, contacts, constraints, and outfit fit after scaling.

## Platform Filter and per-platform work

Use platform filtering only when the project intentionally has desktop/mobile differences. Validate both branches and any VRChat per-platform override avatars; never assume the inactive platform path is valid.
