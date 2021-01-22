# Typing App

_[English](README.md) | 中文_

这个开源示例项目演示了如何使用 AgoraRTM 实现类似 Honk 的聊天效果，实现了实时文字聊天和震一震的效果

## 运行示例程序

这个段落主要讲解了如何编译和运行实例程序。

### 安装依赖库

#### iOS

切换到 **iOS** 目录，运行以下命令使用 CocoaPods 安装依赖。

```
pod install
```

运行后确认 `Typing.xcworkspace` 正常生成即可。

### 创建 Agora 账号并获取 AppId

在编译和启动实例程序前，你需要首先获取一个可用的 App Id:

1. 在[agora.io](https://dashboard.agora.io/signin/)创建一个开发者账号
2. 前往后台页面，点击左部导航栏的 **项目 > 项目列表** 菜单
3. 复制后台的 **App Id** 并备注，稍后启动应用时会用到它
4. 在项目页面生成临时 **Access Token** (24 小时内有效)并备注，注意生成的 Token 只能适用于对应的频道名。

#### iOS

打开 `APIExample.xcworkspace` 并编辑 `KeyCenter.swift`，将你的 AppID 和 Token 分别替换到 `<#Your App Id#>` 与 `<#Temp Access Token#>`

    ```
    let AppID: String = <#Your App Id#>
    // 如果你没有打开Token功能，token可以直接给nil
    let Token: String? = <#Temp Access Token#>
    ```

然后你就可以使用 `Typing.xcworkspace` 编译并运行项目了。

#### Android

打开 `Android` 并编辑 `app/src/main/java/io/agora/typing/base/BuildConfig.kt`，将你的 AppID 和 Token 分别替换到 `<#Your App Id#>` 和 `<#Temp Access Token#>`

    ``` kotlin
    val appId: String = YOUR APP ID
    val token: String? = YOUR ACCESS TOKEN
    ```

然后你就可以编译并运行项目了。
