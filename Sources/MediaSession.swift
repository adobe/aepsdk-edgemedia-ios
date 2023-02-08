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

class MediaSession {
    private static let LOG_TAG = MediaConstants.LOG_TAG
    private static let CLASS_NAME = "MediaSession"

    private(set) var id: String
    private(set) var state: MediaState
    private(set) var dispatcher: ((_ event: Event) -> Void)?
    var isSessionActive: Bool
    var sessionEndHandler: (() -> Void)?
    var trackerSessionId: String?

    /// Initializer for `MediaSession`
    /// - Parameters:
    ///    - id: Unique `MediaSession id`
    ///    - trackerSessionId: A `UUID` string representing tracker session ID which can used be for debugging.
    ///    - mediaState: `MediaState` object
    ///    - dispatchQueue: `DispatchQueue` used for handling response after processing `MediaHit`
    ///    - dispather: A closure used for dispatching `Event`
    init(id: String, trackerSessionId: String?, state: MediaState, dispatchQueue: DispatchQueue, dispatcher: ((_ event: Event) -> Void)?) {
        self.id = id
        self.trackerSessionId = trackerSessionId
        self.state = state
        self.dispatcher = dispatcher
        isSessionActive = true
    }

    /// Queues the media `Event`
    /// - Parameter event: `Event` to be queued.
    func queue(event: MediaXDMEvent) {
        guard isSessionActive else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Failed to queue event. Media Session (\(id)) is inactive.")
            return
        }

        handleQueueEvent(event)
    }

    /// Ends the session
    /// - Parameter onsessionEnd: An optional closure that will be executed after successfully ending the session.
    func end(onSessionEnd sessionEndHandler: (() -> Void)? = nil) {
        guard isSessionActive else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Failed to end session. Media Session (\(id)) is inactive")
            return
        }

        self.sessionEndHandler = sessionEndHandler
        isSessionActive = false
        handleSessionEnd()
    }

    /// Aborts the session.
    /// - Parameter onSessionEnd: An optional closure that will be executed after successfully aborting the session.
    func abort(onSessionEnd sessionEndHandler: (() -> Void)? = nil) {
        guard isSessionActive else {
            Log.debug(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - Failed to abort session. Media Session (\(id)) is inactive")
            return
        }

        self.sessionEndHandler = sessionEndHandler
        isSessionActive = false
        handleSessionAbort()
    }

    /// Notifies MediaState updates
    func handleMediaStateUpdate() {
        Log.warning(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - This function should be handled by the implementing class.")
    }

    /// Includes the business logic for ending session. Implemented by more concrete classes of MediaSession: `MedialRealTimeSession` and `MediaOfflineSession`.
    func handleSessionEnd() {
        Log.warning(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - This function should be handled by the implementing class.")
    }

    /// Includes the business logic for aborting session. Implemented by more concrete classes of MediaSession: `MedialRealTimeSession` and `MediaOfflineSession`.
    func handleSessionAbort() {
        Log.warning(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - This function should be handled by the implementing class.")
    }

    /// Includes the business logic for queuing `MediaHit`. Implemented by more concrete classes of MediaSession: `MedialRealTimeSession` and `MediaOfflineSession`.
    /// - Parameter hit: `MediaHit` to be queued.
    func handleQueueEvent(_ event: MediaXDMEvent) {
        Log.warning(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - This function should be handled by the implementing class.")
    }

    /// Handles sessionId from the server. Implemented by more concrete classes of MediaSession: `MedialRealTimeSession`
    ///  - Parameters:
    ///  - requestEventId: UUID denoting edge request event id.
    ///  - backendSessionId: UUID returned by the backend for the media session.
    func handleSessionUpdate(requestEventId: String, backendSessionId: String?) {
        Log.warning(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - This function should be handled by the implementing class.")
    }

    /// Handles error responses from the server
    ///  - requestEventId: UUID denoting edge request event id.
    ///  - data: dictionary containing errors returned by the backend.
    func handleErrorResponse(requestEventId: String, data: [String: Any?]) {
        Log.warning(label: Self.LOG_TAG, "[\(Self.CLASS_NAME)<\(#function)>] - This function should be handled by the implementing class.")
    }
}
