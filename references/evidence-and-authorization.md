# Evidence, authorization, and ownership boundaries

Borrowed and adapted from the `inspect-vrchat-avatar-project` skill. Use when a conclusion may cross from source inspection into previews, builds, runtime tests, or when a change touches shared or generated assets.

## Evidence ladder

Label every material conclusion with the narrowest layer actually run.

| Label | What it can prove | What it cannot prove |
| --- | --- | --- |
| `STATIC_SOURCE` | Serialized references, literal values, asset identity, declared configuration | Imported semantics, prefab-instance resolution, merged output, runtime behavior |
| `UNITY_RESOLVED` | Current imported objects, component fields, active state, prefab overrides, exact hierarchy via the selected Unity MCP instance | Final NDMF output or VRChat runtime behavior |
| `PROVIDER_PREVIEW` | Provider-visible source inventory or virtual/preview state (e.g. `AvatarProcessor.ProcessAvatar()` on a clone) | Final SDK artifact when later passes can still transform it |
| `NDMF_BUILT` | Merged/generated avatar, menu, parameters, controllers, meshes, components after registered passes | SDK bundle limits or client behavior unless those layers were also run |
| `SDK_BUILD` | SDK validation and the exact generated bundle or final parameter asset | Desktop, VR, multiplayer, or upload behavior |
| `CLIENT_RUNTIME` | Behavior in the named test environment (Gesture Manager, Play Mode, Build & Test, desktop, VR, multiplayer) | Other clients, hardware modes, networking, or upload unless separately tested |
| `UPLOAD_CONFIRMED` | Observed behavior of the explicitly authorized uploaded avatar | Unobserved clients or later edits |

Use the narrowest label supported by current evidence. A newer lower-layer result does not replace an older higher-layer result, and an older higher-layer result does not prove the current source.

## Status language

- `PASS` - executed layer whose acceptance criteria were met.
- `NOT_RUN` - layer not attempted.
- `BUILD_REQUIRED` - source evidence cannot answer a generated-state question.
- `MCP_REQUIRED` - claim requires Unity Editor state but no usable Unity MCP instance is connected.
- `BLOCKED` - attempted layer could not produce reliable evidence.
- `STALE` - dated evidence invalidated by a refresh trigger.
- `AMBIGUOUS_TARGET` - build, cache, or duplicate object cannot be associated with exactly one avatar.

Name blockers precisely: unavailable/ambiguous Unity MCP instance, dirty scene, project lock, compile failure, missing Unity license, tool exception, missing completion marker, ambiguous target, absent authorization.

## Validate in proportion to the claim

- For a literal serialized change: static diff plus Unity import/compile when import occurred.
- For a resolved component or prefab claim: the selected Unity MCP instance.
- For merged menus, parameters, Animator layers, optimized meshes, or generated components: the NDMF/provider build output.
- For visual, audio, gesture, Contact, PhysBone, Blink, Lip Sync, eye tracking, or synchronization behavior: the exact authorized runtime layer.
- For parameter limits: prefer SDK/provider APIs over hand arithmetic. Keep source estimates separate from final built cost.
- For bundle limits: use the exact current build. Do not infer size from scenes, FBX files, textures, or a structurally similar avatar.
- Treat values close to a hard platform limit as ordinary within-limit results. Do not prompt for optimization unless a hard limit is exceeded or the user explicitly requests optimization.
- Do not call an unrun layer `PASS`. Report it as `NOT_RUN`, `BLOCKED`, or `BUILD_REQUIRED`.

## Authorization matrix

