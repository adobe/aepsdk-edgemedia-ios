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
import XCTest

class BaseScenarioTest: XCTestCase {
    var mediaTracker: MediaEventGenerator!
    var mediaEventProcessorSpy: MediaEventProcessorSpy!
    var mediaEventTracker: MediaEventTracking!
    var dispatchedEvents: [Event] = []
    var mediaState: MediaState!

    static let DEFAULT_WAIT_TIMEOUT = TimeInterval(1)

    func getMediaSessions() -> [String: MediaSession] {
        return mediaEventProcessorSpy.mediaSessions
    }

    func fakeDispatcher(_ event: Event) {
        dispatchedEvents.append(event)
    }

    func setup() {
        self.dispatchedEvents = []
        self.mediaEventProcessorSpy = MediaEventProcessorSpy(dispatcher: fakeDispatcher(_:))
        self.mediaState = MediaState()
        createTracker()
    }

    func mockSharedStateUpdate(sessionId: String, sharedStateData: [String: Any]) {
        mediaState.updateConfigurationSharedState(sharedStateData)
        mediaEventProcessorSpy.updateMediaState(configurationSharedStateData: sharedStateData)
        if let session = mediaEventProcessorSpy.mediaSessions[sessionId] {
            session.handleMediaStateUpdate()
        }
        wait()
    }

    func createTracker(trackerConfig: [String: Any] = [:]) {
        mediaEventTracker = MediaEventTracker(eventProcessor: mediaEventProcessorSpy, config: trackerConfig)
        mediaTracker = MediaEventGenerator(config: trackerConfig)
        mediaTracker.connectCoreTracker(tracker: mediaEventTracker)
        mediaTracker.setTimeStamp(value: 0)
    }

    func incrementTrackerTime(seconds: Int, updatePlayhead: Bool) {
        for _ in 1...seconds {
            mediaTracker.incrementTimeStamp(value: 1)
            mediaTracker.incrementCurrentPlayhead(time: updatePlayhead ? 1 : 0)
        }
    }

    func assertEqualsEvents(expectedEvents: [Event], actualEvents: [Event]) {
        if expectedEvents.count != actualEvents.count {
            XCTFail("Expected number of dispatched events (\(expectedEvents.count)) != actual number of dispatched events (\(actualEvents.count))")
            return
        }

        for i in 0...expectedEvents.count - 1 {
            let expectedEvent = expectedEvents[i]
            let actualEvent = actualEvents[i]
            XCTAssertEqual(expectedEvent.name, actualEvent.name)
            XCTAssertEqual(expectedEvent.type, actualEvent.type)
            XCTAssertEqual(expectedEvent.source, actualEvent.source)

            guard let expectedData = expectedEvent.data, let actualData = actualEvent.data else {
                XCTFail("Event data cannot be null")
                return
            }

            XCTAssertTrue( NSDictionary(dictionary: expectedData).isEqual(to: actualData), "Expected event data \n(\(expectedData)\n) does not match the actual event data \n(\(actualData))\n")
        }
    }

    func wait(_ interval: TimeInterval = DEFAULT_WAIT_TIMEOUT) {
        let expectation = XCTestExpectation()
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + interval - 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: interval)
    }
}
