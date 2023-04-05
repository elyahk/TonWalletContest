//
//  BlankTextButtonStyle.swift
//  TonWalletContest
//
//  Created by Viacheslav on 05/04/23.
//

import Foundation
import SwiftUI

struct BlankTextButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17.0, weight: .semibold))
            .foregroundColor(.accentColor)
            .cornerRadius(12)
            .padding(.horizontal, 48)
    }
}

extension View {
    func customBlankButtonStyle() -> some View {
        self
            .modifier(BlankTextButtonStyle())
    }
}
