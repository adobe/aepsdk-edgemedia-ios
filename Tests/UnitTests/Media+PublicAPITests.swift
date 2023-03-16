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
@testable import AEPServices
import XCTest

class MediaPublicAPITests: XCTestCase {

    override func setUp() {
        EventHub.reset()
        MockExtension.reset()
        EventHub.shared.start()
        registerMockExtension(MockExtension.self)
    }

    private func registerMockExtension<T: Extension> (_ type: T.Type) {
        let semaphore = DispatchSemaphore(value: 0)
        EventHub.shared.registerExtension(type) { _ in
            semaphore.signal()
        }

        semaphore.wait()
    }

    // MARK: MediaPublicAPI Unit Tests

    // ==========================================================================
    // createTracker
    // ==========================================================================
    func testCreateTracker() {
        let expectation = XCTestExpectation(description: "createTracker should dispatch createTracker request an event")
        expectation.assertForOverFulfill = true

        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: MediaConstants.Media.EVENT_TYPE, source: MediaConstants.Media.EVENT_SOURCE_CREATE_TRACKER) { event in
            let eventData = event.data
            let trackerId = eventData?[MediaConstants.Tracker.ID] as? String
            let trackerConfig = eventData?[MediaConstants.Tracker.EVENT_PARAM] as? [String: Any]

            XCTAssertEqual(2, eventData?.count ?? 0)
            XCTAssertFalse("" == trackerId)
            XCTAssertEqual(0, trackerConfig?.count)
            expectation.fulfill()
        }

        let mediaTracker = Media.createTracker()

