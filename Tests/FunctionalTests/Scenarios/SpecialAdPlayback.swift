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

class SpecialAdPlayback: BaseScenarioTest {

    let mediaInfoWithDefaultPreroll = MediaInfo(id: "mediaID", name: "mediaName", streamType: "aod", mediaType: MediaType.Audio, length: 30)!
    let mediaMetadata = ["media.show": "sampleshow", "key1": "value1", "key2": "мểŧẳđαţả"]

    let adBreakInfo = AdBreakInfo(name: "adBreakName", position: 1, startTime: 1)!
    let adBreakInfo2 = AdBreakInfo(name: "adBreakName2", position: 2, startTime: 2)!

    let adInfo = AdInfo(id: "adID", name: "adName", position: 1, length: 15)!
    let adMetadata = ["media.ad.advertiser": "sampleAdvertiser", "key1": "value1", "key2": "мểŧẳđαţả"]

    let adInfo2 = AdInfo(id: "adID2", name: "adName2", position: 2, length: 20)!
    let adMetadata2 = ["media.ad.advertiser": "sampleAdvertiser2", "key2": "value2", "key3": "мểŧẳđαţả"]

    let chapterInfo = ChapterInfo(name: "chapterName", position: 1, startTime: 1, length: 30)!
    let chapterMetadata = ["media.artist": "sampleArtist", "key1": "value1", "key2": "мểŧẳđαţả"]

    var mediaSharedState: [String: Any] = ["edgeMedia.channel": "test_channel", "edgeMedia.playerName": "test_playerName", "edgeMedia.appVersion": "test_appVersion"]

    override func setUp() {
        super.setup()
    }

