/*
 Copyright 2023 Adobe. All rights reserved.
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

class CustomPingDuration: BaseScenarioTest {

    var mediaInfo = MediaInfo(id: "mediaID", name: "mediaName", streamType: "aod", mediaType: MediaType.Audio, length: 30.0, prerollWaitingTime: 0)!
    var mediaMetadata = ["media.show": "sampleshow", "key1": "value1"]
    var mediaSharedState: [String: Any] = ["edgemedia.channel": "test_channel", "edgemedia.playerName": "test_playerName", "edgemedia.appVersion": "test_appVersion"]

    let adBreakInfo = AdBreakInfo(name: "adBreakName", position: 1, startTime: 1.1)!
    let adInfo = AdInfo(id: "adID", name: "adName", position: 1, length: 15.0)!
    let adMetadata = ["media.ad.advertiser": "sampleAdvertiser", "key1": "value1", "key2": "мểŧẳđαţả"]

    override func setUp() {
        super.setup()
    }

    // tests
    func testTrackSimplePlayBackWithAd_usingRealTimeTracker_withValidCustomPingInterval_dispatchesPingAfterCustomInterval() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)
        // Custom ping duration
        let trackerConfig = [MediaConstants.TrackerConfig.MAIN_PING_INTERVAL: 15, MediaConstants.TrackerConfig.AD_PING_INTERVAL: 1]
        createTracker(trackerConfig: trackerConfig)

        // test
        mediaTracker.trackSessionStart(info: mediaInfo.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakInfo.toMap())
        mediaTracker.trackEvent(event: MediaEvent.AdStart, info: adInfo.toMap(), metadata: adMetadata) // will send play since adStart triggers trackPlay internally
        incrementTrackerTime(seconds: 5, updatePlayhead: false) // will send ping since interval > custom ad interval (1) seconds
        mediaTracker.trackEvent(event: MediaEvent.AdComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakComplete)
        incrementTrackerTime(seconds: 31, updatePlayhead: true) // will send ping since interval > custom main interval (15) seconds
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: adBreakInfo.toMap()),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: adInfo.toMap(), metadata: adMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 0, ts: 1, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 0, ts: 2, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 0, ts: 3, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 0, ts: 4, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adComplete, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakComplete, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 6, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 16, ts: 21, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 31, ts: 36, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 31, ts: 36, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }

    func testTrackSimplePlayBackWithAd_usingRealTimeTracker_withInvalidValidCustomPingDuration_dispatchesPingAfterDefaultInterval() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)
        // Custom ping duration
        let trackerConfig = [MediaConstants.TrackerConfig.MAIN_PING_INTERVAL: 1, MediaConstants.TrackerConfig.AD_PING_INTERVAL: 11]
        createTracker(trackerConfig: trackerConfig)

        // test
        mediaTracker.trackSessionStart(info: mediaInfo.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakInfo.toMap())
        mediaTracker.trackEvent(event: MediaEvent.AdStart, info: adInfo.toMap(), metadata: adMetadata) // will send play since adStart triggers trackPlay internally
        incrementTrackerTime(seconds: 5, updatePlayhead: false) // will not send ping since interval < default ad interval (10) seconds
        mediaTracker.trackEvent(event: MediaEvent.AdComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakComplete)
        incrementTrackerTime(seconds: 31, updatePlayhead: true) // will send ping since interval > custom main interval (10) seconds
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: adBreakInfo.toMap()),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: adInfo.toMap(), metadata: adMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adComplete, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakComplete, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 6, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 11, ts: 16, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 21, ts: 26, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 31, ts: 36, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 31, ts: 36, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }
}
