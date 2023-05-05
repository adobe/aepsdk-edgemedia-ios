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

class CustomStatePlayback: BaseScenarioTest {

    let mediaInfo = MediaInfo(id: "mediaID", name: "mediaName", streamType: "aod", mediaType: MediaType.Audio, length: 30, prerollWaitingTime: 0)!
    let mediaMetadata = ["media.show": "sampleshow", "key1": "value1", "key2": "мểŧẳđαţả"]

    let customStateInfo = StateInfo(stateName: "customStateName")!
    let standardStateMute = StateInfo(stateName: MediaConstants.PlayerState.MUTE)!
    let standardStateFullScreen = StateInfo(stateName: MediaConstants.PlayerState.FULLSCREEN)!

    var mediaSharedState: [String: Any] = ["edgeMedia.channel": "test_channel", "edgeMedia.playerName": "test_playerName", "edgeMedia.appVersion": "test_appVersion"]

    override func setUp() {
        super.setup()
    }

    // tests
    func testCustomState_usingRealTimeTracker_dispatchesStateStartAndEndEvents() {
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
        mediaTracker.trackEvent(event: MediaEvent.StateStart, info: customStateInfo.toMap())
        incrementTrackerTime(seconds: 5, updatePlayhead: true)
        mediaTracker.trackEvent(event: MediaEvent.StateEnd, info: customStateInfo.toMap())
        incrementTrackerTime(seconds: 5, updatePlayhead: true)
        mediaTracker.trackEvent(event: MediaEvent.StateStart, info: standardStateMute.toMap())
        mediaTracker.trackEvent(event: MediaEvent.StateStart, info: standardStateFullScreen.toMap())
        incrementTrackerTime(seconds: 5, updatePlayhead: true)
        mediaTracker.trackEvent(event: MediaEvent.StateEnd, info: standardStateMute.toMap())
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: customStateInfo.toMap(), stateStart: true),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 1, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 5, ts: 5, backendSessionId: backendSessionId, info: customStateInfo.toMap(), stateStart: false),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 10, ts: 10, backendSessionId: backendSessionId, info: standardStateMute.toMap(), stateStart: true),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 10, ts: 10, backendSessionId: backendSessionId, info: standardStateFullScreen.toMap(), stateStart: true),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 11, ts: 11, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 15, ts: 15, backendSessionId: backendSessionId, info: standardStateMute.toMap(), stateStart: false),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 15, ts: 15, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)

    }

    func testCustomState_withoutStateEnd_usingRealTimeTracker_dispatchesStateStartEvents() {
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
        mediaTracker.trackEvent(event: MediaEvent.StateStart, info: customStateInfo.toMap())
        incrementTrackerTime(seconds: 5, updatePlayhead: true)
        incrementTrackerTime(seconds: 5, updatePlayhead: true)
        mediaTracker.trackEvent(event: MediaEvent.StateStart, info: standardStateMute.toMap())
        mediaTracker.trackEvent(event: MediaEvent.StateStart, info: standardStateFullScreen.toMap())
        incrementTrackerTime(seconds: 5, updatePlayhead: true)
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: customStateInfo.toMap(), stateStart: true),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 1, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 10, ts: 10, backendSessionId: backendSessionId, info: standardStateMute.toMap(), stateStart: true),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 10, ts: 10, backendSessionId: backendSessionId, info: standardStateFullScreen.toMap(), stateStart: true),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 11, ts: 11, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 15, ts: 15, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)

    }

    func testCustomState_moreThanTenUniqueStates_usingRealTimeTracker_dispatchesFirstTenStates() {
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
        for i in 1...15 {
            let info = StateInfo(stateName: "state_\(i)")!
            mediaTracker.trackEvent(event: MediaEvent.StateStart, info: info.toMap())
        }

        mediaTracker.trackComplete()

        wait()

        var expectedStateStartEvents = [Event]()
        // We will have states only till state_10
        for i in 1...10 {
            let info = StateInfo(stateName: "state_\(i)")!
            expectedStateStartEvents.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.statesUpdate, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: info.toMap(), stateStart: true))
        }

        var expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId)
        ]

        expectedEvents.insert(contentsOf: expectedStateStartEvents, at: expectedEvents.endIndex)
        expectedEvents.append(EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 0, ts: 0, backendSessionId: backendSessionId))

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)

    }

}
