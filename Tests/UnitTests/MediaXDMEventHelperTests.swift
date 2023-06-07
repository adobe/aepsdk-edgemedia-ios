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
import XCTest

class MediaXDMEventHelperTests: XCTestCase {
    let mediaInfo = MediaInfo(id: "id", name: "name", streamType: "vod", mediaType: MediaType.Video, length: 10)
    let mediaStandardMetadata = [
        MediaConstants.VideoMetadataKeys.AD_LOAD: "adLoad",
        MediaConstants.VideoMetadataKeys.ASSET_ID: "assetID",
        MediaConstants.VideoMetadataKeys.AUTHORIZED: "authorized",
        MediaConstants.VideoMetadataKeys.DAY_PART: "dayPart",
        MediaConstants.VideoMetadataKeys.EPISODE: "episode",
        MediaConstants.VideoMetadataKeys.FEED: "feed",
        MediaConstants.VideoMetadataKeys.FIRST_AIR_DATE: "firstAirDate",
        MediaConstants.VideoMetadataKeys.FIRST_DIGITAL_DATE: "firstDigitalDate",
        MediaConstants.VideoMetadataKeys.GENRE: "genre",
        MediaConstants.VideoMetadataKeys.MVPD: "mvpd",
        MediaConstants.VideoMetadataKeys.NETWORK: "network",
        MediaConstants.VideoMetadataKeys.ORIGINATOR: "originator",
        MediaConstants.VideoMetadataKeys.RATING: "rating",
        MediaConstants.VideoMetadataKeys.SEASON: "season",
        MediaConstants.VideoMetadataKeys.SHOW: "show",
        MediaConstants.VideoMetadataKeys.SHOW_TYPE: "showType",
        MediaConstants.VideoMetadataKeys.STREAM_FORMAT: "streamFormat",

        MediaConstants.AudioMetadataKeys.ALBUM: "album",
        MediaConstants.AudioMetadataKeys.ARTIST: "artist",
        MediaConstants.AudioMetadataKeys.AUTHOR: "author",
        MediaConstants.AudioMetadataKeys.LABEL: "label",
        MediaConstants.AudioMetadataKeys.PUBLISHER: "publisher",
        MediaConstants.AudioMetadataKeys.STATION: "station"
    ]
    var mediaMetadata: [String: String] = ["key1": "value1", "key2": "value2"]

    var adInfo = AdInfo(id: "id", name: "name", position: 1, length: 10)
    let adStandardMetadata = [
        MediaConstants.AdMetadataKeys.ADVERTISER: "advertiser",
        MediaConstants.AdMetadataKeys.CAMPAIGN_ID: "campaignID",
        MediaConstants.AdMetadataKeys.CREATIVE_ID: "creativeID",
        MediaConstants.AdMetadataKeys.CREATIVE_URL: "creativeURL",
        MediaConstants.AdMetadataKeys.PLACEMENT_ID: "placementID",
        MediaConstants.AdMetadataKeys.SITE_ID: "siteID"
    ]
    var adMetadata: [String: String] = ["key1": "value1", "key2": "value2"]

    var qoeInfo = QoEInfo(bitrate: 1, droppedFrames: 2, fps: 3, startupTime: 4)

    var muteStateInfo = StateInfo(stateName: MediaConstants.PlayerState.MUTE)!
    var testStateInfo = StateInfo(stateName: "testStateName")!

    override func setUp() {
        mediaMetadata.merge(mediaStandardMetadata) { current, _ in current }
        adMetadata.merge(adStandardMetadata) { current, _ in current }
    }

    func testGenerateSessionDetails() {
        // setup
        var expectedSessionDetails = XDMSessionDetails(name: "id", friendlyName: "name", length: 10, streamType: XDMStreamType.video, contentType: "vod", hasResume: false)

        // Standard metadata
        expectedSessionDetails.adLoad = "adLoad"
        expectedSessionDetails.assetID = "assetID"
        expectedSessionDetails.authorized = "authorized"
        expectedSessionDetails.dayPart = "dayPart"
        expectedSessionDetails.episode = "episode"
        expectedSessionDetails.feed = "feed"
        expectedSessionDetails.firstAirDate = "firstAirDate"
        expectedSessionDetails.firstDigitalDate = "firstDigitalDate"
        expectedSessionDetails.genre = "genre"
        expectedSessionDetails.mvpd = "mvpd"
        expectedSessionDetails.network = "network"
        expectedSessionDetails.originator = "originator"
        expectedSessionDetails.rating = "rating"
        expectedSessionDetails.season = "season"
        expectedSessionDetails.show = "show"
        expectedSessionDetails.showType = "showType"
        expectedSessionDetails.streamFormat = "streamFormat"

        expectedSessionDetails.album = "album"
        expectedSessionDetails.artist = "artist"
        expectedSessionDetails.author = "author"
        expectedSessionDetails.label = "label"
        expectedSessionDetails.publisher = "publisher"
        expectedSessionDetails.station = "station"

        // test
        let sessionDetails = MediaXDMEventHelper.generateSessionDetails(mediaInfo: mediaInfo!, metadata: mediaMetadata)

        // verify
        XCTAssertTrue(AssertUtils.compareSizeAndKeys(expectedSessionDetails.asDictionary(), sessionDetails.asDictionary()))
        XCTAssertEqual(expectedSessionDetails, sessionDetails)
    }

