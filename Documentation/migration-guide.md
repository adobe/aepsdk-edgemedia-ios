## Migrating from AEPMedia to AEPEdgeMedia

This is the complete migration guide from AEPMedia to AEPEdgeMedia SDK.

| Quick Links |
| --- |
| [Configuration](#configuration)  |
| [Add extensions to your app](#add-the-aepedgemedia-extension-to-your-app) <ul> <li>[Dependencies](#dependencies)<li> [Download extension with dependencies](#download-extension-with-dependencies) <li> [Import and register extensions](#import-and-register-extensions) </ul> |
| [Granular ad tracking](#granular-ad-tracking)  |
| [Downloaded content tracking](#downloaded-content-tracking)  |
| [API Reference](#api-reference)|

------

## Configuration 

### AEPMedia
| Name | Key | Value | Required |
| --- | --- | --- | --- |
| Collection API Server | "media.trackingServer" | String | Yes |
| Channel | "media.channel" | String | No |
| Player Name | "media.playerName" | String | No |
| Application Version | "media.appVersion" | String | No |

### AEPEdgeMedia
| Name | Key | Value | Required |
| --- | --- | --- | --- |
| Channel | "edgeMedia.channel" | String | Yes |
| Player Name | "edgeMedia.playerName" | String | Yes |
| Application Version | "edgeMedia.appVersion" | String | No |

Please refer [AEPEdgeMedia configuration](getting-started.md/#configuration) for more details.

------

## Add the AEPEdgeMedia extension to your app

### Dependencies

| AEPMedia | AEPEdgeMedia|
| --- | --- |
|```AEPCore, AEPIdentity, AEPAnalytics```|```AEPCore, AEPEdge, AEPEdgeIdentity```|

------

### Download extension with dependencies

#### 1. Using Cocoapods:<br>

Update pod file in your project

```diff
  pod 'AEPCore'
- pod 'AEPAnalytics'
- pod 'AEPMedia'
+ pod 'AEPEdge'
+ pod 'AEPEdgeIdentity'
+ pod 'AEPEdgeMedia'
```

#### 2. Using SPM:

Import the package:

a. Using repository URL

```diff
- https://github.com/adobe/aepsdk-media-ios.git
+ https://github.com/adobe/aepsdk-edgemedia-ios.git
```

b. Using `Package.swift` file

Make changes to your dependencies as shown below:
   
```diff
  dependencies: [
  .package(url: "https://github.com/adobe/aepsdk-core-ios.git", .upToNextMajor(from: "4.0.0")),
- .package(url: "https://github.com/adobe/aepsdk-analytics-ios.git", .upToNextMajor(from: "3.0.0")),
- .package(url: "https://github.com/adobe/aepsdk-media-ios.git", .upToNextMajor(from: "3.0.0"))
+ .package(url: "https://github.com/adobe/aepsdk-edge-ios.git", .upToNextMajor(from: "4.0.0")),
+ .package(url: "https://github.com/adobe/aepsdk-edgeidentity-ios.git", .upToNextMajor(from: "4.0.0")),
+ .package(url: "https://github.com/adobe/aepsdk-edgemedia-ios.git", .upToNextMajor(from: "4.0.0"))
  ]
```

------

### Import and register extensions

##### Swift

```diff
// AppDelegate.swift
import AEPCore
- import AEPIdentity
- import AEPAnalytics
- import AEPMedia
+ import AEPEdge
+ import AEPEdgeIdentity
+ import AEPEdgeMedia
```

```diff
// AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
-  MobileCore.registerExtensions([Identity.self, Analytics.self, Media.self], {
+  MobileCore.registerExtensions([Edge.self, Identity.self, Media.self], {
    MobileCore.configureWith(appId: "yourEnvironmentID")
   })
   ...
}
```

<details>
  <summary>Using both AEPMedia and AEPEdgeMedia for a side-by-side comparison?</summary>
  </br>
  <p>If you wish to use both the extensions together during migration time for a side-by-side comparison, use the Swift module name along with the extension class names for registration, as well as for any classes that use API s from both the modules.</p>

**Example**

```swift
// AppDelegate.swift
import AEPCore
import AEPIdentity
import AEPAnalytics
import AEPMedia
import AEPEdge
import AEPEdgeIdentity
import AEPEdgeMedia
```

```swift
// AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
MobileCore.registerExtensions([
      Edge.self,
      AEPEdgeMedia.Media.self, 
      AEPEdgeIdentity.Identity.self, 
      AEPMedia.Media.self, 
      AEPIdentity.Identity.self,
      Analytics.self,
      ], {
    MobileCore.configureWith(appId: "yourEnvironmentID")
   })
   ...
}
```
</details>

------

### Public API changes

All Numeric parameters of the public APIs have been updated to type Int.

##### updateCurrentPlayhead
```diff
- func updateCurrentPlayhead(time: Double)
+ func updateCurrentPlayhead(time: Int)
```

##### createMediaObjectWith
```diff
- static func createMediaObjectWith(name: String, id: String, length: Double, streamType: String, mediaType: MediaType) -> [String: Any]?
+ static func createMediaObjectWith(name: String, id: String, length: Int, streamType: String, mediaType: MediaType) -> [String: Any]?
```

##### createAdBreakObjectWith
```diff
- static func createAdBreakObjectWith(name: String, position: Int, startTime: Double) -> [String: Any]?
+ static func createAdBreakObjectWith(name: String, position: Int, startTime: Int) -> [String: Any]?
```

##### createAdbjectWith
```diff
- static func createAdObjectWith(name: String, id: String, position: Int, length: Double) -> [String: Any]?
+ static func createAdObjectWith(name: String, id: String, position: Int, length: Int) -> [String: Any]?
```

##### createChapterObjectWith
```diff
- static func createChapterObjectWith(name: String, position: Int, length: Double, startTime: Double) -> [String: Any]?
+ static func createChapterObjectWith(name: String, position: Int, length: Int, startTime: Int) -> [String: Any]?
```

##### createQoEObjectWith
```diff
- static func createQoEObjectWith(bitrate: Double, startupTime: Double, fps: Double, droppedFrames: Double) -> [String: Any]?
+ static func createQoEObjectWith(bitrate: Int, startupTime: Int, fps: Int, droppedFrames: Int) -> [String: Any]?
```

------

### Granular ad tracking

AEPMedia allowed for ad content tracking of `1 second` when setting the `MediaConstants.MediaObjectKey.GRANULAR_AD_TRACKING` key in the media object. AEPEdgeMedia is even more customizable and now the ad content tracking interval can be set using the tracker configuration to a value between `[1-10] seconds`. For more details, refer to the [createTrackerWithConfig API](api-reference.md/#createTrackerWithConfig).

```diff
- let tracker = Media.createTracker()
+ var trackerConfig: [String: Any] = [:]
+ trackerConfig[MediaConstants.TrackerConfig.AD_PING_INTERVAL] = 1
+ let tracker = Media.createTrackerWith(config: trackerConfig)

guard var mediaObject = guard let mediaObject = Media.createMediaObjectWith(name: "name", id: "id", length: 30, streamType: "vod", mediaType: MediaType.Video) else {
  return
}
- mediaObject[MediaConstants.MediaObjectKey.GRANULAR_AD_TRACKING] = true

tracker.trackSessionStart(info: mediaObject, metadata: videoMetadata)
```
------

### Downloaded content tracking

AEPMedia supports offline tracking for downloaded videos by setting the `MediaConstants.TrackerConfig.DOWNLOADED_CONTENT` key in the tracker configuration and calling `createTrackerWithConfig` API. 

AEPEdgemedia currently does not support this workflow. 

------

## API reference
The AEPEdgeMedia SDK has similar APIs with AEPMedia. Please refer the [API reference docs](api-reference.md) to check out the APIs and their usage.

------
