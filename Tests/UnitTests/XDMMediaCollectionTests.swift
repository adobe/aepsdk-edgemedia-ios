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

class XDMMediaCollectionTests: XCTestCase {

    // MARK: Encodable tests
    func testEncode_sessionStart() throws {
        // setup
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

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("id", map["sessionDetails.name"] as! String)
        XCTAssertEqual("name", map["sessionDetails.friendlyName"] as! String)
        XCTAssertEqual(30, map["sessionDetails.length"] as! Int64)
        XCTAssertEqual("video", map["sessionDetails.streamType"] as! String)
        XCTAssertEqual("test_appVersion", map["sessionDetails.appVersion"] as! String)
        XCTAssertEqual("test_channel", map["sessionDetails.channel"] as! String)
        XCTAssertEqual("test_playerName", map["sessionDetails.playerName"] as! String)

        XCTAssertEqual("test_assetID", map["sessionDetails.assetID"] as! String)
        XCTAssertEqual("1", map["sessionDetails.episode"] as! String)
        XCTAssertEqual("test_feed", map["sessionDetails.feed"] as! String)
        XCTAssertEqual("test_firstAirDate", map["sessionDetails.firstAirDate"] as! String)
        XCTAssertEqual("test_firstAirDigitalDate", map["sessionDetails.firstDigitalDate"] as! String)
        XCTAssertEqual("test_genre", map["sessionDetails.genre"] as! String)
        XCTAssertEqual("false", map["sessionDetails.authorized"] as! String)
        XCTAssertEqual("test_mvpd", map["sessionDetails.mvpd"] as! String)
        XCTAssertEqual("test_network", map["sessionDetails.network"] as! String)
        XCTAssertEqual("test_originator", map["sessionDetails.originator"] as! String)
        XCTAssertEqual("test_rating", map["sessionDetails.rating"] as! String)
        XCTAssertEqual("1", map["sessionDetails.season"] as! String)
        XCTAssertEqual("test_segment", map["sessionDetails.segment"] as! String)
        XCTAssertEqual("test_show", map["sessionDetails.show"] as! String)
        XCTAssertEqual("test_showType", map["sessionDetails.showType"] as! String)
        XCTAssertEqual("test_streamFormat", map["sessionDetails.streamFormat"] as! String)
    }

    func testEncode_adBreakStart() throws {
        // setup
        let adBreakDetails = XDMAdvertisingPodDetails(friendlyName: "name", index: 1, offset: 2)

        var mediaCollection = XDMMediaCollection()
        mediaCollection.advertisingPodDetails = adBreakDetails

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("name", map["advertisingPodDetails.friendlyName"] as! String)
        XCTAssertEqual(2, map["advertisingPodDetails.offset"] as! Int64)
        XCTAssertEqual(1, map["advertisingPodDetails.index"] as! Int64)
    }

    func testEncode_adStart() throws {
        // setup

        // setup
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

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("id", map["advertisingDetails.name"] as! String)
        XCTAssertEqual("name", map["advertisingDetails.friendlyName"] as! String)
        XCTAssertEqual(10, map["advertisingDetails.length"] as! Int64)
        XCTAssertEqual(1, map["advertisingDetails.podPosition"] as! Int64)
        XCTAssertEqual("test_playerName", map["advertisingDetails.playerName"] as! String)
        XCTAssertEqual("test_advertiser", map["advertisingDetails.advertiser"] as! String)
        XCTAssertEqual("test_campaignID", map["advertisingDetails.campaignID"] as! String)
        XCTAssertEqual("test_creativeID", map["advertisingDetails.creativeID"] as! String)
        XCTAssertEqual("test_creativeURL", map["advertisingDetails.creativeURL"] as! String)
        XCTAssertEqual("test_placementID", map["advertisingDetails.placementID"] as! String)
        XCTAssertEqual("test_siteID", map["advertisingDetails.siteID"] as! String)
    }

    func testEncode_chapterStart() throws {
        // setup
        let chapterDetails = XDMChapterDetails(friendlyName: "name", index: 1, length: 10, offset: 2)

        var mediaCollection = XDMMediaCollection()
        mediaCollection.chapterDetails = chapterDetails

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("name", map["chapterDetails.friendlyName"] as! String)
        XCTAssertEqual(1, map["chapterDetails.index"] as! Int64)
        XCTAssertEqual(10, map["chapterDetails.length"] as! Int64)
        XCTAssertEqual(2, map["chapterDetails.offset"] as! Int64)
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

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("test_mute", map["statesStart[0].name"] as! String)
        XCTAssertEqual("test_fullscreen", map["statesStart[1].name"] as! String)
    }

    func testEncode_stateEnd() throws {
        // setup

        let muteState = XDMPlayerStateData(name: "test_mute")
        let fullscreenState = XDMPlayerStateData(name: "test_fullscreen")

        let states = [muteState, fullscreenState]

        var mediaCollection = XDMMediaCollection()
        mediaCollection.statesEnd = states

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(mediaCollection))

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("test_mute", map["statesEnd[0].name"] as! String)
        XCTAssertEqual("test_fullscreen", map["statesEnd[1].name"] as! String)
    }
}
