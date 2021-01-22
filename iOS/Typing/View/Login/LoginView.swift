//
//  LoginView.swift
//  OpenChat
//
//  Created by XC on 2021/1/14.
//

import SwiftUI
import Combine
import ExytePopupView

struct LoginView: View {
    @EnvironmentObject var model: LoginModel
    var body: some View {
        NavigationView {
            VStack {
                Text("Typing")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .font(.system(size: 32))
                    .multilineTextAlignment(.center)
                    .offset(x: 0, y: -30)
                TextField("Your Name", text: $model.userName)
                    .textFieldStyle(InputViewStyle())
                    .textContentType(.nickname)
                    .padding(.horizontal, 30)
                    .disabled(model.isConnecting)
                TextField("Friend's Name", text: $model.friendName, onCommit: { model.loginAction() })
                    .textFieldStyle(InputViewStyle())
                    .textContentType(.nickname)
                    .padding(.horizontal, 30)
                    .disabled(model.isConnecting)
                NavigationLink(
                    destination: ChatView().environmentObject(model),
                    isActive: $model.isOnline) {
                    EmptyView()
                }
                RoundButton(title: "GO", showProgress: model.isConnecting) { model.loginAction() }
                    .disabled(model.isConnecting)
                    .padding(.horizontal, 30)
                    .offset(x: 0, y: 30)
                Spacer()
            }
            .keyboardAdaptive()
            .background(Image("background"))
            .onAppear {
                model.onAppear()
            }
            .onDisappear {
                model.onDisappear()
            }
        }
        .popup(isPresented: $model.showingPopup, type: .toast, position: .top, autohideIn: 2) {
            VStack {
                HStack {
                    Text(model.message)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                }
                .frame(height: 60)
                .background(Color(hex: "#099dfd"))
                .cornerRadius(30.0)
            }.padding(.top, 50)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(LoginModel())
    }
}
