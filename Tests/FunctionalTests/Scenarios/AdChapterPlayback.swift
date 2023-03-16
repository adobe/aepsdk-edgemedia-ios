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

class AdChapterPlayback: BaseScenarioTest {

    let mediaInfoWithDefaultPreroll = MediaInfo(id: "mediaID", name: "mediaName", streamType: "aod", mediaType: MediaType.Audio, length: 30.0)!
    let mediaMetadata = ["media.show": "sampleshow", "key1": "value1", "key2": "мểŧẳđαţả"]

    let adBreakInfo = AdBreakInfo(name: "adBreakName", position: 1, startTime: 1.1)!
    let adBreakInfo2 = AdBreakInfo(name: "adBreakName2", position: 2, startTime: 2.2)!

    let adInfo = AdInfo(id: "adID", name: "adName", position: 1, length: 15.0)!
    let adMetadata = ["media.ad.advertiser": "sampleAdvertiser", "key1": "value1", "key2": "мểŧẳđαţả"]

    let adInfo2 = AdInfo(id: "adID2", name: "adName2", position: 2, length: 20.0)!
    let adMetadata2 = ["media.ad.advertiser": "sampleAdvertiser2", "key2": "value2", "key3": "мểŧẳđαţả"]

    let chapterInfo = ChapterInfo(name: "chapterName", position: 1, startTime: 1.1, length: 30)!
    let chapterMetadata = ["media.artist": "sampleArtist", "key1": "value1", "key2": "мểŧẳđαţả"]

    let chapterInfo2 = ChapterInfo(name: "chapterName2", position: 2, startTime: 2.2, length: 40)!
    let chapterMetadata2 = ["media.artist": "sampleArtist2", "key2": "value2", "key3": "мểŧẳđαţả"]

    // Expected Values
    var mediaSharedState: [String: Any] = ["edgemedia.channel": "test_channel", "edgemedia.playerName": "test_playerName", "edgemedia.appVersion": "test_appVersion"]

    override func setUp() {
        super.setup()
    }

    // tests
    func testMultipleAdChapter_usingRealTimeTracker_shouldDispatchAdBreakAdAndChapterEventsProperly() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)

        // test
        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakInfo.toMap())
        mediaTracker.trackEvent(event: MediaEvent.AdStart, info: adInfo.toMap(), metadata: adMetadata) // will send play since adStart triggers trackPlay internally
        incrementTrackerTime(seconds: 15, updatePlayhead: false) // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.AdComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakComplete)
        // should switch to play state
        mediaTracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo.toMap(), metadata: chapterMetadata)
        incrementTrackerTime(seconds: 15, updatePlayhead: true) // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.ChapterComplete)
        mediaTracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo2.toMap(), metadata: chapterMetadata2)
        incrementTrackerTime(seconds: 15, updatePlayhead: true) // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.ChapterComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakInfo2.toMap())
        mediaTracker.trackEvent(event: MediaEvent.AdStart, info: adInfo2.toMap(), metadata: adMetadata2)
        incrementTrackerTime(seconds: 15, updatePlayhead: false) // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.AdComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakComplete)
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: adBreakInfo.toMap()),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: adInfo.toMap(), metadata: adMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 0, ts: 10, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adComplete, playhead: 0, ts: 15, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakComplete, playhead: 0, ts: 15, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 15, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterStart, playhead: 0, ts: 15, backendSessionId: backendSessionId, info: chapterInfo.toMap(), metadata: chapterMetadata),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 16, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 11, ts: 26, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterComplete, playhead: 15, ts: 30, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterStart, playhead: 15, ts: 30, backendSessionId: backendSessionId, info: chapterInfo2.toMap(), metadata: chapterMetadata2),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 21, ts: 36, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterComplete, playhead: 30, ts: 45, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakStart, playhead: 30, ts: 45, backendSessionId: backendSessionId, info: adBreakInfo2.toMap()),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adStart, playhead: 30, ts: 45, backendSessionId: backendSessionId, info: adInfo2.toMap(), metadata: adMetadata2, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 30, ts: 45, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 30, ts: 55, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adComplete, playhead: 30, ts: 60, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakComplete, playhead: 30, ts: 60, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 30, ts: 60, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 30, ts: 60, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }
}
