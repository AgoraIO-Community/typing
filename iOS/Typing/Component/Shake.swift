//
//  Shake.swift
//  OpenChat
//
//  Created by XC on 2021/1/21.
//

import SwiftUI

struct Shake: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 5
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
