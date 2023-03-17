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

class MediaRealTimeSession: MediaSession {

    private static let LOG_TAG = MediaConstants.LOG_TAG
    private static let CLASS_NAME = "MediaRealTimeSession"

    private var lastHitTS: Int64 = 0

    #if DEBUG
    var mediaBackendSessionId: String = ""
    var sessionStartEdgeRequestId: String?
    var events: [MediaXDMEvent] = []
    #else
    private var mediaBackendSessionId: String = ""
    private var sessionStartEdgeRequestId: String?
    private var events: [MediaXDMEvent] = []
    #endif

    typealias ErrorData = MediaConstants.Edge.ErrorData
    typealias ErrorKeys = MediaConstants.Edge.ErrorKeys

    /// Handles media state update. Triggers the dispatch loop if it was halted waiting for media state properties.
    override func handleMediaStateUpdate() {
        Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - [Session (\(id))] Handling media state update.")

        // Trigger the event dispatch loop if it was blocked by the required media state properties
        tryDispatchExperienceEvent()
    }

    /// Add media events to the queue.
    override func handleQueueEvent(_ event: MediaXDMEvent) {
        if !isSessionActive {
            return
        }

        Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - [Session (\(id))] Queuing media event (\(event.eventType)).")
        events.append(event)

        // Start processing and dispatching media events
        tryDispatchExperienceEvent()
    }

    /// handles media session end scenario.
    override func handleSessionEnd() {
        Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - [Session (\(id))] Ending media session.")

        // Trigger the event dispatch loop and ensure all the events are dispatched before ending the session
        tryDispatchExperienceEvent()
    }

