# Source policy and version discipline

## Authority order

Use information in this order:

1. `Packages/manifest.json`
2. `Packages/packages-lock.json`
3. Installed package `package.json`
4. Installed package C# source, inspectors, samples, and bundled documentation
5. Official documentation matching the installed version
6. Official GitHub release notes and changelog
7. Community material only as a lead to verify against official sources/source code

## Why the installed package wins

A Unity project may use:

- a stable VPM release;
- a beta or alpha release;
- a Git URL pinned to a branch, tag, or commit;
- a local package;
- an embedded package;
- a package cache resolved from an older lock file.

The latest website may describe fields or behavior that do not exist in the project. Never apply a current web example without checking the installed type and editor code.

## Package locations

Common locations include:

```text
Packages/<embedded-or-local-package>/
Library/PackageCache/<package-id>@<version>/
```

Git and VPM package details are recorded in `Packages/packages-lock.json`. Do not edit package-cache files.

## Web access policy

Use the web for:

- conceptual explanations;
- official tutorials;
- changelog and migration notes;
- confirming when a feature was introduced;
- resolving behavior not clear from source.

Do not browse for every routine action. Do not copy entire documentation pages into context. Load the smallest relevant page.

## Version statement

Before using a feature introduced recently, state:

```text
Installed MA version: X
Documentation/release version consulted: Y
Compatibility conclusion: supported / unsupported / uncertain
```

If uncertain, do not perform the write operation until the type/field is found in the installed package.
