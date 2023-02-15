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
import AEPEdge
import AEPEdgeIdentity
@testable import AEPEdgeMedia
import AEPServices
import Foundation
import XCTest

class EdgeMediaIntegrationTests: FunctionalTestBase {
    private let sessionStartEdgeEndpoint = "https://edge.adobedc.net/ee/va/v1/sessionStart"
    private let configuration = ["edge.configId": "12345-example",
                                 "edgemedia.channel": "testChannel",
                                 "edgemedia.playerName": "testPlayerName"
    ]

    let mediaInfo = Media.createMediaObjectWith(name: "testName", id: "testId", length: 30.0, streamType: "VOD", mediaType: MediaType.Video)!
    let adBreakInfo = Media.createAdBreakObjectWith(name: "testName", position: 1, startTime: 1)!
    let adInfo = Media.createAdObjectWith(name: "testName", id: "testId", position: 1, length: 15)!
    let chapterInfo = Media.createChapterObjectWith(name: "testName", position: 1, length: 30, startTime: 2)!
    let qoeInfo = Media.createQoEObjectWith(bitrate: 1, startupTime: 2, fps: 3, droppedFrames: 4)!
    let muteStateInfo = Media.createStateObjectWith(stateName: MediaConstants.PlayerState.MUTE)!
    let customStateInfo = Media.createStateObjectWith(stateName: "testStateName")!

    let metadata = ["testKey": "testValue"]

    let testBackendSessionId = "99cf4e3e7145d8e2b8f4f1e9e1a08cd52518a74091c0b0c611ca97b259e03a4d"
    let successResponseBody = "\u{0000}{\"handle\":[{\"payload\":[{\"sessionId\":\"99cf4e3e7145d8e2b8f4f1e9e1a08cd52518a74091c0b0c611ca97b259e03a4d\"}],\"type\":\"media-analytics:new-session\",\"eventIndex\":0}]}"

    public class override func setUp() {
        super.setUp()
        FunctionalTestBase.debugEnabled = true
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        // hub shared state update for 1 extension versions Edge, Identity, Configuration, EventHub shared state updates
        setExpectationEvent(type: EventType.hub, source: EventSource.sharedState, expectedCount: 4)

        // expectations for update config request&response events
        setExpectationEvent(type: EventType.configuration, source: EventSource.requestContent, expectedCount: 1)
        setExpectationEvent(type: EventType.configuration, source: EventSource.responseContent, expectedCount: 1)

        // wait for async registration because the EventHub is already started in FunctionalTestBase
        let waitForRegistration = CountDownLatch(1)
        MobileCore.registerExtensions([Identity.self, Edge.self, Media.self], {
            print("Extensions registration is complete")
            waitForRegistration.countDown()
        })
        XCTAssertEqual(DispatchTimeoutResult.success, waitForRegistration.await(timeout: 2))

        MobileCore.updateConfigurationWith(configDict: configuration)

        assertExpectedEvents(ignoreUnexpectedEvents: false)
        resetTestExpectations()
    }

    // Test Cases
    func testPlayback_singleSession_play_pause_complete() {
        // setup
        let responseConnection: HttpConnection = HttpConnection(data: successResponseBody.data(using: .utf8),
                                                                response: HTTPURLResponse(url: URL(string: sessionStartEdgeEndpoint)!,
                                                                                          statusCode: 200,
                                                                                          httpVersion: nil,
                                                                                          headerFields: nil),
                                                                error: nil)
        setNetworkResponseFor(url: sessionStartEdgeEndpoint, httpMethod: .post, responseHttpConnection: responseConnection)

        // test
        let tracker = Media.createTracker()
        tracker.trackSessionStart(info: mediaInfo, metadata: metadata)
        tracker.trackPlay()
        tracker.updateCurrentPlayhead(time: 7)
        tracker.trackPause()
        tracker.trackComplete()

        // verify
        let networkRequests = getAllNetworkRequests()
        XCTAssertEqual(4, networkRequests.count)

        assertXDMData(networkRequest: networkRequests[0], eventType: "sessionStart", info: mediaInfo, metadata: metadata, configuration: configuration)
        assertXDMData(networkRequest: networkRequests[1], eventType: "play", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[2], eventType: "pauseStart", backendSessionId: testBackendSessionId, playhead: 7)
        assertXDMData(networkRequest: networkRequests[3], eventType: "sessionComplete", backendSessionId: testBackendSessionId, playhead: 7)
    }

