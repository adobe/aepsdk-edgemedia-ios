# Adobe Streaming Media for Edge Network extension - iOS

## Prerequisites

To set up the extension and start using these APIs, see the [Getting Started Guide](getting-started.md).

## API reference

| APIs                                                  |
| ----------------------------------------------------- |
| [extensionVersion](#extensionVersion)                 |
| [registerExtensions](#registerExtensions)               |
| [createTracker](#createTracker)                       |
| [createTrackerWithConfig](#createTrackerWithConfig)   |
| [createMediaObjectWith](#createMediaObjectWith)               |
| [createAdBreakObjectWith](#createAdBreakObjectWith)           |
| [createAdObjectWith](#createAdObjectWith)                     |
| [createChapterObjectWith](#createChapterObjectWith)           |
| [createQoEObjectWith](#createQoEObjectWith)                   |
| [createStateObjectWith](#createStateObjectWith)               |

## Media Tracker API reference

| APIs                                                  |
| ----------------------------------------------------- |
| [trackSessionStart](#trackSessionStart)               |
| [trackPlay](#trackPlay)                               |
| [trackPause](#trackPause)                             |
| [trackComplete](#trackComplete)                       |
| [trackSessionEnd](#trackSessionEnd)                   |
| [trackError](#trackError)                             |
| [trackEvent](#trackEvent)                             |
| [updateCurrentPlayhead](#updateCurrentPlayhead)       |
| [updateQoEObject](#updateQoEObject)                   |

------

### extensionVersion

The extensionVersion API returns the version of the Media for Edge Network extension.

#### Swift

##### Syntax
```swift
static var extensionVersion: String
```

##### Example
```swift
let extensionVersion = EdgeMedia.extensionVersion
```

#### Objective-C

##### Syntax
```objectivec
+ (nonnull NSString*) extensionVersion;
```

##### Example
```objectivec
NSString *extensionVersion = [AEPMobileEdgeMedia extensionVersion];
```
------

### registerExtensions

Registers the Media for Edge Network extension with the Mobile Core extension.

The extension registration occurs by passing the Media for Edge Network extension to the [MobileCore.registerExtensions](https://developer.adobe.com/client-sdks/documentation/mobile-core/api-reference/#registerextensions) API.

#### Swift

##### Syntax
```swift
static func registerExtensions(_ extensions: [NSObject.Type],
                               _ completion: (() -> Void)? = nil)
```

##### Example
```swift
import AEPEdgeMedia

...
MobileCore.registerExtensions([Media.self])
```

#### Objective-C

##### Syntax
```objectivec
+ (void) registerExtensions: (NSArray<Class*>* _Nonnull) extensions
                 completion: (void (^ _Nullable)(void)) completion;
```

##### Example
```objectivec
@import AEPEdgeMedia;

...
[AEPMobileCore registerExtensions:@[AEPMobileEdgeMedia.class] completion:nil];
```

------

### createTracker

Creates a media tracker instance that tracks the playback session. The created tracker should be used to track the streaming content and it sends periodic pings to the Media Collection Service.


#### Swift

##### Syntax
```swift
static func createTracker()
```

##### Example
```swift
let tracker = Media.createTracker()  // Use the instance for tracking media playback session.
```

#### Objective-C

##### Syntax
```objectivec
+ (void) createTracker
```

##### Example
```objectivec
id<AEPEdgeMediaTracker> tracker;
_tracker = [AEPMobileEdgeMedia createTracker];  // Use the instance for tracking media playback session.
```

------

### createTrackerWithConfig

Creates a media tracker instance based on the provided configuration to track the playback session.

| Key | Description | Value | Required |
| --- | --- | --- | --- |
| "config.channel" | The channel name for media. Set this to overwrite the channel name configured in the Data Collection UI for media tracked with this tracker instance. | String | No |
| "config.mainpinginterval" | Overwrites the default main content tracking interval `(in seconds)`. The value should be in the allowed range `[10-50] seconds`. The default value is 10 seconds. | Int | No |
| "config.adpinginterval" | Overwrites the default ad content tracking interval `(in seconds)`. The value should be in the allowed range `[1-10] seconds`. The default value is 10 seconds. | Int | No |

#### Swift

##### Syntax
```swift
static func createTrackerWith(config: [String: Any]?)
```

##### Example
```swift

var config: [String: Any] = [:]
config[MediaConstants.TrackerConfig.CHANNEL] = "custom-channel" // Overwrites channel configured in the Data Collection UI.
​config[MediaConstants.TrackerConfig.AD_PING_INTERVAL] = 1 // Overwrites ad content ping interval to 1 second.
config[MediaConstants.TrackerConfig.MAIN_PING_INTERVAL] = 30 // Overwrites main content ping interval to 30 seconds.

let tracker = Media.createTrackerWith(config: config) // Use the instance for tracking media playback session.
```

#### Objective-C

##### Syntax
```objectivec
+(id<AEPEdgeMediaTracker> _Nonnull) createTrackerWithConfig:(NSDictionary<NSString *,id> * _Nullable)
```

##### Example
```objectivec
id<AEPEdgeMediaTracker> _tracker;
NSMutableDictionary* config = [NSMutableDictionary dictionary];

config[AEPEdgeMediaTrackerConfig.CHANNEL] = @"custom-channel"; // Overrides channel configured in the Data Collection UI

_tracker = [AEPMobileEdgeMedia createTrackerWithConfig:config]; // Use the instance for tracking media playback session.
```

------

### createMediaObjectWith

Creates an instance of the Media object which is a dictionary that contains information about the media.

| Parameter | Description | Required |
| --- | --- | --- |
| name | The friendly name of the media | Yes |
| id | The unique identifier for the media | Yes |
| length | The length of the media in seconds | Yes |
| streamType | [StreamType](#streamtype) | Yes |
| mediaType | [MediaType](#mediatype) | Yes |


#### Swift

##### Syntax
```swift
static func createMediaObjectWith(name: String,
                                    id: String,
                                length: Int,
                            streamType: String,
                             mediaType: MediaType) -> [String: Any]?
```

##### Example
```swift
let mediaObject = Media.createMediaObjectWith(name: "video-name",
                                                id: "videoId",
                                            length: 60,
                                        streamType: MediaConstants.StreamType.VOD,
                                         mediaType: MediaType.Video)
```

#### Objective-C

##### Syntax
```objectivec
+ (NSDictionary<NSString *, id> * _Nullable) createMediaObjectWith:(NSString * _Nonnull) id:(NSString * _Nonnull) length:(NSInteger) streamType:(NSString * _Nonnull) mediaType:(enum AEPEdgeMediaType)
```

##### Example
```objectivec
NSDictionary *mediaObject = [AEPMobileEdgeMedia createMediaObjectWith:@"video-name"
                                                                id:@"video-id"
                                                            length:60
                                                        streamType:AEPEdgeMediaStreamType.VOD
                                                         mediaType:AEPEdgeMediaTypeVideo];
```

### createAdBreakObjectWith

Creates an instance of the AdBreak object which is a dictionary that contains information about the ad break.

| Parameter | Description | Required |
| --- | --- | --- |
| name | The friendly name of ad break such as pre-roll, mid-roll, and post-roll | Yes |
| position | The numeric position of the ad break within the content, starting with 1 | Yes |
| startTime | The playhead value in seconds at the start of the ad break | Yes |

#### Swift

##### Syntax
```swift
static func createAdBreakObjectWith(name: String,
                                position: Int,
                                startTime: Int) -> [String: Any]?
```

##### Example
```swift
let adBreakObject = Media.createAdBreakObjectWith(name: "adbreak-name",
                                              position: 1,
                                             startTime: 0)
```

#### Objective-C

##### Syntax
```objectivec
+ (NSDictionary  <NSString *, id> * _Nullable) createAdBreakObjectWith:(NSString * _Nonnull)position:(NSInteger) startTime:(NSInteger)
```

##### Example
```objectivec
NSDictionary *adBreakObject = [AEPMobileEdgeMedia createAdBreakObjectWith:@"adbreak-name"
                                                             position:1
                                                            startTime:0];
```

### createAdObjectWith

Creates an instance of the Ad object which is a dictionary that contains information about the ad.

| Parameter | Description | Required |
| --- | --- | --- |
| name | The friendly name of the Ad | Yes |
| id | The unique identifier for the Ad | Yes |
| position | The numeric position of the Ad within the ad break, starting with 1 | Yes |
| length | The length of Ad in seconds | Yes |

#### Swift

##### Syntax
```swift
static func createAdObjectWith(name: String,
                                 id: String,
                           position: Int,
                             length: Int) -> [String: Any]?
```

##### Example
```swift
let adObject = Media.createObjectWith(name: "ad-name",
                                        id: "ad-id",
                                  position: 0,
                                    length: 30)
```

#### Objective-C

##### Syntax
```objectivec
+ (NSDictionary  <NSString *, id> * _Nullable) createAdObjectWith: (NSString * _Nonnull
                                                               id:(NSString * _Nonnull)
                                                         position:(NSInteger)
                                                           length:(NSInteger)
```

##### Example
```objectivec
NSDictionary *adObject = [AEPMobileEdgeMedia createAdObjectWith:@"ad-name"
                                                         id:@"ad-id"
                                                   position:0
                                                     length:30];
```

### createChapterObjectWith

Creates an instance of the Chapter object which is a dictionary that contains information about the chapter.

| Parameter | Description | Required |
| --- | --- | --- |
| name | The friendly name of the Chapter | Yes |
| position | The numeric position of the Chapter within the content, starting with 1 | Yes |
| length | The length of Chapter in seconds | Yes |
| startTime | The playhead value at the start of the chapter | Yes |

#### Swift

##### Syntax
```swift
static func createChapterObjectWith(name: String,
                                position: Int,
                                  length: Int,
                               startTime: Int) -> [String: Any]?
```

##### Example
```swift
let chapterObject = Media.createChapterObjectWith(name: "chapter_name",
                                              position: 1,
                                                length: 60,
                                             startTime: 0)
```

#### Objective-C

##### Syntax
```objectivec
+ (NSDictionary  <NSString *, id> * _Nullable) createChapterObjectWith:(NSString * _Nonnull)
                                                              position:(NSInteger)
                                                                length:(NSInteger)
                                                             startTime:(NSInteger)
```

##### Example
```objectivec
NSDictionary *chapterObject = [AEPMobileEdgeMedia createChapterObjectWith:@"chapter_name"
                                                             position:1
                                                               length:60
                                                            startTime:0];
```

### createQoEObjectWith

Creates an instance of the QoE (Quality of Experience) object which is a dictionary that contains information about the quality of experience.

| Parameter | Description | Required |
| --- | --- | --- |
| bitrate | The bitrate of media in bits per second | Yes |
| startupTime | The start up time of media in seconds | Yes |
| fps | The current frames per second | Yes |
| droppedFrames | The number of dropped frames so far | Yes |

> **Note**  
> All the QoE values bitrate, startupTime, fps, droppedFrames would be converted to Int64 for reporting purposes.

#### Swift

##### Syntax
```swift
static func createQoEObjectWith(bitrate: Int,
                            startupTime: Int,
                                    fps: Int,
                          droppedFrames: Int) -> [String: Any]?
```

##### Example
```swift
let qoeObject = Media.createQoEObjectWith(bitrate: 500000,
                                      startupTime: 2,
                                              fps: 24,
                                    droppedFrames: 10)
```

#### Objective-C

##### Syntax
```objectivec
+ (NSDictionary  <NSString *, id> * _Nullable) createQoEObjectWith:(NSInteger)
                                                         startTime:(NSInteger)
                                                               fps:(NSInteger)
                                                     droppedFrames:(NSInteger)
```

##### Example
```objectivec
NSDictionary *qoeObject = [AEPMobileEdgeMedia createQoEObjectWith:500000
                                                    startTime:2
                                                          fps:24
                                                droppedFrames:10];
```

### createStateObjectWith
Creates an instance of the Player State object which is a dictionary that contains information about the player state.

| Parameter | Description | Required |
| --- | --- | --- |
| name | The player state name. Use [Player State constants](#player-state-constants) to track standard player states | Yes |

#### Swift

##### Syntax
```swift
static func createStateObjectWith(stateName: String) -> [String: Any]
```

##### Example
```swift
let fullScreenState = Media.createStateObjectWith(stateName: "fullscreen")
```

#### Objective-C

##### Syntax
```objectivec
+ (NSDictionary  <NSString *, id> * _Nullable) createStateObjectWith:(NSString * _Nonnull)
```

##### Example
```objectivec
NSDictionary* fullScreenState = [AEPMobileEdgeMedia createStateObjectWith:AEPEdgeMediaPlayerState.FULLSCREEN]
```


## Media Tracker API Reference

> **Note**  
> The following APIs are **tracker instance** dependent. Please create tracker instance using [`createTracker`](#createTracker) or [`createTrackerWithConfig`](#createTrackerWithConfig) and call the following APIs.

### trackSessionStart
Tracks the intention to start playback. This starts a tracking session on the media tracker instance. To resume a previously closed session, see the [media resume guide](#media-resume).

| Parameter | Description | Required |
| --- | --- | --- |
| mediaInfo | Media information created using the [`createMediaObjectWith`](#createMediaObjectWith) method | Yes |
| contextData | Optional Media context data. For standard metadata keys, use [standard video constants](#standard-video-metadata-constants) or [standard audio constants](#standard-audio-metadata-constants). | No |

#### Swift

##### Syntax
```swift
public func trackSessionStart(info: [String: Any], metadata: [String: String]? = nil)
```

##### Example
```swift
let mediaObject = Media.createMediaObjectWith(name: "video-name", id: "videoId", length: 60, streamType: MediaConstants.StreamType.VOD, mediaType: MediaType.Video)

var videoMetadata: [String: String] = [:]
// Sample implementation for using video standard metadata keys
videoMetadata[MediaConstants.VideoMetadataKeys.SHOW] = "Sample show"
videoMetadata[MediaConstants.VideoMetadataKeys.SEASON] = "Sample season"

// Sample implementation for using custom metadata keys
videoMetadata["isUserLoggedIn"] = "false"
videoMetadata["tvStation"] = "Sample TV station"

tracker.trackSessionStart(info: mediaObject, metadata: videoMetadata)
```

#### Objective-C

##### Syntax
```objectivec
+ (void) trackSessionStart:(NSDictionary<NSString *,id> * _Nonnull) metadata:(NSDictionary<NSString *,NSString *> * _Nullable)
```

##### Example
```objectivec
NSDictionary *mediaObject = [AEPMobileEdgeMedia createMediaObjectWith:@"video-name" id:@"video-id" length:60 streamType:AEPEdgeMediaStreamType.VOD mediaType:AEPEdgeMediaTypeVideo];

NSMutableDictionary *videoMetadata = [[NSMutableDictionary alloc] init];
// Sample implementation for using standard video metadata keys
[videoMetadata setObject:@"Sample show" forKey:AEPEdgeMediaVideoMetadataKeys.SHOW];
[videoMetadata setObject:@"Sample Season" forKey:AEPEdgeMediaVideoMetadataKeys.SEASON];

// Sample implementation for using custom metadata keys
[videoMetadata setObject:@"false" forKey:@"isUserLoggedIn"];
[videoMetadata setObject:@"Sample TV station" forKey:@"tvStation"];

[_tracker trackSessionStart:mediaObject metadata:videoMetadata];
```

### trackPlay
Tracks the media play, or resume, after a previous pause.

#### Swift

##### Syntax
```swift
func trackPlay()
```

##### Example
```swift
tracker.trackPlay()
```

#### Objective-C

##### Syntax
```objectivec
- (void) trackPlay;
```

##### Example
```objectivec
[_tracker trackPlay];
```

### trackPause
Tracks the media pause.

#### Swift

##### Syntax
```swift
func trackPause()
```

##### Example
```swift
tracker.trackPause()
```

#### Objective-C

##### Syntax
```objectivec
- (void) trackPause
```

##### Example
```objectivec
[_tracker trackPause];
```

### trackComplete
Tracks the completion of the media playback session. Call this method only when the media has been completely viewed. If the viewing session is ended before the media is completely viewed, use [`trackSessionEnd`](#trackSessionEnd) instead.

#### Swift

##### Syntax
```swift
func trackComplete()
```

##### Example
```swift
tracker.trackComplete()
```

#### Objective-C

##### Syntax
```objectivec
- (void) trackComplete
```

##### Example
```objectivec
[_tracker trackComplete];
```

### trackSessionEnd
Tracks the end of a media playback session. Call this method when the viewing session ends, even if the user has not viewed the media to completion. If the media is viewed to completion, use [`trackComplete`](#trackComplete) instead.

#### Swift

##### Syntax
```swift
func trackSessionEnd()
```

##### Example
```swift
tracker.trackSessionEnd()
```

#### Objective-C

##### Syntax
```objectivec
- (void) trackSessionEnd
```

##### Example
```objectivec
[_tracker trackSessionEnd];
```

### trackError
Tracks an error in media playback.

| Parameter | Description | Required |
| --- | --- | --- |
| errorID | The custom error Identifier | Yes |


#### Swift

##### Syntax
```swift
func trackError(errorId: String)
```

##### Example
```swift
tracker.trackError(errorId: "errorId")
```

#### Objective-C

##### Syntax
```objectivec
- (void) trackError:(NSString * _Nonnull)
```

##### Example
```objectivec
[_tracker trackError:@"errorId"];
```

### trackEvent
Tracks media events.

| Parameter | Description | Required |
| --- | --- | --- |
| event | The media event being tracked, use [Media event constants](#media-events-constants) | Yes|
| info | For an `AdBreakStart` event, the AdBreak information is created by using the [`createAdBreakObjectWith`](#createAdBreakObjectWith) method.<br/> For an `AdStart` event, the Ad information is created by using the [`createAdObjectWith`](#createAdObjectWith) method.<br/> For a `ChapterStart` event, the Chapter information is created by using the [`createChapterObjectWith`](#createChapterObjectWith) method.<br/> For a `StateStart` and `StateEnd` event, the State information is created by using the [`createStateObjectWith`](#createStateObjectWith) method. | Yes/No* |
| metadata | Optional context data can be provided for `AdStart` and `ChapterStart` events. This is not required for other events. | No |

> **Note**  
> * info is a required parameter for `AdBreakStart`, `AdStart`, `ChapterStart`, `StateStart`, `StateEnd` events. Not set for any other event types.

#### Swift

##### Syntax
```swift
func trackEvent(event: MediaEvent, info: [String: Any]?, metadata: [String: String]?)
```

##### Example
Tracking ad breaks
```swift
// AdBreakStart
  let adBreakObject = Media.createAdBreakObjectWith(name: "adbreak-name", position: 1, startTime: 0)
  tracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakObject, metadata: nil)

// AdBreakComplete
  tracker.trackEvent(event: MediaEvent.AdBreakComplete, info: nil, metadata: nil)
```

Tracking ads
```swift
// AdStart
  let adObject = Media.createObjectWith(name: "adbreak-name", id: "ad-id", position: 0, length: 30)

// Standard metadata keys provided by adobe.
  var adMetadata: [String: String] = [:]
  adMetadata[MediaConstants.AdMetadataKeys.ADVERTISER] = "Sample Advertiser"
  adMetadata[MediaConstants.AdMetadataKeys.CAMPAIGN_ID] = "Sample Campaign"

// Custom metadata keys
  adMetadata["affiliate"] = "Sample affiliate"

  tracker.trackEvent(event: MediaEvent.AdStart, info: adObject, metadata: adMetadata)

// AdComplete
  tracker.trackEvent(event: MediaEvent.AdComplete, info: nil, metadata: nil)

// AdSkip
   tracker.trackEvent(event: MediaEvent.AdSkip, info: nil, metadata: nil)
```

Tracking chapters
```swift
// ChapterStart
  let chapterObject = Media.createChapterObjectWith(name: "chapter_name", position: 1, length: 60, startTime: 0)
  let chapterDictionary = ["segmentType": "Sample segment type"]

  tracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterObject, metadata: chapterDictionary)

// ChapterComplete
  tracker.trackEvent(event: MediaEvent.ChapterComplete, info: nil, metadata: nil)

// ChapterSkip
  tracker.trackEvent(event: MediaEvent.ChapterSkip, info: nil, metadata: nil)
```

Tracking player states
```swift
// StateStart
  let fullScreenState = Media.createStateObjectWith(stateName: MediaConstants.PlayerState.FULLSCREEN)
  tracker.trackEvent(event: MediaEvent.StateStart, info: fullScreenState, metadata: nil)

// StateEnd
  let fullScreenState = Media.createStateObjectWith(stateName: MediaConstants.PlayerState.FULLSCREEN)
  tracker.trackEvent(event: MediaEvent.StateEnd, info: fullScreenState, metadata: nil)
```

Tracking playback events
```swift
// BufferStart
   tracker.trackEvent(event: MediaEvent.BufferStart, info: nil, metadata: nil)

// BufferComplete
   tracker.trackEvent(event: MediaEvent.BufferComplete, info: nil, metadata: nil)

// SeekStart
   tracker.trackEvent(event: MediaEvent.SeekStart, info: nil, metadata: nil)

// SeekComplete
   tracker.trackEvent(event: MediaEvent.SeekComplete, info: nil, metadata: nil)
```

Tracking bitrate change
```swift
// If the new bitrate value is available provide it to the tracker.
  let qoeObject = Media.createQoEObjectWith(bitrate: 500000, startupTime: 2, fps: 24, droppedFrames: 10)
  tracker.updateQoEObject(qoeObject)

// Bitrate change
  tracker.trackEvent(event: MediaEvent.BitrateChange, info: nil, metadata: nil)
```

#### Objective-C

##### Syntax
```objectivec
- (void) trackEvent:(enum AEPEdgeMediaEvent) info:(NSDictionary<NSString *,id> * _Nullable) metadata:(NSDictionary<NSString *,NSString *> * _Nullable)
```

##### Example
Tracking ad breaks
```objectivec
// AdBreakStart
  NSDictionary *adBreakObject = [AEPMobileEdgeMedia createAdBreakObjectWith:@"adbreak-name" position:1 startTime:0];
  [_tracker trackEvent:AEPEdgeMediaEventAdBreakStart info:adBreakObject metadata:nil];

// AdBreakComplete
  [_tracker trackEvent:AEPEdgeMediaEventAdBreakComplete info:nil metadata:nil];
```

Tracking ads
```objectivec
// AdStart
  NSDictionary *adObject = [AEPMobileEdgeMedia createAdObjectWith:@"ad-name" id:@"ad-id" position:0 length:30];
  NSMutableDictionary* adMetadata = [[NSMutableDictionary alloc] init];

// Standard metadata keys provided by adobe.
  [adMetadata setObject:@"Sample Advertiser" forKey:AEPEdgeMediaAdMetadataKeys.ADVERTISER];
  [adMetadata setObject:@"Sample Campaign" forKey:AEPEdgeMediaAdMetadataKeys.CAMPAIGN_ID];

// Custom metadata keys
  [adMetadata setObject:@"Sample affiliate" forKey:@"affiliate"];

  [_tracker trackEvent:AEPEdgeMediaEventAdStart info:adObject metadata:adMetadata];

// AdComplete
  [_tracker trackEvent:AEPEdgeMediaEventAdComplete info:nil metadata:nil];

// AdSkip
  [_tracker trackEvent:AEPEdgeMediaEventAdSkip info:nil metadata:nil];
```

Tracking chapters
```objectivec
// ChapterStart
  NSDictionary *chapterObject = [AEPMobileEdgeMedia createChapterObjectWith:@"chapter_name" position:1 length:60 startTime:0];

  NSMutableDictionary *chapterMetadata = [[NSMutableDictionary alloc] init];
  [chapterMetadata setObject:@"Sample segment type" forKey:@"segmentType"];

  [_tracker trackEvent:AEPEdgeMediaEventChapterStart info:chapterObject metadata:chapterMetadata];

// ChapterComplete
  [_tracker trackEvent:AEPEdgeMediaEventChapterComplete info:nil metadata:nil];

// ChapterSkip
  [_tracker trackEvent:AEPEdgeMediaEventChapterSkip info:nil metadata:nil];
```

Tracking player states
```objectivec
// StateStart
  NSDictionary* fullScreenState = [AEPMobileEdgeMedia createStateObjectWith:AEPEdgeMediaPlayerState.FULLSCREEN];
  [_tracker trackEvent:AEPEdgeMediaEventStateStart info:fullScreenState metadata:nil];

// StateEnd
  NSDictionary* fullScreenState = [AEPMobileEdgeMedia createStateObjectWith:AEPEdgeMediaPlayerState.FULLSCREEN];
  [_tracker trackEvent:AEPEdgeMediaEventStateEnd info:fullScreenState metadata:nil];
```

Tracking playback events
```objectivec
// BufferStart
  [_tracker trackEvent:AEPEdgeMediaEventBufferStart info:nil metadata:nil];

// BufferComplete
  [_tracker trackEvent:AEPEdgeMediaEventBufferComplete info:nil metadata:nil];

// SeekStart
  [_tracker trackEvent:AEPEdgeMediaEventSeekStart info:nil metadata:nil];

// SeekComplete
  [_tracker trackEvent:AEPEdgeMediaEventSeekComplete info:nil metadata:nil];
```

Tracking bitrate change
```objectivec
// If the new bitrate value is available provide it to the tracker.
  NSDictionary *qoeObject = [AEPMobileEdgeMedia createQoEObjectWith:50000 startTime:2 fps:24 droppedFrames:10];

// Bitrate change
  [_tracker trackEvent:AEPEdgeMediaEventBitrateChange info:nil metadata:nil];
```

### updateCurrentPlayhead

Provides the current media playhead value to the media tracker instance. For accurate tracking, call this method every time the playhead value changes. If the player does not notify playhead value changes, call this method once every second with the most recent playhead value.

| Parameter | Description | Required |
| --- | --- | --- |
| time | Current playhead value in seconds.<br/><br/> For video-on-demand (VOD), the value is specified in seconds from the beginning of the media item.<br/><br/> For live streaming, if the player does not provide information about the content duration, the value can be specified as the number of seconds since midnight UTC of that day.| Yes |

> **Note**  
> When using progress markers, the content duration is required and the playhead value needs to be updated as the number of seconds from the beginning of the media item, starting with 0.

#### Swift

##### Syntax
```swift
func updateCurrentPlayhead(time: Int)
```

##### Example
```swift
tracker.updateCurrentPlayhead(1);
```

Live streaming example
```swift
//Calculation for number of seconds since midnight UTC of the day
let secondsSince1970: TimeInterval = (Date().timeIntervalSince1970)
let timeFromMidnightInSecond = secondsSince1970.truncatingRemainder(dividingBy: 86400)

tracker.updateCurrentPlayhead(time: timeFromMidnightInSecond)
```

#### Objective-C

##### Syntax
```objectivec
- (void) updateCurrentPlayhead:(NSInteger)
```

##### Example
```objectivec
[_tracker updateCurrentPlayhead:1];
```

### updateQoEObject
Provides the media tracker with the current Quality of Experience (QoE) information. For accurate tracking, call this method every time the media player provides the updated QoE information.

| Parameter | Description | Required |
| --- | --- | --- |
| qoeObject | Current QoE information that was created by using the [`createQoEObjectWith`](#createQoEObjectWith) method. | Yes |

#### Swift

##### Syntax
```swift
func updateQoEObject(qoe: [String: Any])
```

##### Example
```swift
let qoeObject = Media.createQoEObjectWith(bitrate: 500000, startupTime: 2, fps: 24, droppedFrames: 10)
tracker.updateQoEObject(qoe: qoeObject)
```

#### Objective-C

##### Syntax
```objectivec
- (void) updateQoEObject:(NSDictionary<NSString *,id> * _Nonnull)
```

##### Example
```objectivec
NSDictionary *qoeObject = [AEPMobileEdgeMedia createQoEObjectWith:50000 startTime:2 fps:24 droppedFrames:10]
[_tracker updateQoEObject:qoeObject];
```

## Media Constants

### MediaType

Defines the type of media that is currently being tracked. It can be either `MediaType.Video` or `MediaType.Audio`.

##### Definition
```swift
@objc(AEPEdgeMediaType)
public enum MediaType: Int, RawRepresentable {
 //Constant defining media type for Video streams
 case Audio
 //Constant defining media type for Audio streams
 case Video
}
```
#### Swift

##### Example
```swift
var mediaObject = Media.createMediaObjectWith(name: "video-name",
                                                id: "videoId",
                                            length: "60",
                                        streamType: MediaConstants.StreamType.VOD,    
                                         mediaType: MediaType.Video)
```

#### Objective-C

##### Example
```objectivec

NSDictionary *mediaObject = [AEPMobileEdgeMedia createMediaObjectWith:@"video-name"
                                                                   id:@"video-id"
                                                               length:60
                                                           streamType:AEPEdgeMediaStreamType.VOD      
                                                            mediaType:AEPEdgeMediaTypeVideo];
```

### StreamType

Defines the type of streamed content that is currently being tracked. Use the available constants or custom defined stream type values.

##### Definition
```swift

public class MediaConstants: NSObject {
  @objc(AEPEdgeMediaStreamType)
  public class StreamType: NSObject {
     // Constant defining stream type for VOD streams.
        public static let VOD = "vod"
     // Constant defining stream type for Live streams.
        public static let LIVE = "live"
     // Constant defining stream type for Linear streams.
        public static let LINEAR = "linear"
     // Constant defining stream type for Podcast streams.
        public static let PODCAST = "podcast"
     // Constant defining stream type for Audiobook streams.
        public static let AUDIOBOOK = "audiobook"
     // Constant defining stream type for AOD streams.
        public static let AOD = "aod"
    }
}
```

#### Swift

##### Example
```swift
var mediaObject = Media.createMediaObjectWith(name: "video-name",
                                                id: "videoId",
                                            length: "60",
                                        streamType: MediaConstants.StreamType.VOD,    
                                         mediaType: MediaType.Video)
```

#### Objective-C

##### Example
```objectivec

NSDictionary *mediaObject = [AEPMobileEdgeMedia createMediaObjectWith:@"video-name"
                                                                   id:@"video-id"
                                                               length:60
                                                           streamType:AEPEdgeMediaStreamType.VOD      
                                                            mediaType:AEPEdgeMediaTypeVideo];
```

### Player state constants
Defines the state of the media player that is currently being tracked. Use the available constant values or custom defined player state values.

```swift
public class MediaConstants: NSObject {
  @objc(AEPEdgeMediaPlayerState)
  public class PlayerState: NSObject {
        public static let FULLSCREEN = "fullscreen"
        public static let PICTURE_IN_PICTURE = "pictureInPicture"
        public static let CLOSED_CAPTION = "closeCaption"
        public static let IN_FOCUS = "inFocus"
        public static let MUTE = "mute"
    }
}
```
#### Swift

##### Example
```swift
let inFocusState = Media.createStateObjectWith(stateName: MediaConstants.PlayerState.IN_FOCUS)
tracker.trackEvent(event: MediaEvent.StateStart, info: inFocusState, metadata: nil)
```

#### Objective-C

##### Example
```objectivec
NSDictionary* inFocusState = [AEPMobileEdgeMedia createStateObjectWith:AEPEdgeMediaPlayerState.IN_FOCUS];
[_tracker trackEvent:AEPEdgeMediaEventStateStart info:muteState metadata:nil];
```

### Standard video metadata constants

Defines the standard video constants used as keys when creating or modifying video metadata dictionaries. Use the available constant values or custom defined video metadata key values.

```swift
public class MediaConstants: NSObject {
  @objc(AEPEdgeMediaVideoMetadataKeys)
  public class VideoMetadataKeys: NSObject {
        public static let AD_LOAD = "adLoad"
        public static let ASSET_ID = "assetID"
        public static let AUTHORIZED = "isAuthenticated"
        public static let DAY_PART = "dayPart"
        public static let EPISODE = "episode"
        public static let FEED = "feed"
        public static let FIRST_AIR_DATE = "firstAirDate"
        public static let FIRST_DIGITAL_DATE = "firstDigitalDate"
        public static let GENRE = "genre"
        public static let MVPD = "mvpd"
        public static let NETWORK = "network"
        public static let ORIGINATOR = "originator"
        public static let RATING = "rating"
        public static let SEASON = "season"
        public static let SHOW = "show"
        public static let SHOW_TYPE = "showType"
        public static let STREAM_FORMAT = "streamFormat"
    }
}
```

#### Swift

##### Example
```swift
var mediaObject = Media.createMediaObjectWith(name: "video-name", id: "videoId", length: "60", streamType: MediaConstants.StreamType.VOD, mediaType: MediaType.Video)

var videoMetadata: [String: String] = [:]
// Standard Video Metadata
videoMetadata[MediaConstants.VideoMetadataKeys.SHOW] = "Sample show"
videoMetadata[MediaConstants.VideoMetadataKeys.SEASON] = "Sample season"

tracker.trackSessionStart(info: mediaObject, metadata: videoMetadata)
```

#### Objective-C

##### Example
```objectivec
NSDictionary *mediaObject = [AEPMobileEdgeMedia createMediaObjectWith:@"video-name" id:@"video-id" length:60 streamType:AEPEdgeMediaStreamType.VOD mediaType:AEPEdgeMediaTypeVideo];

NSMutableDictionary *videoMetadata = [[NSMutableDictionary alloc] init];
// Standard Video Metadata
[videoMetadata setObject:@"Sample show" forKey:AEPEdgeMediaVideoMetadataKeys.SHOW];
[videoMetadata setObject:@"Sample Season" forKey:AEPEdgeMediaVideoMetadataKeys.SEASON];

[_tracker trackSessionStart:mediaObject metadata:videoMetadata];
```

### Standard audio metadata constants

Defines the standard audio constants used as keys when creating or modifying audio metadata dictionaries. Use the available constant values or custom defined audio metadata key values.

```swift
public class MediaConstants: NSObject {
  @objc(AEPEdgeMediaAudioMetadataKeys)
  public class AudioMetadataKeys: NSObject {
        public static let ALBUM = "album"
        public static let ARTIST = "artist"
        public static let AUTHOR = "author"
        public static let LABEL = "label"
        public static let PUBLISHER = "publisher"
        public static let STATION = "station"
    }
}
```

#### Swift

##### Example
```swift
var audioObject = Media.createMediaObjectWith(name: "audio-name", id: "audioId", length: 30, streamType: MediaConstants.StreamType.AOD, mediaType: MediaType.AUDIO)

var audioMetadata: [String: String] = [:]
// Standard Audio Metadata
audioMetadata[MediaConstants.AudioMetadataKeys.ARTIST] = "Sample artist"
audioMetadata[MediaConstants.AudioMetadataKeys.ALBUM] = "Sample album"

tracker.trackSessionStart(info: audioObject, metadata: audioMetadata)
```

#### Objective-C

##### Example
```objectivec
NSDictionary *audioObject = [AEPMobileEdgeMedia createMediaObjectWith:@"audio-name" id:@"audioid" length:30 streamType:AEPEdgeMediaStreamType.AOD mediaType:AEPEdgeMediaTypeAudio];

NSMutableDictionary *audioMetadata = [[NSMutableDictionary alloc] init];
// Standard Audio Metadata
[audioMetadata setObject:@"Sample artist" forKey:AEPEdgeMediaAudioMetadataKeys.ARTIST];
[audioMetadata setObject:@"Sample album" forKey:AEPEdgeMediaAudioMetadataKeys.ALBUM];

[_tracker trackSessionStart:audioObject metadata:audioMetadata];
```

### Standard ad metadata constants

Defines the standard ad metadata constants used as keys when creating or modifying ad metadata dictionaries. Use the available constant values or custom defined ad metadata key values.

```swift
public class MediaConstants: NSObject {
  @objc(AEPEdgeMediaAdMetadataKeys)
  public class AdMetadataKeys: NSObject {
        public static let ADVERTISER = "advertiser"
        public static let CAMPAIGN_ID = "campaignID"
        public static let CREATIVE_ID = "creativeID"
        public static let CREATIVE_URL = "creativeURL"
        public static let PLACEMENT_ID = "placementID"
        public static let SITE_ID = "siteID"
    }
}

```

#### Swift

##### Example
```swift
let adObject = Media.createAdObjectWith(name: "ad-name", id: "ad-id", position: 0, length: 30)
var adMetadata: [String: String] = [:]
// Standard Ad Metadata
adMetadata[MediaConstants.AdMetadataKeys.ADVERTISER] = "Sample Advertiser"
adMetadata[MediaConstants.AdMetadataKeys.CAMPAIGN_ID] = "Sample Campaign"

tracker.trackEvent(event: MediaEvent.AdStart, info: adObject, metadata: adMetadata)
```

#### Objective-C

##### Example
```objectivec
NSDictionary *adObject = [AEPMobileEdgeMedia createAdObjectWith:@"ad-name" id:@"ad-id" position:0 length:30];

NSMutableDictionary *adMetadata = [[NSMutableDictionary alloc] init];
// Standard Ad Metadata
[adMetadata setObject:@"Sample Advertiser" forKey:AEPEdgeMediaAdMetadataKeys.ADVERTISER];
[adMetadata setObject:@"Sample Campaign" forKey:AEPEdgeMediaAdMetadataKeys.CAMPAIGN_ID];

[_tracker trackEvent:AEPEdgeMediaEventAdStart info:adObject metadata:adMetadata];
```

### Media event constants

Defines the media event that is currently being tracked. Only the available constant values are allowed.

```swift
@objc(AEPEdgeMediaEvent)
public enum MediaEvent: Int, RawRepresentable {
 // event type for AdBreak start
    case AdBreakStart
 // event type for AdBreak Complete
    case AdBreakComplete
 // event type for Ad Start
    case AdStart
 // event type for Ad Complete
    case AdComplete
 // event type for Ad Skip
    case AdSkip
 // event type for Chapter Start
    case ChapterStart
 // event type for Chapter Complete
    case ChapterComplete
 // event type for Chapter Skip
    case ChapterSkip
 // event type for Seek Start
    case SeekStart
 // event type for Seek Complete
    case SeekComplete
 // event type for Buffer Start
    case BufferStart
 // event type for Buffer Complete
    case BufferComplete
 // event type for change in Bitrate
    case BitrateChange
 // event type for Player State Start
    case StateStart
 // event type for Player State End
    case StateEnd
}
```

#### Swift

##### Example
```swift
tracker.trackEvent(event: MediaEvent.BitrateChange, info: nil, metadata: nil)
```

#### Objective-C

##### Example
```objectivec
[_tracker trackEvent:AEPEdgeMediaEventBitrateChange info:nil metadata:nil];
```

### Media resume
Constant used to denote that the current tracking session is resuming a previously closed session. This information must be provided when starting a tracking session.

#### Swift

##### Syntax
```swift
public class MediaConstants: NSObject {
 @objc(AEPEdgeMediaObjectKey)
 public class MediaObjectKey: NSObject {
      public static let RESUMED = "media.resumed"
    }
}
```

##### Example
```swift
var mediaObject = Media.createMediaObjectWith(name: "video-name", id: "videoId", length: "60", streamType: MediaConstants.StreamType.VOD, mediaType: MediaType.Video)
mediaObject[MediaConstants.MediaObjectKey.RESUMED] = true

tracker.trackSessionStart(info: mediaObject, metadata: nil)
```

#### Objective-C

##### Syntax
```objectivec
@interface AEPEdgeMediaObjectKey : NSObject
+ (NSString * _Nonnull)RESUMED
```

##### Example
```objectivec
NSDictionary *mediaObject = [AEPMobileEdgeMedia createMediaObjectWith:@"video-name" id:@"video-id" length:60 streamType:AEPEdgeMediaStreamType.VOD mediaType:AEPEdgeMediaTypeVideo];

// Attach media resumed information.    
NSMutableDictionary *obj  = [mediaObject mutableCopy];
[obj setObject:@YES forKey:AEPEdgeMediaObjectKey.RESUMED];

[_tracker trackSessionStart:obj metadata:nil];
```
