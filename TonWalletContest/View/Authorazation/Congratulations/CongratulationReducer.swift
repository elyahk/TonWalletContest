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
        case recoveryPhrase(PresentationAction<RecoveryPhraseReducer.Action>)
        case proceedButtonTapped
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .proceedButtonTapped:
                state.recoveryPhrase = .init(words: state.words)
                
                return .none
                
            case .recoveryPhrase:
                
                return .none
            }
        }
        .ifLet(\.recoveryPhrase, action: /Action.recoveryPhrase) {
            RecoveryPhraseReducer()
        }
    }
}
