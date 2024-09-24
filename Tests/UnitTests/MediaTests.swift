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

@testable import AEPCore
@testable import AEPEdgeMedia
import AEPServices
import AEPTestUtils
import XCTest

class MediaTests: XCTestCase {
    var media: Media!
    var mockRuntime: TestableExtensionRuntime!
    var fakeMediaProcessor: FakeMediaEventProcessor!

    override func setUp() {
        ServiceProvider.shared.namedKeyValueService = MockDataStore()
        mockRuntime = TestableExtensionRuntime()
        media = Media(runtime: mockRuntime)
        media.onRegistered()

        fakeMediaProcessor = FakeMediaEventProcessor()
        media.mediaEventProcessor = fakeMediaProcessor
    }

    func testExtensionVersion() {
        XCTAssertEqual(MediaConstants.EXTENSION_VERSION, Media.extensionVersion)
    }

    func testReadyForEvent() {
        let event = Event(name: "test-event", type: "test-type", source: "test-source", data: nil)
        XCTAssertTrue(media.readyForEvent(event))
    }

    func testHandleEdgeErrorResponse_WithoutRequestEventId_doesNotNotifyMediaEventProcessor() {
        let event = Event(name: "test-event", type: "test-type", source: "test-source", data: ["key": "value"])
        media.handleEdgeErrorResponse(event)
        XCTAssertFalse(fakeMediaProcessor.notifyErrorResponseCalled)
    }

    func testHandleEdgeErrorResponse_WithNilEventData_doesNotNotifyMediaEventProcessor() {
        let event = Event(name: "test-event", type: "test-type", source: "test-String", data: nil)
        media.handleEdgeErrorResponse(event)
        XCTAssertFalse(fakeMediaProcessor.notifyErrorResponseCalled)
    }

    func testHandleEdgeErrorResponse_WithRequestEventId_notifiesMediaEventProcessor() {
        let event = Event(name: "test-event", type: "test-type", source: "test-String", data: [MediaConstants.Edge.EventData.REQUEST_EVENT_ID: "testRequestId", MediaConstants.Edge.ErrorKeys.STATUS: Int64(400), MediaConstants.Edge.ErrorKeys.TYPE: "https://ns.adobe.com/aep/errors/va-edge-0400-400"])
        media.handleEdgeErrorResponse(event)
        XCTAssertTrue(fakeMediaProcessor.notifyErrorResponseCalled)
        XCTAssertEqual(3, fakeMediaProcessor.notifyErrorResponseCalledWithData.count)
        XCTAssertEqual("testRequestId", fakeMediaProcessor.notifyErrorResponseCalledWithRequestEventId)
        XCTAssertEqual(400, fakeMediaProcessor.notifyErrorResponseCalledWithData[MediaConstants.Edge.ErrorKeys.STATUS] as? Int64 ?? 0)
        XCTAssertEqual("https://ns.adobe.com/aep/errors/va-edge-0400-400", fakeMediaProcessor.notifyErrorResponseCalledWithData[MediaConstants.Edge.ErrorKeys.TYPE] as? String ?? "")
    }

    func testHandleMediaEdgeSessionDetails_WithoutRequestEventId_doesNotNotifyMediaEventProcessor() {
        let event = Event(name: "test-event", type: "test-type", source: "test-source", data: ["key": "value"])
        media.handleMediaEdgeSessionDetails(event)
        XCTAssertFalse(fakeMediaProcessor.notifyBackendSessionIdCalled)
    }

    func testHandleMediaEdgeSessionDetails_WithNilEventData_doesNotNotifyMediaEventProcessor() {
        let event = Event(name: "test-event", type: "test-type", source: "test-String", data: nil)
        media.handleMediaEdgeSessionDetails(event)
        XCTAssertFalse(fakeMediaProcessor.notifyBackendSessionIdCalled)
    }

    func testHandleMediaEdgeSessionDetails_WithRequestEventId_notifiesMediaEventProcessor() {
        let payload: [[String: Any?]] = [[MediaConstants.Edge.EventData.SESSION_ID: "testBackendSessionId"]]
        let data: [String: Any] = [MediaConstants.Edge.EventData.REQUEST_EVENT_ID: "testRequestId",
                                   MediaConstants.Edge.EventData.PAYLOAD: payload]

        let event = Event(name: "test-event", type: "test-type", source: "test-String", data: data)
        media.handleMediaEdgeSessionDetails(event)
        XCTAssertTrue(fakeMediaProcessor.notifyBackendSessionIdCalled)
        XCTAssertEqual("testRequestId", fakeMediaProcessor.notifyBackendSessionIdCalledWithRequestEventId)
        XCTAssertEqual("testBackendSessionId", fakeMediaProcessor.notifyBackendSessionIdCalledWithBackendSessionId)

    }
}
