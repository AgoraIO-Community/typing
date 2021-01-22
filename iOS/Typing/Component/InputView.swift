//
//  InputView.swift
//  OpenChat
//
//  Created by XC on 2021/1/14.
//

import SwiftUI

struct InputView: View {
    let title: String
    let text: Binding<String>
    var onCommit: (() -> Void)?
    
    var body: some View {
        TextField(title, text: text, onCommit: onCommit ?? {})
            .keyboardType(.default)
            .lineLimit(1)
            .overlay(VStack {
                Divider()
                    .frame(height: 1.0)
                    .background(Color.white)
                    .offset(x: 0, y: 18)
            })
            .foregroundColor(.white)
            .padding(.top, 15)
            .padding(.bottom, 9)
            .font(.system(size: 18))
    }
}

struct InputViewStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .lineLimit(1)
            .autocapitalization(.none)
            .foregroundColor(.white)
            .padding(.top, 15)
            .padding(.bottom, 9)
            .font(.system(size: 18))
            .overlay(
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 1)
                    .offset(x: 0, y: 18)
            )
    }
}
