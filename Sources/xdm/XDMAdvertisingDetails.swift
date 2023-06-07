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

import Foundation

struct XDMAdvertisingDetails: Encodable {
    // Required fields sourced from public APIs
    let friendlyName: String
    let length: Int
    let name: String
    let podPosition: Int

    // Required field sourced from media configuration
    // It is marked optional here to allow lazy initalization of the field
    var playerName: String?

    // Optional fields
    var advertiser: String?
    var campaignID: String?
    var creativeID: String?
    var creativeURL: String?
    var placementID: String?
    var siteID: String?

    init(name: String, friendlyName: String, length: Int, podPosition: Int) {
        self.name = name
        self.friendlyName = friendlyName
        self.length = length
        self.podPosition = podPosition
    }
}
