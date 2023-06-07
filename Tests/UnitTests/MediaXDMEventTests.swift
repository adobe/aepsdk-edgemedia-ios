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
import XCTest

class MediaXDMEventTests: XCTestCase {

    func testCreateMediaXDMEvent() {
        // Setup
        var sessionDetails = XDMSessionDetails(name: "test_mediaId", friendlyName: "name", length: 30, streamType: XDMStreamType.video, contentType: "vod", hasResume: false)
        sessionDetails.appVersion = "test_appVersion"
        sessionDetails.channel = "test_channel"
        sessionDetails.playerName = "test_playerName"
        sessionDetails.assetID = "test_assetID"

        var mediaCollection = XDMMediaCollection()
        mediaCollection.sessionDetails = sessionDetails

        // Test
        let mediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: Date(timeIntervalSince1970: 2), mediaCollection: mediaCollection)

        // Verify
        XCTAssertEqual(XDMMediaEventType.sessionStart, mediaXDMEvent.eventType)
        XCTAssertEqual(Date(timeIntervalSince1970: 2), mediaXDMEvent.timestamp)
        XCTAssertEqual(mediaCollection, mediaXDMEvent.mediaCollection)
    }

    func testToXDMData() {
        // Setup
        var sessionDetails = XDMSessionDetails(name: "id", friendlyName: "name", length: 30, streamType: XDMStreamType.video, contentType: "vod", hasResume: false)
        sessionDetails.appVersion = "test_appVersion"
        sessionDetails.channel = "test_channel"
        sessionDetails.playerName = "test_playerName"
        sessionDetails.assetID = "test_assetID"

        var mediaCollection = XDMMediaCollection()
        mediaCollection.sessionDetails = sessionDetails

        let mediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: Date(timeIntervalSince1970: 2), mediaCollection: mediaCollection)

        // Test
        let xdmEventData = mediaXDMEvent.toXDMData()
        let xdmMap = xdmEventData["xdm"] as? [String: Any] ?? [:]

        XCTAssertFalse(xdmMap.isEmpty)
        XCTAssertEqual("media.sessionStart", xdmMap["eventType"] as? String ?? "")
        XCTAssertEqual(Date(timeIntervalSince1970: 2).getISO8601UTCDateWithMilliseconds(), xdmMap["timestamp"] as? String)
        let actualMediaCollection = xdmMap["mediaCollection"] as? [String: Any] ?? [:]
        XCTAssertFalse(actualMediaCollection.isEmpty)

        let actualSessionDetails = actualMediaCollection["sessionDetails"] as? [String: Any] ?? [:]
        XCTAssertEqual(10, actualSessionDetails.count)

        XCTAssertEqual("name", actualSessionDetails["friendlyName"] as! String)
        XCTAssertEqual("id", actualSessionDetails["name"] as! String)
        XCTAssertEqual(Int64(30), actualSessionDetails["length"] as! Int64)
        XCTAssertEqual("video", actualSessionDetails["streamType"] as! String)
        XCTAssertEqual("vod", actualSessionDetails["contentType"] as! String)
        XCTAssertEqual(false, actualSessionDetails["hasResume"] as! Bool)
        XCTAssertEqual("test_appVersion", actualSessionDetails["appVersion"] as! String)
        XCTAssertEqual("test_channel", actualSessionDetails["channel"] as! String)
        XCTAssertEqual("test_playerName", actualSessionDetails["playerName"] as! String)
        XCTAssertEqual("test_assetID", actualSessionDetails["assetID"] as! String)
    }

}
