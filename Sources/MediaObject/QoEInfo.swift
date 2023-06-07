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

class QoEInfo: Equatable {
    private static let LOG_TAG = MediaConstants.LOG_TAG
    private static let CLASS_NAME = "QoEInfo"
    let bitrate: Int
    let droppedFrames: Int
    let fps: Int
    let startupTime: Int

    static func == (lhs: QoEInfo, rhs: QoEInfo) -> Bool {
        return  lhs.bitrate == rhs.bitrate &&
            lhs.droppedFrames == rhs.droppedFrames &&
            lhs.fps == rhs.fps &&
            lhs.startupTime == rhs.startupTime
    }

    init?(bitrate: Int, droppedFrames: Int, fps: Int, startupTime: Int) {
        guard bitrate >= 0 else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error creating QoEInfo, bitrate must not be less than zero")
            return nil
        }

        guard droppedFrames >= 0 else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error creating QoEInfo, dropped frames must not be less than zero")
            return nil
        }

        guard fps >= 0 else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error creating QoEInfo, fps must not be less than zero")
            return nil
        }

        guard startupTime >= 0 else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error creating QoEInfo, startup time must not be less than zero")
            return nil
        }

        self.bitrate = bitrate
        self.droppedFrames = droppedFrames
        self.fps = fps
        self.startupTime = startupTime
    }

    convenience init?(info: [String: Any]?) {
        guard info != nil else {
            return nil
        }

        guard let bitrate = info?[MediaConstants.QoEInfo.BITRATE] as? Int else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error parsing QoEInfo, invalid bitrate")
            return nil
        }

        guard let droppedFrames = info?[MediaConstants.QoEInfo.DROPPED_FRAMES] as? Int else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error parsing QoEInfo, invalid dropped frames")
            return nil
        }

        guard let fps = info?[MediaConstants.QoEInfo.FPS] as? Int else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error parsing QoEInfo, invalid fps")
            return nil
        }

        guard let startupTime = info?[MediaConstants.QoEInfo.STARTUP_TIME] as? Int else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Error parsing QoEInfo, invalid start time")
            return nil
        }

        self.init(bitrate: bitrate, droppedFrames: droppedFrames, fps: fps, startupTime: startupTime)
    }

    func toMap() -> [String: Any] {
        var qoeInfoMap: [String: Any] = [:]
        qoeInfoMap[MediaConstants.QoEInfo.BITRATE] = self.bitrate
        qoeInfoMap[MediaConstants.QoEInfo.DROPPED_FRAMES] = self.droppedFrames
        qoeInfoMap[MediaConstants.QoEInfo.FPS] = self.fps
        qoeInfoMap[MediaConstants.QoEInfo.STARTUP_TIME] = self.startupTime

        return qoeInfoMap
    }
}
