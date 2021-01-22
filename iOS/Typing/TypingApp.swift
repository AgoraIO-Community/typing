//
//  OpenChatApp.swift
//  OpenChat
//
//  Created by XC on 2021/1/14.
//

import SwiftUI

@main
struct TypingApp: App {
    @ObservedObject var model: LoginModel = LoginModel()
    var body: some Scene {
        WindowGroup {
            LoginView().environmentObject(model)
        }
    }
}
