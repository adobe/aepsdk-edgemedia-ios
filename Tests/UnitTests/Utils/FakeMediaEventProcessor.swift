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

@testable import AEPCore
@testable import AEPEdgeMedia
import Foundation

class FakeMediaEventProcessor: MediaEventProcessor {

    private var sessionEnded = false
    private var processedEvents: [String: [MediaXDMEvent]] = [:]
    private var currentSessionId: String = "-1"
    private var isSessionStartCalled = false
    var dispatcher: ((_ event: Event) -> Void)?
    var notifyErrorResponseCalled = false
    var notifyErrorResponseCalledWithRequestEventId = ""
    var notifyErrorResponseCalledWithData = [String: Any?]()
    var notifyBackendSessionIdCalled = false
    var notifyBackendSessionIdCalledWithBackendSessionId = ""
    var notifyBackendSessionIdCalledWithRequestEventId = ""

    init() {
        super.init(dispatcher: dispatcher)
    }

    override func createSession(trackerConfig: [String: Any], trackerSessionId: String?) -> String? {
        isSessionStartCalled = true
        var intSessionId = (Int(currentSessionId) ?? 0)
        intSessionId += 1
        currentSessionId = "\(intSessionId)"
        processedEvents[currentSessionId] = []
        // for testing failed session creation
        if let forcedFail = trackerConfig["testFail"] as? Bool, forcedFail == true {
            return nil
        }
        return currentSessionId
    }

    override func endSession(sessionId: String) {
        sessionEnded = true
    }

    override func processEvent(sessionId: String, event: MediaXDMEvent) {
        processedEvents[sessionId]?.append(event)
    }

    override func notifyErrorResponse(requestEventId: String, data: [String: Any?]) {
        notifyErrorResponseCalled = true
        notifyErrorResponseCalledWithData = data
        notifyErrorResponseCalledWithRequestEventId = requestEventId
    }

    override func notifyBackendSessionId(requestEventId: String, backendSessionId: String?) {
        notifyBackendSessionIdCalled = true
        notifyBackendSessionIdCalledWithBackendSessionId = backendSessionId ?? "unknown"
        notifyBackendSessionIdCalledWithRequestEventId = requestEventId
    }

    func getEventFromActiveSession(index: Int) -> MediaXDMEvent? {
        return getEvent(sessionId: currentSessionId, index: index)
    }

    func getEvent(sessionId: String, index: Int) -> MediaXDMEvent? {
        guard let events = processedEvents[sessionId], events.count != 0 else {
            return nil
        }

        if index >= events.count {
            return nil
        }

        return events[index]
    }

    func getEventCountFromActiveSession() -> Int {
        return getEventCount(sessionId: currentSessionId)
    }

    func getEventCount(sessionId: String) -> Int {
        return processedEvents[sessionId]?.count ?? 0
    }

    func clearEventsFromActiveSession() {
        if processedEvents[currentSessionId] != nil {
            processedEvents[currentSessionId]?.removeAll()
        }
    }
}
