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
import AEPTestUtils
import XCTest

class MediaXDMEventHelperTests: XCTestCase, AnyCodableAsserts {
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
        // Setup
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

        // Test
        let sessionDetails = MediaXDMEventHelper.generateSessionDetails(mediaInfo: mediaInfo!, metadata: mediaMetadata)

        // Verify
        assertEqual(expected: expectedSessionDetails.asDictionary(), actual: sessionDetails.asDictionary())
        XCTAssertEqual(expectedSessionDetails, sessionDetails)
    }

    func testGenerateMediaCustomMetadataDetails() {
        // Setup
        let expectedMetadata = [XDMCustomMetadata(name: "key1", value: "value1"), XDMCustomMetadata(name: "key2", value: "value2")]

        // Test
        let customMediaMetadata = MediaXDMEventHelper.generateMediaCustomMetadataDetails(metadata: mediaMetadata)

        // Verify
        XCTAssertTrue(verifyMetadata(expectedMetadata, customMediaMetadata), "Error: expected metadata does not match actual metadata.")
    }

    func testGenerateAdvertisingDetails() {
        // Setup
        var expectedAdDetails = XDMAdvertisingDetails(name: "id", friendlyName: "name", length: 10, podPosition: 1)
        expectedAdDetails.advertiser = "advertiser"
        expectedAdDetails.campaignID = "campaignID"
        expectedAdDetails.creativeID = "creativeID"
        expectedAdDetails.creativeURL = "creativeURL"
        expectedAdDetails.placementID = "placementID"
        expectedAdDetails.siteID = "siteID"

        // Test
        let advertisingDetails = MediaXDMEventHelper.generateAdvertisingDetails(adInfo: adInfo, adMetadata: adMetadata)

        // Verify
        assertEqual(expected: expectedAdDetails.asDictionary(), actual: advertisingDetails?.asDictionary())
        XCTAssertEqual(expectedAdDetails, advertisingDetails)
    }

    func testGenerateAdCustomMetadataDetails() {
        // Setup
        let expectedMetadata = [XDMCustomMetadata(name: "key1", value: "value1"), XDMCustomMetadata(name: "key2", value: "value2")]

        // Test
        let customMediaMetadata = MediaXDMEventHelper.generateAdCustomMetadataDetails(metadata: adMetadata)

        // Verify
        XCTAssertTrue(verifyMetadata(expectedMetadata, customMediaMetadata), "Error: expected metadata does not match actual metadata.")
    }

    func testGenerateQoEDetails() {
        // Setup
        let expectedQoEDetails = XDMQoeDataDetails(bitrate: 1, droppedFrames: 2, framesPerSecond: 3, timeToStart: 4)

        // Test
        let qoeDetails = MediaXDMEventHelper.generateQoEDataDetails(qoeInfo: qoeInfo)

        // Verify
        assertEqual(expected: expectedQoEDetails.asDictionary(), actual: qoeDetails?.asDictionary())
        XCTAssertEqual(expectedQoEDetails, qoeDetails)
    }

    func testGenerateErrorDetails() {
        // Setup
        let expectedErrorDetails = XDMErrorDetails(name: "testName", source: "player")

        // Test
        let errorDetails = MediaXDMEventHelper.generateErrorDetails(errorID: "testName")

        // Verify
        assertEqual(expected: expectedErrorDetails.asDictionary(), actual: errorDetails.asDictionary())
        XCTAssertEqual(expectedErrorDetails, errorDetails)
    }

    func testGenerateStateDetails() {
        // Setup
        let expectedTestStateDetails = XDMPlayerStateData(name: "testStateName")
        let expectedMuteStateDetails = XDMPlayerStateData(name: "mute")
        let expectedStateDetailsList = [expectedTestStateDetails, expectedMuteStateDetails]

        // Test
        let stateDetails = MediaXDMEventHelper.generateStateDetails(states: [testStateInfo, muteStateInfo])

        // Verify
        XCTAssertEqual(expectedStateDetailsList, stateDetails)
    }

    // Test helper
    private func verifyMetadata(_ expected: [XDMCustomMetadata], _ actual: [XDMCustomMetadata]) -> Bool {
        if expected.count != actual.count {
            XCTFail("Expected metadata size:(\(expected.count) does not match actual metadata size:(\(actual.count)")
        }

        let sortedExpected = expected.sorted()
        let sortedActual = actual.sorted()

        return sortedExpected == sortedActual
    }
}
