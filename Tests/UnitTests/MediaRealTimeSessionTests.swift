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
import XCTest

class MediaRealTimeSessionTests: XCTestCase {

    let dispatchQueue = DispatchQueue(label: "test.DispatchQueue")
    var mediaState = MediaState()
    var dispatchedEvents: [Event] = []
    static let trackerSessionId = "testTrackerSessionId"

    let errorResponseDataFromEdgeExtension: [String: Any] = ["status": Int64(400), "type": "https://ns.adobe.com/aep/errors/va-edge-0400-400"]
    let errorResponseDataWithExtraFields: [String: Any] = ["status": Int64(400), "type": "https://ns.adobe.com/aep/errors/va-edge-0400-400", "extra": "error message"]
    let invalidErrorResponses: [[String: Any]] = [
        [:],
        ["status": Int64(500), "type": "https://ns.adobe.com/aep/errors/edge-0400-400"],
        ["status": 400, "type": "https://ns.adobe.com/aep/errors/va-edge-0400-400"],
        ["status": Int64(400), "type": "https://ns.adobe.com/aëp/ërrors/va-ëdgë-0400-400"],
        ["status": Int64(500), "type": "https://ns.adobe.com/aep/errors/va-edge-0400-400"],
        ["status": Int64(404), "type": "https://ns.adobe.com/aep/errors/va-edge-0400-400"],
        ["type": "https://ns.adobe.com/aep/errors/va-edge-0400-400"],
        ["status": Int64(400)]
    ]

    var config = [MediaConstants.Configuration.MEDIA_CHANNEL: "testChannel",
                  MediaConstants.Configuration.MEDIA_APP_VERSION: "testAppVersion",
                  MediaConstants.Configuration.MEDIA_PLAYER_NAME: "testPlayerName"]

    func fakeDispatcher(_ event: Event) {
        dispatchedEvents.append(event)
    }

    func testTrackerSessionId_isValidStringWhenSetValidStringOnCreateSession() {
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        XCTAssertEqual("testTrackerSessionId", session.trackerSessionId)
    }

    func testTrackerSessionId_isNilWhenSetNilOnCreateSession() {
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: nil, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        XCTAssertNil(session.trackerSessionId)
    }

