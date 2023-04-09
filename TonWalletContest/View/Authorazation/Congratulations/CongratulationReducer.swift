//
//  CongratulationReducer.swift
//  TonWalletContest
//
//  Created by Viacheslav on 04/04/23.
//

import Foundation
import ComposableArchitecture
import SwiftyTON

struct CongratulationReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var recoveryPhrase: RecoveryPhraseReducer.State?
        var id: UUID = .init()
        var words: [String]
    }

    enum Action: Equatable {
        case recoveryPhrase(RecoveryPhraseReducer.Action)
        case proceedButtonTapped
        case dismissRecoveryPhrase
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .proceedButtonTapped:
            state.recoveryPhrase = .init(words: state.words)
            
            return .none
        case .recoveryPhrase:
            return .none
        case .dismissRecoveryPhrase:
            state.recoveryPhrase = nil
            
            return .none
        }
    }
}
