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

import AEPCore
@testable import AEPEdgeMedia
import AEPServices
import Foundation

class EdgeEventHelper {
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

    static func getCustomMetadata(eventType: XDMMediaEventType, metadata: [String: String]) -> [[String: Any]]? {
        var metadataList: [XDMCustomMetadata] = []
        for (k, v) in metadata {
            if (eventType == XDMMediaEventType.sessionStart && standardMediaMetadataSet.contains(k)) || (eventType == XDMMediaEventType.adStart && standardAdMetadataSet.contains(k)) {
                continue
            }

            metadataList.append(XDMCustomMetadata(name: k, value: v))
        }

        // sort the list using name values of the custom Metadata
        metadataList.sort { $0.name < $1.name }

        // convert the XDMCustomMetadata to a dictionary [String: Any]
        var metadataDictList = [[String: Any]]()
        for m in metadataList {
            if let metadataEntryAsDictionary = m.asDictionary() {
                metadataDictList.append(metadataEntryAsDictionary)
            }
        }

        return metadataDictList
    }

    static func getSessionDetailsDictionary(mediaInfo: [String: Any], metadata: [String: String], mediaState: MediaState) -> [String: Any] {
        var sessionDetails: [String: Any] = [:]
        sessionDetails["name"] = mediaInfo["media.id"]
        sessionDetails["friendlyName"] = mediaInfo["media.name"]
        sessionDetails["length"] = mediaInfo["media.length"]
        sessionDetails["streamType"] = mediaInfo["media.type"]
        sessionDetails["contentType"] = mediaInfo["media.streamtype"]
        sessionDetails["hasResume"] = mediaInfo["media.resumed"]

        for (key, value) in metadata {
            if !standardMediaMetadataSet.contains(key) {
                continue
            }

            switch key {
            // Video standard metadata cases
            case MediaConstants.VideoMetadataKeys.AD_LOAD:
                sessionDetails["adLoad"] = value
            case MediaConstants.VideoMetadataKeys.ASSET_ID:
                sessionDetails["assetID"] = value
            case MediaConstants.VideoMetadataKeys.AUTHORIZED:
                sessionDetails["authorized"] = value
            case MediaConstants.VideoMetadataKeys.DAY_PART:
                sessionDetails["dayPart"] = value
            case MediaConstants.VideoMetadataKeys.EPISODE:
                sessionDetails["episode"] = value
            case MediaConstants.VideoMetadataKeys.FEED:
                sessionDetails["feed"] = value
            case MediaConstants.VideoMetadataKeys.FIRST_AIR_DATE:
                sessionDetails["firstAirDate"] = value
            case MediaConstants.VideoMetadataKeys.FIRST_DIGITAL_DATE:
                sessionDetails["firstDigitalDate"] = value
            case MediaConstants.VideoMetadataKeys.GENRE:
                sessionDetails["genre"] = value
            case MediaConstants.VideoMetadataKeys.MVPD:
                sessionDetails["mvpd"] = value
            case MediaConstants.VideoMetadataKeys.NETWORK:
                sessionDetails["network"] = value
            case MediaConstants.VideoMetadataKeys.ORIGINATOR:
                sessionDetails["originator"] = value
            case MediaConstants.VideoMetadataKeys.RATING:
                sessionDetails["rating"] = value
            case MediaConstants.VideoMetadataKeys.SEASON:
                sessionDetails["season"] = value
            case MediaConstants.VideoMetadataKeys.SHOW:
                sessionDetails["show"] = value
            case MediaConstants.VideoMetadataKeys.SHOW_TYPE:
                sessionDetails["showType"] = value
            case MediaConstants.VideoMetadataKeys.STREAM_FORMAT:
                sessionDetails["streamFormat"] = value

            // Audio standard metadata cases
            case MediaConstants.AudioMetadataKeys.ALBUM:
                sessionDetails["album"] = value
            case MediaConstants.AudioMetadataKeys.ARTIST:
                sessionDetails["artist"] = value
            case MediaConstants.AudioMetadataKeys.AUTHOR:
                sessionDetails["author"] = value
            case MediaConstants.AudioMetadataKeys.LABEL:
                sessionDetails["label"] = value
            case MediaConstants.AudioMetadataKeys.PUBLISHER:
                sessionDetails["publisher"] = value
            case MediaConstants.AudioMetadataKeys.STATION:
                sessionDetails["station"] = value
            default:
                break
            }
        }

        if let channel = mediaState.channel, !channel.isEmpty {
            sessionDetails["channel"] = mediaState.channel
        }

        if let playerName = mediaState.playerName, !playerName.isEmpty {
            sessionDetails["playerName"] = mediaState.playerName
        }

        if let appVersion = mediaState.appVersion, !appVersion.isEmpty {
            sessionDetails["appVersion"] = mediaState.appVersion
        }

        return sessionDetails
    }