    func testPlayback_withPrerollAdBreak() {
        // setup
        let responseConnection: HttpConnection = HttpConnection(data: successResponseBody.data(using: .utf8),
                                                                response: HTTPURLResponse(url: URL(string: sessionStartEdgeEndpoint)!,
                                                                                          statusCode: 200,
                                                                                          httpVersion: nil,
                                                                                          headerFields: nil),
                                                                error: nil)
        setNetworkResponseFor(url: sessionStartEdgeEndpoint, httpMethod: .post, responseHttpConnection: responseConnection)

        // test
        let tracker = Media.createTracker()
        tracker.trackSessionStart(info: mediaInfo, metadata: metadata)
        tracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakInfo, metadata: nil)
        tracker.updateQoEObject(qoe: qoeInfo)
        tracker.trackEvent(event: MediaEvent.AdStart, info: adInfo, metadata: metadata)
        tracker.trackPlay()
        tracker.trackEvent(event: MediaEvent.AdComplete, info: nil, metadata: nil)
        tracker.trackEvent(event: MediaEvent.AdBreakComplete, info: nil, metadata: nil)
        tracker.trackComplete()

        // verify
        let networkRequests = getAllNetworkRequests()
        XCTAssertEqual(8, networkRequests.count)

        assertXDMData(networkRequest: networkRequests[0], eventType: "sessionStart", info: mediaInfo, metadata: metadata, configuration: configuration)
        assertXDMData(networkRequest: networkRequests[1], eventType: "adBreakStart", info: adBreakInfo, backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[2], eventType: "adStart", info: adInfo, metadata: metadata, configuration: configuration, backendSessionId: testBackendSessionId, qoeInfo: qoeInfo)
        assertXDMData(networkRequest: networkRequests[3], eventType: "play", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[4], eventType: "adComplete", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[5], eventType: "adBreakComplete", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[6], eventType: "play", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[7], eventType: "sessionComplete", backendSessionId: testBackendSessionId)
    }

    func testPlayback_withSingleChapter() {
        // setup
        let responseConnection: HttpConnection = HttpConnection(data: successResponseBody.data(using: .utf8),
                                                                response: HTTPURLResponse(url: URL(string: sessionStartEdgeEndpoint)!,
                                                                                          statusCode: 200,
                                                                                          httpVersion: nil,
                                                                                          headerFields: nil),
                                                                error: nil)
        setNetworkResponseFor(url: sessionStartEdgeEndpoint, httpMethod: .post, responseHttpConnection: responseConnection)

        // test
        let tracker = Media.createTracker()
        tracker.trackSessionStart(info: mediaInfo, metadata: metadata)
        tracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo, metadata: metadata)
        tracker.trackPlay()
        tracker.trackEvent(event: MediaEvent.ChapterComplete, info: nil, metadata: nil)
        tracker.trackComplete()

        // verify
        let networkRequests = getAllNetworkRequests()
        XCTAssertEqual(5, networkRequests.count)

        assertXDMData(networkRequest: networkRequests[0], eventType: "sessionStart", info: mediaInfo, metadata: metadata, configuration: configuration)
        assertXDMData(networkRequest: networkRequests[1], eventType: "chapterStart", info: chapterInfo, metadata: metadata, backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[2], eventType: "play", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[3], eventType: "chapterComplete", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[4], eventType: "sessionComplete", backendSessionId: testBackendSessionId)
    }

    func testPlayback_withBuffer_withSeek_withBitrate_withQoeUpdate_withError() {
        // setup
        let responseConnection: HttpConnection = HttpConnection(data: successResponseBody.data(using: .utf8),
                                                                response: HTTPURLResponse(url: URL(string: sessionStartEdgeEndpoint)!,
                                                                                          statusCode: 200,
                                                                                          httpVersion: nil,
                                                                                          headerFields: nil),
                                                                error: nil)
        setNetworkResponseFor(url: sessionStartEdgeEndpoint, httpMethod: .post, responseHttpConnection: responseConnection)

        // test
        let tracker = Media.createTracker()
        tracker.trackSessionStart(info: mediaInfo, metadata: metadata)
        tracker.trackPlay()
        tracker.updateCurrentPlayhead(time: 5)
        tracker.trackEvent(event: MediaEvent.BufferStart, info: nil, metadata: nil)
        tracker.trackEvent(event: MediaEvent.BufferComplete, info: nil, metadata: nil)
        tracker.updateQoEObject(qoe: qoeInfo)
        tracker.updateCurrentPlayhead(time: 10)
        tracker.trackEvent(event: MediaEvent.BitrateChange, info: nil, metadata: nil)
        tracker.updateCurrentPlayhead(time: 15)
        tracker.trackEvent(event: MediaEvent.SeekStart, info: nil, metadata: nil)
        tracker.trackEvent(event: MediaEvent.SeekComplete, info: nil, metadata: nil)
        tracker.trackError(errorId: "testError")
        tracker.updateCurrentPlayhead(time: 20)
        tracker.trackComplete()

        // verify
        let networkRequests = getAllNetworkRequests()
        XCTAssertEqual(9, networkRequests.count)

        assertXDMData(networkRequest: networkRequests[0], eventType: "sessionStart", info: mediaInfo, metadata: metadata, configuration: configuration)
        assertXDMData(networkRequest: networkRequests[1], eventType: "play", backendSessionId: testBackendSessionId, playhead: 0)
        assertXDMData(networkRequest: networkRequests[2], eventType: "bufferStart", backendSessionId: testBackendSessionId, playhead: 5)
        assertXDMData(networkRequest: networkRequests[3], eventType: "play", backendSessionId: testBackendSessionId, playhead: 5)
        assertXDMData(networkRequest: networkRequests[4], eventType: "bitrateChange", info: qoeInfo, backendSessionId: testBackendSessionId, playhead: 10)
        assertXDMData(networkRequest: networkRequests[5], eventType: "pauseStart", backendSessionId: testBackendSessionId, playhead: 15)
        assertXDMData(networkRequest: networkRequests[6], eventType: "play", backendSessionId: testBackendSessionId, playhead: 15)
        assertXDMData(networkRequest: networkRequests[7], eventType: "error", info: ["error.id": "testError", "error.source": "player"], backendSessionId: testBackendSessionId, playhead: 15)
        assertXDMData(networkRequest: networkRequests[8], eventType: "sessionComplete", backendSessionId: testBackendSessionId, playhead: 20)
    }

    func testPlayback_withPrerollAdBreak_noAdComplete_noAdbreakComplete_withSessionEnd() {
        // setup
        let responseConnection: HttpConnection = HttpConnection(data: successResponseBody.data(using: .utf8),
                                                                response: HTTPURLResponse(url: URL(string: sessionStartEdgeEndpoint)!,
                                                                                          statusCode: 200,
                                                                                          httpVersion: nil,
                                                                                          headerFields: nil),
                                                                error: nil)
        setNetworkResponseFor(url: sessionStartEdgeEndpoint, httpMethod: .post, responseHttpConnection: responseConnection)

        // test
        let tracker = Media.createTracker()
        tracker.trackSessionStart(info: mediaInfo, metadata: metadata)
        tracker.updateQoEObject(qoe: qoeInfo)
        tracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreakInfo, metadata: nil)
        tracker.trackEvent(event: MediaEvent.AdStart, info: adInfo, metadata: metadata)
        tracker.trackPlay()
        tracker.trackSessionEnd()

        // verify
        let networkRequests = getAllNetworkRequests()
        XCTAssertEqual(7, networkRequests.count)

        assertXDMData(networkRequest: networkRequests[0], eventType: "sessionStart", info: mediaInfo, metadata: metadata, configuration: configuration)
        assertXDMData(networkRequest: networkRequests[1], eventType: "adBreakStart", info: adBreakInfo, backendSessionId: testBackendSessionId, qoeInfo: qoeInfo)
        assertXDMData(networkRequest: networkRequests[2], eventType: "adStart", info: adInfo, metadata: metadata, configuration: configuration, backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[3], eventType: "play", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[4], eventType: "adSkip", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[5], eventType: "adBreakComplete", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[6], eventType: "sessionEnd", backendSessionId: testBackendSessionId)
    }

    func testPlayback_withChapterStart_noChapterComplete_withSessionEnd() {
        // setup
        let responseConnection: HttpConnection = HttpConnection(data: successResponseBody.data(using: .utf8),
                                                                response: HTTPURLResponse(url: URL(string: sessionStartEdgeEndpoint)!,
                                                                                          statusCode: 200,
                                                                                          httpVersion: nil,
                                                                                          headerFields: nil),
                                                                error: nil)
        setNetworkResponseFor(url: sessionStartEdgeEndpoint, httpMethod: .post, responseHttpConnection: responseConnection)

        // test
        let tracker = Media.createTracker()
        tracker.trackSessionStart(info: mediaInfo, metadata: metadata)
        tracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo, metadata: metadata)
        tracker.trackPlay()
        tracker.updateCurrentPlayhead(time: 12)
        tracker.trackSessionEnd()

        // verify
        let networkRequests = getAllNetworkRequests()
        XCTAssertEqual(5, networkRequests.count)

        assertXDMData(networkRequest: networkRequests[0], eventType: "sessionStart", info: mediaInfo, metadata: metadata, configuration: configuration)
        assertXDMData(networkRequest: networkRequests[1], eventType: "chapterStart", info: chapterInfo, metadata: metadata, backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[2], eventType: "play", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[3], eventType: "chapterSkip", backendSessionId: testBackendSessionId, playhead: 12)
        assertXDMData(networkRequest: networkRequests[4], eventType: "sessionEnd", backendSessionId: testBackendSessionId, playhead: 12)
    }

    func testPlayback_withSingleChapter_withMuteState_withCustomState() {
        // setup
        let responseConnection: HttpConnection = HttpConnection(data: successResponseBody.data(using: .utf8),
                                                                response: HTTPURLResponse(url: URL(string: sessionStartEdgeEndpoint)!,
                                                                                          statusCode: 200,
                                                                                          httpVersion: nil,
                                                                                          headerFields: nil),
                                                                error: nil)
        setNetworkResponseFor(url: sessionStartEdgeEndpoint, httpMethod: .post, responseHttpConnection: responseConnection)

        // test
        let tracker = Media.createTracker()
        tracker.trackSessionStart(info: mediaInfo, metadata: metadata)
        tracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo, metadata: metadata)
        tracker.trackPlay()
        tracker.trackEvent(event: MediaEvent.StateStart, info: muteStateInfo, metadata: nil)
        tracker.trackEvent(event: MediaEvent.StateStart, info: customStateInfo, metadata: nil)
        tracker.updateCurrentPlayhead(time: 12)
        tracker.trackEvent(event: MediaEvent.StateEnd, info: customStateInfo, metadata: nil)
        tracker.trackEvent(event: MediaEvent.StateEnd, info: muteStateInfo, metadata: nil)
        tracker.trackEvent(event: MediaEvent.ChapterComplete, info: nil, metadata: nil)
        tracker.trackComplete()

        // verify
        let networkRequests = getAllNetworkRequests()
        XCTAssertEqual(9, networkRequests.count)

        assertXDMData(networkRequest: networkRequests[0], eventType: "sessionStart", info: mediaInfo, metadata: metadata, configuration: configuration)
        assertXDMData(networkRequest: networkRequests[1], eventType: "chapterStart", info: chapterInfo, metadata: metadata, backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[2], eventType: "play", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[3], eventType: "statesUpdate", info: muteStateInfo, backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[4], eventType: "statesUpdate", info: customStateInfo, backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[5], eventType: "statesUpdate", info: customStateInfo, backendSessionId: testBackendSessionId, playhead: 12, stateStart: false)
        assertXDMData(networkRequest: networkRequests[6], eventType: "statesUpdate", info: muteStateInfo, backendSessionId: testBackendSessionId, playhead: 12, stateStart: false)
        assertXDMData(networkRequest: networkRequests[7], eventType: "chapterComplete", backendSessionId: testBackendSessionId, playhead: 12)
        assertXDMData(networkRequest: networkRequests[8], eventType: "sessionComplete", backendSessionId: testBackendSessionId, playhead: 12)
    }

    func testPlayback_withChapterStart_noChapterComplete_withMuteStateStart_withCustomStateStart_noMuteStateEnd_noCustomStateEnd_withSessionEnd() {
        // setup
        let responseConnection: HttpConnection = HttpConnection(data: successResponseBody.data(using: .utf8),
                                                                response: HTTPURLResponse(url: URL(string: sessionStartEdgeEndpoint)!,
                                                                                          statusCode: 200,
                                                                                          httpVersion: nil,
                                                                                          headerFields: nil),
                                                                error: nil)
        setNetworkResponseFor(url: sessionStartEdgeEndpoint, httpMethod: .post, responseHttpConnection: responseConnection)

        // test
        let tracker = Media.createTracker()
        tracker.trackSessionStart(info: mediaInfo, metadata: metadata)
        tracker.updateQoEObject(qoe: qoeInfo)
        tracker.trackEvent(event: MediaEvent.ChapterStart, info: chapterInfo, metadata: metadata)
        tracker.trackPlay()
        tracker.trackEvent(event: MediaEvent.StateStart, info: muteStateInfo, metadata: nil)
        tracker.trackEvent(event: MediaEvent.StateStart, info: customStateInfo, metadata: nil)
        tracker.updateCurrentPlayhead(time: 12)
        tracker.trackSessionEnd()

        // verify
        let networkRequests = getAllNetworkRequests()
        XCTAssertEqual(7, networkRequests.count)

        assertXDMData(networkRequest: networkRequests[0], eventType: "sessionStart", info: mediaInfo, metadata: metadata, configuration: configuration)
        assertXDMData(networkRequest: networkRequests[1], eventType: "chapterStart", info: chapterInfo, metadata: metadata, backendSessionId: testBackendSessionId, qoeInfo: qoeInfo)
        assertXDMData(networkRequest: networkRequests[2], eventType: "play", backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[3], eventType: "statesUpdate", info: muteStateInfo, backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[4], eventType: "statesUpdate", info: customStateInfo, backendSessionId: testBackendSessionId)
        assertXDMData(networkRequest: networkRequests[5], eventType: "chapterSkip", backendSessionId: testBackendSessionId, playhead: 12)
        assertXDMData(networkRequest: networkRequests[6], eventType: "sessionEnd", backendSessionId: testBackendSessionId, playhead: 12)
    }

    // Test Assert Utils

    func assertXDMData(networkRequest: NetworkRequest, eventType: String, info: [String: Any] = [:], metadata: [String: String] = [:], configuration: [String: Any] = [:], backendSessionId: String? = nil, qoeInfo: [String: Any]? = nil, playhead: Int64? = nil, stateStart: Bool = true) {
        let expectedMediaCollectionData = EdgeEventHelper.generateMediaCollection(eventType: XDMMediaEventType(rawValue: eventType) ?? XDMMediaEventType.sessionEnd,
                                                                                  playhead: playhead ?? 0,
                                                                                  backendSessionId: testBackendSessionId,
                                                                                  info: info,
                                                                                  metadata: metadata,
                                                                                  mediaState: getMediaStateFrom(configuration),
                                                                                  qoeInfo: qoeInfo,
                                                                                  stateStart: stateStart)

        let actualXDMData = getXDMDataFromNetworkRequest(networkRequest)

        XCTAssertEqual("media." + eventType, actualXDMData["eventType"] as? String)
        XCTAssertNotNil(actualXDMData["timestamp"] as? String)
        XCTAssertNotNil(actualXDMData["_id"] as? String)

        let actualMediaCollectionData = actualXDMData["mediaCollection"] as? [String: Any] ?? [:]

        XCTAssertTrue( NSDictionary(dictionary: expectedMediaCollectionData).isEqual(to: actualMediaCollectionData), "For media event (\(String(describing: actualXDMData["eventType"]))) expected mediaCollection data \n(\(expectedMediaCollectionData)\n) does not match the actual mediaCollection data \n(\(actualMediaCollectionData))\n")
    }

    // Test Helpers

    func getXDMDataFromNetworkRequest(_ networkRequest: NetworkRequest, eventNumber: Int = 0) -> [String: Any] {
        let data = getNetworkRequestBodyAsDictionary(networkRequest)

        guard let eventDataList = data["events"] as? [[String: Any]] else {
            return [:]
        }

        let eventData = eventDataList[0]

        return eventData["xdm"] as? [String: Any] ?? [:]
    }

    func getMediaStateFrom(_ config: [String: Any]) -> MediaState {
        let mediaState = MediaState()
        mediaState.updateConfigurationSharedState(config)
        return mediaState
    }
}