    /// Handles session abort scenario.
    override func handleSessionAbort() {
        Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] -[Session (\(id))] Aborting media.")
        events.removeAll()
        sessionEndHandler?()
    }

    /// Handles media backend session id dispatched by the edge extension.
    /// If valid backend session id is found it dispatches the session created event and starts dispatching subsequent media events. In case of invalid session id, the media session is aborted and no events are dispatched.
    /// - Parameters:
    ///    - requestEventId: A `String` UUID for the edge request event.
    ///    - backendSessionId: A `String` UUID representing the session id returned by the backend.
    override func handleSessionUpdate(requestEventId: String, backendSessionId: String?) {
        if sessionStartEdgeRequestId != requestEventId {
            return
        }

        // If valid backendSessionId is received start processing the queued media events
        if updateBackendSessionId(backendSessionId) {
            Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - [Session (\(id)] Updating MediaEdge session with backendSessionId:(\(mediaBackendSessionId)).")
            tryDispatchExperienceEvent()

        } else {
            // Unable to update backend session id as it is invalid, so abort the session
            Log.warning(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - [Session (\(id)] Dropping the current tracking media session as invalid session id returned by the backend.")
            abort(onSessionEnd: sessionEndHandler)
        }
    }

    /// Handles error response dispatched by the edge extension. Aborts the media session if the error code is `ErrorData.ERROR_CODE_400` and error type is `ErrorData.ERROR_TYPE_VA_EDGE_400`.
    /// - Parameters:
    ///    - requestEventId: A `String` UUID for the edge request event.
    ///    - data: A dictionary with error details returned by the backend.
    override func handleErrorResponse(requestEventId: String, data: [String: Any?]) {
        if sessionStartEdgeRequestId != requestEventId {
            // Error is not for the events dispatched in this session
            return
        }

        guard let statusCode = data[ErrorKeys.STATUS] as? Int64, let errorType = data[ErrorKeys.TYPE] as? String else {
            return
        }

        if statusCode == ErrorData.ERROR_CODE_400 && errorType.caseInsensitiveCompare(ErrorData.ERROR_TYPE_VA_EDGE_400) == .orderedSame {
            // Abort the session as the sessionStart request failed
            Log.warning(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - [Session (\(id)] Aborting session as error occured while dispatching"
                            + "\(XDMMediaEventType.sessionStart.rawValue) request. Error payload: (\(data))")
            abort()
        }
    }

    /// Sends the  Media Edge `Event` with XDM data to the edge extension
    private func tryDispatchExperienceEvent() {
        if events.isEmpty {
            Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - [Session (\(id)] Exiting as there are no events to be dispatched.")
            return
        }

        guard let dispatcher = dispatcher else {
            Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - [Session (\(id)] Exiting as event dispatcher not found.")
            return
        }

        guard state.hasRequiredConfiguration() else {
            Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - [Session (\(id)] Exiting as the required configuration is missing, verify channel and playerName are configured.")
            return
        }

        while !events.isEmpty {
            var event = events[0]

            if !isReadyToDispatchEvent(eventType: event.eventType) {
                break
            }

            attachMediaStateInfo(to: &event)

            generateMediaEdgeEventAndDispatch(dispatcher: dispatcher, event: event)

            // Remove the processed event from the list
            events.removeFirst()
        }

        // Check if session has ended
        // Call the sessionEndHandler closure after processing all the events if the session is not active
        if events.isEmpty && !isSessionActive {
            sessionEndHandler?()
            return
        }
    }

    /// Checks if current event can be dispatched based on type and backend session id. It specifically checks if mediaBackendSessionId is available for all the media events except sessionStart.
    ///  - Parameter eventType: Current `XDMMediaEventType`.
    /// - Returns: `True` for sessionStart event or when `mediaBackendSessionId` is available for other events.
    func isReadyToDispatchEvent(eventType: XDMMediaEventType) -> Bool {
        if eventType != XDMMediaEventType.sessionStart && mediaBackendSessionId.isEmpty {
            // Ensure media backend session id is present for events other than sessionStart
            // If not present wait till the session id updates as a response from edge extension
            // The session aborts in case the sessionStart event returns error response
            Log.trace(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] -  [Session (\(id)] Exiting as the media session id is unavailable, will retry later.")
            return false
        }

        return true
    }

    /// Creates XDM formatted Media Edge `Event` object from the internal `MediaXDMEvent` object and dispatches the resulting `Event`.
    ///  - Parameters:
    ///    - dispatcher: A closure used for dispatching `Event`.
    ///    - event:A `MediaXDMEvent` object to be converted to `Event` and then dispatched.
    private func generateMediaEdgeEventAndDispatch(dispatcher: ((_ event: Event) -> Void), event: MediaXDMEvent) {
        let mediaEdgeEvent: Event = getXDMFormattedMediaEdgeEvent(event: event)

        if event.eventType == XDMMediaEventType.sessionStart {
            // Store the edge request id media for sessionStart event for handling the success/error reponses from the backend
            sessionStartEdgeRequestId = mediaEdgeEvent.id.uuidString
        }

        // Dispatch the media event to the eventhub to be sent by the edge extension to the backend
        dispatcher(mediaEdgeEvent)
    }

    /// Generates XDM formatted Media Edge `Event`.
    ///  - Parameter event: A `MediaXDMEvent` object.
    ///  - Returns: An `Event` object representing XDM formatted Media Edge event.
    private func getXDMFormattedMediaEdgeEvent(event: MediaXDMEvent) -> Event {
        // Generate custom path for the Interact API call for media backend
        let eventOverwritePath = generateEventPath(eventType: event.eventType.rawValue)

        var mediaXDMData = event.toXDMData()
        mediaXDMData[MediaConstants.Edge.EventData.REQUEST] = [MediaConstants.Edge.EventData.PATH: eventOverwritePath]

        let mediaEdgeEvent = Event(name: "MediaEdge event - \(event.eventType.edgeEventType())",
                                   type: EventType.edge,
                                   source: EventSource.requestContent,
                                   data: mediaXDMData)

        return mediaEdgeEvent
    }

    /// Attaches media state fields and backendSessionId based on the eventType
    ///  - Parameters:
    ///     -   event: A mutable `MediaXDMEvent` object to attach additional details to.
    private func attachMediaStateInfo(to event: inout MediaXDMEvent) {
        if event.eventType == XDMMediaEventType.sessionStart {
            event.mediaCollection.sessionDetails?.playerName = state.playerName
            event.mediaCollection.sessionDetails?.appVersion = state.appVersion

            // Channel would exist if the value is overriden using tracker configuration
            if event.mediaCollection.sessionDetails?.channel == nil {
                event.mediaCollection.sessionDetails?.channel = state.channel
            }
        } else {
            // Append backend session id for hits other than sessionStart
            event.mediaCollection.sessionID = self.mediaBackendSessionId

            if event.eventType == XDMMediaEventType.adStart {
                event.mediaCollection.advertisingDetails?.playerName = state.playerName
            }

        }
    }

    /// Generates custom request path to be overwritten by the edge request for Media.
    /// - Parameter evenType: A `String` denoting media event type for which the path is generated.
    /// - Returns: A `String` path used by the edge to send the edge media requests to.
    private func generateEventPath(eventType: String) -> String {
        return MediaConstants.Edge.MEDIA_CUSTOM_PATH_PREFIX + eventType
    }

    /// Verifies that the `backendSessionId` is a valid, non-empty string, and if so caches it.
    /// The backend session id is returned by the Edge as a response to the sessionStart event response.
    /// This backend session id is required for all the events after sessionStart event.
    /// - Parameter backendSessionId: A  UUID `String` returned by the backend.
    /// - Returns: `true` if the backend session id is a valid non-empty `String`, otherwise it returns `false`.
    private func updateBackendSessionId(_ backendSessionId: String?) -> Bool {
        guard let backendSessionId = backendSessionId, !backendSessionId.isEmpty else {
            return false
        }

        self.mediaBackendSessionId = backendSessionId

        return true
    }
}
