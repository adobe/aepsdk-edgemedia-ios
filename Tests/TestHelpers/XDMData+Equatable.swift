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

@testable import AEPEdgeMedia

extension XDMMediaCollection: Equatable {
    public static func == (lhs: XDMMediaCollection, rhs: XDMMediaCollection) -> Bool {
        return  lhs.advertisingDetails == rhs.advertisingDetails &&
            lhs.advertisingPodDetails == rhs.advertisingPodDetails &&
            lhs.chapterDetails == rhs.chapterDetails &&
            lhs.customMetadata == rhs.customMetadata &&
            lhs.errorDetails == rhs.errorDetails &&
            lhs.playhead == rhs.playhead &&
            lhs.sessionDetails == rhs.sessionDetails &&
            lhs.sessionID == rhs.sessionID &&
            lhs.statesStart == rhs.statesStart &&
            rhs.statesEnd == rhs.statesEnd
    }

}

extension XDMAdvertisingDetails: Equatable {
    public static func == (lhs: XDMAdvertisingDetails, rhs: XDMAdvertisingDetails) -> Bool {
        return  lhs.friendlyName == rhs.friendlyName &&
            lhs.length == rhs.length &&
            lhs.name == rhs.name &&
            lhs.podPosition == rhs.podPosition &&
            lhs.playerName == rhs.playerName &&
            lhs.advertiser == rhs.advertiser &&
            lhs.campaignID == rhs.campaignID &&
            lhs.creativeID == rhs.creativeID &&
            lhs.creativeURL == rhs.creativeURL &&
            lhs.placementID == rhs.placementID &&
            lhs.siteID == rhs.siteID
    }
}

extension XDMAdvertisingPodDetails: Equatable {
    public static func == (lhs: XDMAdvertisingPodDetails, rhs: XDMAdvertisingPodDetails) -> Bool {
        return lhs.friendlyName == rhs.friendlyName &&
            lhs.index == rhs.index &&
            lhs.offset == rhs.offset
    }
}

extension XDMChapterDetails: Equatable {
    public static func == (lhs: XDMChapterDetails, rhs: XDMChapterDetails) -> Bool {
        return lhs.friendlyName == rhs.friendlyName &&
            lhs.index == rhs.index &&
            lhs.length == rhs.length &&
            lhs.offset == rhs.offset
    }
}

extension XDMCustomMetadata: Equatable {
    public static func == (lhs: XDMCustomMetadata, rhs: XDMCustomMetadata) -> Bool {
        return lhs.name == rhs.name &&
            lhs.value == rhs.value
    }
}

extension XDMErrorDetails: Equatable {
    public static func == (lhs: XDMErrorDetails, rhs: XDMErrorDetails) -> Bool {
        return lhs.name == rhs.name &&
            lhs.source == rhs.source
    }
}

extension XDMPlayerStateData: Equatable {
    public static func == (lhs: XDMPlayerStateData, rhs: XDMPlayerStateData) -> Bool {
        return lhs.name == rhs.name
    }
}

extension XDMSessionDetails: Equatable {
    public static func == (lhs: XDMSessionDetails, rhs: XDMSessionDetails) -> Bool {
        return lhs.contentType == rhs.contentType &&
            lhs.friendlyName == rhs.friendlyName &&
            lhs.hasResume == rhs.hasResume &&
            lhs.length == rhs.length &&
            lhs.name == rhs.name &&
            lhs.streamType == rhs.streamType &&

            lhs.channel == rhs.channel &&
            lhs.playerName == rhs.playerName &&
            lhs.appVersion == rhs.appVersion &&

            lhs.album == rhs.album &&
            lhs.artist == rhs.artist &&
            lhs.author == rhs.author &&
            lhs.label == rhs.label &&
            lhs.publisher == rhs.publisher &&
            lhs.station == rhs.station &&

            lhs.adLoad == rhs.adLoad &&
            lhs.authorized == rhs.authorized &&
            lhs.assetID == rhs.assetID &&
            lhs.dayPart == rhs.dayPart &&
            lhs.episode == rhs.episode &&
            lhs.feed == rhs.feed &&
            lhs.firstAirDate == rhs.firstAirDate &&
            lhs.firstDigitalDate == rhs.firstDigitalDate &&
            lhs.genre == rhs.genre &&
            lhs.mvpd == rhs.mvpd &&
            lhs.network == rhs.network &&
            lhs.originator == rhs.originator &&
            lhs.rating == rhs.rating &&
            lhs.season == rhs.season &&
            lhs.segment == rhs.segment &&
            lhs.show == rhs.show &&
            lhs.showType == rhs.showType &&
            lhs.streamType == rhs.streamType &&
            lhs.streamFormat == rhs.streamFormat
    }
}

extension MediaXDMEvent: Equatable {
    public static func == (lhs: MediaXDMEvent, rhs: MediaXDMEvent) -> Bool {
        return lhs.eventType == rhs.eventType &&
            lhs.mediaCollection == rhs.mediaCollection &&
            lhs.timestamp == rhs.timestamp
    }
}
