/*
 Copyright 2022 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPEdgeMedia
import AVKit
import Foundation

class MediaAnalyticsProvider: NSObject {

    let logTag = "MediaAnalyticsProvider"
    var _player: VideoPlayer?
    var _tracker: MediaTracker?

    @objc func initWithPlayer(player: VideoPlayer) {

        _player = player

        // Pass optional configuration when creating tracker
        var config: [String: Any] = [:]
        // config[MediaConstants.TrackerConfig.CHANNEL] = "e2e-swift-channel" // Overwrites channel configured from remote configuration
        // ​config[MediaConstants.TrackerConfig.AD_PING_INTERVAL] = 1 // Overwrites ad content ping interval to 1 second.
        // config[MediaConstants.TrackerConfig.MAIN_PING_INTERVAL] = 30 // Overwrites main content ping interval to 30 seconds.
        _tracker = Media.createTrackerWith(config: config)

        setupPlayerNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        _tracker = nil
    }

    @objc func updateQoE(notification: NSNotification) {
        NSLog("\(logTag) onUpdateQoE()")

        let qoeData = notification.userInfo

        let qoeBitrate = qoeData?["bitrate"] as? Double ?? 0
        let qoeStartup = qoeData?["startupTime"] as? Double ?? 0
        let qoeFPS = qoeData?["fps"] as? Double ?? 0
        let qoeDroppedFrame = qoeData?["droppedFrames"] as? Double ?? 0

        guard let qoeObject = Media.createQoEObjectWith(bitrate: qoeBitrate, startupTime: qoeStartup, fps: qoeFPS, droppedFrames: qoeDroppedFrame) else { return }

        _tracker?.updateQoEObject(qoe: qoeObject)
    }

    @objc func updateCurrentPlaybackTime(notification: NSNotification) {
        guard let playhead = _player?.getCurrentPlaybackTime() else {
            return
        }

        NSLog("\(logTag) updatePlayhead() - updated playhead value to %f", playhead)
        _tracker?.updateCurrentPlayhead(time: playhead)
    }

    @objc func onMainVideoLoaded(notification: NSNotification) {
        NSLog("\(logTag) onMainVideoLoaded()")

        let videoData = notification.userInfo

        let videoName = videoData?["name"] as? String ?? ""
        let videoId = videoData?["id"] as? String ?? ""
        let vidLength = videoData?["length"] as? Double ?? 0

        guard var mediaObject = Media.createMediaObjectWith(name: videoName, id: videoId, length: vidLength, streamType: MediaConstants.StreamType.VOD, mediaType: MediaType.Video) else {
            return
        }

        var videoMetadata: [String: String] = [:]
        // Standard Video Metadata
        videoMetadata[MediaConstants.VideoMetadataKeys.SHOW] = "Sample show"
        videoMetadata[MediaConstants.VideoMetadataKeys.SEASON] = "Sample season"

        // Custom Metadata
        videoMetadata["isUserLoggedIn"] = "false"
        videoMetadata["tvStation"] = "Sample TV station"
        mediaObject[MediaConstants.MediaObjectKey.GRANULAR_AD_TRACKING] = true

        _tracker?.trackSessionStart(info: mediaObject, metadata: videoMetadata)
    }

    @objc func onMainVideoUnloaded(notification: NSNotification) {
        NSLog("\(logTag) onMainVideoUnloaded()")
        _tracker?.trackSessionEnd()
    }

    @objc func onPlay(notification: NSNotification) {
        NSLog("\(logTag) onPlay()")
        _tracker?.trackPlay()
    }

    @objc func onStop(notification: NSNotification) {
        NSLog("\(logTag) onStop()")
        _tracker?.trackPause()
    }

    @objc func onComplete(notification: NSNotification) {
        NSLog("\(logTag) onComplete()")
        _tracker?.trackComplete()
    }

    @objc func onSeekStart(notification: NSNotification) {
        NSLog("\(logTag) onSeekStart()")
        _tracker?.trackEvent(event: MediaEvent.SeekStart, info: nil, metadata: nil)
    }

    @objc func onSeekComplete(notification: NSNotification) {
        NSLog("\(logTag) onSeekComplete()")
        _tracker?.trackEvent(event: MediaEvent.SeekComplete, info: nil, metadata: nil)
    }

    @objc func onChapterStart(notification: NSNotification) {
        NSLog("\(logTag) onChapterStart()")

        let chapterDictionary = ["segmentType": "Sample segment type"]

        let chapterData = notification.userInfo

        let chapterName = chapterData?["name"] as? String ?? ""
        let chapterPosition = chapterData?["position"] as? Int ?? 0
        let chapterLength = chapterData?["length"] as? Double ?? 0
        let chapterTime = chapterData?["time"] as? Double ?? 0

        let chapterObject = Media.createChapterObjectWith(name: chapterName, position: chapterPosition, length: chapterLength, startTime: chapterTime)

        _tracker?.trackEvent(event: MediaEvent.ChapterStart, info: chapterObject, metadata: chapterDictionary)
    }

    @objc func onChapterComplete(notification: NSNotification) {
        NSLog("\(logTag) onChapterComplete()")
        _tracker?.trackEvent(event: MediaEvent.ChapterComplete, info: nil, metadata: nil)
    }

    @objc func onAdStart(notification: NSNotification) {
        NSLog("\(logTag) onAdStart()")

        let adBreakData = notification.userInfo?["adbreak"] as? [String: Any] ?? [:]
        let adData = notification.userInfo?["ad"] as? [String: Any] ?? [:]

        let adBreakName = adBreakData["name"] as? String ?? ""
        let adBreakPosition = adBreakData["position"] as? Int ?? 0
        let adBreakStartTime = adBreakData["time"] as? Double ?? 0

        let adBreakObject = Media.createAdBreakObjectWith(name: adBreakName, position: adBreakPosition, startTime: adBreakStartTime)

        let adName = adData["name"] as? String ?? ""
        let adId = adData["id"] as? String ?? ""
        let adPosition = adData["position"] as? Int ?? 0
        let adLength = adData["length"] as? Double ?? 0

        let adObject = Media.createAdObjectWith(name: adName, id: adId, position: adPosition, length: adLength)

        var adMetadata: [String: String] = [:]
        // Standard Ad Metadata
        adMetadata[MediaConstants.AdMetadataKeys.ADVERTISER] = "Sample Advertiser"
        adMetadata[MediaConstants.AdMetadataKeys.CAMPAIGN_ID] = "Sample Campaign"

        // Custom Ad Metadata
        adMetadata["affiliate"] = "Sample affiliate"

        // AdBreak Start
        _tracker?.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakObject, metadata: nil)

        // Ad Start
        _tracker?.trackEvent(event: MediaEvent.AdStart, info: adObject, metadata: adMetadata)
    }

    @objc func onAdComplete(notification: NSNotification) {
        NSLog("\(logTag) onAdComplete()")
        // Ad Complete
        _tracker?.trackEvent(event: MediaEvent.AdComplete, info: nil, metadata: nil)

        // AdBreak Complete
        _tracker?.trackEvent(event: MediaEvent.AdBreakComplete, info: nil, metadata: nil)
    }

    @objc func onMuteUpdate(notification: NSNotification) {
        let muted: Bool = (notification.userInfo?["muted"]) as? Bool ?? false
        NSLog("\(logTag) onMuteUpdate(): Player muted: \(muted)")

        let muteState = Media.createStateObjectWith(stateName: MediaConstants.PlayerState.MUTE)
        let event = muted ? MediaEvent.StateStart : MediaEvent.StateEnd

        _tracker?.trackEvent(event: event, info: muteState, metadata: nil)
    }

    @objc func onCCUpdate(notification: NSNotification) {
        let ccActive: Bool = (notification.userInfo?["ccActive"]) as? Bool ?? false
        NSLog("\(logTag) onCCUpdate(): Closed caption active: \(ccActive)")

        let ccState = Media.createStateObjectWith(stateName: MediaConstants.PlayerState.CLOSED_CAPTION)
        let event = ccActive ? MediaEvent.StateStart : MediaEvent.StateEnd

        _tracker?.trackEvent(event: event, info: ccState, metadata: nil)
    }

    func setupPlayerNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onMainVideoLoaded), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_VIDEO_LOAD), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onMainVideoUnloaded), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_VIDEO_UNLOAD), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onPlay), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_PLAY), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onStop), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_PAUSE), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onSeekStart), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_SEEK_START), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onSeekComplete), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_SEEK_COMPLETE), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onComplete), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_COMPLETE), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onChapterStart), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_CHAPTER_START), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onChapterComplete), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_CHAPTER_COMPLETE), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onAdStart), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_AD_START), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onAdComplete), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_AD_COMPLETE), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.updateQoE(notification:)), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_QOE_UPDATE), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.updateCurrentPlaybackTime), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_PLAYHEAD_UPDATE), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onCCUpdate), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_CC_CHANGE), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Self.onMuteUpdate), name: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_MUTE_CHANGE), object: nil)

    }

}
