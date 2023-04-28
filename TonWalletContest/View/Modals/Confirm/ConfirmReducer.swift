//
//  ConfirmReducer.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import ComposableArchitecture
import SwiftyTON
import Foundation

struct ConfirmReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
    }

    enum Action: Equatable {
        case destination
        case backButtonTapped
        case sendButtonTapped
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                print("Back button tapped")
                return .none

            case .sendButtonTapped:
                print("View my wallet button tapped")
                return .none

            case .destination:
                return .none
            }
        }
    }
}


