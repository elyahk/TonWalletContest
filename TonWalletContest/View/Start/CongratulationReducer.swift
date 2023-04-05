//
//  CongratulationReducer.swift
//  TonWalletContest
//
//  Created by Viacheslav on 04/04/23.
//

import Foundation
import ComposableArchitecture

struct CongratulationReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var destination: Destination?
        var id: UUID = .init()
    }

    enum Destination: Equatable {
        case recoveryPhraseView
    }

    enum Action: Equatable {
        case proceedButtonTapped
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .proceedButtonTapped:
            state.destination = .recoveryPhraseView
            return .none
        }
    }
}