    static func getAdvertisingDetailsDictionary(adInfo: [String: Any], metadata: [String: String], mediaState: MediaState) -> [String: Any] {
        var advertisingDetails: [String: Any] = [:]
        advertisingDetails["name"] = adInfo["ad.id"]
        advertisingDetails["friendlyName"] = adInfo["ad.name"]
        advertisingDetails["length"] = adInfo["ad.length"]
        advertisingDetails["podPosition"] = adInfo["ad.position"]

        for (key, value) in metadata {
            if !standardAdMetadataSet.contains(key) {
                continue
            }

            switch key {
            // Video standard metadata cases
            case MediaConstants.AdMetadataKeys.ADVERTISER:
                advertisingDetails["advertiser"] = value
            case MediaConstants.AdMetadataKeys.CAMPAIGN_ID:
                advertisingDetails["campaignID"] = value
            case MediaConstants.AdMetadataKeys.CREATIVE_ID:
                advertisingDetails["creativeID"] = value
            case MediaConstants.AdMetadataKeys.CREATIVE_URL:
                advertisingDetails["creativeURL"] = value
            case MediaConstants.AdMetadataKeys.PLACEMENT_ID:
                advertisingDetails["placementID"] = value
            case MediaConstants.AdMetadataKeys.SITE_ID:
                advertisingDetails["siteID"] = value
            default:
                break
            }
        }

        if let playerName = mediaState.playerName, !playerName.isEmpty {
            advertisingDetails["playerName"] = mediaState.playerName
        }

        return advertisingDetails
    }

    static func getAdvertisingPodDetailsDictionary(adBreakInfo: [String: Any]) -> [String: Any] {
        var advertisingPodDetails: [String: Any] = [:]
        advertisingPodDetails["friendlyName"] = adBreakInfo["adbreak.name"]
        advertisingPodDetails["index"] = adBreakInfo["adbreak.position"]
        advertisingPodDetails["offset"] = adBreakInfo["adbreak.starttime"]

        return advertisingPodDetails
    }

    static func getChapterDetailsDictionary(chapterInfo: [String: Any], metadata: [String: String]) -> [String: Any] {
        var chapterDetails: [String: Any] = [:]
        chapterDetails["friendlyName"] = chapterInfo["chapter.name"]
        chapterDetails["index"] = chapterInfo["chapter.position"]
        chapterDetails["offset"] = chapterInfo["chapter.starttime"]
        chapterDetails["length"] = chapterInfo["chapter.length"]

        return chapterDetails
    }

    static func getErrorDetailsDictionary(errorInfo: [String: Any]) -> [String: Any] {
        var errorDetails: [String: Any] = [:]
        errorDetails["name"] = errorInfo["error.id"]
        errorDetails["source"] = errorInfo["error.source"]

        return errorDetails
    }

    static func getStatesUpdateList(stateInfo: [String: Any]) -> [[String: Any]] {
        var statesUpdateList: [[String: Any]] = []
        var stateDetails: [String: Any] = [:]
        stateDetails["name"] = stateInfo["state.name"]

        statesUpdateList.append(stateDetails)
        return statesUpdateList
    }

