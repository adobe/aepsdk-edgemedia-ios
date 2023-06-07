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

class SimplePlayback: BaseScenarioTest {

    var mediaInfo = MediaInfo(id: "mediaID", name: "mediaName", streamType: "aod", mediaType: MediaType.Audio, length: 30, prerollWaitingTime: 0)!
    var mediaMetadata = ["media.show": "sampleshow", "key1": "value1"]
    var mediaSharedState: [String: Any] = ["edgeMedia.channel": "test_channel", "edgeMedia.playerName": "test_playerName", "edgeMedia.appVersion": "test_appVersion"]

    override func setUp() {
        super.setup()
    }

    // tests
    func testTrackSimplePlayBack_usingRealTimeTracker_dispatchesAllEventsInOrderWithCorrectPlayheadAndTS() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)

        // test
        mediaTracker.trackSessionStart(info: mediaInfo.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 5, updatePlayhead: true) // content start play ping at 1 second
        mediaTracker.trackPause()
        incrementTrackerTime(seconds: 15, updatePlayhead: false) // will send ping since interval > 10 seconds
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 15, updatePlayhead: true) // will send ping since interval > 10 seconds
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 1, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 5, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 5, ts: 15, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 5, ts: 20, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 15, ts: 30, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 20, ts: 35, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }

    func testTrackSimplePlayBack_withSessionEnd_usingRealTimeTracker_dispatchesAllEventsInOrderWithCorrectPlayheadAndTS() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)

        // test
        mediaTracker.trackSessionStart(info: mediaInfo.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 5, updatePlayhead: true) // content start play ping at 1 second
        mediaTracker.trackPause()
        incrementTrackerTime(seconds: 15, updatePlayhead: false) // will send ping since interval > 10 seconds
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 15, updatePlayhead: true) // will send ping since interval > 10 seconds
        mediaTracker.trackSessionEnd() // sends sessionEnd event

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 1, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 5, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 5, ts: 15, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 5, ts: 20, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 15, ts: 30, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionEnd, playhead: 20, ts: 35, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }

    func testTrackSimplePlayBack_withBuffer_usingRealTimeTracker_dispatchesAllEventsInOrderWithCorrectPlayheadAndTS() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)

        // test
        mediaTracker.trackSessionStart(info: mediaInfo.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackEvent(event: MediaEvent.BufferStart)
        incrementTrackerTime(seconds: 5, updatePlayhead: false) // content start play ping at 1 second
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 5, updatePlayhead: true)
        mediaTracker.trackEvent(event: MediaEvent.BufferStart)
        incrementTrackerTime(seconds: 15, updatePlayhead: false)
        mediaTracker.trackEvent(event: MediaEvent.BufferComplete)
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 15, updatePlayhead: true)
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.bufferStart, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 6, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.bufferStart, playhead: 5, ts: 10, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 5, ts: 20, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 5, ts: 25, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 15, ts: 35, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 20, ts: 40, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }

    func testTrackSimplePlayBack_withSeek_usingRealTimeTracker_dispatchesAllEventsInOrderWithCorrectPlayheadAndTS() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)

        // test
        mediaTracker.trackSessionStart(info: mediaInfo.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackEvent(event: MediaEvent.SeekStart)
        incrementTrackerTime(seconds: 5, updatePlayhead: false)
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 5, updatePlayhead: true)
        mediaTracker.trackEvent(event: MediaEvent.SeekStart)
        incrementTrackerTime(seconds: 15, updatePlayhead: false) // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.SeekComplete)
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 15, updatePlayhead: true) // will send ping since interval > 10 seconds
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 6, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 5, ts: 10, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 5, ts: 20, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 5, ts: 25, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 15, ts: 35, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 20, ts: 40, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }
}
