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
import Foundation

struct MediaXDMEvent {
    let timestamp: Date
    let eventType: XDMMediaEventType
    var mediaCollection: XDMMediaCollection

    init(eventType: XDMMediaEventType, timestamp: Date, mediaCollection: XDMMediaCollection) {
        self.eventType = eventType
        self.timestamp = timestamp
        self.mediaCollection = mediaCollection
    }

    func toXDMData() -> [String: Any] {
        var mediaXDMData = [String: Any]()
        mediaXDMData[MediaConstants.XDMKeys.EVENT_TYPE] = self.eventType.edgeEventType()
        mediaXDMData[MediaConstants.XDMKeys.TIMESTAMP] = timestamp.getISO8601UTCDateWithMilliseconds()
        mediaXDMData[MediaConstants.XDMKeys.MEDIA_COLLECTION] = self.mediaCollection.asDictionary()

        var xdmData = [String: Any]()
        xdmData[MediaConstants.XDMKeys.XDM] = mediaXDMData
        return xdmData
    }
}
