# HyperConnect IoT - Remote Controller for iOS

The Remote Controller is the software component of the HyperConnect IoT Framework that runs on the mobile phone of a user and allows an overview of one or more connected [Edge Clients](https://github.com/cyber-republic/hyperconnect-edge-client) in a visual manner.

![HyperConnect IoT](/images/hyperconnect-banner.png)

### Installation

#### (Option One) Download from Apple App Store
- Using Apple's TestFlight: https://testflight.apple.com/join/oGk6CdKj

#### (Option Two) Build from source code with CocoaPod - Simple

***Prerequisites***

- Install CocoaPods ( https://guides.cocoapods.org/using/getting-started.html )
```
sudo gem install cocoapods
```
- Install or update to the latest XCode version ( https://developer.apple.com/support/xcode/ )

**Step 1.** Download the source code for XCode from: https://github.com/cyber-republic/hyperconnect-remote-controller-ios

- Download by clicking the green button "Clone or download" on the GitHub repository.
- Or using Git:
```
git clone https://github.com/cyber-republic/hyperconnect-remote-controller-ios
```

**Step 2.** Open a new terminal window and navigate to the HyperConnect project folder, where the 'Podfile' is located.
```
cd /YOUR-PATH/hyperconnect-remote-controller-ios
```

Install the dependent libraries by running the following command:
```
sudo pod install
```

**Step 4.** Open the HyperConnect Swift **Workspace** (not project) in the XCode IDE.

**Step 6.** Build the project.

**Step 7.** Start the iOS Simulator.

#### (Option Three) Build from source code with Native Carrier and Swift SDK - Advanced

***Prerequisites***

- Install CocoaPods ( https://guides.cocoapods.org/using/getting-started.html )
```
sudo gem install cocoapods
```
- Install or update to the latest XCode version ( https://developer.apple.com/support/xcode/ )

***Important Note***
The Native Carrier and Swift SDK have to be built with matching 'iphoneos' or 'iphonesimulator' type for the application to work.
'iphoneos' versions are intended for iOS phones, will not work on the simulator.
'iphonesimulator' versions are intended for the XCode Simulator, will not work on iOS phones.

**Step 1.**
The Elastos Carrier Swift SDK in the next step requires the Elastos Native Carrier to be built beforehand. Follow the steps described at https://github.com/elastos/Elastos.NET.Carrier.Native.SDK to build the required files.

Remember to choose 'iphoneos' or 'iphonesimulator' type.

**Step 2.**
Follow the steps to build the Elastos Carrier Swift SDK: https://github.com/elastos/Elastos.NET.Carrier.Swift.SDK . The Elastos Swift SDK will require the files from the Elastos Carrier Native SDK previously built.

Remember to choose 'iphoneos' or 'iphonesimulator' type, matching the build type of the Native Carrier.

**Step 3.** Download the source code for XCode from: https://github.com/cyber-republic/hyperconnect-remote-controller-ios

- Download by clicking the green button "Clone or download" on the GitHub repository.
- Or using Git:
```
git clone https://github.com/cyber-republic/hyperconnect-remote-controller-ios
```
************************************
**Step 4.**
Extract and open the downloaded folder 'hyperconnect-remote-controller-ios'.

**Step 5.**
Open the 'Podfile' in a visual editor, and remove the line:
```
pod ‘ElastosCarrierSDK’
```
Save and close the file.

**Step 6.**
Open a new terminal window and navigate to the HyperConnect project folder, where the 'Podfile' is located.
```
cd /YOUR-PATH/hyperconnect-remote-controller-ios
```

**Step 7.**
Install the dependent libraries by running the following command:
```
sudo pod install
```

**Step 8.**
Open the HyperConnect **Workspace** (not project) in the XCode IDE.

**Step 9.**
Open a file browser and drag the 'ElastosCarrierSDK.framework' (from Step 3) onto the XCode Project navigator.

**Step 10.**
In Xcode, open the file: /HyperConnect/elastos/ElastosCarrier.swift

Change the import statement 'import ElastosCarrier' to
```
import ElastosCarrierSDK
```
Save the changes.

**Step 11.**
In XCode, in the navigation panel click the HyperConnect project (blue icon) , select the tab Build Phases in the HyperConnect **TARGET** item.
Under the tab 'Run Script' **remove** the following script: "${SRCROOT}/Pods/ElastosCarrierSDK/ElastosCarrier-framework/CocoaPods/codesigncarrierframework.sh"

**Step 12.**
Build the project.

**Step 13**
Start the iOS Simulator.

### Libraries

- Elastos Carrier Native SDK: https://github.com/elastos/Elastos.NET.Carrier.Native.SDK
- Elastos Carrier Swift SDK: https://github.com/elastos/Elastos.NET.Carrier.Swift.SDK

### Contribution
We welcome contributions to the HyperConnect IoT project.

### Acknowledgments
A sincere thank you to all teams and projects that we rely on directly or indirectly.

### License
This project is licensed under the terms of the [GPLv3 license](https://github.com/elastos/Elastos.NET.Carrier.Swift.SDK/blob/readme/LICENSE).
