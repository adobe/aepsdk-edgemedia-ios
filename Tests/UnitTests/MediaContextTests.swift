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
import XCTest

class MediaContextTests: XCTestCase {
    let mediaInfo = MediaInfo(id: "mediaID", name: "mediaName", streamType: "aod", mediaType: MediaType.Audio, length: 30.0, prerollWaitingTime: 0)!
    let mediaMetadata = ["media.show": "sampleshow", "key1": "value1", "key2": "мểŧẳđαţả"]
    let adBreakInfo = AdBreakInfo(name: "adBreakName", position: 1, startTime: 1.1)!
    let adInfo = AdInfo(id: "adID", name: "adName", position: 1, length: 15.0)!
    let adMetadata = ["media.ad.advertiser": "sampleAdvertiser", "key1": "value1", "key2": "мểŧẳđαţả"]
    let chapterInfo = ChapterInfo(name: "chapterName", position: 1, startTime: 1.1, length: 30)!
    let chapterMetadata = ["media.artist": "sampleArtist", "key1": "value1", "key2": "мểŧẳđαţả"]
    var muteStateInfo = StateInfo(stateName: MediaConstants.PlayerState.MUTE)!
    var testStateInfo = StateInfo(stateName: "testStateName")!

    func testMediaContextCreation_cachesMediaInfoAndMetadata() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        XCTAssertNotNil(mediaContext)
        XCTAssertNotNil(mediaContext.mediaInfo)
        XCTAssertEqual("mediaID", mediaContext.mediaInfo.id)
        XCTAssertEqual("mediaName", mediaContext.mediaInfo.name)
        XCTAssertEqual("aod", mediaContext.mediaInfo.streamType)
        XCTAssertEqual("audio", mediaContext.mediaInfo.mediaType.rawValue)
        XCTAssertEqual(30.0, mediaContext.mediaInfo.length)
        XCTAssertEqual(0, mediaContext.mediaInfo.prerollWaitingTime)
        XCTAssertEqual(mediaMetadata, mediaContext.mediaMetadata)
        XCTAssertEqual(3, mediaContext.mediaMetadata.count)
    }

    func testSetAdInfo_getAdInfoReturnsValidAdInfo() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        mediaContext.setAdInfo(adInfo, metadata: adMetadata)

        XCTAssertNotNil(mediaContext.adInfo)
        XCTAssertEqual("adID", mediaContext.adInfo?.id)
        XCTAssertEqual("adName", mediaContext.adInfo?.name)
        XCTAssertEqual(1, mediaContext.adInfo?.position)
        XCTAssertEqual(15, mediaContext.adInfo?.length)
        XCTAssertEqual(adMetadata, mediaContext.adMetadata)
        XCTAssertEqual(3, mediaContext.adMetadata.count)
    }

    func testClearAdInfo_shouldClearAdInfoAndMetadata() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        mediaContext.setAdInfo(adInfo, metadata: adMetadata)
        XCTAssertNotNil(mediaContext.adInfo)
        XCTAssertEqual(4, mediaContext.adInfo?.toMap().count)
        XCTAssertNotNil(mediaContext.adMetadata)
        XCTAssertEqual(3, mediaContext.adMetadata.count)

        mediaContext.clearAdInfo()
        XCTAssertNil(mediaContext.adInfo)
        XCTAssertTrue(mediaContext.adMetadata.isEmpty)
    }

    func testSetAdbreakInfo_getAdbreakInfoReturnsValidAdbreakInfo() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        mediaContext.setAdBreakInfo(adBreakInfo)

        XCTAssertNotNil(mediaContext.adBreakInfo)
        XCTAssertEqual("adBreakName", mediaContext.adBreakInfo?.name)
        XCTAssertEqual(1, mediaContext.adBreakInfo?.position)
        XCTAssertEqual(1.1, mediaContext.adBreakInfo?.startTime)
    }

    func testClearAdbreakInfo_clearsAdbreakInfo() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        mediaContext.setAdBreakInfo(adBreakInfo)
        XCTAssertNotNil(mediaContext.adBreakInfo)
        XCTAssertEqual(3, mediaContext.adBreakInfo?.toMap().count)

        mediaContext.clearAdBreakInfo()
        XCTAssertNil(mediaContext.adBreakInfo)
    }

    func testSetChapterbreakInfo_getChapterInfoReturnsValidChapterInfo() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        mediaContext.setChapterInfo(chapterInfo, metadata: chapterMetadata)

        XCTAssertNotNil(mediaContext.chapterInfo)
        XCTAssertEqual("chapterName", mediaContext.chapterInfo?.name)
        XCTAssertEqual(1, mediaContext.chapterInfo?.position)
        XCTAssertEqual(30, mediaContext.chapterInfo?.length)
        XCTAssertEqual(1.1, mediaContext.chapterInfo?.startTime)
    }

    func testClearChapterInfo_clearsChapterInfo() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        mediaContext.setChapterInfo(chapterInfo, metadata: chapterMetadata)
        XCTAssertNotNil(mediaContext.chapterInfo)
        XCTAssertEqual(4, mediaContext.chapterInfo?.toMap().count)

        mediaContext.clearChapterInfo()
        XCTAssertNil(mediaContext.chapterInfo)
        XCTAssertTrue(mediaContext.chapterMetadata.isEmpty)
    }

    func testStartPlayerState_isInStateReturnsTrue() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        XCTAssertTrue(mediaContext.startState(info: muteStateInfo))
        XCTAssertTrue(mediaContext.isInState(info: muteStateInfo))
    }

    func testStartPlayerState_failsAfterMaxNoOfStatesCreated() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        for stateName in 1...10 {
            XCTAssertTrue(mediaContext.startState(info: StateInfo(stateName: "State\(stateName)")!))
        }

        XCTAssertFalse(mediaContext.startState(info: StateInfo(stateName: "State11")!))
        XCTAssertFalse(mediaContext.startState(info: StateInfo(stateName: "State12")!))
    }

    func testClearStates_AfterMaxNoOfStatesCreated_clearAStates_allowsNewStates() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        for stateName in 1...10 {
            XCTAssertTrue(mediaContext.startState(info: StateInfo(stateName: "State\(stateName)")!))
        }

        mediaContext.clearStates()

        // Now can again track 10 new states
        XCTAssertTrue(mediaContext.startState(info: StateInfo(stateName: "State11")!))
        XCTAssertTrue(mediaContext.startState(info: StateInfo(stateName: "State12")!))
    }

    func testEndPlayerState_isInStateReturnsFalse() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        XCTAssertTrue(mediaContext.startState(info: muteStateInfo))
        XCTAssertTrue(mediaContext.startState(info: testStateInfo))

        mediaContext.endState(info: muteStateInfo)
        XCTAssertFalse(mediaContext.isInState(info: muteStateInfo))
        XCTAssertTrue(mediaContext.isInState(info: testStateInfo))

        XCTAssertTrue(mediaContext.endState(info: testStateInfo))
        XCTAssertFalse(mediaContext.isInState(info: testStateInfo))
    }

    func testGetAllStates_returnsAllStatesWithTheirCurrentStatus() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)
        for stateName in 1...10 {
            XCTAssertTrue(mediaContext.startState(info: StateInfo(stateName: "State\(stateName)")!))
        }

        var activeStatesList = mediaContext.getActiveTrackedStates()
        XCTAssertEqual(10, activeStatesList.count)
        for stateName in 1...10 {
            XCTAssertTrue(activeStatesList.contains(StateInfo(stateName: "State\(stateName)")!))  // 1-5 states are active
        }

        for stateName in 6...10 {
            XCTAssertTrue(mediaContext.endState(info: StateInfo(stateName: "State\(stateName)")!))
        }

        activeStatesList = mediaContext.getActiveTrackedStates()
        XCTAssertEqual(5, activeStatesList.count)
        for stateName in 1...5 {
            XCTAssertTrue(activeStatesList.contains(StateInfo(stateName: "State\(stateName)")!))  // 1-5 states are active
        }
    }

    func testEnterPlaybackState_setsStateInContext() {
        let mediaContext = MediaContext(mediaInfo: mediaInfo, metadata: mediaMetadata)

        mediaContext.enterPlaybackState(state: MediaContext.MediaPlaybackState.Init)
        XCTAssertTrue(mediaContext.isInMediaPlaybackState(state: MediaContext.MediaPlaybackState.Init))

        mediaContext.enterPlaybackState(state: MediaContext.MediaPlaybackState.Play)
        XCTAssertTrue(mediaContext.isInMediaPlaybackState(state: MediaContext.MediaPlaybackState.Play))
        XCTAssertFalse(mediaContext.isIdle())

        mediaContext.enterPlaybackState(state: MediaContext.MediaPlaybackState.Pause)
        XCTAssertTrue(mediaContext.isInMediaPlaybackState(state: MediaContext.MediaPlaybackState.Pause))
        XCTAssertTrue(mediaContext.isIdle())

        mediaContext.enterPlaybackState(state: MediaContext.MediaPlaybackState.Seek)
        XCTAssertTrue(mediaContext.isInMediaPlaybackState(state: MediaContext.MediaPlaybackState.Seek))
        XCTAssertTrue(mediaContext.isIdle())

        mediaContext.enterPlaybackState(state: MediaContext.MediaPlaybackState.Buffer)
        XCTAssertTrue(mediaContext.isInMediaPlaybackState(state: MediaContext.MediaPlaybackState.Buffer))
        XCTAssertTrue(mediaContext.isIdle())
    }
}
