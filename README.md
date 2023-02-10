# Repro for react-native-zoom-video-sdk issue

Clone down this repo and run `yarn`,
`cd ios && arch -x86_64 pod install && cd -`
then `yarn ios` to see the error.

## Full steps to repro

```bash
yarn create expo-app
# name it iced-tea
cd iced-tea
yarn
yarn expo prebuild # to eject
yarn ios # make sure it works as expected
yarn add @zoom/react-native-videosdk
```

NOTE: pod install will appear to work, but compiling will fail with this error:

```
❌  Undefined symbols for architecture arm64
┌─ Symbol: _OBJC_CLASS_$_ZoomVideoSDK
└─ Referenced from: objc-class-ref in libreact-native-zoom-video-sdk.a(RNZoomView.o)
```

So, download the SDK manually (Kevin will provide it)
Then unzip the SDK and copy the contents to ios/zoom-video-sdk-iOS-1.6.2

Add the following to ios/Podfile, line 18(ish), right after `use_frameworks!`

```ruby
  vendored_frameworks = "zoom-video-sdk-iOS-1.6.2/Sample-Libs/lib/zoomcml.xcframework", "zoom-video-sdk-iOS-1.6.2/Sample-Libs/lib/ZoomVideoSDK.xcframework", "zoom-video-sdk-iOS-1.6.2/Sample-Libs/lib/ZoomVideoSDKScreenShare.xcframework"
```

Now open the workspace in Xcode:

```bash
open ./ios/icedtea.xcworkspace
```

Click
Click on `icedtea` in the project navigator, then `icedtea` under the TARGETS section, then in the General tab under Frameworks, Libraries, and Embedded Content, click the + button. Click `Add Other...` in the bottom left and then `Add Files` and navigate to `zoom-video-sdk-iOS-1.6.2/Sample-Libs/lib/zoomcml.xcframework` and select it. Also command-click `ZoomVideoSDK.xcframework` and `ZoomVideoSDKScreenShare.xcframework` so all 3 are selected. Click `Open` to add them.

Now try running the project with `yarn ios` again.

Still doesn't work -- we get this error:

```
❌  Undefined symbols for architecture arm64
┌─ Symbol: _OBJC_CLASS_$_ZoomVideoSDK
└─ Referenced from: objc-class-ref in libreact-native-zoom-video-sdk.a(RNZoomView.o)


❌  ld: symbol(s) not found for architecture arm64



❌  clang: error: linker command failed with exit code 1 (use -v to see invocation)
```
