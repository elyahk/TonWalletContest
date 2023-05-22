//
//  Transcation.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 20/05/23.
//

import Foundation

struct Transaction1: Identifiable, Equatable, Codable {
    var id = UUID()
    let senderAddress: String
    let humanAddress: String
    var amount: Double
    var comment: String
    let fee: Double
    let date: Date
    var status: Status
    let isTransactionSend: Bool
    let transactionId: String

    enum Status: Codable {
        case success
        case cancelled
        case pending
    }

    static let previewInstance: Transaction1 = Transaction1(
        senderAddress: "wedo3irjwljOj)J09JH0j9josdijfo394",
        humanAddress: "EldorTheCoolest.ton",
        amount: 121.2231,
        comment: "Testing Time. Hello world!",
        fee: 0.0023123,
        date: Date(),
        status: .pending,
        isTransactionSend: true,
        transactionId: "JIoUHj9h(iJJ9jiJ((J(J*&B^D4d5d%CTCGFC%c5dctr45646"
    )
}
