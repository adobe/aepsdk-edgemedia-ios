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

class MediaState {
    private static let LOG_TAG = MediaConstants.LOG_TAG
    private static let CLASS_NAME = "MediaState"

    private(set) var channel: String?
    private(set) var playerName: String?
    private(set) var appVersion: String?

    //  Updates the configuration shared state data related to media edge.
    /// - Parameter data: the configuration shared state data
    func updateConfigurationSharedState(_ data: [String: Any]?) {
        guard let configurationData = data else {
            Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Failed to extract configuration data (event data was nil).")
            return
        }
        self.channel = configurationData[MediaConstants.Configuration.MEDIA_CHANNEL] as? String
        self.playerName = configurationData[MediaConstants.Configuration.MEDIA_PLAYER_NAME] as? String
        self.appVersion = configurationData[MediaConstants.Configuration.MEDIA_APP_VERSION] as? String
    }

    func hasRequiredConfiguration() -> Bool {
        return !(channel ?? "").isEmpty && !(playerName ?? "").isEmpty
    }
}
