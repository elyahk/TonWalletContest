//
//  DigitsStringModifier.swift
//  TonWalletContest
//
//  Created by Viacheslav on 18/05/23.
//

import Foundation
import SwiftUI

struct DigitStringModifier: ViewModifier {

    let numberString: String

    func body(content: Content) -> some View {
//        let numberString = String(format: "%.2f", number)

        let attributedString = NSMutableAttributedString(string: numberString)

        let dotIndex = numberString.firstIndex(of: ".") ?? numberString.endIndex

        let largeRange = NSRange(location: 0, length: numberString.distance(from: numberString.startIndex, to: dotIndex))
        let largeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 48)
        ]
        attributedString.addAttributes(largeAttributes, range: largeRange)

        let smallRange = NSRange(location: 0, length: numberString.distance(from: dotIndex, to: numberString.endIndex))
        let smallAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 30)
        ]
        attributedString.addAttributes(smallAttributes, range: smallRange)

        return Text(attributedString.string)
    }
}

