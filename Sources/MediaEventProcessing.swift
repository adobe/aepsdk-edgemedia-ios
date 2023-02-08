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

import Foundation

protocol MediaEventProcessing {

    /// Creates a new `session` and return its `sessionId`.
    /// - Parameters:
    ///    - trackerConfig: The tracker configuration.
    ///    - trackerSessionId: A `UUID` string representing tracker session ID which can used be for debugging.
    /// - Returns: Unique SessionId for the session.
    func createSession(trackerConfig: [String: Any], trackerSessionId: String?) -> String?

    /// Process the Media Session with id `sessionId`
    ///
    /// - Parameters:
    ///    - sessionId: The id of session to process.
    ///    - event: a `MediaXDMEvent` containing media event name and media experience XDM data.
    func processEvent(sessionId: String, event: MediaXDMEvent)

    /// Ends the session with id `sessionId`
    /// - Parameters:
    ///     - sessionId: The id of session to end.
    func endSession(sessionId: String)
}