| Request wording | Normally authorized | Not automatically authorized |
| --- | --- | --- |
| Inspect, explain, audit, compare, diagnose | Read files, inspect live state, perform non-mutating diagnostics | Save, Apply, import/refresh, Play Mode, build, upload |
| Fix, change, remove, migrate | Narrow source edits, affected audit-document updates, proportional import/compile validation | Build & Test, fresh size probes/builds, publish/upload |
| Add or import a feature/plugin | Narrow installation, source edits, import/compile validation, documentation of menu/parameters/footprint | Fresh SDK size build, Build & Test, publish/upload unless separately authorized |
| Update texture/material/shader/mesh/visual animation | Narrow asset/source edits, importer validation, shared-consumer audit | Fresh SDK size build, client visual acceptance, publish/upload unless separately authorized |
| Preview or test | The named preview/runtime layer and its normal reversible setup | Upload or unrelated project cleanup |
| Build | The named build for the exact target | Upload; destructive source changes; assuming Build & Test enforces upload limits |
| Check avatar size | Read relevant size guide, run needed report/cache probe or exact size build for the named target | Upload or applying the result to a different avatar |
| Upload or publish | Only the exact confirmed avatar and platform after preflight | Selecting a target by guess or uploading another active descriptor |

When the requested action can overwrite unsaved scene work, modify a shared source, or affect multiple consumers beyond the named target, stop and obtain the missing decision.

## Shared and generated ownership

Before a change, classify the target as one of:

| Boundary | Source of truth | Typical contents | Safe default |
| --- | --- | --- | --- |
| Scene override (instance) | The exact scene instance and its prefab modifications | Active state, local transform, added/removed component, overridden reference | Edit only the named instance after mapping its prefab and consumers. Do not assume the prefab asset changes. |
| Shared asset | The referenced asset file | Prefab, menu, parameters, controller, clip, material, mesh, or texture used by multiple roots | Map every consumer first. A change is a multi-consumer change unless isolation is proven. |
| Editable generator source | The provider component, source prefab, configuration asset, or stable user clip | MA components, optimizer settings, commercial module configs | Edit the source supported by that provider, then regenerate through its documented path. |
| Generated output | The provider's generated controller, menu, parameter asset, merged component, optimized result | Timestamped tool output, NDMF result, merged Animator, optimized mesh/material | Inspect or diff it, but do not edit it as the source of truth. Regenerate from source. |
| Build clone | A temporary avatar clone made for preview or SDK build | NDMF preview clone, SDK build copy, test-only hierarchy | Treat as disposable. Record the exact source fingerprint and target; never copy changes back by guessing. |
| Cache | A tool or editor cache | Library, Temp, SDK build cache, provider cache, stale report | Diagnostic only. It may be stale or match more than one avatar. |

Prefab overrides, added/removed components, inactive objects, and asset GUIDs belong to the boundary where they are stored. Ownership follows the write path, not the object name.

### MA/NDMF provider ownership notes

- Editable source is the component or source prefab that declares menu items, parameters, merge Animators, bone proxies, armature/object changes.
- NDMF resolves order, remapping, deduplication, and generated names during preview/build. The merged clone is not a replacement for the source component.
- Changes to a shared source prefab or menu can affect every avatar that consumes it. Isolate the source before making a one-avatar change.
- Use provider preview for the source inventory and `NDMF_BUILT` for final merged menu, parameter, Animator, mesh, and component claims.

### Generated-output editing policy

Do not edit timestamped or tool-owned generated output from MA/NDMF, FaceEmo, lilycalInventory, DressingTools, Avatar Optimizer, or a SDK build. Generated output may be regenerated, renamed, cleaned, or replaced, and a hand edit is not a durable fix.

The narrow exception is an explicit, documented tool handoff that declares a particular export user-editable and non-regenerated, with all conditions: the exact artifact is isolated from shared consumers, the user authorized the edit, regeneration/ownership behavior is recorded, and the result is saved as a stable source or documented input for the next build. If any condition is missing, inspect or diff the output and change the editable source instead.

## Failure and retry behavior

After a timeout or unclear response, inspect durable evidence first: Editor state, Console, source changes, scene dirty state, produced artifacts. Do not blindly repeat a mutation that may already have succeeded. Stop after two materially identical failures and report the exact attempted layer, the last proven state, and the smallest user/environment action needed to continue.