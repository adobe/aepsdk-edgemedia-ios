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

public class MediaConstants: NSObject {

    /// These constant strings define the stream type of the main content that is currently tracked.
    @objc(AEPMediaStreamType)
    @objcMembers
    public class StreamType: NSObject {
        /// Constant defining stream type for VOD streams.
        public static let VOD = "vod"
        /// Constant defining stream type for Live streams.
        public static let LIVE = "live"
        /// Constant defining stream type for Linear streams.
        public static let LINEAR = "linear"
        /// Constant defining stream type for Podcast streams.
        public static let PODCAST = "podcast"
        /// Constant defining stream type for Audiobook streams.
        public static let AUDIOBOOK = "audiobook"
        /// Constant defining stream type for AOD streams.
        public static let AOD = "aod"
    }

    /// These constant strings define standard metadata keys for video content.
    @objc(AEPVideoMetadataKeys)
    @objcMembers
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

    /// These constant strings define standard metadata keys for audio content.
    @objc(AEPAudioMetadataKeys)
    @objcMembers
    public class AudioMetadataKeys: NSObject {
        public static let ALBUM = "album"
        public static let ARTIST = "artist"
        public static let AUTHOR = "author"
        public static let LABEL = "label"
        public static let PUBLISHER = "publisher"
        public static let STATION = "station"
    }

    /// These constant strings define standard metadata keys for ads.
    @objc(AEPAdMetadataKeys)
    @objcMembers
    public class AdMetadataKeys: NSObject {
        public static let ADVERTISER = "advertiser"
        public static let CAMPAIGN_ID = "campaignID"
        public static let CREATIVE_ID = "creativeID"
        public static let CREATIVE_URL = "creativeURL"
        public static let PLACEMENT_ID = "placementID"
        public static let SITE_ID = "siteID"
    }

    /// These constant strings define standard player states.
    @objc(AEPMediaPlayerState)
    @objcMembers
    public class PlayerState: NSObject {
        public static let FULLSCREEN = "fullScreen"
        public static let PICTURE_IN_PICTURE = "pictureInPicture"
        public static let CLOSED_CAPTION = "closeCaption"
        public static let IN_FOCUS = "inFocus"
        public static let MUTE = "mute"
    }

    /// These constant strings define additional event keys that can be attached to media object.
    @objc(AEPMediaObjectKey)
    @objcMembers
    public class MediaObjectKey: NSObject {
        public static let RESUMED = "media.resumed"
        public static let PREROLL_TRACKING_WAITING_TIME = "media.prerollwaitingtime"
    }

    /// These constant strings define keys that can be attached to config object.
    @objc(AEPMediaTrackerConfig)
    @objcMembers
    public class TrackerConfig: NSObject {
        public static let CHANNEL = "config.channel"
        public static let AD_PING_INTERVAL = "config.adpinginterval"
        public static let MAIN_PING_INTERVAL = "config.mainpinginterval"

    }
}
