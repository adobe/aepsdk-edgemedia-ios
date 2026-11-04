#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

# Builds a minimal Swift 6 consumer of AEPEdgeMedia to continuously protect the
# public API surface for Swift 6 apps.
#
# The consumer registers the extension and drives a full tracker session
# (session, chapter, ad break, ad, QoE, states, complete) from @MainActor code,
# the way a SwiftUI or UIKit player would. The consumer target is compiled in
# Swift 6 language mode; dependencies keep their own declared language modes.

PROJECT_NAME=Swift6Consumer

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create the package.
swift package init

# Create the Package.swift. The consumer target is compiled in Swift 6 language
# mode; dependencies keep their own declared language modes.
echo "// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let package = Package(
    name: \"Swift6Consumer\",
    defaultLocalization: \"en-US\",
    platforms: [
        .iOS(.v15), .tvOS(.v15)
    ],
    products: [
        .library(
            name: \"Swift6Consumer\",
            targets: [\"Swift6Consumer\"]
        )
    ],
    dependencies: [
        .package(name: \"AEPCore\", url: \"https://github.com/adobe/aepsdk-core-ios.git\", .branch(\"main\")),
        .package(name: \"AEPEdge\", url: \"https://github.com/adobe/aepsdk-edge-ios.git\", .branch(\"main\")),
        .package(name: \"AEPEdgeMedia\", path: \"../\")
    ],
    targets: [
        .target(
            name: \"Swift6Consumer\",
            dependencies: [
                .product(name: \"AEPCore\", package: \"AEPCore\"),
                .product(name: \"AEPEdge\", package: \"AEPEdge\"),
                .product(name: \"AEPEdgeMedia\", package: \"AEPEdgeMedia\"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ])
    ]
)
" >Package.swift

# Replace the generated source with a @MainActor consumer that exercises the
# public tracker APIs.
rm -rf Sources/Swift6Consumer
mkdir -p Sources/Swift6Consumer
echo "import AEPCore
import AEPEdge
import AEPEdgeMedia
import Foundation

@MainActor
final class Swift6Consumer {
    var tracker: MediaTracker?

    func register() {
        MobileCore.registerExtensions([Edge.self, Media.self])
        _ = Media.extensionVersion
    }

    func exercise() {
        var config: [String: Any] = [:]
        config[MediaConstants.TrackerConfig.CHANNEL] = \"swift6-consumer\"
        config[MediaConstants.TrackerConfig.AD_PING_INTERVAL] = 1
        let tracker = Media.createTrackerWith(config: config)
        self.tracker = tracker

        guard let media = Media.createMediaObjectWith(name: \"video\", id: \"id\", length: 60, streamType: MediaConstants.StreamType.VOD, mediaType: MediaType.Video) else {
            return
        }
        tracker.trackSessionStart(info: media, metadata: [MediaConstants.VideoMetadataKeys.SHOW: \"show\"])
        tracker.trackPlay()

        let chapter = Media.createChapterObjectWith(name: \"chapter\", position: 1, length: 30, startTime: 0)
        tracker.trackEvent(event: MediaEvent.ChapterStart, info: chapter, metadata: nil)

        let adBreak = Media.createAdBreakObjectWith(name: \"adbreak\", position: 1, startTime: 0)
        let ad = Media.createAdObjectWith(name: \"ad\", id: \"ad-id\", position: 1, length: 15)
        tracker.trackEvent(event: MediaEvent.AdBreakStart, info: adBreak, metadata: nil)
        tracker.trackEvent(event: MediaEvent.AdStart, info: ad, metadata: nil)
        tracker.trackEvent(event: MediaEvent.AdComplete, info: nil, metadata: nil)
        tracker.trackEvent(event: MediaEvent.AdBreakComplete, info: nil, metadata: nil)

        let qoe = Media.createQoEObjectWith(bitrate: 1, startupTime: 1, fps: 30, droppedFrames: 0)
        tracker.updateQoEObject(qoe: qoe ?? [:])
        let mute = Media.createStateObjectWith(stateName: MediaConstants.PlayerState.MUTE)
        tracker.trackEvent(event: MediaEvent.StateStart, info: mute, metadata: nil)
        tracker.updateCurrentPlayhead(time: 10)

        tracker.trackEvent(event: MediaEvent.ChapterComplete, info: nil, metadata: nil)
        tracker.trackComplete()
        tracker.trackSessionEnd()
    }
}
" >Sources/Swift6Consumer/Swift6Consumer.swift

swift package update
swift package resolve

# This is necessary to avoid internal PIF error
swift package dump-pif > /dev/null
(xcodebuild clean -scheme Swift6Consumer -destination 'generic/platform=iOS' > /dev/null) || :

# Build for generic iOS device in Swift 6 language mode
echo '############# Build Swift 6 consumer for generic iOS device ###############'
xcodebuild build -scheme Swift6Consumer -destination 'generic/platform=iOS'

# Build for generic tvOS device in Swift 6 language mode
echo '############# Build Swift 6 consumer for generic tvOS device ###############'
xcodebuild build -scheme Swift6Consumer -destination 'generic/platform=tvOS'

# Clean up.
cd ../
rm -rf $PROJECT_NAME
