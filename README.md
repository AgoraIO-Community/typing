# Typing App

_English | [中文](README.zh.md)_

This project shows you how to use AgoraRTM sdk to build an app like Honk

## Quick Start

This section shows you how to prepare, build, and run the application.

### Prepare Dependencies

#### iOS

Change directory into **iOS** folder, run following command to install project dependencies,

```
pod install
```

Verify `Typing.xcworkspace` has been properly generated.

### Obtain an App Id

To build and run the sample application, get an App Id:

1. Create a developer account at [agora.io](https://dashboard.agora.io/signin/). Once you finish the signup process, you will be redirected to the Dashboard.
2. Navigate in the Dashboard tree on the left to **Projects** > **Project List**.
3. Save the **App Id** from the Dashboard for later use.
4. Generate the **Access Token**, you can follow the step by step at [agora.io](https://docs.agora.io/en/Real-time-Messaging/rtm_token?platform=All%20Platforms#generate-an-rtm-token).

#### iOS

Open `Typing.xcworkspace` and edit the `KeyCenter.swift` file. In the `KeyCenter` struct, update `<#Your App Id#>` with your App Id, and change `<#Temp Access Token#>` with the temp Access Token generated from dashboard. Note you can leave the token variable `nil` if your project has not turned on security token.

    ``` Swift
    struct KeyCenter {
        static let AppId: String = <#Your App Id#>

        // assign token to nil if you have not enabled app certificate
        static var Token: String? = <#Temp Access Token#>
    }
    ```

You are all set. Now connect your iPhone or iPad device and run the project.

#### Android

Open `Android` and edit the `app/src/main/java/io/agora/typing/base/BuildConfig.kt` file. Update `<#Your App Id#>` with your App Id, and change `<#Temp Access Token#>` with the temp Access Token generated from dashboard. Note you can leave the token variable `null` if your project has not turned on security token.

    ``` kotlin
    val appId: String = YOUR APP ID
    val token: String? = YOUR ACCESS TOKEN
    ```

You are all set. Now connect your Android device and run the project.
