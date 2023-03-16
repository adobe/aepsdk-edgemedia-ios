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

@objc(AEPMobileEdgeMedia)
public class Media: NSObject, Extension {
    private static let LOG_TAG = MediaConstants.LOG_TAG
    private static let CLASS_NAME = "Media"

    public var runtime: ExtensionRuntime
    public var name = MediaConstants.EXTENSION_NAME
    public var friendlyName = MediaConstants.FRIENDLY_NAME
    public static var extensionVersion = MediaConstants.EXTENSION_VERSION
    public var metadata: [String: String]?

    #if DEBUG
    var trackers: [String: MediaEventTracking]
    var mediaEventProcessor: MediaEventProcessor
    #else
    private var trackers: [String: MediaEventTracking]
    private var mediaEventProcessor: MediaEventProcessor
    #endif

    // MARK: Extension
    /// Initializes the Media extension and it's dependencies
    public required init(runtime: ExtensionRuntime) {
        self.runtime = runtime
        self.mediaEventProcessor = MediaEventProcessor(dispatcher: runtime.dispatch(event:))
        self.trackers = [:]
    }

    /// Invoked when the Media extension has been registered by the `EventHub`
    public func onRegistered() {
        registerListener(type: MediaConstants.Media.EVENT_TYPE, source: MediaConstants.Media.EVENT_SOURCE_CREATE_TRACKER, listener: handleMediaTrackerRequest)
        registerListener(type: MediaConstants.Media.EVENT_TYPE, source: MediaConstants.Media.EVENT_SOURCE_TRACK_MEDIA, listener: handleMediaTrack)
        registerListener(type: EventType.configuration, source: EventSource.responseContent, listener: handleConfigurationResponseEvent)
        registerListener(type: EventType.edge, source: MediaConstants.Media.EVENT_SOURCE_MEDIA_EDGE_SESSION, listener: handleMediaEdgeSessionDetails)
        registerListener(type: EventType.edge, source: MediaConstants.Media.EVENT_SOURCE_EDGE_ERROR_RESPONSE, listener: handleEdgeErrorResponse)
        registerListener(type: EventType.genericIdentity, source: EventSource.requestReset, listener: handleResetIdentitiesEvent)
    }

    /// Invoked when the Media extension has been unregistered by the `EventHub`, currently a no-op.
    public func onUnregistered() { }

    // Media extension is always ready for processing `Event`
    /// - Parameter event: an `Event`
    public func readyForEvent(_ event: Event) -> Bool {
        return true
    }

    /// Handles the session ID returned by the media backend response dispatched by the edge extension
    /// - Parameter:
    ///   - event: The new media edge session response event with media backend ID
    public func handleMediaEdgeSessionDetails(_ event: Event) {
        guard event.data != nil, let requestEventId = event.requestEventId else {
            return
        }

        mediaEventProcessor.notifyBackendSessionId(requestEventId: requestEventId, backendSessionId: event.backendSessionId)
    }

    /// Handles the error response event dispatched by the edge extension
    /// - Parameter:
    ///   - event: The error response event
    public func handleEdgeErrorResponse(_ event: Event) {
        guard let eventData = event.data, let requestEventId = event.requestEventId else {
            return
        }

        mediaEventProcessor.notifyErrorResponse(requestEventId: requestEventId, data: eventData)
    }

    /// Processes Configuration response content events to retrieve the configuration data.
    /// - Parameter:
    ///   - event: The configuration response event
    private func handleConfigurationResponseEvent(_ event: Event) {
        mediaEventProcessor.updateMediaState(configurationSharedStateData: retrieveConfigurationStateForEvent(event))
    }

    /// Handler for media tracker creation events
    /// - Parameter event: an event containing  data for creating tracker
    private func handleMediaTrackerRequest(event: Event) {
        guard let trackerId = event.trackerId, !trackerId.isEmpty else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Public tracker ID is invalid, unable to create internal tracker.")
            return
        }

        let trackerConfig = event.trackerConfig ?? [:]

        Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Creating an internal tracker with tracker ID: \(trackerId).")
        trackers[trackerId] = MediaEventTracker(eventProcessor: mediaEventProcessor, config: trackerConfig)
    }

    /// Handler for media track events
    /// - Parameter event: an event containing  media event data for processing
    private func handleMediaTrack(event: Event) {
        guard let trackerId = event.trackerId, !trackerId.isEmpty else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Public tracker ID is invalid, unable to get internal tracker.")
            return
        }

        guard let tracker = trackers[trackerId] else {
            Log.error(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Unable to find internal tracker for the given tracker ID: (\(trackerId)).")
            return
        }

        tracker.track(event: event)
    }

    /// Processes Reset identites event
    /// - Parameter event: The Reset identities event
    private func handleResetIdentitiesEvent(_ event: Event) {
        Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Clearing all tracking sessions.")
        mediaEventProcessor.abortAllSessions()
        trackers.removeAll()
    }

    /// Fetched latest configuration for given event
    /// - Parameter event: the `Event` being processed
    private func retrieveConfigurationStateForEvent(_ event: Event) -> [String: Any]? {
        return getSharedState(extensionName: MediaConstants.Configuration.SHARED_STATE_NAME, event: event)?.value
    }
}
