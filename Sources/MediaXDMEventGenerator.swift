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
import AEPServices
import Foundation

class  MediaXDMEventGenerator {
    private static let LOG_TAG = MediaConstants.LOG_TAG
    private static let CLASS_NAME = "MediaExperienceEventGenerator"
    private let mediaEventProcessor: MediaEventProcessing
    private let trackerConfig: [String: Any]
    private let refEvent: Event
    private var lastReportedQoe: XDMQoeDataDetails?
    private var isTracking: Bool = false
    private var refTS: Int64
    private var currentPlaybackState: MediaContext.MediaPlaybackState?
    private var currentPlaybackStateStartRefTS: Int64
    private let allowedAdPingIntervalRangeInSeconds = 1...10
    private let allowedMainPingIntervalRangeInSeconds = 10...50

    #if DEBUG
    var mediaContext: MediaContext
    var sessionId: String = ""
    #else
    private var mediaContext: MediaContext
    private var sessionId: String = ""
    #endif

    /// Initializes the Media XDM Event Generator
    public required init(context: MediaContext, eventProcessor: MediaEventProcessing, config: [String: Any], refEvent: Event, refTS: Int64) {
        self.mediaContext = context
        self.mediaEventProcessor = eventProcessor
        self.trackerConfig = config
        self.refEvent = refEvent
        self.refTS = refTS
        self.currentPlaybackState = .Init
        self.currentPlaybackStateStartRefTS = refTS
        startTrackingSession(trackerSessionId: refEvent.sessionId)
    }

    func processSessionStart(forceResume: Bool = false) {
        var sessionDetails = MediaXDMEventHelper.generateSessionDetails(mediaInfo: mediaContext.mediaInfo, metadata: mediaContext.mediaMetadata, forceResume: forceResume)
        let customMetadata = MediaXDMEventHelper.generateMediaCustomMetadataDetails(metadata: mediaContext.mediaMetadata)

        if let channel = trackerConfig[MediaConstants.TrackerConfig.CHANNEL] as? String, !channel.isEmpty {
            sessionDetails.channel = channel
        }

        var mediaCollection = XDMMediaCollection()
        mediaCollection.sessionDetails = sessionDetails
        mediaCollection.customMetadata = customMetadata

        addGenericDataAndProcess(eventType: XDMMediaEventType.sessionStart, mediaCollection: mediaCollection)
    }

    func processSessionComplete() {
        addGenericDataAndProcess(eventType: XDMMediaEventType.sessionComplete, mediaCollection: nil)
        endTrackingSession()
    }

    func processSessionEnd() {
        addGenericDataAndProcess(eventType: XDMMediaEventType.sessionEnd, mediaCollection: nil)
        endTrackingSession()
    }

    func processAdBreakStart() {
        var mediaCollection = XDMMediaCollection()
        mediaCollection.advertisingPodDetails = MediaXDMEventHelper.generateAdvertisingPodDetails(adBreakInfo: mediaContext.adBreakInfo)

        addGenericDataAndProcess(eventType: XDMMediaEventType.adBreakStart, mediaCollection: mediaCollection)
    }

    func processAdBreakComplete() {
        addGenericDataAndProcess(eventType: XDMMediaEventType.adBreakComplete, mediaCollection: nil)
    }

    func processAdBreakSkip() {
        addGenericDataAndProcess(eventType: XDMMediaEventType.adBreakComplete, mediaCollection: nil)
    }

    func processAdStart() {
        var mediaCollection = XDMMediaCollection()
        mediaCollection.advertisingDetails = MediaXDMEventHelper.generateAdvertisingDetails(adInfo: mediaContext.adInfo, adMetadata: mediaContext.adMetadata)
        mediaCollection.customMetadata = MediaXDMEventHelper.generateAdCustomMetadataDetails(metadata: mediaContext.adMetadata)

        addGenericDataAndProcess(eventType: XDMMediaEventType.adStart, mediaCollection: mediaCollection)
    }

    func processAdComplete() {
        addGenericDataAndProcess(eventType: XDMMediaEventType.adComplete, mediaCollection: nil)
    }

    func processAdSkip() {
        addGenericDataAndProcess(eventType: XDMMediaEventType.adSkip, mediaCollection: nil)
    }

    func processChapterStart() {
        var mediaCollection = XDMMediaCollection()
        mediaCollection.chapterDetails = MediaXDMEventHelper.generateChapterDetails(chapterInfo: mediaContext.chapterInfo)
        mediaCollection.customMetadata = MediaXDMEventHelper.generateChapterMetadata(metadata: mediaContext.chapterMetadata)

        addGenericDataAndProcess(eventType: XDMMediaEventType.chapterStart, mediaCollection: mediaCollection)
    }