        // verify
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(mediaTracker)
    }

    func testCreateTrackerWithConfig() {
        let expectation = XCTestExpectation(description: "createTracker should dispatch createTracker request an event")
        expectation.assertForOverFulfill = true

        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: MediaConstants.Media.EVENT_TYPE, source: MediaConstants.Media.EVENT_SOURCE_CREATE_TRACKER) { event in
            let eventData = event.data
            let trackerId = eventData?[MediaConstants.Tracker.ID] as? String
            let trackerConfig = eventData?[MediaConstants.Tracker.EVENT_PARAM] as? [String: Any]

            XCTAssertEqual(2, eventData?.count ?? 0)
            XCTAssertFalse("" == trackerId)
            XCTAssertTrue(trackerConfig?["downloaded"] as? Bool ?? false)
            XCTAssertNotNil(trackerConfig)
            expectation.fulfill()
        }

        let mediaTracker = Media.createTrackerWith(config: ["downloaded": true])

        // verify
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(mediaTracker)
    }

    // ==========================================================================
    // createMediaObjects
    // ==========================================================================
    func testCreateMediaInfo() {
        let infoMap = Media.createMediaObjectWith(name: "testName", id: "testId", length: 30, streamType: "aod", mediaType: MediaType.Audio)
        XCTAssertFalse(infoMap?.isEmpty ?? true)
        XCTAssertEqual("testId", infoMap?[MediaConstants.MediaInfo.ID] as? String ?? "")
        XCTAssertEqual("testName", infoMap?[MediaConstants.MediaInfo.NAME] as? String ?? "")
        XCTAssertEqual(30.0, infoMap?[MediaConstants.MediaInfo.LENGTH] as? Double ?? 0.0)
        XCTAssertEqual("aod", infoMap?[MediaConstants.MediaInfo.STREAM_TYPE] as? String ?? "")
        XCTAssertEqual(MediaType.Audio.rawValue, infoMap?[MediaConstants.MediaInfo.MEDIA_TYPE] as? String ?? "")
        XCTAssertEqual(false, infoMap?[MediaConstants.MediaInfo.RESUMED] as? Bool ?? false)
        XCTAssertEqual(250, infoMap?[MediaConstants.MediaInfo.PREROLL_TRACKING_WAITING_TIME] as? Int ?? 0)
        XCTAssertEqual(false, infoMap?[MediaConstants.MediaInfo.GRANULAR_AD_TRACKING] as? Bool ?? true)
    }

    func testCreateMediaInfo_Invalid() {
        // empty name
        var infoMap = Media.createMediaObjectWith(name: "", id: "testId", length: 30, streamType: "aod", mediaType: MediaType.Audio)
        XCTAssertNil(infoMap)

        // empty id
        infoMap = Media.createMediaObjectWith(name: "testName", id: "", length: 30, streamType: "aod", mediaType: MediaType.Audio)
        XCTAssertNil(infoMap)

        // <0 length
        infoMap = Media.createMediaObjectWith(name: "testName", id: "testId", length: -1, streamType: "aod", mediaType: MediaType.Audio)
        XCTAssertNil(infoMap)

        // empty streamType
        infoMap = Media.createMediaObjectWith(name: "testName", id: "testId", length: 30, streamType: "", mediaType: MediaType.Audio)
        XCTAssertNil(infoMap)
    }

    // ==========================================================================
    // createAdBreakObjects
    // ==========================================================================
    func testCreateAdBreakInfo() {
        let infoMap = Media.createAdBreakObjectWith(name: "adBreakName", position: 5, startTime: 0)
        XCTAssertFalse(infoMap?.isEmpty ?? true)
        XCTAssertEqual("adBreakName", infoMap?[MediaConstants.AdBreakInfo.NAME] as? String ?? "")
        XCTAssertEqual(5, infoMap?[MediaConstants.AdBreakInfo.POSITION] as? Int ?? 0)
        XCTAssertEqual(0, infoMap?[MediaConstants.AdBreakInfo.START_TIME] as? Double ?? 0.0)
    }

    func testCreateAdBreakInfo_Invalid() {
        // empty name
        var infoMap = Media.createAdBreakObjectWith(name: "", position: 5, startTime: 2.0)
        XCTAssertNil(infoMap)

        // <1 position
        infoMap = Media.createAdBreakObjectWith(name: "adBreakName", position: 0, startTime: 2.0)
        XCTAssertNil(infoMap)

        // <0 start time
        infoMap = Media.createAdBreakObjectWith(name: "adBreakName", position: 5, startTime: -1)
        XCTAssertNil(infoMap)
    }

    // ==========================================================================
    // createAdObjects
    // ==========================================================================
    func testCreateAdInfo() {
        let infoMap = Media.createAdObjectWith(name: "adName", id: "AdId", position: 3, length: 20)
        XCTAssertFalse(infoMap?.isEmpty ?? true)
        XCTAssertEqual("adName", infoMap?[MediaConstants.AdInfo.NAME] as? String ?? "")
        XCTAssertEqual("AdId", infoMap?[MediaConstants.AdInfo.ID] as? String ?? "")
        XCTAssertEqual(3, infoMap?[MediaConstants.AdInfo.POSITION] as? Int ?? 0)
        XCTAssertEqual(20, infoMap?[MediaConstants.AdInfo.LENGTH] as? Double ?? 0.0)
    }

    func testCreateAdInfo_Invalid() {
        // empty name
        var infoMap = Media.createAdObjectWith(name: "", id: "AdId", position: 2, length: 20)
        XCTAssertNil(infoMap)

        // empty id name
        infoMap = Media.createAdObjectWith(name: "adName", id: "", position: 2, length: 20)
        XCTAssertNil(infoMap)

        // < 1 position
        infoMap = Media.createAdObjectWith(name: "adName", id: "AdId", position: 0, length: 20)
        XCTAssertNil(infoMap)

        // < 0 length
        infoMap = Media.createAdObjectWith(name: "adName", id: "AdId", position: 2, length: -1)
        XCTAssertNil(infoMap)
    }

    // ==========================================================================
    // createChapterObjects
    // ==========================================================================

    func testCreateChapterInfo() {
        let infoMap = Media.createChapterObjectWith(name: "chapterName", position: 2, length: 30, startTime: 5)
        XCTAssertFalse(infoMap?.isEmpty ?? true)
        XCTAssertEqual("chapterName", infoMap?[MediaConstants.ChapterInfo.NAME] as? String ?? "")
        XCTAssertEqual(2, infoMap?[MediaConstants.ChapterInfo.POSITION] as? Int ?? 0)
        XCTAssertEqual(30, infoMap?[MediaConstants.ChapterInfo.LENGTH] as? Double ?? 0.0)
        XCTAssertEqual(5, infoMap?[MediaConstants.ChapterInfo.START_TIME] as? Double ?? 0.0)
    }

    func testCreateChapterInfo_Invalid() {
        // empty name
        var infoMap = Media.createChapterObjectWith(name: "", position: 2, length: 30, startTime: 50)
        XCTAssertNil(infoMap)

        // < 1 position
        infoMap = Media.createChapterObjectWith(name: "chapterName", position: 0, length: 0, startTime: 5)
        XCTAssertNil(infoMap)

        // < 0 length
        infoMap = Media.createChapterObjectWith(name: "chapterName", position: 2, length: -1, startTime: 5 )
        XCTAssertNil(infoMap)

        // < 0 start time
        infoMap = Media.createChapterObjectWith(name: "chapterName", position: 2, length: 30, startTime: -2)
        XCTAssertNil(infoMap)
    }

    // ==========================================================================
    // createQoEObjects
    // ==========================================================================

    func testCreateQoEInfo() {
        let infoMap = Media.createQoEObjectWith(bitrate: 24.0, startupTime: 0.5, fps: 30.0, droppedFrames: 2.0)
        XCTAssertFalse(infoMap?.isEmpty ?? true)
        XCTAssertEqual(24, infoMap?[MediaConstants.QoEInfo.BITRATE] as? Double ?? 0.0)
        XCTAssertEqual(0.5, infoMap?[MediaConstants.QoEInfo.STARTUP_TIME] as? Double ?? 0.0)
        XCTAssertEqual(30, infoMap?[MediaConstants.QoEInfo.FPS] as? Double ?? 0.0)
        XCTAssertEqual(2, infoMap?[MediaConstants.QoEInfo.DROPPED_FRAMES] as? Double ?? 0.0)
    }

    func testCreateQoEInfo_Invalid() {
        // < 0 bitrate
        var infoMap = Media.createQoEObjectWith(bitrate: -1, startupTime: 0.5, fps: 30.0, droppedFrames: 2.0)
        XCTAssertNil(infoMap)

        // < 0 startupTime
        infoMap = Media.createQoEObjectWith(bitrate: -2.5, startupTime: 0.5, fps: 30.0, droppedFrames: 2.0)
        XCTAssertNil(infoMap)

        // < 0 fps
        infoMap = Media.createQoEObjectWith(bitrate: -15, startupTime: 0.5, fps: 30.0, droppedFrames: 2.0)
        XCTAssertNil(infoMap)

        // < 0 dropped frame
        infoMap = Media.createQoEObjectWith(bitrate: -4.9, startupTime: 0.5, fps: 30.0, droppedFrames: 2.0)
        XCTAssertNil(infoMap)
    }

    // ==========================================================================
    // createStateObjects
    // ==========================================================================

    func testCreateStateInfo() {
        let infoMap = Media.createStateObjectWith(stateName: "muted")
        XCTAssertFalse(infoMap?.isEmpty ?? true)
        XCTAssertEqual("muted", infoMap?[MediaConstants.StateInfo.STATE_NAME_KEY] as? String ?? "")
    }

    func testCreateStateInfo_Invalid() {
        // empty state name
        var infoMap = Media.createStateObjectWith(stateName: "")
        XCTAssertNil(infoMap)

        // Invalid state name
        infoMap = Media.createStateObjectWith(stateName: "mute$$")
        XCTAssertNil(infoMap)
    }

    func testMediaEventEnum_RawValue() {
        XCTAssertEqual(MediaConstants.EventName.CHAPTER_START, MediaEvent.ChapterStart.rawValue)
        XCTAssertEqual(MediaConstants.EventName.CHAPTER_SKIP, MediaEvent.ChapterSkip.rawValue)
        XCTAssertEqual(MediaConstants.EventName.CHAPTER_COMPLETE, MediaEvent.ChapterComplete.rawValue)
        XCTAssertEqual(MediaConstants.EventName.ADBREAK_START, MediaEvent.AdBreakStart.rawValue)
        XCTAssertEqual(MediaConstants.EventName.ADBREAK_COMPLETE, MediaEvent.AdBreakComplete.rawValue)
        XCTAssertEqual(MediaConstants.EventName.AD_START, MediaEvent.AdStart.rawValue)
        XCTAssertEqual(MediaConstants.EventName.AD_COMPLETE, MediaEvent.AdComplete.rawValue)
        XCTAssertEqual(MediaConstants.EventName.AD_SKIP, MediaEvent.AdSkip.rawValue)
        XCTAssertEqual(MediaConstants.EventName.BUFFER_START, MediaEvent.BufferStart.rawValue)
        XCTAssertEqual(MediaConstants.EventName.BUFFER_COMPLETE, MediaEvent.BufferComplete.rawValue)
        XCTAssertEqual(MediaConstants.EventName.SEEK_START, MediaEvent.SeekStart.rawValue)
        XCTAssertEqual(MediaConstants.EventName.SEEK_COMPLETE, MediaEvent.SeekComplete.rawValue)
        XCTAssertEqual(MediaConstants.EventName.BITRATE_CHANGE, MediaEvent.BitrateChange.rawValue)
        XCTAssertEqual(MediaConstants.EventName.STATE_START, MediaEvent.StateStart.rawValue)
        XCTAssertEqual(MediaConstants.EventName.STATE_END, MediaEvent.StateEnd.rawValue)
    }

    func testMediaEventEnum_init() {
        XCTAssertEqual(MediaEvent.ChapterStart, MediaEvent(rawValue: MediaConstants.EventName.CHAPTER_START))
        XCTAssertEqual(MediaEvent.ChapterSkip, MediaEvent(rawValue: MediaConstants.EventName.CHAPTER_SKIP))
        XCTAssertEqual(MediaEvent.ChapterComplete, MediaEvent(rawValue: MediaConstants.EventName.CHAPTER_COMPLETE))
        XCTAssertEqual(MediaEvent.AdBreakStart, MediaEvent(rawValue: MediaConstants.EventName.ADBREAK_START))
        XCTAssertEqual(MediaEvent.AdBreakComplete, MediaEvent(rawValue: MediaConstants.EventName.ADBREAK_COMPLETE))
        XCTAssertEqual(MediaEvent.AdStart, MediaEvent(rawValue: MediaConstants.EventName.AD_START))
        XCTAssertEqual(MediaEvent.AdComplete, MediaEvent(rawValue: MediaConstants.EventName.AD_COMPLETE))
        XCTAssertEqual(MediaEvent.AdSkip, MediaEvent(rawValue: MediaConstants.EventName.AD_SKIP))
        XCTAssertEqual(MediaEvent.BufferStart, MediaEvent(rawValue: MediaConstants.EventName.BUFFER_START))
        XCTAssertEqual(MediaEvent.BufferComplete, MediaEvent(rawValue: MediaConstants.EventName.BUFFER_COMPLETE))
        XCTAssertEqual(MediaEvent.SeekStart, MediaEvent(rawValue: MediaConstants.EventName.SEEK_START))
        XCTAssertEqual(MediaEvent.SeekComplete, MediaEvent(rawValue: MediaConstants.EventName.SEEK_COMPLETE))
        XCTAssertEqual(MediaEvent.BitrateChange, MediaEvent(rawValue: MediaConstants.EventName.BITRATE_CHANGE))
        XCTAssertEqual(MediaEvent.StateStart, MediaEvent(rawValue: MediaConstants.EventName.STATE_START))
        XCTAssertEqual(MediaEvent.StateEnd, MediaEvent(rawValue: MediaConstants.EventName.STATE_END))
        XCTAssertNil(MediaEvent(rawValue: "invalid"))
    }
}
