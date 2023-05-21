//
//  WideBlueTextButtonStyle.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI

struct WideBlueTextButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17.0, weight: .semibold))
            .foregroundColor(.white)
            .background(Color.accentColor)
            .cornerRadius(12)
    }
}

extension View {
    func customWideBlueButtonStyle() -> some View {
        self
            .modifier(WideBlueTextButtonStyle())
    }
}