    func processChapterComplete() {
        addGenericDataAndProcess(eventType: XDMMediaEventType.chapterComplete, mediaCollection: nil)
    }

    func processChapterSkip() {
        addGenericDataAndProcess(eventType: XDMMediaEventType.chapterSkip, mediaCollection: nil)
    }

    /// End media session after 24 hr timeout or idle timeout(30 mins).
    func processSessionAbort() {
        processSessionEnd()
    }

    /// Restart session again after 24 hr timeout or idle timeout recovered.
    func processSessionRestart() {
        currentPlaybackState = .Init
        currentPlaybackStateStartRefTS = refTS

        lastReportedQoe = nil
        startTrackingSession(trackerSessionId: refEvent.sessionId)
        processSessionStart(forceResume: true)

        if mediaContext.chapterInfo != nil {
            processChapterStart()
        }

        if mediaContext.adBreakInfo != nil {
            processAdBreakStart()
        }

        if mediaContext.adInfo != nil {
            processAdStart()
        }

        for state in mediaContext.getActiveTrackedStates() {
            processStateStart(stateInfo: state)
        }

        processPlayback(doFlush: true)
    }

    func processBitrateChange() {
        var mediaCollection = XDMMediaCollection()
        mediaCollection.qoeDataDetails = MediaXDMEventHelper.generateQoEDataDetails(qoeInfo: mediaContext.qoeInfo)

        addGenericDataAndProcess(eventType: XDMMediaEventType.bitrateChange, mediaCollection: mediaCollection)
    }

    func processError(errorId: String) {
        let errorDetails = MediaXDMEventHelper.generateErrorDetails(errorID: errorId)
        var mediaCollection = XDMMediaCollection()
        mediaCollection.errorDetails = errorDetails

        addGenericDataAndProcess(eventType: XDMMediaEventType.error, mediaCollection: mediaCollection)
    }

    func processPlayback(doFlush: Bool = false) {
        let reportingInterval = getReportingIntervalFromTrackerConfig(isAdStart: (mediaContext.adInfo != nil))

        if !isTracking {
            return
        }

        let newPlaybackState = getPlaybackState()

        if self.currentPlaybackState != newPlaybackState || doFlush {
            let eventType = getMediaEventForPlaybackState(newPlaybackState)

            addGenericDataAndProcess(eventType: eventType, mediaCollection: nil)
            currentPlaybackState = newPlaybackState
            currentPlaybackStateStartRefTS = refTS
        } else if (newPlaybackState == currentPlaybackState) && (refTS - currentPlaybackStateStartRefTS >= reportingInterval) {
            // If the ts difference is more than interval we need to send it as multiple pings
            addGenericDataAndProcess(eventType: XDMMediaEventType.ping, mediaCollection: nil)
            currentPlaybackStateStartRefTS = refTS
        }
    }

    func processStateStart(stateInfo: StateInfo) {
        let stateStartDetails = MediaXDMEventHelper.generateStateDetails(states: [stateInfo])
        var mediaCollection = XDMMediaCollection()
        mediaCollection.statesStart = stateStartDetails

        addGenericDataAndProcess(eventType: XDMMediaEventType.statesUpdate, mediaCollection: mediaCollection)
    }

    func processStateEnd(stateInfo: StateInfo) {
        let stateEndDetails = MediaXDMEventHelper.generateStateDetails(states: [stateInfo])
        var mediaCollection = XDMMediaCollection()
        mediaCollection.statesEnd = stateEndDetails

        addGenericDataAndProcess(eventType: XDMMediaEventType.statesUpdate, mediaCollection: mediaCollection)
    }

    func setRefTS(ts: Int64) {
        refTS = ts
    }

