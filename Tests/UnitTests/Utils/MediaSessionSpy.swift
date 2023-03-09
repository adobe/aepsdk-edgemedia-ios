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
@testable import AEPEdgeMedia
import Foundation

class MediaSessionSpy: MediaSession {

    var events: [MediaXDMEvent] = []
    var hasQueueEventCalled = false
    var hasSessionEndCalled = false
    var hasSesionAbortCalled = false
    var hasHandleSessionUpdateCalled = false
    var hasHandleErrorResponseCalled = false
    var backendSessionId = ""
    var requestEventId = ""
    var errorData = [String: Any?]()

    override func handleSessionEnd() {
        hasSessionEndCalled = true
        sessionEndHandler?()
    }

    override func handleSessionAbort() {
        hasSesionAbortCalled = true
        sessionEndHandler?()
    }

    override func handleQueueEvent(_ event: MediaXDMEvent) {
        hasQueueEventCalled = true
        events.append(event)
    }

    override func handleSessionUpdate(requestEventId: String, backendSessionId: String?) {
        hasHandleSessionUpdateCalled = true
        self.requestEventId = requestEventId
        self.backendSessionId = backendSessionId ?? ""
    }

    override func handleErrorResponse(requestEventId: String, data: [String: Any?]) {
        hasHandleErrorResponseCalled = true
        self.requestEventId = requestEventId
        self.errorData = data
    }
}
