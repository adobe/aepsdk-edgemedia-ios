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

import SwiftUI

struct ContentView: View {
    @State var videoPlayer = VideoPlayer(url: Bundle.main.url(forResource: "video", withExtension: "mp4")!)
    @State var isPlayingAd = false
    @State var videoSegment: String = "Main Content" // main, ad
    @State var mediaAnalyticsProvider: MediaAnalyticsProvider?

    var body: some View {
        VStack {
            #if os(iOS)
            AssuranceView()
            Divider()
                .frame(height: 2)
                .background(Color.white)
            #endif

            Text(self.isPlayingAd ? "Playing AD" : "Playing Main Video")
                .foregroundColor(.white)
                .padding()

            VideoPlayerView(player: videoPlayer.player)
                .onAppear {
                    mediaAnalyticsProvider = MediaAnalyticsProvider()
                    mediaAnalyticsProvider?.initWithPlayer(player: videoPlayer)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_AD_START))) { _ in
                    self.isPlayingAd = true
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(rawValue: PlayerEvent.PLAYER_EVENT_AD_COMPLETE))) { _ in
                    self.isPlayingAd = false
                }

        }
        .preferredColorScheme(.dark)

    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
