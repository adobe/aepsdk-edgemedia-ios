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

@testable import AEPEdgeMedia
import XCTest

class MediaStateTests: XCTestCase {

    static let validConfigurationSharedState = [
        TestConstants.Configuration.MEDIA_CHANNEL: "test_channel",
        TestConstants.Configuration.MEDIA_PLAYER_NAME: "test_player_name",
        TestConstants.Configuration.MEDIA_APP_VERSION: "test_app_version"
    ]

    static let invalidValues: [Any] = [
        1,
        true,
        [:],
        2.2,
        []
    ]

    static let emptyConfigurationSharedState = [String: Any]()

    func testUpdateConfigurationSharedStateUpdate_withValidConfig_populatesMediaConfig() throws {
        let mediaState = MediaState()
        mediaState.updateConfigurationSharedState(Self.validConfigurationSharedState)
        XCTAssertEqual("test_channel", mediaState.channel)
        XCTAssertEqual("test_player_name", mediaState.playerName)
        XCTAssertEqual("test_app_version", mediaState.appVersion)
    }

    func testUpdateConfigurationSharedStateUpdate_withEmptyConfig_hasNilMediaConfig() throws {
        let mediaState = MediaState()
        mediaState.updateConfigurationSharedState(Self.emptyConfigurationSharedState)
        XCTAssertNil(mediaState.channel)
        XCTAssertNil(mediaState.playerName)
        XCTAssertNil(mediaState.appVersion)
    }

    func testUpdateConfigurationSharedStateUpdate_withInvalidConfig_hasNilMediaConfig() throws {
        let mediaState = MediaState()

        for val in Self.invalidValues {
            let invalidConfigurationSharedState = [
                TestConstants.Configuration.MEDIA_CHANNEL: val,
                TestConstants.Configuration.MEDIA_PLAYER_NAME: val,
                TestConstants.Configuration.MEDIA_APP_VERSION: val
            ]

            mediaState.updateConfigurationSharedState(invalidConfigurationSharedState)
            XCTAssertNil(mediaState.channel)
            XCTAssertNil(mediaState.playerName)
            XCTAssertNil(mediaState.appVersion)
        }
    }

    func testHasRequiredConfiguration_withValidConfig_returnsTrue() throws {
        let mediaState = MediaState()
        mediaState.updateConfigurationSharedState(Self.validConfigurationSharedState)
        XCTAssertTrue(mediaState.hasRequiredConfiguration())
    }

    func testHasRequiredConfiguration_withValidPlayerNameAndValidChannel_returnsTrue() throws {
        let mediaState = MediaState()
        let configurationSharedState = [
            TestConstants.Configuration.MEDIA_CHANNEL: "test_channel",
            TestConstants.Configuration.MEDIA_PLAYER_NAME: "test_player_name"]
        mediaState.updateConfigurationSharedState(configurationSharedState)
        XCTAssertTrue(mediaState.hasRequiredConfiguration())
    }

    func testHasRequiredConfiguration_withValidPlayerNameAndInvalidChannel_returnsFalse() throws {
        let mediaState = MediaState()
        let configurationSharedState = [
            TestConstants.Configuration.MEDIA_PLAYER_NAME: "test_player_name",
            TestConstants.Configuration.MEDIA_APP_VERSION: "test_app_version"]
        mediaState.updateConfigurationSharedState(configurationSharedState)
        XCTAssertFalse(mediaState.hasRequiredConfiguration())
    }

    func testHasRequiredConfiguration_withValidChannelAndInvalidPlayerName_returnsFalse() throws {
        let mediaState = MediaState()
        let configurationSharedState = [
            TestConstants.Configuration.MEDIA_CHANNEL: "test_channel",
            TestConstants.Configuration.MEDIA_APP_VERSION: "test_app_version"]
        mediaState.updateConfigurationSharedState(configurationSharedState)
        XCTAssertFalse(mediaState.hasRequiredConfiguration())
    }

    func testHasRequiredConfiguration_withEmptyConfig_returnsFalse() throws {
        let mediaState = MediaState()
        mediaState.updateConfigurationSharedState(Self.emptyConfigurationSharedState)
        XCTAssertFalse(mediaState.hasRequiredConfiguration())
    }

    func testHasRequiredConfiguration_withEmptyChannel_returnsFalse() throws {
        let mediaState = MediaState()
        let configurationSharedState = [
            TestConstants.Configuration.MEDIA_CHANNEL: "",
            TestConstants.Configuration.MEDIA_PLAYER_NAME: "test_player_name",
            TestConstants.Configuration.MEDIA_APP_VERSION: "test_app_version"]
        mediaState.updateConfigurationSharedState(configurationSharedState)
        XCTAssertFalse(mediaState.hasRequiredConfiguration())
    }

    func testHasRequiredConfiguration_withEmptyPlayerName_returnsFalse() throws {
        let mediaState = MediaState()
        let configurationSharedState = [
            TestConstants.Configuration.MEDIA_CHANNEL: "test_channel",
            TestConstants.Configuration.MEDIA_PLAYER_NAME: "",
            TestConstants.Configuration.MEDIA_APP_VERSION: "test_app_version"]
        mediaState.updateConfigurationSharedState(configurationSharedState)
        XCTAssertFalse(mediaState.hasRequiredConfiguration())
    }

    func testhasRequiredConfiguration_withInvalidConfig_returnsFalse() throws {
        let mediaState = MediaState()

        for val in Self.invalidValues {
            let invalidConfigurationSharedState = [
                TestConstants.Configuration.MEDIA_CHANNEL: val,
                TestConstants.Configuration.MEDIA_PLAYER_NAME: val,
                TestConstants.Configuration.MEDIA_APP_VERSION: val
            ]

            mediaState.updateConfigurationSharedState(invalidConfigurationSharedState)
            XCTAssertFalse(mediaState.hasRequiredConfiguration())
        }
    }

}
