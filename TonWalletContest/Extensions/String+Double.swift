//
//  String+Double.swift
//  TonWalletContest
//
//  Created by Eldorbek Nusratov on 13/05/23.
//

import Foundation

extension String {
    func toDouble() -> Double {
        Double(self) ?? 0.0
    }
}

extension Double {
    func integerString() -> String {
        return String(Int(self.rounded(.down)))
    }

    func fractionalString() -> String {
        let stringAmount = String(self)
        return String(stringAmount.suffix(from: stringAmount.firstIndex(of: ".") ?? stringAmount.endIndex))
    }
}
