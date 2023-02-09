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

import Foundation

internal extension MediaConstants {
    static let EXTENSION_NAME                           = "com.adobe.edge.media"
    static let FRIENDLY_NAME                            = "Edge Media Analytics"
    static let EXTENSION_VERSION                        = "1.0.0-beta"
    static let DATASTORE_NAME                           = EXTENSION_NAME
    static let DATABASE_NAME                            = EXTENSION_NAME
    static let LOG_TAG                                  = EXTENSION_NAME

    enum Configuration {
        static let SHARED_STATE_NAME = "com.adobe.module.configuration"
        static let MEDIA_CHANNEL = "edgemedia.channel"
        static let MEDIA_PLAYER_NAME = "edgemedia.playerName"
        static let MEDIA_APP_VERSION = "edgemedia.appVersion"
    }

    enum Media {
        static let EVENT_TYPE = "com.adobe.eventtype.edgemedia"
        static let EVENT_SOURCE_TRACKER_REQUEST = "com.adobe.eventsource.edgemedia.requesttracker"
        static let EVENT_SOURCE_TRACKER_RESPONSE = "com.adobe.eventsource.edgemedia.responsetracker"
        static let EVENT_SOURCE_TRACK_MEDIA = "com.adobe.eventsource.edgemedia.trackmedia"
        static let EVENT_SOURCE_SESSION_CREATED = "com.adobe.eventsource.edgemedia.sessioncreated"
        static let EVENT_NAME_CREATE_TRACKER = "Media::CreateTrackerRequest"
        static let EVENT_NAME_TRACK_MEDIA = "Media::TrackMedia"
        static let EVENT_NAME_SESSION_CREATED = "Media::SessionCreated"
        static let EVENT_SOURCE_MEDIA_EDGE_SESSION = "media-analytics:new-session"
        static let EVENT_SOURCE_EDGE_ERROR_RESOURCE = "com.adobe.eventSource.errorResponseContent"

    }

    enum MediaConfig {
        static let CHANNEL = "config.channel"
        static let DOWNLOADED_CONTENT = "config.downloadedcontent"
    }

    enum EventName {
        static let SESSION_START = "sessionstart"
        static let SESSION_END = "sessionend"
        static let PLAY = "play"
        static let PAUSE = "pause"
        static let COMPLETE = "complete"
        static let BUFFER_START = "bufferstart"
        static let BUFFER_COMPLETE = "buffercomplete"
        static let SEEK_START = "seekstart"
        static let SEEK_COMPLETE = "seekcomplete"
        static let ADBREAK_START = "adbreakstart"
        static let ADBREAK_COMPLETE = "adbreakcomplete"
        static let AD_START = "adstart"
        static let AD_COMPLETE = "adcomplete"
        static let AD_SKIP = "adskip"
        static let CHAPTER_START = "chapterstart"
        static let CHAPTER_COMPLETE = "chaptercomplete"
        static let CHAPTER_SKIP = "chapterskip"
        static let BITRATE_CHANGE = "bitratechange"
        static let ERROR = "error"
        static let QOE_UPDATE = "qoeupdate"
        static let PLAYHEAD_UPDATE = "playheadupdate"
        static let STATE_START = "statestart"
        static let STATE_END = "stateend"
    }

    enum MediaInfo {
        static let NAME   = "media.name"
        static let ID     = "media.id"
        static let LENGTH = "media.length"
        static let MEDIA_TYPE = "media.type"
        static let STREAM_TYPE = "media.streamtype"
        static let RESUMED = "media.resumed"
        static let PREROLL_TRACKING_WAITING_TIME = "media.prerollwaitingtime"
        static let GRANULAR_AD_TRACKING = "media.granularadtracking"
    }
    enum AdBreakInfo {
        static let NAME = "adbreak.name"
        static let POSITION = "adbreak.position"
        static let START_TIME = "adbreak.starttime"
    }
    enum AdInfo {
        static let ID = "ad.id"
        static let NAME = "ad.name"
        static let POSITION = "ad.position"
        static let LENGTH = "ad.length"
    }

    enum ChapterInfo {
        static let NAME = "chapter.name"
        static let POSITION = "chapter.position"
        static let START_TIME = "chapter.starttime"
        static let LENGTH = "chapter.length"
    }

    enum QoEInfo {
        static let BITRATE = "qoe.bitrate"
        static let DROPPED_FRAMES = "qoe.droppedframes"
        static let FPS = "qoe.fps"
        static let STARTUP_TIME = "qoe.startuptime"
    }

    enum ErrorInfo {
        static let ID = "error.id"
        static let SOURCE = "error.source"
    }

    enum StateInfo {
        static let STATE_NAME_KEY = "state.name"
        static let STATE_LIMIT = 10
    }

    enum Tracker {
        static let ID = "trackerid"
        static let SESSION_ID = "sessionid"
        static let CREATED = "trackercreated"
        static let EVENT_NAME = "event.name"
        static let EVENT_PARAM = "event.param"
        static let EVENT_METADATA = "event.metadata"
        static let EVENT_TIMESTAMP = "event.timestamp"
        static let EVENT_INTERNAL = "event.internal"
        static let PLAYHEAD = "time.playhead"
        static let BACKEND_SESSION_ID = "mediaservice.sessionid"
    }

    enum PingInterval {
        static let OFFLINE_TRACKING_MS: Int64 = 50 * 1000 // 50 sec
        static let REALTIME_TRACKING_MS: Int64 = 10 * 1000  // 10 sec
    }

    enum XDMKeys {
        static let XDM = "xdm"
        static let EVENT_TYPE = "eventType"
        static let TS = "timestamp"
        static let MEDIA_COLLECTION = "mediaCollection"
        static let CUSTOM_METADATA = "customMetadata"
    }

    enum ErrorSource {
        static let PLAYER = "player"
        static let EXTERNAL = "external"
    }

    enum Edge {
        static let MEDIA_CUSTOM_PATH_PREFIX = "/va/v1/"

        enum EventData {
            static let SESSION_ID = "sessionId"
            static let PAYLOAD = "payload"
            static let REQUEST_EVENT_ID = "requestEventId"
            static let REQUEST = "request"
            static let PATH = "path"
        }

        enum ErrorKeys {
            static let STATUS = "status"
            static let TYPE = "type"
        }

        enum ErrorData {
            static let ERROR_CODE_400 = 400
            static let ERROR_TYPE_VA_EDGE_400 = "https://ns.adobe.com/aep/errors/va-edge-0400-400"
        }

    }
}
