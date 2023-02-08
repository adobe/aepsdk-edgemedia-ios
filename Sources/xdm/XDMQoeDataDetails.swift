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

struct XDMQoeDataDetails: Equatable, Encodable {
    let bitrate: Int64?
    let droppedFrames: Int64?
    let framesPerSecond: Int64?
    let timeToStart: Int64?

    init(bitrate: Int64, droppedFrames: Int64, framesPerSecond: Int64, timeToStart: Int64) {
        self.bitrate = bitrate
        self.droppedFrames = droppedFrames
        self.framesPerSecond = framesPerSecond
        self.timeToStart = timeToStart
    }
}

extension XDMQoeDataDetails {
    func isNullOrEmpty() -> Bool {
        return bitrate == nil && droppedFrames == nil && framesPerSecond == nil && timeToStart == nil
    }
}
