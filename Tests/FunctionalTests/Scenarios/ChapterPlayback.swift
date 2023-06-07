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

class ChapterPlayback: BaseScenarioTest {

    let mediaInfo = MediaInfo(id: "mediaID", name: "mediaName", streamType: "aod", mediaType: MediaType.Audio, length: 30, prerollWaitingTime: 0)!
    let mediaInfoWithDefaultPreroll = MediaInfo(id: "mediaID", name: "mediaName", streamType: "aod", mediaType: MediaType.Audio, length: 30)!
    let mediaMetadata = ["media.show": "sampleshow", "key1": "value1", "key2": "мểŧẳđαţả"]

    let chapterInfo = ChapterInfo(name: "chapterName", position: 1, startTime: 1, length: 30)!
    let chapterMetadata = ["media.artist": "sampleArtist", "key1": "value1", "key2": "мểŧẳđαţả"]

    let chapterInfo2 = ChapterInfo(name: "chapterName2", position: 2, startTime: 2, length: 40)!
    let chapterMetadata2 = ["media.artist": "sampleArtist2", "key2": "value2", "key3": "мểŧẳđαţả"]

    var mediaSharedState: [String: Any] = ["edgeMedia.channel": "test_channel", "edgeMedia.playerName": "test_playerName", "edgeMedia.appVersion": "test_appVersion"]

    override func setUp() {
        super.setup()
    }

    // tests
    func testChapter_usingRealTimeTracker_shouldSendChapterEvents() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)

        // test
        mediaTracker.trackSessionStart(info: mediaInfo.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        // test
        mediaTracker.trackSessionStart(info: mediaInfoWithDefaultPreroll.toMap(), metadata: mediaMetadata)
        mediaTracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo.toMap(), metadata: chapterMetadata)
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 15, updatePlayhead: true) // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.ChapterComplete)
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: chapterInfo.toMap(), metadata: chapterMetadata),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 1, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 11, ts: 11, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterComplete, playhead: 15, ts: 15, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 15, ts: 15, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }

    func testMultipleChapter_usingRealTimeTracker_shouldSendMultipleChapterEventsInProperOrder() {
        // setup
        let curSessionId = "1"
        let backendSessionId = "FakeBackendID"
        mockSharedStateUpdate(sessionId: curSessionId, sharedStateData: mediaSharedState)

        // test
        mediaTracker.trackSessionStart(info: mediaInfo.toMap(), metadata: mediaMetadata)
        wait()

        // mock sessionIDUpdate
        mediaEventProcessorSpy.mockBackendSessionId(sessionId: curSessionId, sessionStartEvent: dispatchedEvents[0], fakeBackendId: backendSessionId)

        mediaTracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo.toMap(), metadata: chapterMetadata)
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 15, updatePlayhead: true) // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.ChapterComplete)
        mediaTracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo2.toMap(), metadata: chapterMetadata2)
        mediaTracker.trackPlay()
        incrementTrackerTime(seconds: 15, updatePlayhead: true) // will send ping since interval > 10 seconds
        mediaTracker.trackEvent(event: MediaEvent.ChapterComplete)
        mediaTracker.trackComplete()

        wait()

        let expectedEvents: [Event] = [
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: mediaInfo.toMap(), metadata: mediaMetadata, mediaState: mediaState),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterStart, playhead: 0, ts: 0, backendSessionId: backendSessionId, info: chapterInfo.toMap(), metadata: chapterMetadata),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 0, ts: 0, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.play, playhead: 1, ts: 1, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 11, ts: 11, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterComplete, playhead: 15, ts: 15, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterStart, playhead: 15, ts: 15, backendSessionId: backendSessionId, info: chapterInfo2.toMap(), metadata: chapterMetadata2),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.ping, playhead: 21, ts: 21, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.chapterComplete, playhead: 30, ts: 30, backendSessionId: backendSessionId),
            EdgeEventHelper.generateEdgeEvent(eventType: XDMMediaEventType.sessionComplete, playhead: 30, ts: 30, backendSessionId: backendSessionId)
        ]

        // verify
        assertEqualsEvents(expectedEvents: expectedEvents, actualEvents: dispatchedEvents)
    }

}
