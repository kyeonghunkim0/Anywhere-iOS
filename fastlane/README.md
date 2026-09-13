fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios check_api_key

```sh
[bundle exec] fastlane ios check_api_key
```

Verify that the App Store Connect API Key configurations are valid

### ios clean

```sh
[bundle exec] fastlane ios clean
```

Clean the build artifacts and cache using Tuist

### ios generate

```sh
[bundle exec] fastlane ios generate
```

Generate the Xcode project and workspace using Tuist

### ios build

```sh
[bundle exec] fastlane ios build
```

Build the application target for the iOS Simulator

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload the application to TestFlight

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload App Store screenshots only (from fastlane/screenshots/<locale>/)

### ios release

```sh
[bundle exec] fastlane ios release
```

Build and submit the application to App Store Connect

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
