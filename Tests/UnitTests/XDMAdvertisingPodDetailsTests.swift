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

class XDMAdvertisingPodDetailsTests: XCTestCase {

    // MARK: Encodable tests
    func testEncode() throws {
        // setup
        let adBreakDetails = XDMAdvertisingPodDetails(friendlyName: "name", index: 1, offset: 2)

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(adBreakDetails))

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("name", map["friendlyName"] as! String)
        XCTAssertEqual(2, map["offset"] as! Int64)
        XCTAssertEqual(1, map["index"] as! Int64)
    }
}
