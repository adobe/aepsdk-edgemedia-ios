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

class XDMSessionDetailsTests: XCTestCase {

    // MARK: Encodable tests
    func testEncode_streamTypeVideo() throws {
        // setup
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

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(sessionDetails))

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("id", map["name"] as! String)
        XCTAssertEqual("name", map["friendlyName"] as! String)
        XCTAssertEqual(30, map["length"] as! Int64)
        XCTAssertEqual("video", map["streamType"] as! String)
        XCTAssertEqual("vod", map["contentType"] as! String)
        XCTAssertFalse(map["hasResume"] as! Bool)

        XCTAssertEqual("test_appVersion", map["appVersion"] as! String)
        XCTAssertEqual("test_channel", map["channel"] as! String)
        XCTAssertEqual("test_playerName", map["playerName"] as! String)

        XCTAssertEqual("preroll", map["adLoad"] as! String)
        XCTAssertEqual("test_assetID", map["assetID"] as! String)
        XCTAssertEqual("evening", map["dayPart"] as! String)
        XCTAssertEqual("1", map["episode"] as! String)
        XCTAssertEqual("test_feed", map["feed"] as! String)
        XCTAssertEqual("test_firstAirDate", map["firstAirDate"] as! String)
        XCTAssertEqual("test_firstAirDigitalDate", map["firstDigitalDate"] as! String)
        XCTAssertEqual("test_genre", map["genre"] as! String)
        XCTAssertEqual("false", map["authorized"] as! String)
        XCTAssertEqual("test_mvpd", map["mvpd"] as! String)
        XCTAssertEqual("test_network", map["network"] as! String)
        XCTAssertEqual("test_originator", map["originator"] as! String)
        XCTAssertEqual("test_rating", map["rating"] as! String)
        XCTAssertEqual("1", map["season"] as! String)
        XCTAssertEqual("test_segment", map["segment"] as! String)
        XCTAssertEqual("test_show", map["show"] as! String)
        XCTAssertEqual("test_showType", map["showType"] as! String)
        XCTAssertEqual("test_streamFormat", map["streamFormat"] as! String)
    }

    func testEncode_streamTypeAudio() throws {
        // setup
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

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(sessionDetails))

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("id", map["name"] as! String)
        XCTAssertEqual("name", map["friendlyName"] as! String)
        XCTAssertEqual(30, map["length"] as! Int64)
        XCTAssertEqual("audio", map["streamType"] as! String)
        XCTAssertEqual("aod", map["contentType"] as! String)
        XCTAssertFalse(map["hasResume"] as! Bool)

        XCTAssertEqual("test_appVersion", map["appVersion"] as! String)
        XCTAssertEqual("test_channel", map["channel"] as! String)
        XCTAssertEqual("test_playerName", map["playerName"] as! String)

        XCTAssertEqual("test_album", map["album"] as! String)
        XCTAssertEqual("test_artist", map["artist"] as! String)
        XCTAssertEqual("test_author", map["author"] as! String)
        XCTAssertEqual("test_label", map["label"] as! String)
        XCTAssertEqual("test_publisher", map["publisher"] as! String)
        XCTAssertEqual("test_station", map["station"] as! String)
    }
}
