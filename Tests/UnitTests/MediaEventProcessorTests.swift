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
import XCTest

class MediaEventProcessorTests: XCTestCase {

    static let trackerSessionId = "testTrackerSessionId"

    func testCreateSession() {
        // test
        let mediaProcessor = MediaEventProcessor(dispatcher: nil)
        let sessionId = mediaProcessor.createSession()

        // Assert
        XCTAssertNotNil(sessionId)
        XCTAssertTrue(mediaProcessor.mediaSessions.keys.contains(sessionId))
        XCTAssertNotNil(mediaProcessor.mediaSessions[sessionId])

    }

    func testProcessEvent_validSesionId() {
        // Action
        let mediaProcessor = MediaEventProcessor(dispatcher: nil)
        let sessionId = mediaProcessor.createSession()

        let mediaSessionSpy = MediaSessionSpy(id: sessionId, state: MediaState(), dispatcher: nil)
        mediaProcessor.mediaSessions[sessionId] = mediaSessionSpy
        mediaProcessor.processEvent(sessionId: sessionId, event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: Date(timeIntervalSince1970: 0), mediaCollection: XDMMediaCollection()))
        Thread.sleep(forTimeInterval: 0.25)

        // Assert
        XCTAssertTrue(mediaSessionSpy.hasQueueEventCalled)
        XCTAssertTrue(mediaSessionSpy.events.contains { event in
            event.eventType == XDMMediaEventType.sessionStart
        })
    }

    func testProcessEvent_invalidSessionId() {
        // setup
        let mediaProcessor = MediaEventProcessor(dispatcher: nil)
        let mediaSessionSpy = MediaSessionSpy(id: "SessionID-1", state: MediaState(), dispatcher: nil)

        // test
        mediaProcessor.processEvent(sessionId: "InvalidSessionID", event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: Date(timeIntervalSince1970: 0), mediaCollection: XDMMediaCollection()))
        Thread.sleep(forTimeInterval: 0.25)

        // Assert
        XCTAssertFalse(mediaSessionSpy.hasQueueEventCalled)
        XCTAssertTrue(mediaSessionSpy.events.isEmpty)

    }

    func testEndSession_validSessionId() {
        // test
        let mediaProcessor = MediaEventProcessor(dispatcher: nil)
        let sessionId = mediaProcessor.createSession()

        // Assert
        XCTAssertNotNil(sessionId)
        XCTAssertTrue(mediaProcessor.mediaSessions.keys.contains(sessionId))
        XCTAssertNotNil(mediaProcessor.mediaSessions[sessionId])
        let mediaSessionSpy = MediaSessionSpy(id: sessionId, state: MediaState(), dispatcher: nil)
        mediaProcessor.mediaSessions[sessionId] = mediaSessionSpy
        mediaProcessor.endSession(sessionId: sessionId)
        Thread.sleep(forTimeInterval: 0.25)

        // Assert
        XCTAssertTrue(mediaSessionSpy.hasSessionEndCalled)
        XCTAssertFalse(mediaProcessor.mediaSessions.keys.contains(sessionId))

    }

    func testEndSession_invalidSessionId() {
        // setup
        let mediaProcessor = MediaEventProcessor(dispatcher: nil)
        let mediaSessionSpy = MediaSessionSpy(id: "SessionID-1", state: MediaState(), dispatcher: nil)

        // test
        mediaProcessor.endSession(sessionId: "InvalidSessionID")
        Thread.sleep(forTimeInterval: 0.25)

        // Assert
        XCTAssertFalse(mediaSessionSpy.hasSessionEndCalled)

    }

    func testAbortAllSession_validSessionIds() {
        // test
        let mediaProcessor = MediaEventProcessor(dispatcher: nil)
        let sessionId1 = mediaProcessor.createSession()
        let sessionId2 = mediaProcessor.createSession()

        // Assert
        XCTAssertNotNil(sessionId1)
        XCTAssertNotNil(sessionId2)
        XCTAssertTrue(mediaProcessor.mediaSessions.keys.contains(sessionId1))
        XCTAssertTrue(mediaProcessor.mediaSessions.keys.contains(sessionId2))
        XCTAssertNotNil(mediaProcessor.mediaSessions[sessionId1])
        XCTAssertNotNil(mediaProcessor.mediaSessions[sessionId2])

        let mediaSessionSpy1 = MediaSessionSpy(id: sessionId1, state: MediaState(), dispatcher: nil)
        let mediaSessionSpy2 = MediaSessionSpy(id: sessionId2, state: MediaState(), dispatcher: nil)
        mediaProcessor.mediaSessions[sessionId1] = mediaSessionSpy1
        mediaProcessor.mediaSessions[sessionId2] = mediaSessionSpy2

        mediaProcessor.abortAllSessions()
        Thread.sleep(forTimeInterval: 0.25)

        // Assert
        XCTAssertTrue(mediaSessionSpy1.hasSesionAbortCalled)
        XCTAssertTrue(mediaSessionSpy2.hasSesionAbortCalled)
        XCTAssertFalse(mediaProcessor.mediaSessions.keys.contains(sessionId1))
        XCTAssertFalse(mediaProcessor.mediaSessions.keys.contains(sessionId2))

    }

    func testAbortAllSession_WithValidAndInvalidSesions() {
        // setup
        let mediaProcessor = MediaEventProcessor(dispatcher: nil)

        let mediaSessionSpy1 = MediaSessionSpy(id: "sessionId1", state: MediaState(), dispatcher: nil)
        let mediaSessionSpy2 = MediaSessionSpy(id: "SessionId2", state: MediaState(), dispatcher: nil)

        mediaProcessor.mediaSessions["sessionId2"] = mediaSessionSpy2

        // test
        mediaProcessor.abortAllSessions()
        Thread.sleep(forTimeInterval: 0.25)

        // Assert
        XCTAssertFalse(mediaSessionSpy1.hasSesionAbortCalled)
        XCTAssertTrue(mediaSessionSpy2.hasSesionAbortCalled)

    }

    func testUpdateSessionId() {
        // test
        let mediaProcessor = MediaEventProcessor(dispatcher: nil)
        let sessionId = mediaProcessor.createSession()

        // Assert
        XCTAssertNotNil(sessionId)
        XCTAssertTrue(mediaProcessor.mediaSessions.keys.contains(sessionId))
        XCTAssertNotNil(mediaProcessor.mediaSessions[sessionId])

        let mediaSessionSpy = MediaSessionSpy(id: sessionId, state: MediaState(), dispatcher: nil)
        mediaProcessor.mediaSessions[sessionId] = mediaSessionSpy
        mediaProcessor.notifyBackendSessionId(requestEventId: "testRequestEventId", backendSessionId: "testSessionId")
        Thread.sleep(forTimeInterval: 0.25)

        // Assert
        XCTAssertTrue(mediaSessionSpy.hasHandleSessionUpdateCalled)
        XCTAssertEqual("testRequestEventId", mediaSessionSpy.requestEventId)
        XCTAssertEqual("testSessionId", mediaSessionSpy.backendSessionId)
    }

    func testHandleErrorResponse() {
        // test
        let mediaProcessor = MediaEventProcessor(dispatcher: nil)
        let sessionId = mediaProcessor.createSession()

        // Assert
        XCTAssertNotNil(sessionId)
        XCTAssertTrue(mediaProcessor.mediaSessions.keys.contains(sessionId))
        XCTAssertNotNil(mediaProcessor.mediaSessions[sessionId])

        let mediaSessionSpy = MediaSessionSpy(id: sessionId, state: MediaState(), dispatcher: nil)
        mediaProcessor.mediaSessions[sessionId] = mediaSessionSpy
        mediaProcessor.notifyErrorResponse(requestEventId: "testRequestEventId", data: ["error1": "errorMsg"])
        Thread.sleep(forTimeInterval: 0.25)

        // Assert
        XCTAssertTrue(mediaSessionSpy.hasHandleErrorResponseCalled)
        XCTAssertEqual("testRequestEventId", mediaSessionSpy.requestEventId)
        XCTAssertEqual("errorMsg", mediaSessionSpy.errorData["error1"] as? String ?? "")
    }
}
