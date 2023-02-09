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
import AEPServices
import Foundation

class MediaXDMEventHelper {
    private static let LOG_TAG = MediaConstants.LOG_TAG
    private static let CLASS_NAME = "MediaXDMHelper"
    private static let standardMediaMetadataSet: Set = [
        MediaConstants.VideoMetadataKeys.AD_LOAD,
        MediaConstants.VideoMetadataKeys.ASSET_ID,
        MediaConstants.VideoMetadataKeys.AUTHORIZED,
        MediaConstants.VideoMetadataKeys.DAY_PART,
        MediaConstants.VideoMetadataKeys.EPISODE,
        MediaConstants.VideoMetadataKeys.FEED,
        MediaConstants.VideoMetadataKeys.FIRST_AIR_DATE,
        MediaConstants.VideoMetadataKeys.FIRST_DIGITAL_DATE,
        MediaConstants.VideoMetadataKeys.GENRE,
        MediaConstants.VideoMetadataKeys.MVPD,
        MediaConstants.VideoMetadataKeys.NETWORK,
        MediaConstants.VideoMetadataKeys.ORIGINATOR,
        MediaConstants.VideoMetadataKeys.RATING,
        MediaConstants.VideoMetadataKeys.SEASON,
        MediaConstants.VideoMetadataKeys.SHOW,
        MediaConstants.VideoMetadataKeys.SHOW_TYPE,
        MediaConstants.VideoMetadataKeys.STREAM_FORMAT,
        MediaConstants.AudioMetadataKeys.ALBUM,
        MediaConstants.AudioMetadataKeys.ARTIST,
        MediaConstants.AudioMetadataKeys.AUTHOR,
        MediaConstants.AudioMetadataKeys.LABEL,
        MediaConstants.AudioMetadataKeys.PUBLISHER,
        MediaConstants.AudioMetadataKeys.STATION
    ]

    private static let standardAdMetadataSet: Set = [
        MediaConstants.AdMetadataKeys.ADVERTISER,
        MediaConstants.AdMetadataKeys.CAMPAIGN_ID,
        MediaConstants.AdMetadataKeys.CREATIVE_ID,
        MediaConstants.AdMetadataKeys.CREATIVE_URL,
        MediaConstants.AdMetadataKeys.PLACEMENT_ID,
        MediaConstants.AdMetadataKeys.SITE_ID
    ]

    static func generateSessionDetails(mediaInfo: MediaInfo, metadata: [String: String], forceResume: Bool = false) -> XDMSessionDetails {
        var streamType = XDMStreamType.video
        if mediaInfo.mediaType == MediaType.Audio {
            streamType = XDMStreamType.audio
        }

        // To also handle the internally triggered resume by the SDK for long running sessions >= 24 hours
        let hasResume = forceResume || mediaInfo.resumed

        var sessionDetailsXDM = XDMSessionDetails(name: mediaInfo.id, friendlyName: mediaInfo.name, length: Int64(mediaInfo.length), streamType: streamType, contentType: mediaInfo.streamType, hasResume: hasResume)

        // Append standard metadata to sessionDetails
        for (key, value) in metadata {
            if !standardMediaMetadataSet.contains(key) {
                continue
            }

            switch key {
            // Video standard metadata cases
            case MediaConstants.VideoMetadataKeys.AD_LOAD:
                sessionDetailsXDM.adLoad = value
            case MediaConstants.VideoMetadataKeys.ASSET_ID:
                sessionDetailsXDM.assetID = value
            case MediaConstants.VideoMetadataKeys.AUTHORIZED:
                sessionDetailsXDM.authorized = value
            case MediaConstants.VideoMetadataKeys.DAY_PART:
                sessionDetailsXDM.dayPart = value
            case MediaConstants.VideoMetadataKeys.EPISODE:
                sessionDetailsXDM.episode = value
            case MediaConstants.VideoMetadataKeys.FEED:
                sessionDetailsXDM.feed = value
            case MediaConstants.VideoMetadataKeys.FIRST_AIR_DATE:
                sessionDetailsXDM.firstAirDate = value
            case MediaConstants.VideoMetadataKeys.FIRST_DIGITAL_DATE:
                sessionDetailsXDM.firstDigitalDate = value
            case MediaConstants.VideoMetadataKeys.GENRE:
                sessionDetailsXDM.genre = value
            case MediaConstants.VideoMetadataKeys.MVPD:
                sessionDetailsXDM.mvpd = value
            case MediaConstants.VideoMetadataKeys.NETWORK:
                sessionDetailsXDM.network = value
            case MediaConstants.VideoMetadataKeys.ORIGINATOR:
                sessionDetailsXDM.originator = value
            case MediaConstants.VideoMetadataKeys.RATING:
                sessionDetailsXDM.rating = value
            case MediaConstants.VideoMetadataKeys.SEASON:
                sessionDetailsXDM.season = value
            case MediaConstants.VideoMetadataKeys.SHOW:
                sessionDetailsXDM.show = value
            case MediaConstants.VideoMetadataKeys.SHOW_TYPE:
                sessionDetailsXDM.showType = value
            case MediaConstants.VideoMetadataKeys.STREAM_FORMAT:
                sessionDetailsXDM.streamFormat = value

            // Audio standard metadata cases
            case MediaConstants.AudioMetadataKeys.ALBUM:
                sessionDetailsXDM.album = value
            case MediaConstants.AudioMetadataKeys.ARTIST:
                sessionDetailsXDM.artist = value
            case MediaConstants.AudioMetadataKeys.AUTHOR:
                sessionDetailsXDM.author = value
            case MediaConstants.AudioMetadataKeys.LABEL:
                sessionDetailsXDM.label = value
            case MediaConstants.AudioMetadataKeys.PUBLISHER:
                sessionDetailsXDM.publisher = value
            case MediaConstants.AudioMetadataKeys.STATION:
                sessionDetailsXDM.station = value
            default:
                break

            }
        }

        return sessionDetailsXDM
    }

