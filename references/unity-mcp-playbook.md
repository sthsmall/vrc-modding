# Unity MCP playbook

Exact tool names vary by MCP for Unity version. Use only tools actually injected into the current Agent.

## Read-only discovery sequence

1. List connected Unity instances/resources.
2. Select the intended project instance when multiple editors are open.
3. Read active scene and dirty state.
4. Search for `VRCAvatarDescriptor` components.
5. Inspect target hierarchy, prefab instance status, and components.
6. Search for components whose namespace/type/display name indicates Modular Avatar or NDMF.
7. Read Console errors/warnings.
8. Capture Scene/Game view only when visual inspection is useful and image results reach the vision model.

## Safe write sequence

1. State exact target and intended component/asset.
2. Create a wrapper/module object if possible.
3. Add one component or perform one coherent change.
4. Set fields using actual object references/serialized properties discovered from the installed version.
5. Re-read the component.
6. Mark dirty through Unity APIs; do not save yet unless approved.
7. Run preview/validation and inspect Console.
8. Ask before save/prefab apply/build/upload when approval is required.

## Prompt template

```text
Load the vrc-modding skill and use only native unityMCP_* tools for Unity operations.
Do not call the MCP endpoint through Python, curl, PowerShell, or raw JSON-RPC.
First inspect the installed Modular Avatar version and exact target objects.
Do not guess class names, serialized fields, paths, or GUIDs.
Perform read-only discovery, report the proposed modification and rollback method,
and wait for approval before destructive writes.
```

## When a generic Unity tool is too low-level

If the MCP can only execute arbitrary C# and cannot reliably set the needed component:

1. Generate a minimal Editor script under a custom project folder.
2. Use `Undo.RegisterCreatedObjectUndo`, `Undo.AddComponent`, and `Undo.RecordObject`.
3. Resolve component types through compile-time references or reflection against installed assemblies.
4. Fail loudly when a field/property is missing; never silently skip.
5. Run through Unity, inspect Console, verify the result, then remove the temporary script if approved.

Never use a script to directly call the MCP server. The script may automate Unity Editor APIs only.
