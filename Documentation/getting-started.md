## Getting started

## Configure the Media for Edge Network extension in the Data Collection UI
The Media for Edge Network extension has specific configuration requirements for including the Media Collection Details field group in the XDM schema, enabling Media Analytics in a datastream, and installing the Adobe Streaming Media for Edge Network extension in a Tag mobile property.

Use the following guides to configure the Media for Edge Network in the Data Collection UI
* [Configure and Setup Adobe Streaming Media for Edge Network](https://developer.adobe.com/client-sdks/documentation/media-for-edge-network/index.md#configure-and-setup-adobe-streaming-media-for-edge-network)
* [Configure and Install Dependencies](https://developer.adobe.com/client-sdks/documentation/media-for-edge-network/index.md#configure-and-install-dependencies)
* [Configure Media for Edge Network extension in the Data Collection Tags](https://developer.adobe.com/client-sdks/documentation/media-for-edge-network/index.md#configure-media-for-edge-network-extension-in-the-data-collection-tags)

----

## Add the AEPEdgeMedia extension to your app

The Adobe Streaming Media for Edge Network mobile extension has the following dependencies, which must be installed prior to installing the extension:
- [AEPCore](https://github.com/adobe/aepsdk-core-ios)
- [AEPEdge](https://github.com/adobe/aepsdk-edge-ios)
- [AEPEdgeIdentity](https://github.com/adobe/aepsdk-edgeidentity-ios)

### Download AEPEdgeMedia extension

> **Note**
> The following instructions are for setting up an application using Adobe Experience Platform Edge Network mobile extensions. If an application will include both Edge Network and Adobe Solution extensions, both the Identity for Edge Network and Identity for Experience Cloud ID Service extensions are required. For more details, see the [Frequently Asked Questions](https://developer.adobe.com/client-sdks/documentation/identity-for-edge-network/faq/) page.

#### Add the AEPEdgeMedia and other dependency extensions to your project: 
> **Note** 
> Try to use the [latest extension versions](https://developer.adobe.com/client-sdks/documentation/current-sdk-versions/#ios--swift) to have access to all our latest features and fixes. 

#### Using [Cocoapods]("https://cocoapods.org/")

1. Add following pods in your `Podfile`:

  ```ruby
  use_frameworks!
  target 'YourTargetApp' do
     pod 'AEPCore'
     pod 'AEPEdge'
     pod 'AEPEdgeIdentity'
     pod 'AEPEdgeMedia'
  end
  ```

2. Replace the target (`YourTargetApp`) with your actual app target name.

3. Install the pod dependencies by typing the following command in your Podfile directory:
  ```bash
  $ pod install
  ```

#### Using [Swift Package Manager](https://github.com/apple/swift-package-manager)

To add the AEPEdgeMedia Package to your application, from the Xcode menu select:

`File > Add Packages...`

> **Note** 
>  The menu options may vary depending on the version of Xcode being used.

Enter the URL for the AEPMedia package repository: `https://github.com/adobe/aepsdk-edgemedia-ios.git`.

When prompted, input a specific version or a range of versions for Version rule.

Alternatively, if your project has a `Package.swift` file, you can add AEPEdgeMedia directly to your dependencies:

```
dependencies: [
  .package(url: "https://github.com/adobe/aepsdk-edge-ios.git", .upToNextMajor(from: "4.0.0")),
  .package(url: "https://github.com/adobe/aepsdk-edgeidentity-ios.git", .upToNextMajor(from: "4.0.0")),
  .package(url: "https://github.com/adobe/aepsdk-edgemedia-ios.git", .upToNextMajor(from: "4.0.0"))
]
```

#### Using Binaries

Run `make archive` from the root directory to generate `.xcframeworks` for each module under the `build` folder. Drag and drop all `.xcframeworks` to your app target in Xcode.

----

### Import the AEPEdgeMedia along with the dependencies and register the extensions with `MobileCore`:

#### Swift
  ```swift
  // AppDelegate.swift
  import AEPCore
  import AEPEdge
  import AEPEdgeIdentity
  import AEPEdgeMedia
  ```

  ```swift
  // AppDelegate.swift
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    MobileCore.registerExtensions([Edge.self, Identity.self, Media.self], {
       MobileCore.configureWith(appId: "yourEnvironmentID")
        // Configure EdgeMedia extension
        let mediaConfiguration: [String: Any] = [
                                                  "edgeMedia.channel": "<YOUR_CHANNEL_NAME>", 
                                                  "edgeMedia.playerName": "<YOUR_PLAYER_NAME>", 
                                                  "edgeMedia.appVersion": "<YOUR_APP_VERSION>"
                                                ]
        MobileCore.updateConfigurationWith(configDict: mediaConfiguration)
     })
     ...
  }
  ```

#### Objective-C
  ```objectivec
  // AppDelegate.h
  @import AEPCore;
  @import AEPEdge;
  @import AEPEdgeIdentity;
  @import AEPEdgeMedia;
  ```

  ```objectivec
  // AppDelegate.m
  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      [AEPMobileCore registerExtensions:@[AEPMobileEdge.class, AEPMobileEdgeIdentity.class, AEPMobileEdgeMedia.class] completion:^{
      ...
    }];
    [AEPMobileCore configureWithAppId: @"yourEnvironmentID"];
    ...
  }
  ```
