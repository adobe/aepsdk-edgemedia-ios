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

/// These enumeration values define the type of a media.
/// These enumeration are to be used in *createMediaObjectWith(name:id:length:streamType:mediaType: )*
@objc(AEPEdgeMediaType)
public enum MediaType: Int, RawRepresentable {
    // swiftlint:disable identifier_name
    case Audio
    case Video
    // swiftlint:enable identifier_name

    public typealias RawValue = String

    public var rawValue: RawValue {
        switch self {
        case .Audio:
            return "audio"
        case .Video:
            return "video"
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "audio":
            self = .Audio
        case "video":
            self = .Video
        default:
            return nil
        }
    }
}
