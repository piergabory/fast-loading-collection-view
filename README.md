# FastCollection
Technical demonstration for a SwiftUI photo library with smooth loading.
Photos are paired by front/back facing camera like in the BeReal social network. 
To efficiently load thousands of photos, assets are pre-baked off the main thread 
using `UIGraphicsImageRenderer`. 

There are then two levels of cache:
- Memory cache, fast, needs to be reloaded on restart
- Storage cache, persistent, but too slow when scrolling really fast.

The cache can be warmed-up before loading the view to maximise the chance of 
hitting the memory cache.

The first screen is equiped with controls and live statistics to experiment with
cache loading. 

| Main Screen                          | Gallery                             |
|--------------------------------------|-------------------------------------|
| ![Main Screen](Screenshots/Main.png) | ![Gallery](Screenshots/Gallery.png) |
|                                      |                                     |

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
Your Immich library must contain tags with the exact values `BeReal/front` and `BeReal/back` respectively assigned to front-facing and back-facing cameras of a smartphone.

## Run
Open `FastCollection/FastCollection.xcodeproj`, select the `FastCollection` scheme, and run the app.

## Roadmap
- [x] Add corner radius to the thumbnails. (ish. I cheated eheh)
- [x] Run new prefetching jobs when the user reaches the last 200 cached assets
- [x] Minor Refactoring:
  - [x] Reword some types (PostLoader, PageLoader, PostStore... that's messy)
  - [x] Factorise the image and post metadata disk caches with a generic type
- [ ] Add a priority property to cached assets. The expected spread of asset request is likely following an inverse exponential of some kind, where the first ones display much more often. Adding a priority value would be useful for some optimisation:
  - [ ] Handle memory and storage pressure, dropping the lower priority assets first
  - [ ] Organise concurrent cache warmup processing with a prioqueue.
