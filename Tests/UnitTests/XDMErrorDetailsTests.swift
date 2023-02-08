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

class XDMErrorDetailsTests: XCTestCase {

    // MARK: Encodable tests
    func testEncode() throws {
        // setup
        let errorDetails = XDMErrorDetails(name: "test_errorID", source: "test_errorSource")

        // test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(errorDetails))

        let map = asFlattenDictionary(data: data)

        XCTAssertEqual("test_errorID", map["name"] as! String)
        XCTAssertEqual("test_errorSource", map["source"] as! String)
    }
}
