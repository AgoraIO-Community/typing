//
//  ChatView.swift
//  OpenChat
//
//  Created by XC on 2021/1/14.
//

import SwiftUI
import Combine

struct ChatView: View {
    
    @State var autoFocus = true
    @State var textHeight: CGFloat = 50
    @ObservedObject var model = ChatModel()
    @EnvironmentObject var loginModel: LoginModel
    
    var body: some View {
        GeometryReader { proxy in
            let padding: CGFloat = 15
            let width = proxy.size.width - padding * 2
            let height = (proxy.size.height - padding * 2) / 2
            let offsetX = width / 2 - 10
            let offsetY = 10 - height / 2
            
            VStack(spacing: padding) {
                ZStack {
                    VStack {
                        Text(model.receivedMessage)
                            .frame(alignment: .center)
                            .padding(10)
                            .font(.title)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }.frame(width: width, height: height,
                            alignment: .center
                    ).background(Color(hex: "#dfdfdf"))
                    .cornerRadius(30)
                    .padding(.horizontal, padding)
                    if model.isFriendOnline {
                        Circle()
                            .fill(Color(hex: "#00ff00"))
                            .frame(width: 20, height: 20)
                            .offset(x: offsetX, y: offsetY)
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 20, height: 20)
                            .offset(x: offsetX, y: offsetY)
                    }
                }
                .modifier(Shake(animatableData: CGFloat(model.friendAnimation)))
                .onTouchDownGesture {
                    model.touchAction()
                }
                ZStack {
                    if model.inputMessage.isEmpty {
                        Text("type something")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                    ZStack {
                        ChatTextField(text: $model.inputMessage, height: $textHeight, onFinish: model.onFinish)
                            .padding(15)
                    }
                    .frame(width: width, height: textHeight + 30, alignment: .center)
                }
                .frame(width: width, height: height, alignment: .center)
                .background(Color(hex: "#dfdfdf"))
                .cornerRadius(30)
                .padding(.horizontal, padding)
                .modifier(Shake(animatableData: CGFloat(model.userAnimation)))
            }
            .navigationTitle("chat(\(loginModel.friendName))")
            .onAppear {
                model.onAppearWithFriend(name: loginModel.friendName)
            }
            .onDisappear {
                model.onDisappear()
            }
        }.popup(isPresented: $model.showingPopup, type: .toast, position: .top, autohideIn: 2) {
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

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView().environmentObject(LoginModel())
    }
}
