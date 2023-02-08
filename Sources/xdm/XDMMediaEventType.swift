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

enum XDMMediaEventType: String, Encodable, Equatable {
    case sessionStart = "sessionStart"
    case sessionComplete = "sessionComplete"
    case sessionEnd = "sessionEnd"
    case play = "play"
    case pauseStart = "pauseStart"
    case ping = "ping"
    case error = "error"
    case bufferStart = "bufferStart"
    case bitrateChange = "bitrateChange"
    case adBreakStart = "adBreakStart"
    case adBreakComplete = "adBreakComplete"
    case adStart = "adStart"
    case adSkip = "adSkip"
    case adComplete = "adComplete"
    case chapterSkip = "chapterSkip"
    case chapterStart = "chapterStart"
    case chapterComplete = "chapterComplete"
    case statesUpdate = "statesUpdate"

    func edgeEventType() -> String {
        return "media.\(self.rawValue)"
    }
}
