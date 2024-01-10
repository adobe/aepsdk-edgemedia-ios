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

class XDMMediaCollectionTests: XCTestCase, AnyCodableAsserts {

    // MARK: Encodable tests
    func testEncode_sessionStart() throws {
        // Setup
        var sessionDetails = XDMSessionDetails(name: "id", friendlyName: "name", length: 30, streamType: XDMStreamType.video, contentType: "vod", hasResume: false)
        sessionDetails.appVersion = "test_appVersion"
        sessionDetails.channel = "test_channel"
        sessionDetails.playerName = "test_playerName"

        // Video Standard Metadata
        sessionDetails.assetID = "test_assetID"
        sessionDetails.authorized = "false"
        sessionDetails.episode = "1"
        sessionDetails.feed = "test_feed"
        sessionDetails.firstAirDate = "test_firstAirDate"
        sessionDetails.firstDigitalDate = "test_firstAirDigitalDate"
        sessionDetails.genre = "test_genre"
        sessionDetails.mvpd = "test_mvpd"
        sessionDetails.network = "test_network"
        sessionDetails.originator = "test_originator"
        sessionDetails.rating = "test_rating"
        sessionDetails.season = "1"
        sessionDetails.segment = "test_segment"
        sessionDetails.show = "test_show"
        sessionDetails.showType = "test_showType"
        sessionDetails.streamFormat = "test_streamFormat"

        var mediaCollection = XDMMediaCollection()
        mediaCollection.sessionDetails = sessionDetails

        // Test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let decodedMediaCollection = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Verify
        let expected = """
        {
          "sessionDetails": {
            "appVersion": "test_appVersion",
            "assetID": "test_assetID",
            "authorized": "false",
            "channel": "test_channel",
            "episode": "1",
            "feed": "test_feed",
            "firstAirDate": "test_firstAirDate",
            "firstDigitalDate": "test_firstAirDigitalDate",
            "friendlyName": "name",
            "genre": "test_genre",
            "length": 30,
            "mvpd": "test_mvpd",
            "name": "id",
            "network": "test_network",
            "originator": "test_originator",
            "playerName": "test_playerName",
            "rating": "test_rating",
            "season": "1",
            "segment": "test_segment",
            "show": "test_show",
            "showType": "test_showType",
            "streamFormat": "test_streamFormat",
            "streamType": "video"
          }
        }
        """

        assertExactMatch(expected: expected, actual: decodedMediaCollection)
    }

    func testEncode_adBreakStart() throws {
        // Setup
        let adBreakDetails = XDMAdvertisingPodDetails(friendlyName: "name", index: 1, offset: 2)

        var mediaCollection = XDMMediaCollection()
        mediaCollection.advertisingPodDetails = adBreakDetails

        // Test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let decodedMediaCollection = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Verify
        let expected = """
        {
          "advertisingPodDetails": {
            "friendlyName": "name",
            "index": 1,
            "offset": 2
          }
        }
        """

        assertExactMatch(expected: expected, actual: decodedMediaCollection)
    }

    func testEncode_adStart() throws {
        // Setup
        var adDetails = XDMAdvertisingDetails(name: "id", friendlyName: "name", length: 10, podPosition: 1)
        adDetails.playerName = "test_playerName"

        // Standard Metadata
        adDetails.advertiser = "test_advertiser"
        adDetails.campaignID = "test_campaignID"
        adDetails.creativeID = "test_creativeID"
        adDetails.creativeURL = "test_creativeURL"
        adDetails.placementID = "test_placementID"
        adDetails.siteID = "test_siteID"

        var mediaCollection = XDMMediaCollection()
        mediaCollection.advertisingDetails = adDetails

        // Test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let decodedMediaCollection = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Verify
        let expected = """
        {
          "advertisingDetails": {
            "advertiser": "test_advertiser",
            "campaignID": "test_campaignID",
            "creativeID": "test_creativeID",
            "creativeURL": "test_creativeURL",
            "friendlyName": "name",
            "length": 10,
            "name": "id",
            "placementID": "test_placementID",
            "playerName": "test_playerName",
            "podPosition": 1,
            "siteID": "test_siteID"
          }
        }
        """

        assertExactMatch(expected: expected, actual: decodedMediaCollection)
    }

    func testEncode_chapterStart() throws {
        // Setup
        let chapterDetails = XDMChapterDetails(friendlyName: "name", index: 1, length: 10, offset: 2)

        var mediaCollection = XDMMediaCollection()
        mediaCollection.chapterDetails = chapterDetails

        // Test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let decodedMediaCollection = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Verify
        let expected = """
        {
          "chapterDetails": {
            "friendlyName": "name",
            "index": 1,
            "length": 10,
            "offset": 2
          }
        }
        """

        assertExactMatch(expected: expected, actual: decodedMediaCollection)
    }

    func testEncode_stateStart() throws {
        // setup
        let muteState = XDMPlayerStateData(name: "test_mute")
        let fullscreenState = XDMPlayerStateData(name: "test_fullscreen")

        let states = [muteState, fullscreenState]

        var mediaCollection = XDMMediaCollection()
        mediaCollection.statesStart = states

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let decodedMediaCollection = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Verify
        let expected = """
        {
          "statesStart": [
            {
              "name": "test_mute"
            },
            {
              "name": "test_fullscreen"
            }
          ]
        }
        """

        assertExactMatch(expected: expected, actual: decodedMediaCollection)
    }

    func testEncode_stateEnd() throws {
        // Setup

        let muteState = XDMPlayerStateData(name: "test_mute")
        let fullscreenState = XDMPlayerStateData(name: "test_fullscreen")

        let states = [muteState, fullscreenState]

        var mediaCollection = XDMMediaCollection()
        mediaCollection.statesEnd = states

        // Test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let decodedMediaCollection = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Verify
        let expected = """
        {
          "statesEnd": [
            {
              "name": "test_mute"
            },
            {
              "name": "test_fullscreen"
            }
          ]
        }
        """

        assertExactMatch(expected: expected, actual: decodedMediaCollection)
    }
}
