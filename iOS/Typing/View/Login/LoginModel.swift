//
//  LoginModel.swift
//  OpenChat
//
//  Created by XC on 2021/1/14.
//

import SwiftUI
import Combine

class LoginModel: ObservableObject {
    
    @Published var userName = ""
    @Published var friendName = ""
    @Published var isConnecting = false
    @Published var isOnline = false
    
    @Published var showingPopup = false
    var message = ""
    func showToast(message: String) {
        self.message = message
        self.showingPopup = true
    }
    
    private var disposables = Set<AnyCancellable>()

    func loginAction() {
        self.isConnecting = true
        login().sink(receiveCompletion: { _ in
            self.isConnecting = false
        }, receiveValue: { result in
            if result.success {
                self.isOnline = true
            } else {
                self.showToast(message: result.message ?? "unknown error!")
            }
        })
        .store(in: &disposables)
    }
    
    private func login() -> AnyPublisher<Result<Void>, Never> {
        if self.userName.isEmpty || self.friendName.isEmpty {
            return Just(Result<Void>(success: false, message: "Input user's name or friend's name!")).eraseToAnyPublisher()
        } else {
            return Server.shared().login(user: userName)
        }
    }
    
    func onAppear() {
        
    }
    
    func onDisappear() {
        disposables.forEach { cancellable in
            cancellable.cancel()
        }
        disposables.removeAll()
    }
}
