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

class XDMChapterDetailsTests: XCTestCase, AnyCodableAsserts {

    // MARK: Encodable tests
    func testEncode() throws {
        // Setup
        let chapterDetails = XDMChapterDetails(friendlyName: "name", index: 1, length: 10, offset: 2)

        // Test
        let encoder = JSONEncoder()
        let data = try XCTUnwrap(encoder.encode(chapterDetails))

        let decodedChapterDetails = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // Verify
        let expected = """
        {
          "friendlyName": "name",
          "index": 1,
          "length": 10,
          "offset": 2
        }
        """

        assertExactMatch(expected: expected, actual: decodedChapterDetails)
    }
}
