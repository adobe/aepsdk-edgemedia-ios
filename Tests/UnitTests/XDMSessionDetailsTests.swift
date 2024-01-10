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

class XDMSessionDetailsTests: XCTestCase, AnyCodableAsserts {

    // MARK: Encodable tests
    func testEncode_streamTypeVideo() throws {
        // Setup
        var sessionDetails = XDMSessionDetails(name: "id", friendlyName: "name", length: 30, streamType: XDMStreamType.video, contentType: "vod", hasResume: false)
        sessionDetails.appVersion = "test_appVersion"
        sessionDetails.channel = "test_channel"
        sessionDetails.playerName = "test_playerName"

        // Video Standard Metadata
        sessionDetails.adLoad = "preroll"
        sessionDetails.assetID = "test_assetID"
        sessionDetails.authorized = "false"
        sessionDetails.dayPart = "evening"
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

        // Test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(sessionDetails))

        let decodedSessionDetails = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Verify
        let expected = """
        {
          "adLoad": "preroll",
          "appVersion": "test_appVersion",
          "assetID": "test_assetID",
          "authorized": "false",
          "channel": "test_channel",
          "contentType": "vod",
          "dayPart": "evening",
          "episode": "1",
          "feed": "test_feed",
          "firstAirDate": "test_firstAirDate",
          "firstDigitalDate": "test_firstAirDigitalDate",
          "friendlyName": "name",
          "genre": "test_genre",
          "hasResume": false,
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
        """

        assertExactMatch(expected: expected, actual: decodedSessionDetails)
    }

    func testEncode_streamTypeAudio() throws {
        // Setup
        var sessionDetails = XDMSessionDetails(name: "id", friendlyName: "name", length: 30, streamType: XDMStreamType.audio, contentType: "aod", hasResume: false)
        sessionDetails.appVersion = "test_appVersion"
        sessionDetails.channel = "test_channel"
        sessionDetails.playerName = "test_playerName"

        sessionDetails.album = "test_album"
        sessionDetails.artist = "test_artist"
        sessionDetails.author = "test_author"
        sessionDetails.label = "test_label"
        sessionDetails.publisher = "test_publisher"
        sessionDetails.station = "test_station"

        // Test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(sessionDetails))

        let decodedSessionDetails = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Verify
        let expected = """
        {
          "album": "test_album",
          "appVersion": "test_appVersion",
          "artist": "test_artist",
          "author": "test_author",
          "channel": "test_channel",
          "contentType": "aod",
          "friendlyName": "name",
          "hasResume": false,
          "label": "test_label",
          "length": 30,
          "name": "id",
          "playerName": "test_playerName",
          "publisher": "test_publisher",
          "station": "test_station",
          "streamType": "audio"
        }
        """

        assertExactMatch(expected: expected, actual: decodedSessionDetails)
    }
}
