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
