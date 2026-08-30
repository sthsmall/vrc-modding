# 常见坑（gotchas）

Every known pitfall from the modding workflow, with symptom → root cause → fix.

## 1. EditorOnly tag strips nodes at build

- **Symptom**: a whole category of nodes vanishes after build while menus/params/toggles all work.
- **Cause**: `EditorOnly` tag (or a folder marked EditorOnly) — silently strips the entire subtree at build; stripped objects get no responsive layer.
- **Fix**: ensure containers and target nodes are `Untagged`. When "everything of type X disappeared after build", check the container/parent tag first.

## 2. ObjectToggle referencePath must be complete

- **Symptom**: ObjectToggle silently does nothing.
- **Cause**: `referencePath` empty/wrong.
- **Fix**: set the full avatar-relative path, e.g. `Clothes/Default/Cardigan`, and `targetObject`.

## 3. automaticValue trap (mutual exclusion silently breaks)

MA's default-value logic (ParameterAssignerPass): only an item that is `isDefault && !automaticValue` becomes the param's default value.

- **isDefault + automaticValue=true** in a mutual-exclusion group → param defaults to **0** → nothing is worn on load.
- **non-default item with Bool/Float param** → MA forces value=1 → two outfits on at once, cannot switch.
- **Int params** → MA auto-assigns increasing values (accidental mutual exclusion).

Symptoms: two `all` toggles both end up value=1; clicking an outfit doesn't switch; built `cloth`/`hair` param is Bool instead of Int; nothing worn on startup.

**Fix**: every outfit's `all` (default included) sets `automaticValue=false` + a manual distinct value (Default=1, next=2...). Default outfit additionally `isDefault=true` so its value becomes the param default.

Verify after build: `cloth`/`hair` are **Int**, default value = default outfit's value (not 0), default container active, others inactive.

## 4. Chinese in codegen becomes `?`

codedom/C#6 with raw Chinese characters writes `?` garble. Always use Unicode escapes (`\u4E0A\u88C5`). Verify with base64.

## 5. SMR bone references break after moving nodes

- **Symptom**: a skinned mesh (often cloned from a prefab) stops following the body after reparenting.
- **Cause**: SMR `bones` still point at the old prefab armature, not the avatar's main Armature.
- **Detect**: count bones whose parent chain reaches the main Armature (was `0/222` broken).
- **Fix**: rebuild `smr.bones` by name from the main Armature; set `smr.rootBone` = `AutoAnchorObject`. Verify `222/222` under main Armature and check the actual references, not just names.

## 6. FX anim paths break after reparenting

Regrouping nodes breaks FX clips that bind old root paths (`path: Cardigan` → `path: Clothes/Default/Cardigan`). Rewrite bindings for all clips reachable from the FX controller. Slider layers stay in FX; toggles move to MA (delete the old FX toggle layers to avoid double control).

## 7. Multi-avatar scenes

- Don't hard-code avatar names in scripts (`root.Find("mango.milfy.26.08.05")` breaks on rename); locate the **active** avatar dynamically.
- NDMF build of an **inactive** avatar is unreliable (missing SMRs etc.) — activate the target before building.
- Shared expression assets across avatars: MA generates per-clone copies at build; the original shared assets are untouched — that's normal, not parameter loss.
- Keep one working copy (latest version) and treat older ones as backups.

## 8. Commercial modules and auto-generated NDMF menus

- Module MenuInstaller activates as long as a MenuItem is on the same node — menu may appear duplicated; fold it under your menu instead of deleting.
- NDMF plugin assets (LightController) generate menus at build — no manual menu needed.
- Verify generated menus don't collide.

## 9. Chinese menu renames that break functions

- Do NOT rename nodes with `ModularAvatarObjectToggle` + empty param (auto param changes, breaks the toggle).
- Do NOT rename empty-param sliders (Front Length / Twintail Length).
- Keep brand names English (Nova/@MA_Lili/GLEIPNIR/KnitNoise/Default) and commercial module internals untouched.
- Safe to rename: fixed-param items (`Nail`/`Face`/`FHSharp`), `all` masters (cloth/hair), KumaPhone.

## 10. Leftover/stale menu items

- After moving nodes, old group references go stale — delete leftover groups or update references.
- Watch for stray bare-named items (e.g. a `GameObject`-named item in a 鞋 submenu) from rename mistakes.
- Check group names still match contents after regroup.