    static func generateMediaCustomMetadataDetails(metadata: [String: String]) -> [XDMCustomMetadata] {
        var customMetadataList = [XDMCustomMetadata]()
        for (key, value) in metadata {
            if !standardMediaMetadataSet.contains(key) {
                customMetadataList.append(XDMCustomMetadata(name: key, value: value))
            }
        }

        customMetadataList.sort { $0.name < $1.name }

        return customMetadataList
    }

    static func generateAdvertisingPodDetails(adBreakInfo: AdBreakInfo?) -> XDMAdvertisingPodDetails? {
        guard let adBreakInfo = adBreakInfo else {
            Log.trace(label: LOG_TAG, "[\(CLASS_NAME)<\(#function)>] - found empty ad break info.")
            return nil
        }

        let advertisingPodDetailsXDM = XDMAdvertisingPodDetails(friendlyName: adBreakInfo.name, index: Int64(adBreakInfo.position), offset: Int64(adBreakInfo.startTime))

        return advertisingPodDetailsXDM
    }

    static func generateAdvertisingDetails(adInfo: AdInfo?, adMetadata: [String: String]) -> XDMAdvertisingDetails? {
        guard let adInfo = adInfo else {
            Log.trace(label: LOG_TAG, "[\(CLASS_NAME)<\(#function)>] - found empty ad info.")
            return nil
        }

        var advertisingDetailsXDM = XDMAdvertisingDetails(name: adInfo.id, friendlyName: adInfo.name, length: Int64(adInfo.length), podPosition: Int64(adInfo.position))

        // Append standard metadata to advertisingDetails
        for (key, value) in adMetadata {
            if !standardAdMetadataSet.contains(key) {
                continue
            }

            switch key {
            case MediaConstants.AdMetadataKeys.ADVERTISER:
                advertisingDetailsXDM.advertiser = value
            case MediaConstants.AdMetadataKeys.CAMPAIGN_ID:
                advertisingDetailsXDM.campaignID = value
            case MediaConstants.AdMetadataKeys.CREATIVE_ID:
                advertisingDetailsXDM.creativeID = value
            case MediaConstants.AdMetadataKeys.CREATIVE_URL:
                advertisingDetailsXDM.creativeURL = value
            case MediaConstants.AdMetadataKeys.PLACEMENT_ID:
                advertisingDetailsXDM.placementID = value
            case MediaConstants.AdMetadataKeys.SITE_ID:
                advertisingDetailsXDM.siteID = value
            default:
                break
            }
        }

        return advertisingDetailsXDM
    }

    static func generateAdCustomMetadataDetails(metadata: [String: String]) -> [XDMCustomMetadata] {
        var customMetadataList = [XDMCustomMetadata]()
        for (key, value) in metadata {
            if !standardAdMetadataSet.contains(key) {
                let customMetadata = XDMCustomMetadata(name: key, value: value)
                customMetadataList.append(customMetadata)
            }
        }

        customMetadataList.sort { $0.name < $1.name }

        return customMetadataList
    }

    static func generateChapterDetails(chapterInfo: ChapterInfo?) -> XDMChapterDetails? {
        guard let chapterInfo = chapterInfo else {
            Log.trace(label: LOG_TAG, "[\(CLASS_NAME)<\(#function)>] - found empty chapter info.")
            return nil
        }

        let chapterDetailsXDM = XDMChapterDetails(friendlyName: chapterInfo.name, index: Int64(chapterInfo.position), length: Int64(chapterInfo.length), offset: Int64(chapterInfo.startTime))
        return chapterDetailsXDM
    }

    static func generateChapterMetadata(metadata: [String: String]) -> [XDMCustomMetadata] {
        var metadataList = [XDMCustomMetadata]()
        for (key, value) in metadata {
            metadataList.append(XDMCustomMetadata(name: key, value: value))
        }

        metadataList.sort { m1, m2 in
            m1.name < m2.name
        }

        return metadataList
    }

    static func generateQoEDataDetails(qoeInfo: QoEInfo?, errorId: String? = nil) -> XDMQoeDataDetails? {
        guard let qoeInfo = qoeInfo else {
            Log.trace(label: LOG_TAG, "[\(CLASS_NAME)<\(#function)>] - found empty chapter info.")
            return nil
        }
        let qoeDetailsXDM = XDMQoeDataDetails(bitrate: Int64(qoeInfo.bitrate), droppedFrames: Int64(qoeInfo.droppedFrames), framesPerSecond: Int64(qoeInfo.fps), timeToStart: Int64(qoeInfo.startupTime))

        return qoeDetailsXDM
    }

    static func generateErrorDetails(errorID: String) -> XDMErrorDetails {
        let errorDetailsXDM = XDMErrorDetails(name: errorID, source: MediaConstants.ErrorSource.PLAYER)

        return errorDetailsXDM
    }

    static func generateStateDetails(states: [StateInfo]?) -> [XDMPlayerStateData]? {
        guard let states = states, !states.isEmpty else {
            return nil
        }

        var playerStateXDMList = [XDMPlayerStateData]()
        for state in states {
            playerStateXDMList.append(XDMPlayerStateData(name: state.stateName))
        }

        return playerStateXDMList
    }
}
