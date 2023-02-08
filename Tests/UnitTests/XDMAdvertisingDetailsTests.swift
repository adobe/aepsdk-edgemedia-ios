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

class XDMAdvertisingDetailsTests: XCTestCase {

    // MARK: Encodable tests
    func testEncode() throws {
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

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(adDetails))

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("id", map["name"] as! String)
        XCTAssertEqual("name", map["friendlyName"] as! String)
        XCTAssertEqual(10, map["length"] as! Int64)
        XCTAssertEqual(1, map["podPosition"] as! Int64)
        XCTAssertEqual("test_playerName", map["playerName"] as! String)
        XCTAssertEqual("test_advertiser", map["advertiser"] as! String)
        XCTAssertEqual("test_campaignID", map["campaignID"] as! String)
        XCTAssertEqual("test_creativeID", map["creativeID"] as! String)
        XCTAssertEqual("test_creativeURL", map["creativeURL"] as! String)
        XCTAssertEqual("test_placementID", map["placementID"] as! String)
        XCTAssertEqual("test_siteID", map["siteID"] as! String)
    }
}