    // tests
    func testDelayedAds_usingRealTimeTracker_willSendPingEventsBeforeDelayedAdStartEvents() {
        // test
        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
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
        incrementTrackerTime(seconds: 15, updatePlayhead: false)  // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.AdStart, info: adInfo.toMap(), metadata: adMetadata)
        incrementTrackerTime(seconds: 15, updatePlayhead: false)  // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.AdComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakComplete)
        // should switch to play state
        mediaTracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo.toMap(), metadata: chapterMetadata)
        incrementTrackerTime(seconds: 15, updatePlayhead: true)  // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.ChapterComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakInfo2.toMap())
        incrementTrackerTime(seconds: 25, updatePlayhead: false)  // will send 2 pings since interval > 20 seconds
        mediaTracker.trackEvent(event: MediaEvent.AdStart, info: adInfo2.toMap(), metadata: adMetadata2)
        incrementTrackerTime(seconds: 15, updatePlayhead: false)  // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.AdComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakComplete)
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata, mediaState: mediaState),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: adBreakInfo.toMap()),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 0, ts: 10, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adStart, playhead: 0, ts: 15, backendSessionId: backendSessionId, info: adInfo.toMap(), metadata: adMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 15, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 0, ts: 25, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adComplete, playhead: 0, ts: 30, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakComplete, playhead: 0, ts: 30, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 30, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterStart, playhead: 0, ts: 30, backendSessionId: backendSessionId, info: chapterInfo.toMap(), metadata: chapterMetadata),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 31, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 11, ts: 41, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterComplete, playhead: 15, ts: 45, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakStart, playhead: 15, ts: 45, backendSessionId: backendSessionId, info: adBreakInfo2.toMap()),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 15, ts: 51, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 15, ts: 61, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adStart, playhead: 15, ts: 70, backendSessionId: backendSessionId, info: adInfo2.toMap(), metadata: adMetadata2, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 15, ts: 70, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 15, ts: 80, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adComplete, playhead: 15, ts: 85, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakComplete, playhead: 15, ts: 85, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 15, ts: 85, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 15, ts: 85, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }

    func testAdWithSeek_usingRealTimeTracker_shouldSendPauseStartEventForAdSection() {
        // test
        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
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
        mediaTracker.trackEvent(event: MediaEvent.AdStart, info: adInfo.toMap(), metadata: adMetadata)
        incrementTrackerTime(seconds: 5, updatePlayhead: false)
        // seek out of ad into main content chapter
        mediaTracker.trackEvent(event: MediaEvent.SeekStart)
        mediaTracker.incrementTimeStamp(value: 1)
        mediaTracker.incrementCurrentPlayhead(time: 5)
        mediaTracker.trackEvent(event: MediaEvent.SeekComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdSkip) // seeking from ad to main section
        mediaTracker.trackEvent(event: MediaEvent.AdBreakComplete)
        // should switch to play state
        mediaTracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo.toMap(), metadata: chapterMetadata)
        incrementTrackerTime(seconds: 15, updatePlayhead: true)
        // seek out of chapter into Ad
        mediaTracker.trackEvent(event: MediaEvent.SeekStart)
        mediaTracker.incrementTimeStamp(value: 1)
        mediaTracker.incrementCurrentPlayhead(time: 5)
        mediaTracker.trackEvent(event: MediaEvent.ChapterSkip) // Seeking from chapter to ad section
        mediaTracker.trackEvent(event: MediaEvent.SeekComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakInfo2.toMap())
        mediaTracker.trackEvent(event: MediaEvent.AdStart, info: adInfo2.toMap(), metadata: adMetadata2)
        incrementTrackerTime(seconds: 15, updatePlayhead: false)
        mediaTracker.trackSessionEnd()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata, mediaState: mediaState),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: adBreakInfo.toMap()),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: adInfo.toMap(), metadata: adMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 5, ts: 6, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adSkip, playhead: 5, ts: 6, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakComplete, playhead: 5, ts: 6, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 5, ts: 6, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterStart, playhead: 5, ts: 6, backendSessionId: backendSessionId, info: chapterInfo.toMap(), metadata: chapterMetadata),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 6, ts: 7, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 16, ts: 17, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 20, ts: 21, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterSkip, playhead: 25, ts: 22, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 25, ts: 22, backendSessionId: backendSessionId),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakStart, playhead: 25, ts: 22, backendSessionId: backendSessionId, info: adBreakInfo2.toMap()),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adStart, playhead: 25, ts: 22, backendSessionId: backendSessionId, info: adInfo2.toMap(), metadata: adMetadata2, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 25, ts: 22, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 25, ts: 32, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adSkip, playhead: 25, ts: 37, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakComplete, playhead: 25, ts: 37, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionEnd, playhead: 25, ts: 37, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }

    func testAdWithBuffer_usingRealtimeTracker_shouldSendBufferEventsForAdSection() {
        // test
        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)

        // test
        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
        wait(4)

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackEvent(event: MediaEvent.BufferStart)
        incrementTrackerTime(seconds: 5, updatePlayhead: false)
        mediaTracker.trackEvent(event: MediaEvent.BufferComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakInfo.toMap())
        mediaTracker.trackEvent(event: MediaEvent.BufferStart)
        incrementTrackerTime(seconds: 5, updatePlayhead: false)
        mediaTracker.trackEvent(event: MediaEvent.BufferComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdStart, info: adInfo.toMap(), metadata: adMetadata)
        incrementTrackerTime(seconds: 15, updatePlayhead: false)
        mediaTracker.trackEvent(event: MediaEvent.BufferStart)
        incrementTrackerTime(seconds: 5, updatePlayhead: false)
        mediaTracker.trackEvent(event: MediaEvent.BufferComplete)
        incrementTrackerTime(seconds: 5, updatePlayhead: false)
        mediaTracker.trackEvent(event: MediaEvent.AdComplete)
        mediaTracker.trackEvent(event: MediaEvent.AdBreakComplete)
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 5, updatePlayhead: true)
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata, mediaState: mediaState),

            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.bufferStart, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 0, ts: 5, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakStart, playhead: 0, ts: 5, backendSessionId: backendSessionId, info: adBreakInfo.toMap()),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adStart, playhead: 0, ts: 10, backendSessionId: backendSessionId, info: adInfo.toMap(), metadata: adMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 0, ts: 10, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 0, ts: 20, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.bufferStart, playhead: 0, ts: 25, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 0, ts: 30, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adComplete, playhead: 0, ts: 35, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.adBreakComplete, playhead: 0, ts: 35, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.pauseStart, playhead: 0, ts: 35, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 35, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 36, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 5, ts: 40, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }
}
