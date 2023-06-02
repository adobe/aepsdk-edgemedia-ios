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

import XCTest

class AssertUtils: XCTestCase {
    /// Compares the size of dictionary and checks for keys
    /// - Parameters:
    ///   - expected: expected Dictionary
    ///   - actual: actual Dictinoary
    ///
    static func compareSizeAndKeys(_ expected: [String: Any]?, _ actual: [String: Any]?) -> Bool {
        if expected == nil && actual == nil {
            return true
        }

        guard let expected = expected else {
            return false
        }

        guard let actual = actual else {
            return false
        }

        if expected.count != actual.count {
            XCTFail("expected dictionary size:(\(expected.count) does not match actual dictionary size:(\(actual.count)")
            return checkKeys(expected, actual)
        }

        return checkKeys(expected, actual)
    }

    static func checkKeys(_ expected: [String: Any], _ actual: [String: Any]) -> Bool {
        for k in expected.keys where actual[k] == nil {
            XCTFail("key:(\(k)) present in expected but not in actual object")
            return false
        }

        for k in actual.keys where expected[k] == nil {
            XCTFail("key:(\(k)) present in actual but not in expected object")
            return false
        }

        return true
    }
}
