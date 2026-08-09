# Anywhere

## Requirements

- Xcode 26.5+
- [Tuist](https://tuist.dev) 4.203.4+
  - Older versions (tested down to 4.103.0) fail to resolve explicit
    module dependencies for Objective-C-heavy SPM packages (e.g.
    Firebase, GoogleSignIn) under Xcode 26's explicit module builds —
    `import X` fails with `unable to resolve module dependency`.
    Upgrade with `brew upgrade tuist` before generating the project.

## Setup

```sh
tuist install
tuist generate
```
