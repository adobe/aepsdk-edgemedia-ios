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

import AEPServices

class MediaContext {
    // swiftlint:disable identifier_name
    enum MediaPlaybackState: String {
        case Play
        case Pause
        case Buffer
        case Seek
        case Init
    }
    // swiftlint:enable identifier_name

    private static let LOG_TAG = MediaConstants.LOG_TAG
    private static let CLASS_NAME = "MediaContext"
    private var buffering = false
    private var seeking = false
    private var trackedStates: [String: Bool] = [:]
    private var playState = MediaPlaybackState.Init

    private(set) var mediaInfo: MediaInfo
    private(set) var mediaMetadata: [String: String]

    private(set) var adBreakInfo: AdBreakInfo?
    private(set) var adInfo: AdInfo?
    private(set) var adMetadata: [String: String] = [:]

    private(set) var chapterInfo: ChapterInfo?
    private(set) var chapterMetadata: [String: String] = [:]

    private(set) var errorInfo: [String: String]?

    var playhead = 0
    var qoeInfo: QoEInfo?

    init(mediaInfo: MediaInfo, metadata: [String: String]?) {
        self.mediaInfo = mediaInfo
        self.mediaMetadata = metadata ?? [:]
    }

    /// Sets `AdBreakInfo` for the AdBreak being tracked
    /// - Parameters:
    ///    - info: `AdBreakInfo` object.
    func setAdBreakInfo(_ info: AdBreakInfo) {
        adBreakInfo = info
    }

    /// Clears AdBreakInfo.
    func clearAdBreakInfo() {
        adBreakInfo = nil
    }

    /// Sets `AdInfo` and metadata for the Ad being tracked
    /// - Parameters:
    ///    - info: `AdInfo` object.
    ///    - metadata: Custom metadata associated with the Ad.
    func setAdInfo(_ info: AdInfo, metadata: [String: String]) {
        adInfo = info
        adMetadata = metadata
    }

    /// Clears `AdInfo` and metadata.
    func clearAdInfo() {
        adInfo = nil
        adMetadata = [:]
    }

    /// Sets `ChapterInfo` and metadata for the Chapter being tracked
    /// - Parameters:
    ///    - info: `ChapterInfo` object.
    ///    - metadata: Custom metadata associated with the Chapter.
    func setChapterInfo(_ info: ChapterInfo, metadata: [String: String]) {
        chapterInfo = info
        chapterMetadata = metadata
    }

    /// Clears `ChapterInfo` and metadata.
    func clearChapterInfo() {
        chapterInfo = nil
        chapterMetadata = [:]
    }

    /// Enter `MediaPlaybackState` when a valid state play/pause/buffer/stall is passed.
    /// Play and Pause can only be entered into and are mutually exclusive, while Buffer and Seek may be entered and exited.
    /// - Parameters:
    ///    - state: `MediaPlaybackState` value.
    func enterPlaybackState(state: MediaPlaybackState) {
        Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Enter playback state: (\(state))")
        switch state {
        case .Play, .Pause:
            playState = state
        case .Buffer:
            buffering = true
        case .Seek:
            seeking = true
        default:
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Cannot enter playback state: (\(state)), invalid playback state.")
        }
    }

    /// Exit `MediaPlaybackState` when a valid state play/pause/buffer/stall is passed.
    /// Buffer and Seek may be exited and entered, while Play and Pause are mutually exclusive and can only be entered but not exited.
    /// - Parameters:
    ///    - state: MediaPlaybackState value.
    func exitPlaybackState(state: MediaPlaybackState) {
        Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Exit playback state: (\(state))")
        switch state {
        case .Buffer:
            buffering = false
        case .Seek:
            seeking = false
        default:
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Cannot exit playback state: (\(state)), invalid playback state.")
        }
    }

    /// Returns `true` if the player is in a particular `MediaPlaybackState`.
    /// - Parameters:
    ///    - state: MediaPlaybackState value.
    func isInMediaPlaybackState(state: MediaPlaybackState) -> Bool {
        switch state {
        case .Init, .Play, .Pause:
            return (playState == state)
        case .Buffer:
            return buffering
        case .Seek:
            return seeking
        }
    }

    /// Returns `true` if the player is in seeking, buffering state or not in play state.
    func isIdle() -> Bool {
        return !isInMediaPlaybackState(state: .Play) ||
            isInMediaPlaybackState(state: .Seek) ||
            isInMediaPlaybackState(state: .Buffer)
    }

    /// Starts tracking customState.
    /// - Parameters:
    ///    - info: `StateInfo` object that contains custom state name.
    @discardableResult
    func startState(info: StateInfo) -> Bool {
        if !hasTrackedState(info: info) && didReachMaxStateLimit() {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Failed to start state,"
                        + " already tracked max states (\(MediaConstants.StateInfo.STATE_LIMIT)) for the current session.")
            return false
        }

        if isInState(info: info) {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Failed to start state, state (\(info.stateName)) is already being tracked.")
            return false
        }

        trackedStates[info.stateName] = true
        return true
    }

    /// Stops tracking customState if the state is actively being tracked.
    /// - Parameters:
    ///    - info: `StateInfo` object that contains custom state name.
    @discardableResult
    func endState(info: StateInfo) -> Bool {
        if !isInState(info: info) {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Failed to end state, state (\(info.stateName)) is not being tracked in the current session.")
            return false
        }

        trackedStates[info.stateName] = false
        return true
    }

    /// Returns `true` if the state is actively being tracked or not.
    /// - Parameters:
    ///    - info: `StateInfo` object that contains custom state name.
    func isInState(info: StateInfo) -> Bool {
        return trackedStates[info.stateName] ?? false
    }

    /// Returns `true` if the state is actively being tracked or is inactive but had been already tracked.
    /// - Parameters:
    ///    - info: `StateInfo` object that contains custom state name
    func hasTrackedState(info: StateInfo) -> Bool {
        return trackedStates[info.stateName] != nil
    }

    /// Returns all the states that are actively being tracked.
    /// - Parameters:
    ///    - info: `StateInfo` object that contains custom state name.
    func getActiveTrackedStates() -> [StateInfo] {
        var activeStates: [StateInfo] = []

        for state in trackedStates where state.value {
            if let stateInfo = StateInfo(stateName: state.key) {
                activeStates.append(stateInfo)
            }
        }

        return activeStates
    }

    /// Returns `true` if the maximum allowed number of custom states to be tracked in a session has been reached.
    func didReachMaxStateLimit() -> Bool {
        return trackedStates.count >= MediaConstants.StateInfo.STATE_LIMIT
    }

    /// Delete all the tracked custom states.
    func clearStates() {
        trackedStates.removeAll()
    }
}
