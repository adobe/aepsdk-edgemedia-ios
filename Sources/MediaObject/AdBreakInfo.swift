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

import AEPServices
import Foundation

class AdBreakInfo: Equatable {
    private static let LOG_TAG = MediaConstants.LOG_TAG
    private static let CLASS_NAME = "AdBreakInfo"
    let name: String
    let position: Int
    let startTime: Int

    static func == (lhs: AdBreakInfo, rhs: AdBreakInfo) -> Bool {
        return  lhs.name == rhs.name &&
            lhs.position == rhs.position &&
            lhs.startTime == rhs.startTime
    }

    init?(name: String, position: Int, startTime: Int) {

        guard !name.isEmpty else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error creating AdBreakInfo, name must not be Empty")
            return nil
        }

        guard position >= 1 else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error creating AdBreakInfo, position must be greater than zero")
            return nil
        }

        guard startTime >= 0 else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error creating AdBreakInfo, start time must not be less than zero")
            return nil
        }

        self.name = name
        self.position = position
        self.startTime = startTime
    }

    convenience init?(info: [String: Any]?) {
        guard info != nil else {
            return nil
        }

        guard let name = info?[MediaConstants.AdBreakInfo.NAME] as? String else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error parsing AdBreakInfo, invalid name")
            return nil
        }

        guard let position = info?[MediaConstants.AdBreakInfo.POSITION] as? Int else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error parsing AdBreakInfo, invalid position")
            return nil
        }

        guard let startTime = info?[MediaConstants.AdBreakInfo.START_TIME] as? Int else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error parsing AdBreakInfo, invalid start time")
            return nil
        }

        self.init(name: name, position: position, startTime: startTime)
    }

    func toMap() -> [String: Any] {
        var adBreakInfoMap: [String: Any] = [:]
        adBreakInfoMap[MediaConstants.AdBreakInfo.NAME] = self.name
        adBreakInfoMap[MediaConstants.AdBreakInfo.POSITION] = self.position
        adBreakInfoMap[MediaConstants.AdBreakInfo.START_TIME] = self.startTime

        return adBreakInfoMap
    }
}
