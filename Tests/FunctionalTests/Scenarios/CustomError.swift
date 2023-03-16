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

class CustomError: BaseScenarioTest {

    let mediaInfoWithDefaultPreroll = MediaInfo(id: "mediaID", name: "mediaName", streamType: "aod", mediaType: MediaType.Audio, length: 30.0)!
    let mediaMetadata = ["media.show": "sampleshow", "key1": "value1", "key2": "мểŧẳđαţả"]

    var mediaSharedState: [String: Any] = ["edgemedia.channel": "test_channel", "edgemedia.playerName": "test_playerName", "edgemedia.appVersion": "test_appVersion"]

    override func setUp() {
        super.setup()
    }

    // tests
    func testCustomError_usingRealTimeTracker_dispatchesErrorEventWithSetErrorId() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)

        // test
        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 5, updatePlayhead: true)
        mediaTracker.trackError(errorId: "1000.2000.3000")
        incrementTrackerTime(seconds: 15, updatePlayhead: true)
        mediaTracker.trackError(errorId: "custom.error.code")
        mediaTracker.trackError(errorId: "") // ignored
        mediaTracker.trackComplete()

        wait()

        let errorInfo1 = ["error.id": "1000.2000.3000", "error.source": "player"]
        let errorInfo2 = ["error.id": "custom.error.code", "error.source": "player"]

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 1, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.error, playhead: 5, ts: 5, backendSessionId: backendSessionId, info: errorInfo1),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 11, ts: 11, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.error, playhead: 20, ts: 20, backendSessionId: backendSessionId, info: errorInfo2),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 20, ts: 20, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)

    }
}
