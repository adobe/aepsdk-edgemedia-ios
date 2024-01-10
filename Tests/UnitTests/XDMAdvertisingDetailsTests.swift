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

class XDMAdvertisingDetailsTests: XCTestCase, AnyCodableAsserts {

    // MARK: Encodable tests
    func testEncode() throws {
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

        // Test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(adDetails))

        let decodedAdDetails = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Verify
        let expected = """
        {
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
        """

        assertExactMatch(expected: expected, actual: decodedAdDetails)
    }
}