    static func getQoEDetailsDictionary(qoeInfo: [String: Any]) -> [String: Any] {
        var qoeDetails: [String: Any] = [:]
        qoeDetails["bitrate"] = qoeInfo["qoe.bitrate"]
        qoeDetails["droppedFrames"] = qoeInfo["qoe.droppedframes"]
        qoeDetails["framesPerSecond"] = qoeInfo["qoe.fps"]
        qoeDetails["timeToStart"] = qoeInfo["qoe.startuptime"]

        return qoeDetails
    }

    static func generateMediaCollection(eventType: XDMMediaEventType, playhead: Int, backendSessionId: String?, info: [String: Any], metadata: [String: String]?, mediaState: MediaState?, qoeInfo: [String: Any]? = nil, stateStart: Bool = true) -> [String: Any] {
        var mediaCollection: [String: Any] = [:]

        mediaCollection["playhead"] = playhead

        if eventType != XDMMediaEventType.sessionStart, backendSessionId != nil {
            mediaCollection["sessionID"] = backendSessionId
        }

        if let customMetadata = metadata, !customMetadata.isEmpty {
            mediaCollection["customMetadata"] = getCustomMetadata(eventType: eventType, metadata: customMetadata)
        }

        if eventType == XDMMediaEventType.sessionStart {
            mediaCollection["sessionDetails"] = getSessionDetailsDictionary(mediaInfo: info, metadata: metadata ?? [:], mediaState: mediaState ?? MediaState())
        } else if eventType == XDMMediaEventType.adStart {
            mediaCollection["advertisingDetails"] = getAdvertisingDetailsDictionary(adInfo: info, metadata: metadata ?? [:], mediaState: mediaState ?? MediaState())
        } else if eventType == XDMMediaEventType.adBreakStart {
            mediaCollection["advertisingPodDetails"] = getAdvertisingPodDetailsDictionary(adBreakInfo: info)
        } else if eventType == XDMMediaEventType.chapterStart {
            mediaCollection["chapterDetails"] = getChapterDetailsDictionary(chapterInfo: info, metadata: metadata ?? [:])
        } else if eventType == XDMMediaEventType.error {
            mediaCollection["errorDetails"] = getErrorDetailsDictionary(errorInfo: info)
        } else if eventType == XDMMediaEventType.statesUpdate {
            if stateStart {
                mediaCollection["statesStart"] = getStatesUpdateList(stateInfo: info)
            } else {
                mediaCollection["statesEnd"] = getStatesUpdateList(stateInfo: info)
            }
        } else if eventType == XDMMediaEventType.bitrateChange {
            mediaCollection["qoeDataDetails"] = getQoEDetailsDictionary(qoeInfo: info)
        }

        if qoeInfo != nil {
            // qoe details are attached to any subsequent request after updateQoEObject API is called
            mediaCollection["qoeDataDetails"] = getQoEDetailsDictionary(qoeInfo: qoeInfo ?? [:])
        }

        return mediaCollection
    }

    static func generateEdgeEvent(eventType: XDMMediaEventType, playhead: Int, ts: TimeInterval, backendSessionId: String?, info: [String: Any]? = nil, metadata: [String: String]? = nil, mediaState: MediaState? = nil, stateStart: Bool = true) -> Event {
        let eventOverwritePath = "/va/v1/" + eventType.rawValue

        var data: [String: Any] = [:]
        var xdmData: [String: Any] = [:]

        xdmData["eventType"] = eventType.edgeEventType()
        xdmData["timestamp"] = Date(timeIntervalSince1970: ts).getISO8601UTCDateWithMilliseconds()

        let mediaCollection = generateMediaCollection(eventType: eventType, playhead: playhead, backendSessionId: backendSessionId, info: info ?? [:], metadata: metadata, mediaState: mediaState, stateStart: stateStart)

        xdmData["mediaCollection"] = mediaCollection

        data["xdm"] = xdmData
        data["request"] = ["path": eventOverwritePath]

        let mediaEdgeEvent = Event(name: "MediaEdge event - \(eventType.edgeEventType())",
                                   type: "com.adobe.eventType.edge",
                                   source: "com.adobe.eventSource.requestContent",
                                   data: data)
        return mediaEdgeEvent
    }
}