    /// Signals event processor to start a new media session.
    ///    - Parameter trackerSessionId: A `UUID` string representing tracker session ID which can used be for debugging.
    private func startTrackingSession(trackerSessionId: String?) {
        guard let sessionId = mediaEventProcessor.createSession(trackerConfig: trackerConfig, trackerSessionId: trackerSessionId) else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Unable to create a tracking session.")
            isTracking = false
            return
        }
        self.sessionId = sessionId
        Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Started a new session with id (\(self.sessionId)).")
        isTracking = true
    }

    private func endTrackingSession() {
        if isTracking {
            Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Ending the session with id (\(sessionId)).")
            mediaEventProcessor.endSession(sessionId: sessionId)
            isTracking = false
        }
    }

    /// Prepares the XDM formatted data and creates a`MediaXDMEvent`, which is then sent to `MediaEventProcessor` for processing.
    ///  - Parameters:
    ///   - eventType: A `XDMMediaEventType` enum representing the XDM formatted name of the media event.
    ///   - mediaCollection: A  `XDMMediaCollection` object which is a XDM formatted object with some fields populated depending on the media event.
    private func addGenericDataAndProcess(eventType: XDMMediaEventType, mediaCollection: XDMMediaCollection?) {
        guard isTracking else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Dropping hit as we have stopped tracking the session")
            return
        }

        var mediaCollection = mediaCollection ?? XDMMediaCollection()

        // For bitrate change events and error events, use the qoe data in the current event being generated. For other events check MediaContext QoE object for latest QoE data updates.
        mediaCollection.qoeDataDetails = getQoEForCurrentEvent(qoe: mediaCollection.qoeDataDetails)
        // Add playhead details
        mediaCollection.playhead = Int64(mediaContext.playhead)

        // Convert the refTS from milliseconds to seconds
        let timestampAsDate = Date(timeIntervalSince1970: Double(refTS / 1000))
        let xdmEvent = MediaXDMEvent(eventType: eventType, timestamp: timestampAsDate, mediaCollection: mediaCollection)

        mediaEventProcessor.processEvent(sessionId: sessionId, event: xdmEvent)
    }

    /// Gets the XDM formatted QoE data for the current event.
    ///  - Parameter qoe: A `XDMQoeDataDetails` object
    ///  - Returns:XDMFormatted QoE data if the current event has QoE Data or if the MediaContext has QoE data which is not yet reported to the backend. Otherwise it returns nil.
    private func getQoEForCurrentEvent(qoe: XDMQoeDataDetails?) -> XDMQoeDataDetails? {
        // Cache and return the passed in QoE object if it is not nil
        if let qoe = qoe, !qoe.isNullOrEmpty() {
            lastReportedQoe = qoe
            return qoe
        }

        // If the passed QoE data object is nil, get the QoE data cached by the MediaContext class and convert to XDM formatted object.
        let mediaContextQoe = MediaXDMEventHelper.generateQoEDataDetails(qoeInfo: mediaContext.qoeInfo)
        // If the QoE data cached by the MediaContext class is different than the last reported QoE data, return the MediaContext cached QoE data to be sent to the backend
        if lastReportedQoe != mediaContextQoe {
            lastReportedQoe = mediaContextQoe
            return mediaContextQoe
        }

        // Return nil if the current event does not have any QoE data and the latest QoE data has been already reported
        return nil
    }

    private func getPlaybackState() -> MediaContext.MediaPlaybackState {
        if mediaContext.isInMediaPlaybackState(state: .Buffer) {
            return .Buffer
        } else if mediaContext.isInMediaPlaybackState(state: .Seek) {
            return .Seek
        } else if mediaContext.isInMediaPlaybackState(state: .Play) {
            return .Play
        } else if mediaContext.isInMediaPlaybackState(state: .Pause) {
            return .Pause
        } else {
            return .Init
        }
    }

    private func getMediaEventForPlaybackState(_ state: MediaContext.MediaPlaybackState) -> XDMMediaEventType {
        switch state {
        case .Buffer:
            return XDMMediaEventType.bufferStart
        case .Seek:
            return XDMMediaEventType.pauseStart
        case .Play:
            return XDMMediaEventType.play
        case .Pause:
            return XDMMediaEventType.pauseStart
        case .Init:
            // We should never hit this condition as there is no event to denote init.
            // Ping without any previous playback state denotes init.
            return XDMMediaEventType.ping
        }
    }

    /// Gets the custom reporting interval set in the tracker configuration. Valid custom main ping interval range is (10 seconds - 50 seconds) and valid ad ping interval is (1 second - 10 seconds)
    /// - Parameter isAdStart: A Boolean  when true denotes reporting interval is needed for Ad content or denotes Main content when false.
    /// - Return: the custom interval in `MILLISECONDS` if found in tracker configuration. Returns the default `MediaConstants.PingInterval.REALTIME_TRACKING` if the custom values are invalid or not found
    private func getReportingIntervalFromTrackerConfig(isAdStart: Bool = false) -> Int64 {
        if isAdStart {
            guard let customAdPingInterval = trackerConfig[MediaConstants.TrackerConfig.AD_PING_INTERVAL] as? Int, allowedAdPingIntervalRangeInSeconds.contains(customAdPingInterval) else {
                return MediaConstants.PingInterval.REALTIME_TRACKING_MS
            }

            return Int64(customAdPingInterval) * 1000 // convert to Milliseconds

        } else {
            guard let customMainPingInterval = trackerConfig[MediaConstants.TrackerConfig.MAIN_PING_INTERVAL] as? Int, allowedMainPingIntervalRangeInSeconds.contains(customMainPingInterval) else {
                return MediaConstants.PingInterval.REALTIME_TRACKING_MS
            }

            return Int64(customMainPingInterval) * 1000 // convert to Milliseconds
        }
    }
}