    func testQueueMediaEvents_withoutChannelConfig_doesNotDispatchEvent() {
        // setup
        mediaState.updateConfigurationSharedState([MediaConstants.Configuration.MEDIA_APP_VERSION: "testAppVersion",
                                                   MediaConstants.Configuration.MEDIA_PLAYER_NAME: "testPlayerName"])
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMDataHelper.getSessionStartData()))

        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.pauseStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(0, dispatchedEvents.count)
        XCTAssertEqual(3, session.getQueueSize())
    }

    func testQueueMediaEvents_withoutPlayerNameConfig_doesNotDispatchEvent() {
        // setup
        mediaState.updateConfigurationSharedState([MediaConstants.Configuration.MEDIA_CHANNEL: "testChannel", MediaConstants.Configuration.MEDIA_APP_VERSION: "testAppVersion"])
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMDataHelper.getSessionStartData()))

        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.pauseStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(0, dispatchedEvents.count)
        XCTAssertEqual(3, session.getQueueSize())
    }

    func testQueueSessionStart() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMDataHelper.getSessionStartData()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.sessionStart.edgeEventType(), expectedPath: "/va/v1/sessionStart")
    }

    func testQueueMediaEvents_withoutBackendSessionId_doesNotDispatchEventsOtherThanSessionStart() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.pauseStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.statesUpdate, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.bufferStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.bitrateChange, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.error, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.ping, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adSkip, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adBreakStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adBreakComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.chapterStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.chapterSkip, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.chapterComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionEnd, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        XCTAssertEqual(17, session.getQueueSize())
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.sessionStart.edgeEventType(), expectedPath: "/va/v1/sessionStart")
    }

    func testQueueMediaEvents_withoutBackendSessionId_dispatchesConsecutiveSessionStartEvents() {
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(4, dispatchedEvents.count)
        XCTAssertEqual(0, session.getQueueSize())
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.sessionStart.edgeEventType(), expectedPath: "/va/v1/sessionStart")
    }

    // The session start ping present at the top of the event queue will be dispatched but the other sessionStart events are blocked by low level events waiting for backendSessionId
    func testQueueMediaEvents_withoutBackendSessionId_dispatchesSessionStartEventAtTopOfEventQueue() {
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        var mediaCollection1 = XDMMediaCollection()
        mediaCollection1.sessionID = "session1"

        var mediaCollection2 = XDMMediaCollection()
        mediaCollection2.sessionID = "session2"

        var mediaCollection3 = XDMMediaCollection()
        mediaCollection3.sessionID = "session3"

        var mediaCollection4 = XDMMediaCollection()
        mediaCollection4.sessionID = "session4"

        // test
        // session start 1
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: mediaCollection1))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        // session start 2
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: mediaCollection2))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.pauseStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        // session start 3
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: mediaCollection3))
        // session start 4
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: mediaCollection4))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        XCTAssertEqual(5, session.getQueueSize())
        assertBackendSessionId(expectedBackendSessionId: "session1", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.sessionStart.edgeEventType(), expectedPath: "/va/v1/sessionStart")
    }

    func testQueue_sessionComplete() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.sessionComplete.edgeEventType(), expectedPath: "/va/v1/sessionComplete")
    }

    func testQueue_sessionEnd() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionEnd, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.sessionEnd.edgeEventType(), expectedPath: "/va/v1/sessionEnd")
    }

    func testQueue_play() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.play.edgeEventType(), expectedPath: "/va/v1/play")
    }

    func testQueue_pause() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.pauseStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.pauseStart.edgeEventType(), expectedPath: "/va/v1/pauseStart")
    }

    func testQueue_ping() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.ping, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.ping.edgeEventType(), expectedPath: "/va/v1/ping")
    }

    func testQueue_error() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.error, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.error.edgeEventType(), expectedPath: "/va/v1/error")
    }

    func testQueue_bufferStart() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.bufferStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.bufferStart.edgeEventType(), expectedPath: "/va/v1/bufferStart")
    }

    func testQueue_bitrateChange() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.bitrateChange, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.bitrateChange.edgeEventType(), expectedPath: "/va/v1/bitrateChange")
    }

    func testQueue_adBreakStart() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adBreakStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.adBreakStart.edgeEventType(), expectedPath: "/va/v1/adBreakStart")
    }

    func testQueue_adBreakComplete() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adBreakComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.adBreakComplete.edgeEventType(), expectedPath: "/va/v1/adBreakComplete")
    }

    func testQueue_adStart() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.adStart.edgeEventType(), expectedPath: "/va/v1/adStart")
    }

    func testQueue_adSkip() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adSkip, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.adSkip.edgeEventType(), expectedPath: "/va/v1/adSkip")
    }

    func testQueue_adComplete() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.adComplete.edgeEventType(), expectedPath: "/va/v1/adComplete")
    }

    func testQueue_chapterSkip() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.chapterSkip, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.chapterSkip.edgeEventType(), expectedPath: "/va/v1/chapterSkip")
    }

    func testQueue_chapterStart() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.chapterStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.chapterStart.edgeEventType(), expectedPath: "/va/v1/chapterStart")
    }

    func testQueue_chapterComplete() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.chapterComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.chapterComplete.edgeEventType(), expectedPath: "/va/v1/chapterComplete")
    }

    func testQueue_statesUpdate() {
        // setup
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake backendSessionId
        session.mediaBackendSessionId = "testBackendSessionId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.statesUpdate, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        // verify
        XCTAssertEqual(1, dispatchedEvents.count)
        assertBackendSessionId(expectedBackendSessionId: "testBackendSessionId", actualEvent: dispatchedEvents[0])
        assertEventTypeAndPath(actualEvent: dispatchedEvents[0], expectedEventType: XDMMediaEventType.statesUpdate.edgeEventType(), expectedPath: "/va/v1/statesUpdate")
    }

    func testHandleSessionUpdate_updatesBackendSessionIdAndDispatchesEvents() {
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake sessionStartEdgeRequestId
        session.sessionStartEdgeRequestId = "testSessionStartEdgeRequestId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.ping, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        session.handleSessionUpdate(requestEventId: "testSessionStartEdgeRequestId", backendSessionId: "testBackendSessionId")

        // verify
        XCTAssertTrue(session.isSessionActive)
        XCTAssertEqual(session.mediaBackendSessionId, "testBackendSessionId")
        // 1 sessionCreated event and the 5 queued media events
        XCTAssertEqual(5, dispatchedEvents.count)
        XCTAssertEqual(0, session.getQueueSize())
    }

    func testHandleSessionUpdate_withDifferentEdgeRequestId_ignoresTheEventAndWaitsForBackendSessionIdToDispatchQueuedEvents() {
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake sessionStartEdgeRequestId
        session.sessionStartEdgeRequestId = "testSessionStartEdgeRequestId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.ping, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        session.handleSessionUpdate(requestEventId: "testDifferentSessionStartEdgeRequestId", backendSessionId: "testBackendSessionId")

        // verify
        XCTAssertTrue(session.isSessionActive)
        XCTAssertEqual(5, session.getQueueSize())
    }

    func testHandleSessionUpdate_withEmptyBackendId_abortsMediaSession() {
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake sessionStartEdgeRequestId
        session.sessionStartEdgeRequestId = "testSessionStartEdgeRequestId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.ping, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        session.handleSessionUpdate(requestEventId: "testSessionStartEdgeRequestId", backendSessionId: "")

        // verify
        XCTAssertFalse(session.isSessionActive)
        XCTAssertEqual(0, dispatchedEvents.count)
        XCTAssertEqual(0, session.getQueueSize())
    }

    func testHandleSessionUpdate_withNilBackendId_abortsMediaSession() {
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake sessionStartEdgeRequestId
        session.sessionStartEdgeRequestId = "testSessionStartEdgeRequestId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adStart, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.adComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.ping, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.sessionComplete, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        session.handleSessionUpdate(requestEventId: "testSessionStartEdgeRequestId", backendSessionId: nil)

        // verify
        XCTAssertFalse(session.isSessionActive)
        XCTAssertEqual(0, dispatchedEvents.count)
        XCTAssertEqual(0, session.getQueueSize())
    }

    func testHandleErrorResponse_withVAEdge400Error_abortsSession() {
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake sessionStartEdgeRequestId
        session.sessionStartEdgeRequestId = "testSessionStartEdgeRequestId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.handleErrorResponse(requestEventId: "testSessionStartEdgeRequestId", data: errorResponseDataFromEdgeExtension)

        // verify
        XCTAssertEqual(0, dispatchedEvents.count)
        XCTAssertEqual(0, session.getQueueSize())
        XCTAssertFalse(session.isSessionActive)
    }

    func testHandleErrorResponse_withExtraFieldsInErrorData_abortsSession() {
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake sessionStartEdgeRequestId
        session.sessionStartEdgeRequestId = "testSessionStartEdgeRequestId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.handleErrorResponse(requestEventId: "testSessionStartEdgeRequestId", data: errorResponseDataWithExtraFields)

        // verify
        XCTAssertEqual(0, dispatchedEvents.count)
        XCTAssertEqual(0, session.getQueueSize())
        XCTAssertFalse(session.isSessionActive)
    }

    func testHandleErrorResponse_withDifferentEdgeRequestIdAndValidError_doesNotAbortSession() {
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake sessionStartEdgeRequestId
        session.sessionStartEdgeRequestId = "testSessionStartEdgeRequestId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))
        session.handleErrorResponse(requestEventId: "testDifferentSessionStartEdgeRequestId", data: errorResponseDataFromEdgeExtension)

        // verify
        XCTAssertEqual(0, dispatchedEvents.count)
        XCTAssertEqual(1, session.getQueueSize())
        XCTAssertTrue(session.isSessionActive)
    }

    func testHandleErrorResponse_withInvalidErrorData_doesNotAbortSession() {
        mediaState.updateConfigurationSharedState(config)
        let session = MediaRealTimeSession(id: "testId", trackerSessionId: Self.trackerSessionId, state: mediaState, dispatchQueue: dispatchQueue, dispatcher: fakeDispatcher)

        // set fake sessionStartEdgeRequestId
        session.sessionStartEdgeRequestId = "testSessionStartEdgeRequestId"

        // test
        session.queue(event: MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(1), mediaCollection: XDMMediaCollection()))

        for errorData in invalidErrorResponses {
            session.handleErrorResponse(requestEventId: "testSessionStartEdgeRequestId", data: errorData)
        }

        // verify
        XCTAssertEqual(0, dispatchedEvents.count)
        XCTAssertEqual(1, session.getQueueSize())
        XCTAssertTrue(session.isSessionActive)
    }

    // Test Helper

    private func assertBackendSessionId(expectedBackendSessionId: String, actualEvent: Event) {
        guard let eventData = actualEvent.data else {
            XCTFail("Event data should not be null")
            return
        }

        guard let xdmData = eventData["xdm"] as? [String: Any] else {
            XCTFail("XDM field for the event should not be null")
            return
        }

        guard let mediaCollection = xdmData["mediaCollection"] as? [String: Any] else {
            XCTFail("MediaCollection field inside the XDM Data should not be null")
            return
        }

        XCTAssertEqual(expectedBackendSessionId, mediaCollection["sessionID"] as? String ?? "")
    }

    private func assertEventTypeAndPath(actualEvent: Event, expectedEventType: String, expectedPath: String) {
        guard let eventData = actualEvent.data else {
            XCTFail("Event data should not be null")
            return
        }

        guard let xdmData = eventData["xdm"] as? [String: Any] else {
            XCTFail("XDM field for the event should not be null")
            return
        }

        let actualEventType = xdmData["eventType"] as? String ?? ""
        XCTAssertEqual(expectedEventType, actualEventType, "Expected eventType:(\(expectedEventType)) does not match the actual eventType:(\(actualEventType))")

        guard let requestData = eventData["request"] as? [String: String] else {
            XCTFail("Request field for the event should not be null")
            return
        }

        let actualPath = requestData["path"] ?? ""
        XCTAssertEqual(expectedPath, actualPath, "Expected path:(\(expectedPath)) does not match the actual eventType(\(actualPath))")
    }

    private func getDateFormattedTimestampFor(_ value: Int64) -> Date {
        return Date(timeIntervalSince1970: Double(value / 1000))
    }
}
