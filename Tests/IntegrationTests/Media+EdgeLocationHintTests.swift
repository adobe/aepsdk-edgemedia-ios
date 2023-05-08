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

class EdgeMediaLocationHintIntegrationTests: FunctionalTestBase {
    private let configuration = ["edge.configId": "12345-example",
                                 "edgeMedia.channel": "testChannel",
                                 "edgeMedia.playerName": "testPlayerName"
    ]

    let mediaInfo = Media.createMediaObjectWith(name: "testName", id: "testId", length: 30, streamType: "VOD", mediaType: MediaType.Video)!

    let metadata = ["testKey": "testValue"]

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
    func testEdgeMediaRequests_whenLocationHintSet_urlPathContainsLocationHint() {
        // setup
        let testLocationHint = "or2"
        Edge.setLocationHint(testLocationHint)

        let sessionStartEdgeEndpoint = "https://edge.adobedc.net/ee/\(testLocationHint)/va/v1/sessionStart"

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
        XCTAssertTrue(networkRequests[0].url.absoluteString.contains("https://edge.adobedc.net/ee/\(testLocationHint)/va/v1/sessionStart"))
        XCTAssertTrue(networkRequests[1].url.absoluteString.contains("https://edge.adobedc.net/ee/\(testLocationHint)/va/v1/play"))
        XCTAssertTrue(networkRequests[2].url.absoluteString.contains("https://edge.adobedc.net/ee/\(testLocationHint)/va/v1/pauseStart"))
        XCTAssertTrue(networkRequests[3].url.absoluteString.contains("https://edge.adobedc.net/ee/\(testLocationHint)/va/v1/sessionComplete"))
    }

    func testMediaEdgeRequests_noLocationHintSet_urlPathDoesNotContainLocationHint() {
        // setup
        Edge.setLocationHint(nil)

        let sessionStartEdgeEndpoint = "https://edge.adobedc.net/ee/va/v1/sessionStart"

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
        XCTAssertTrue(networkRequests[0].url.absoluteString.contains("https://edge.adobedc.net/ee/va/v1/sessionStart"))
        XCTAssertTrue(networkRequests[1].url.absoluteString.contains("https://edge.adobedc.net/ee/va/v1/play"))
        XCTAssertTrue(networkRequests[2].url.absoluteString.contains("https://edge.adobedc.net/ee/va/v1/pauseStart"))
        XCTAssertTrue(networkRequests[3].url.absoluteString.contains("https://edge.adobedc.net/ee/va/v1/sessionComplete"))
    }
}
