//
// Copyright 2022 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

import Foundation

/// Flatten a multi-level dictionary to a single level where each key is a dotted notation of each nested key.
/// - Parameter dict: the dictionary to flatten
func flattenDictionary(dict: [String: Any]) -> [String: Any] {
    var result: [String: Any] = [:]

    func recursive(dict: [String: Any], out: inout [String: Any], currentKey: String = "") {
        if dict.isEmpty {
            if currentKey.isEmpty {
                out = [:]
            } else {
                out[currentKey] = "isEmpty"}
            return
        }
        for (key, val) in dict {
            let resultKey = !currentKey.isEmpty ? currentKey + "." + key : key
            process(value: val, out: &out, key: resultKey)
        }
    }

    func recursive(list: [Any], out: inout [String: Any], currentKey: String) {
        if list.isEmpty {
            out[currentKey] = "isEmpty"
            return
        }
        for (index, value) in list.enumerated() {
            let resultKey = currentKey + "[\(index)]"
            process(value: value, out: &out, key: resultKey)
        }
    }

    func process(value: Any, out: inout [String: Any], key: String) {
        if let value = value as? [String: Any] {
            recursive(dict: value, out: &out, currentKey: key)
        } else if let value = value as? [Any] {
            recursive(list: value, out: &out, currentKey: key)
        } else {
            out[key] = value
        }
    }

    recursive(dict: dict, out: &result)
    return result
}

/// Attempts to convert provided data to [String: Any] using JSONSerialization.
/// - Parameter data: data to be converted to [String: Any]
/// - Returns: `data` as [String: Any] or empty if an error occured
func asFlattenDictionary(data: Data?) -> [String: Any] {
    guard let unwrappedData = data else {
        return [:]
    }
    guard let dataAsDictionary = try? JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any] else {
        print("asFlattenDictionary - Unable to convert to [String: Any], data: \(String(data: unwrappedData, encoding: .utf8) ?? "")")
        return [:]
    }

    return flattenDictionary(dict: dataAsDictionary)
}
