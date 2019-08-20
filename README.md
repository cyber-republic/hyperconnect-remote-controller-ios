# HyperConnect IoT - Remote Controller for iOS

The Remote Controller is the software component of the HyperConnect IoT Framework that runs on the mobile phone of a user and allows an overview of one or more connected [Edge Clients](https://github.com/cyber-republic/hyperconnect-edge-client) in a visual manner.

![HyperConnect IoT](/images/hyperconnect-banner.png)

### Installation

#### (Option One) Download from Apple App Store
- Coming soon.

#### (Option Two) Build from source code
**Step 1.** Download the source code for XCode from: https://github.com/cyber-republic/hyperconnect-remote-controller-ios

- Download by clicking the green button "Clone or download" on the GitHub repository.
- Or using Git:
```
git clone https://github.com/cyber-republic/hyperconnect-remote-controller-ios
```

**Step 2.** Open a new terminal window and navigate to the HyperConnet project folder, where the 'Podfile' is located.
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

### Libraries

- Elastos Carrier Native SDK: https://github.com/elastos/Elastos.NET.Carrier.Native.SDK
- Elastos Carrier Swift SDK: https://github.com/elastos/Elastos.NET.Carrier.Swift.SDK

### Contribution
We welcome contributions to the HyperConnect IoT project.

### Acknowledgments
A sincere thank you to all teams and projects that we rely on directly or indirectly.

### License
This project is licensed under the terms of the [GPLv3 license](https://github.com/elastos/Elastos.NET.Carrier.Swift.SDK/blob/readme/LICENSE).
