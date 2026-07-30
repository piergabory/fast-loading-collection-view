# FastCollection

A small SwiftUI app that connects to an Immich library and displays photo counts for the `BeReal/front` and `BeReal/back` tags.

## Requirements

- Xcode 26 or later
- An Immich server accessible from the target device
- An Immich API key with permission to read tags and search assets

## Configuration

1. Copy `FastCollection/Secrets.swift.example` to `FastCollection/FastCollection/Secrets.swift`.
2. Set your Immich server URL, user ID, and API key in the new file:

```swift
import Immich

struct ImmichSecrets: Secrets {
    let serverURL = "https://photos.example.com/api"
    let ownerID = "your-immich-user-id"
    let apiKey = "your-immich-api-key"
}
```

The server URL must include the `/api` path. `Secrets.swift` is excluded from Git and automatically included in the Xcode project.
Your Immich library must contain tags with the exact values `BeReal/front` and `BeReal/back`.

## Run
Open `FastCollection/FastCollection.xcodeproj`, select the `FastCollection` scheme, and run the app.

## Code Quality
The project pins [`swiftlang/swift-format`](https://github.com/swiftlang/swift-format), the first-party formatter used by SourceKit-LSP.
The compiler uses Swift 6 mode, complete concurrency checking, strict memory safety, and treats warnings as errors. A pre-compilation build phase runs `swift-format lint --strict`, so unformatted code fails the build.
To format the project, use **File > Packages > Format Source Code** in Xcode. To check formatting without modifying files, use **File > Packages > Lint Source Code**. Trust each package plugin when Xcode prompts for permission.
Xcode does not provide package plugins with an on-save event. Automatic format-on-save therefore cannot be configured reliably inside the project. The command plugin is the first-party, project-configured option.
