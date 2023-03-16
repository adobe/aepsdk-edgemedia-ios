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

import AEPCore
import Foundation

extension Event {
    /// Returns tracker id associated with Event
    var trackerId: String? {
        return data?[MediaConstants.Tracker.ID] as? String
    }

    /// Returns client generated session id associated with Event
    var sessionId: String? {
        return data?[MediaConstants.Tracker.SESSION_ID] as? String
    }

    /// Returns tracker config associated with EVENT_SOURCE_TRACKER_REQUEST Event
    var trackerConfig: [String: Any]? {
        guard source == MediaConstants.Media.EVENT_SOURCE_CREATE_TRACKER else {
            return nil
        }
        return data?[MediaConstants.Tracker.EVENT_PARAM] as? [String: Any]
    }

    var param: [String: Any]? {
        return data?[MediaConstants.Tracker.EVENT_PARAM] as? [String: Any]
    }

    var metadata: [String: String]? {
        return data?[MediaConstants.Tracker.EVENT_METADATA] as? [String: String]
    }

    var name: String? {
        return data?[MediaConstants.Tracker.EVENT_NAME] as? String
    }

    var eventTs: Int64? {
        return data?[MediaConstants.Tracker.EVENT_TIMESTAMP] as? Int64
    }

    var requestEventId: String? {
        return data?[MediaConstants.Edge.EventData.REQUEST_EVENT_ID] as? String
    }

    var backendSessionId: String? {
        guard let payload = data?[MediaConstants.Edge.EventData.PAYLOAD] as? [[String: Any]], !payload.isEmpty else {
            return nil
        }

        return payload[0][MediaConstants.Edge.EventData.SESSION_ID] as? String
    }
}
