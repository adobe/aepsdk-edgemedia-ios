/*
 Copyright 2022 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http:www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPCore
@testable import AEPEdgeMedia

class Timeout: BaseScenarioTest {

    let standardStateCC = StateInfo(stateName: MediaConstants.PlayerState.CLOSED_CAPTION)!
    let mediaInfoWithDefaultPreroll = MediaInfo(id: "mediaID", name: "mediaName", streamType: "vod", mediaType: MediaType.Video, length: 30.0)!
    let mediaMetadata = ["media.show": "sampleshow", "key1": "value1", "key2": "мểŧẳđαţả"]
    var mediaSharedState: [String: Any] = ["edgemedia.channel": "test_channel", "edgemedia.playerName": "test_playerName", "edgemedia.appVersion": "test_appVersion"]

    override func setUp() {
        super.setup()
    }

    // SDK automatically restarts the long running session >= 24 hours
    func testSessionActiveForMoreThan24Hours_usingRealTimeTracker_shouldEndAndResumeSessionAutomatically() {
        // setup
        let sessionId1 = "1"
        let sessionId2 = "2"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: sessionId1, sharedStateData: mediaSharedState)

        // test
        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: sessionId1, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackPlay()
        // wait for 24 hours
        incrementTrackerTime(seconds: 86400, updatePlayhead: true)
        wait()

        // mock sessionIDUpdate for restart sceario session2
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: sessionId2, sessionStartEvent: dispatchedEvents[8644], fakeBackendId: backendSessionId)

        // wait for 20 seconds
        incrementTrackerTime(seconds: 20, updatePlayhead: true)
        mediaTracker.trackComplete()

        var resumedMediaInfo = mediaInfoWithDefaultPreroll.toMap()
        resumedMediaInfo["media.resumed"] = true

        var expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateSessionCreatedEvent(trackerSessionId: mediaEventProcessorSpy.getTrackerSessionId(sessionId: sessionId1), backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 1, backendSessionId: backendSessionId)
        ]

        var pingList = [Event]()
        for i in stride(from: 11, to: 86400, by: 10) {
            pingList.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: Int64(i), ts: TimeInterval(i), backendSessionId: backendSessionId))
        }

        expectedEvents.insert(contentsOf: pingList, at: expectedEvents.endIndex)
        expectedEvents.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionEnd, playhead: 86400, ts: 86400, backendSessionId: backendSessionId))
        // Session2

        let expectedEventsSession2: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 86400, ts: 86400, backendSessionId: backendSessionId, info: resumedMediaInfo, metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateSessionCreatedEvent(trackerSessionId: mediaEventProcessorSpy.getTrackerSessionId(sessionId: sessionId2), backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 86400, ts: 86400, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 86401, ts: 86401, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 86411, ts: 86411, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 86420, ts: 86420, backendSessionId: backendSessionId)
        ]
        expectedEvents.insert(contentsOf: expectedEventsSession2, at: expectedEvents.endIndex)

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)

    }

    func testIdleTimeOut_RealTimeTrackershouldSendSessionEndAutomaticallyAfterIdleTimeout() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)

        // test idle timeout after 30 mins
        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 3, updatePlayhead: true)
        mediaTracker.trackPause()
        // wait for 30 mins
        incrementTrackerTime(seconds: 1800, updatePlayhead: false)

        var expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateSessionCreatedEvent(trackerSessionId: mediaEventProcessorSpy.getTrackerSessionId(sessionId: curSessionId), backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 1, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 3, ts: 3, backendSessionId: backendSessionId)
        ]
        var pingList = [Event]()
        for i in stride(from: 3, to: 1793, by: 10) {
            pingList.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 3, ts: TimeInterval(i + 10), backendSessionId: backendSessionId))
        }

        expectedEvents.insert(contentsOf: pingList, at: expectedEvents.endIndex)
        expectedEvents.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionEnd, playhead: 3, ts: 1803, backendSessionId: backendSessionId))

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }

    // trackPlay after sessionEnd because of idleTimeout will resume the session.
    // trackSessionStart with resume flag set to true is sent by the SDK sutomatically on receiving play on idle session
    func testPlay_afterIdleTimeOut_usingRealTimeTracker_shouldAutomaticallyStartNewSessionWithResumeFlagSet() {
        // setup
        let sessionId1 = "1"
        let sessionId2 = "2"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: sessionId1, sharedStateData: mediaSharedState)

        // test idle timeout after 30 mins and issue a play event, new session start
        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: sessionId1, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 3, updatePlayhead: true)
        mediaTracker.trackPause()
        // wait for 30 mins
        incrementTrackerTime(seconds: 600, updatePlayhead: false)
        mediaTracker.trackEvent(event: MediaEvent.StateStart, info: standardStateCC.toMap())
        incrementTrackerTime(seconds: 600, updatePlayhead: false)
        mediaTracker.trackEvent(event: MediaEvent.StateEnd, info: standardStateCC.toMap())
        incrementTrackerTime(seconds: 600, updatePlayhead: false)
        mediaTracker.trackPlay()

        wait()
        // mock sessionIDUpdate for restart sceario session2
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: sessionId2, sessionStartEvent: dispatchedEvents[187], fakeBackendId: backendSessionId)
        incrementTrackerTime(seconds: 3, updatePlayhead: true)
        mediaTracker.trackComplete()

        var expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateSessionCreatedEvent(trackerSessionId: mediaEventProcessorSpy.getTrackerSessionId(sessionId: sessionId1), backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 1, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 3, ts: 3, backendSessionId: backendSessionId)
        ]

        var pingList1 = [Event]()
        for i in stride(from: 3, to: 603, by: 10) {
            pingList1.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 3, ts: TimeInterval(i + 10), backendSessionId: backendSessionId))
        }

        expectedEvents.insert(contentsOf: pingList1, at: expectedEvents.endIndex)
        expectedEvents.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 3, ts: 603, backendSessionId: backendSessionId, info: standardStateCC.toMap(), stateStart: true))

        var pingList2 = [Event]()
        for i in stride(from: 603, to: 1203, by: 10) {
            pingList2.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 3, ts: TimeInterval(i + 10), backendSessionId: backendSessionId))
        }
        expectedEvents.insert(contentsOf: pingList2, at: expectedEvents.endIndex)
        expectedEvents.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 3, ts: 1203, backendSessionId: backendSessionId, info: standardStateCC.toMap(), stateStart: false))

        var pingList3 = [Event]()
        for i in stride(from: 1203, to: 1793, by: 10) {
            pingList3.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 3, ts: TimeInterval(i + 10), backendSessionId: backendSessionId))
        }
        expectedEvents.insert(contentsOf: pingList3, at: expectedEvents.endIndex)
        expectedEvents.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionEnd, playhead: 3, ts: 1803, backendSessionId: backendSessionId))

        var resumedMediaInfo = mediaInfoWithDefaultPreroll.toMap()
        resumedMediaInfo["media.resumed"] = true

        let expectedEventsSession2: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 3, ts: 1803, backendSessionId: backendSessionId, info: resumedMediaInfo, metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateSessionCreatedEvent(trackerSessionId: mediaEventProcessorSpy.getTrackerSessionId(sessionId: sessionId2), backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 3, ts: 1803, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 4, ts: 1804, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 6, ts: 1806, backendSessionId: backendSessionId)
        ]
        expectedEvents.insert(contentsOf: expectedEventsSession2, at: expectedEvents.endIndex)

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }

}