    func testGenerateMediaCustomMetadataDetails() {
        // setup
        let expectedMetadata = [XDMCustomMetadata(name: "key1", value: "value1"), XDMCustomMetadata(name: "key2", value: "value2")]

        // test
        let customMediaMetadata = MediaXDMEventHelper.generateMediaCustomMetadataDetails(metadata: mediaMetadata)

        // verify
        XCTAssertTrue(verifyMetadata(expectedMetadata, customMediaMetadata), "Error: expected metadata does not match actual metadata.")
    }

    func testGenerateAdvertisingDetails() {
        // setup
        var expectedAdDetails = XDMAdvertisingDetails(name: "id", friendlyName: "name", length: 10, podPosition: 1)
        expectedAdDetails.advertiser = "advertiser"
        expectedAdDetails.campaignID = "campaignID"
        expectedAdDetails.creativeID = "creativeID"
        expectedAdDetails.creativeURL = "creativeURL"
        expectedAdDetails.placementID = "placementID"
        expectedAdDetails.siteID = "siteID"

        // test
        let advertisingDetails = MediaXDMEventHelper.generateAdvertisingDetails(adInfo: adInfo, adMetadata: adMetadata)

        // verify
        XCTAssertTrue(AssertUtils.compareSizeAndKeys(expectedAdDetails.asDictionary(), advertisingDetails?.asDictionary()))
        XCTAssertEqual(expectedAdDetails, advertisingDetails)
    }

    func testGenerateAdCustomMetadataDetails() {
        // setup
        let expectedMetadata = [XDMCustomMetadata(name: "key1", value: "value1"), XDMCustomMetadata(name: "key2", value: "value2")]

        // test
        let customMediaMetadata = MediaXDMEventHelper.generateAdCustomMetadataDetails(metadata: adMetadata)

        // verify
        XCTAssertTrue(verifyMetadata(expectedMetadata, customMediaMetadata), "Error: expected metadata does not match actual metadata.")
    }

    func testGenerateQoEDetails() {
        // setup
        let expectedQoEDetails = XDMQoeDataDetails(bitrate: 1, droppedFrames: 2, framesPerSecond: 3, timeToStart: 4)

        // test
        let qoeDetails = MediaXDMEventHelper.generateQoEDataDetails(qoeInfo: qoeInfo)

        // verify
        XCTAssertTrue(AssertUtils.compareSizeAndKeys(expectedQoEDetails.asDictionary(), qoeDetails?.asDictionary()))
        XCTAssertEqual(expectedQoEDetails, qoeDetails)
    }

    func testGenerateErrorDetails() {
        // setup
        let expectedErrorDetails = XDMErrorDetails(name: "testName", source: "player")

        // test
        let errorDetails = MediaXDMEventHelper.generateErrorDetails(errorID: "testName")

        // verify
        XCTAssertTrue(AssertUtils.compareSizeAndKeys(expectedErrorDetails.asDictionary(), errorDetails.asDictionary()))
        XCTAssertEqual(expectedErrorDetails, errorDetails)
    }

    func testGenerateStateDetails() {
        // setup
        let expectedTestStateDetails = XDMPlayerStateData(name: "testStateName")
        let expectedMuteStateDetails = XDMPlayerStateData(name: "mute")
        let expectedStateDetailsList = [expectedTestStateDetails, expectedMuteStateDetails]

        // test
        let stateDetails = MediaXDMEventHelper.generateStateDetails(states: [testStateInfo, muteStateInfo])

        // verify
        XCTAssertEqual(expectedStateDetailsList, stateDetails)
    }

    // test helper
    private func verifyMetadata(_ expected: [XDMCustomMetadata], _ actual: [XDMCustomMetadata]) -> Bool {
        if expected.count != actual.count {
            XCTFail("Expected metadata size:(\(expected.count) does not match actual metadata size:(\(actual.count)")
        }

        let sortedExpected = expected.sorted()
        let sortedActual = actual.sorted()

        return sortedExpected == sortedActual
    }
}
