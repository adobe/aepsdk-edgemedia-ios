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

class MediaXDMEventGeneratorTests: XCTestCase {
    private var mediaInfo: MediaInfo!
    private var mediaContext: MediaContext!
    private var eventProcessor: FakeMediaEventProcessor!
    private var eventGenerator: MediaXDMEventGenerator!

    private var mockTimestamp = TimeInterval(0)
    private var mockPlayhead = 0
    static let trackerSessionId = "clientSessionId"
    static let refEvent = Event(name: MediaConstants.Media.EVENT_NAME_TRACK_MEDIA,
                                type: EventType.edgeMedia,
                                source: EventSource.trackMedia,
                                data: [MediaConstants.Tracker.SESSION_ID: trackerSessionId])

    override func setUp() {
        mediaInfo = MediaInfo(id: "id", name: "name", streamType: "vod", mediaType: MediaType.Video, length: 30)
        let metadata = ["k1": "v1", MediaConstants.VideoMetadataKeys.SHOW: "show"]
        self.mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: metadata)
        createXDMEventGeneratorWith([:])
    }

    override func tearDown() {
        self.mediaContext = nil
        self.eventProcessor = nil
        self.eventGenerator = nil
    }

    // MARK: MediaXDMEventGenerator Unit Tests
    func testProcessSessionStart() {
        // setup
        var sessionDetails = MediaXDMEventHelper.generateSessionDetails(mediaInfo: mediaContext.mediaInfo, metadata: mediaContext.mediaMetadata)
        // add standard metadata
        sessionDetails.show = "show"

        let customMetadata = [XDMCustomMetadata(name: "k1", value: "v1")]

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()
        mediaCollectionXDM.sessionDetails = sessionDetails
        mediaCollectionXDM.customMetadata = customMetadata

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processSessionStart()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessSessionComplete() {
        // setup
        mediaContext.playhead = 10
        eventGenerator.setRefTS(10)

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.sessionComplete, timestamp: getDateFormattedTimestampFor(10), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processSessionComplete()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessSessionEnd() {
        // setup
        mediaContext.playhead = 10
        eventGenerator.setRefTS(10)

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.sessionEnd, timestamp: getDateFormattedTimestampFor(10), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processSessionEnd()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessAdBreakStart() {
        // setup
        let adBreakInfo = AdBreakInfo(name: "adBreak", position: 1, startTime: 2)
        mediaContext.setAdBreakInfo(adBreakInfo!)
        let adBreakDetails = MediaXDMEventHelper.generateAdvertisingPodDetails(adBreakInfo: mediaContext.adBreakInfo)

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()
        mediaCollectionXDM.advertisingPodDetails = adBreakDetails

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.adBreakStart, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processAdBreakStart()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessAdBreakComplete() {
        // setup
        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.adBreakComplete, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processAdBreakComplete()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessAdBreakSkip() {
        // setup
        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.adBreakComplete, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processAdBreakSkip()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessAdStart() {
        // setup
        let adInfo = AdInfo(id: "id", name: "ad", position: 1, length: 15)
        let metadata = [MediaConstants.AdMetadataKeys.SITE_ID: "testSiteID",
                        "key": "value"
        ]
        mediaContext.setAdInfo(adInfo!, metadata: metadata)

        let adDetails = MediaXDMEventHelper.generateAdvertisingDetails(adInfo: adInfo, adMetadata: metadata)
        let adMetadata = MediaXDMEventHelper.generateAdCustomMetadataDetails(metadata: metadata)

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()
        mediaCollectionXDM.advertisingDetails = adDetails
        mediaCollectionXDM.customMetadata = adMetadata

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.adStart, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processAdStart()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessAdSkip() {
        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.adSkip, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processAdSkip()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessAdComplete() {
        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.adComplete, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processAdComplete()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessChapterStart() {
        // setup
        let chapterInfo = ChapterInfo(name: "name", position: 1, startTime: 2, length: 10)

        mediaContext.setChapterInfo(chapterInfo!, metadata: ["key1": "value1"])

        let chapterDetails = MediaXDMEventHelper.generateChapterDetails(chapterInfo: chapterInfo)
        let chapterMetadata = MediaXDMEventHelper.generateChapterMetadata(metadata: mediaContext.chapterMetadata)

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.chapterDetails = chapterDetails
        mediaCollectionXDM.customMetadata = chapterMetadata
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.chapterStart, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processChapterStart()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessChapterSkip() {
        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.chapterSkip, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processChapterSkip()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessChapterComplete() {
        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.chapterComplete, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processChapterComplete()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessSessionAbort() {
        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.sessionEnd, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processSessionAbort()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessSessionRestart() {
        // setup
        var sessionDetails = MediaXDMEventHelper.generateSessionDetails(mediaInfo: mediaContext.mediaInfo, metadata: mediaContext.mediaMetadata, forceResume: true)
        // add standard metadata
        sessionDetails.show = "show"

        let customMetadata = [XDMCustomMetadata(name: "k1", value: "v1")]
        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()
        mediaCollectionXDM.sessionDetails = sessionDetails
        mediaCollectionXDM.customMetadata = customMetadata

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.sessionStart, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processSessionRestart()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessBitrateChange() {
        // setup
        let qoeInfo = QoEInfo(bitrate: 123, droppedFrames: 10, fps: 120, startupTime: 1)
        mediaContext.qoeInfo = qoeInfo

        let qoeDetails = MediaXDMEventHelper.generateQoEDataDetails(qoeInfo: qoeInfo)

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()
        mediaCollectionXDM.qoeDataDetails = qoeDetails

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.bitrateChange, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processBitrateChange()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessError() {
        // setup
        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()
        mediaCollectionXDM.errorDetails = MediaXDMEventHelper.generateErrorDetails(errorID: "errorID")

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.error, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processError(errorId: "errorID")

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessPlaybackPlay() {
        // setup
        mediaContext.enterPlaybackState(state: MediaContext.MediaPlaybackState.Play)

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.play, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processPlayback()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessPlaybackPause() {
        // setup
        mediaContext.enterPlaybackState(state: MediaContext.MediaPlaybackState.Pause)

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.pauseStart, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processPlayback()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessPlaybackSeek() {
        // setup
        mediaContext.enterPlaybackState(state: MediaContext.MediaPlaybackState.Seek)

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.pauseStart, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processPlayback()

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessPlaybackBuffer() {
        // setup
        mediaContext.enterPlaybackState(state: MediaContext.MediaPlaybackState.Buffer)

        // test
        eventGenerator.processPlayback()

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.bufferStart, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessPlaybackWithDoFlushSetToTrue() {
        // setup
        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.ping, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        eventGenerator.processPlayback(doFlush: true)

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessStateStart() {
        // setup
        let playerStates = [XDMPlayerStateData(name: MediaConstants.PlayerState.FULLSCREEN)]

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()
        mediaCollectionXDM.statesStart = playerStates

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.statesUpdate, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        let stateInfo = StateInfo(stateName: MediaConstants.PlayerState.FULLSCREEN)
        eventGenerator.processStateStart(stateInfo: stateInfo!)

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testProcessStateEnd() {
        // setup
        let playerStates = [XDMPlayerStateData(name: MediaConstants.PlayerState.FULLSCREEN)]

        var mediaCollectionXDM = XDMMediaCollection()
        mediaCollectionXDM.playhead = getPlayhead()
        mediaCollectionXDM.statesEnd = playerStates

        let expectedMediaXDMEvent = MediaXDMEvent(eventType: XDMMediaEventType.statesUpdate, timestamp: getDateFormattedTimestampFor(0), mediaCollection: mediaCollectionXDM)

        // test
        let stateInfo = StateInfo(stateName: MediaConstants.PlayerState.FULLSCREEN)
        eventGenerator.processStateEnd(stateInfo: stateInfo!)

        // verify
        let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
        XCTAssertEqual(expectedMediaXDMEvent, generatedEvent)
    }

    func testCustomMainPingInterval_validRange_sendsPingWithCustomValue() {
        let validIntervals: [Int] = [10, 11, 22, 33, 44, 50]

        for interval in validIntervals {
            // setup
            let trackerConfig = [MediaConstants.TrackerConfig.MAIN_PING_INTERVAL: interval]
            createXDMEventGeneratorWith(trackerConfig)
            updateTs(timeInSeconds: interval, reset: true)

            // test
            eventGenerator.processPlayback()

            // verify
            let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
            let result = verifyPing(event: generatedEvent, expectedTS: getDate(interval), expectedPlayhead: interval)
            XCTAssertTrue(result.success, result.errors)
        }
    }

    func testCustomMainPingInterval_InvalidRange_sendsPingWithDefaultValue() {
        let invalidIntervals = [0, 1, 2, 5, 9, 51, 100, 400, 100000000000000]

        for interval in invalidIntervals {
            // setup
            let trackerConfig = [MediaConstants.TrackerConfig.MAIN_PING_INTERVAL: interval]
            createXDMEventGeneratorWith(trackerConfig)
            updateTs(timeInSeconds: MediaConstants.PingInterval.REALTIME_TRACKING_S, reset: true)

            // test
            eventGenerator.processPlayback()

            // verify ping will be sent after default interval
            let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
            let result = verifyPing(event: generatedEvent, expectedTS: getDate((MediaConstants.PingInterval.REALTIME_TRACKING_S)), expectedPlayhead: MediaConstants.PingInterval.REALTIME_TRACKING_S)
            XCTAssertTrue(result.success, result.errors)
        }
    }

    func testCustomAdPingInterval_validRange_sendsPingWithCustomValue() {
        let validIntervals = [1, 3, 9, 10]

        for interval in validIntervals {
            // setup
            let trackerConfig = [MediaConstants.TrackerConfig.AD_PING_INTERVAL: interval]
            createXDMEventGeneratorWith(trackerConfig)
            updateTs(timeInSeconds: interval, reset: true)
            // mock adStart
            mediaContext.setAdInfo(AdInfo(id: "testId", name: "name", position: 1, length: 10)!, metadata: [:])

            // test
            eventGenerator.processPlayback()

            // verify
            let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
            let result = verifyPing(event: generatedEvent, expectedTS: getDate(interval), expectedPlayhead: interval)
            XCTAssertTrue(result.success, result.errors)
        }
    }

    func testCustomAdPingInterval_InvalidRange_sendsPingWithDefaultValue() {
        let invalidIntervals = [0, 11, 100, 400, 100000000000000]

        for interval in invalidIntervals {
            let trackerConfig = [MediaConstants.TrackerConfig.AD_PING_INTERVAL: interval]
            createXDMEventGeneratorWith(trackerConfig)
            updateTs(timeInSeconds: MediaConstants.PingInterval.REALTIME_TRACKING_S, reset: true)
            eventGenerator.processPlayback()

            // ping will be sent after default interval
            let generatedEvent = eventProcessor.getEventFromActiveSession(index: 0)
            let result = verifyPing(event: generatedEvent, expectedTS: getDate(MediaConstants.PingInterval.REALTIME_TRACKING_S), expectedPlayhead: MediaConstants.PingInterval.REALTIME_TRACKING_S)
            XCTAssertTrue(result.success, result.errors)
        }
    }

    func testCustomMainPingIntervalAndCustomAdPingInterval_validRange_sendsPingWithCustomValue() {
        // setup
        let trackerConfig = [MediaConstants.TrackerConfig.MAIN_PING_INTERVAL: 15, MediaConstants.TrackerConfig.AD_PING_INTERVAL: 3]
        createXDMEventGeneratorWith(trackerConfig)

        // test
        updateTs(timeInSeconds: 15)
        eventGenerator.processPlayback()

        mediaContext.setAdInfo(AdInfo(id: "testId", name: "name", position: 1, length: 10)!, metadata: [:]) // mock adStart
        updateTs(timeInSeconds: 3)
        eventGenerator.processPlayback()

        // verify main ping
        let generatedMainPingEvent = eventProcessor.getEventFromActiveSession(index: 0)
        let result1 = verifyPing(event: generatedMainPingEvent, expectedTS: getDate(15), expectedPlayhead: 15)
        XCTAssertTrue(result1.success, result1.errors)

        let generatedAdPingEvent = eventProcessor.getEventFromActiveSession(index: 1)
        let result2 = verifyPing(event: generatedAdPingEvent, expectedTS: getDate(15 + 3), expectedPlayhead: (15 + 3))
        XCTAssertTrue(result2.success, result2.errors)
    }

    func testDefaultMainPingIntervalCustomAdPingInterval() {
        let trackerConfig = [MediaConstants.TrackerConfig.AD_PING_INTERVAL: 3]
        createXDMEventGeneratorWith(trackerConfig)

        updateTs(timeInSeconds: MediaConstants.PingInterval.REALTIME_TRACKING_S)
        eventGenerator.processPlayback()

        mediaContext.setAdInfo(AdInfo(id: "testId", name: "name", position: 1, length: 10)!, metadata: [:]) // mock adStart
        updateTs(timeInSeconds: (3))
        eventGenerator.processPlayback()

        mediaContext.clearAdInfo() // mock adComplete, adSkip
        updateTs(timeInSeconds: MediaConstants.PingInterval.REALTIME_TRACKING_S)
        eventGenerator.processPlayback()

        // verify reporting interval for main content is 10 seconds
        let mainPingEvent1 = eventProcessor.getEventFromActiveSession(index: 0)
        var interval = MediaConstants.PingInterval.REALTIME_TRACKING_S
        let result1 = verifyPing(event: mainPingEvent1, expectedTS: getDate(interval), expectedPlayhead: interval)
        XCTAssertTrue(result1.success, result1.errors)

        // verify reporting interval for ad content is 3 seconds
        let adPingEvent1 = eventProcessor.getEventFromActiveSession(index: 1)
        interval += 3
        let result2 = verifyPing(event: adPingEvent1, expectedTS: getDate(interval), expectedPlayhead: interval)
        XCTAssertTrue(result2.success, result2.errors)

        // verify reporting interval for main content is 10 seconds
        let mainPingEvent2 = eventProcessor.getEventFromActiveSession(index: 2)
        interval += MediaConstants.PingInterval.REALTIME_TRACKING_S
        let result3 = verifyPing(event: mainPingEvent2, expectedTS: getDate(interval), expectedPlayhead: interval)
        XCTAssertTrue(result3.success, result3.errors)
    }

    func testCustomMainPingIntervalDefaultAdPingInterval() {
        let trackerConfig = [MediaConstants.TrackerConfig.MAIN_PING_INTERVAL: 21]
        createXDMEventGeneratorWith(trackerConfig)

        updateTs(timeInSeconds: 21)
        eventGenerator.processPlayback()

        mediaContext.setAdInfo(AdInfo(id: "testId", name: "name", position: 1, length: 10)!, metadata: [:]) // mock adStart
        updateTs(timeInSeconds: (MediaConstants.PingInterval.REALTIME_TRACKING_S))
        eventGenerator.processPlayback()

        mediaContext.clearAdInfo() // mock adComplete, adSkip
        updateTs(timeInSeconds: 21)
        eventGenerator.processPlayback()

        // verify reporting interval for main content is 21 seconds
        let mainPingEvent1 = eventProcessor.getEventFromActiveSession(index: 0)
        var interval = 21
        let result1 = verifyPing(event: mainPingEvent1, expectedTS: getDate(interval), expectedPlayhead: interval)
        XCTAssertTrue(result1.success, result1.errors)

        // verify reporting interval for ad content is 10 seconds
        let adPingEvent1 = eventProcessor.getEventFromActiveSession(index: 1)
        interval += MediaConstants.PingInterval.REALTIME_TRACKING_S
        let result2 = verifyPing(event: adPingEvent1, expectedTS: getDate(interval), expectedPlayhead: interval)
        XCTAssertTrue(result2.success, result2.errors)

        // verify reporting interval for main content is 21 seconds
        let mainPingEvent2 = eventProcessor.getEventFromActiveSession(index: 2)
        interval += 21
        let result3 = verifyPing(event: mainPingEvent2, expectedTS: getDate(interval), expectedPlayhead: interval)
        XCTAssertTrue(result3.success, result3.errors)
    }

    // Utils
    private func verifyPing(event: MediaXDMEvent?, expectedTS: Date, expectedPlayhead: Int) -> (success: Bool, errors: String) {
        var errorString = ""
        guard let event = event else {
            return (success: false, "Event should not be null")
        }
        XCTAssertEqual(XDMMediaEventType.ping, event.eventType, "Error::EventTypeMismatch expected(\(XDMMediaEventType.ping.rawValue)) != actual(\(event.eventType.rawValue))")

        if XDMMediaEventType.ping != event.eventType {
            errorString.append("\nError::EventTypeMismatch expected(\(XDMMediaEventType.ping.rawValue)) != actual(\(event.eventType.rawValue))")
        }
        if expectedTS != event.timestamp {
            errorString.append("\nError::TimeStampMismatch (\(expectedTS)) != actual(\(event.timestamp))")
        }
        if expectedPlayhead != event.mediaCollection.playhead {
            errorString.append("\nError::PlayheadMismatch expected(\(expectedPlayhead)) != actual(\(event.mediaCollection.playhead ?? -1))")
        }

        return (success: errorString.isEmpty, errorString)
    }

    private func createXDMEventGeneratorWith(_ trackerConfig: [String: Any]) {
        mockPlayhead = 0
        mockTimestamp = 0
        eventProcessor = FakeMediaEventProcessor()
        eventGenerator = MediaXDMEventGenerator(context: mediaContext, eventProcessor: eventProcessor, config: trackerConfig, refEvent: Self.refEvent, refTS: mockTimestamp)
    }

    private func getDate(_ ts: Int) -> Date {
        return Date(timeIntervalSince1970: Double(ts))
    }

    private func updateTs(timeInSeconds interval: Int, updatePlayhead: Bool = true, reset: Bool = false) {
        if reset {
            mockPlayhead = 0
            mockTimestamp = 0
        }
        mockTimestamp += TimeInterval(interval)
        if updatePlayhead {
            mockPlayhead += (interval)
            mediaContext.playhead = mockPlayhead
        }
        eventGenerator.setRefTS(mockTimestamp)
    }

    private func getPlayhead() -> Int {
        return mediaContext.playhead
    }

    private func setPlayhead(value: Int) {
        mediaContext.playhead = value
    }

    private func getDateFormattedTimestampFor(_ value: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: value)
    }
}
