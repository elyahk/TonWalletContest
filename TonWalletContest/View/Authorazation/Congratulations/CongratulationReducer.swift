//
//  CongratulationReducer.swift
//  TonWalletContest
//
//  Created by Viacheslav on 04/04/23.
//

import Foundation
import ComposableArchitecture
import SwiftyTON

enum BuildType: Equatable {
    case preview
    case real
}

struct CongratulationReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var recoveryPhrase: RecoveryPhraseReducer.State?
        var id: UUID = .init()
        var key: Key
        var buildType: BuildType = .real
    }

    enum Action: Equatable {
        case recoveryPhrase(RecoveryPhraseReducer.Action)
        case proceedButtonTapped
        case showWords([String])
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .proceedButtonTapped:
            return .run { [state] send in
                let words = try await TonWalletManager.shared.words(key: state.key, buildType: state.buildType)
                await send(.showWords(words))
            }
        case let .showWords(words):
            state.recoveryPhrase = .init(key: state.key, words: words)
            return .none
        
        case .recoveryPhrase:
            return .none
        }
    }
}
