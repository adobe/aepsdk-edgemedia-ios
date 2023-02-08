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

struct XDMSessionDetails: Encodable {
    // Required fields sourced from APIs
    let contentType: String
    let friendlyName: String
    let hasResume: Bool
    let length: Int64
    let name: String
    let streamType: XDMStreamType
    // Required fields sourced from media configuration
    var channel: String?
    var playerName: String?

    // Optional field sourced from media configuration
    var appVersion: String?

    // Optional metadata fields
    // Audio Standard Metadata
    var album: String?
    var artist: String?
    var author: String?
    var label: String?
    var publisher: String?
    var station: String?

    // Video Standard Metadata
    var adLoad: String?
    var authorized: String?
    var assetID: String?
    var dayPart: String?
    var episode: String?
    var feed: String?
    var firstAirDate: String?
    var firstDigitalDate: String?
    var genre: String?
    var mvpd: String?
    var network: String?
    var originator: String?
    var rating: String?
    var season: String?
    var segment: String?
    var show: String?
    var showType: String?
    var streamFormat: String?

    init(name: String, friendlyName: String, length: Int64, streamType: XDMStreamType, contentType: String, hasResume: Bool) {
        self.name = name
        self.friendlyName = friendlyName
        self.length = length
        self.streamType = streamType
        self.contentType = contentType
        self.hasResume = hasResume
    }
}
