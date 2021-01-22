//
//  RoundButton.swift
//  OpenChat
//
//  Created by XC on 2021/1/14.
//

import SwiftUI

struct RoundButton: View {
    let title: String
    let showProgress: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            Spacer()
            if self.showProgress {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            } else {
                Text(title)
                    .font(.system(size: 18))
            }
            Spacer()
        })
        .frame(width: .none, height: 26, alignment: .center)
        .padding(.vertical, 10)
        .foregroundColor(Color(hex: "#099dfd"))
        .background(Color.white)
        .cornerRadius(26)
    }
}

struct RoundButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundButton(title: "test", showProgress: false) {
            
        }
    }
}
