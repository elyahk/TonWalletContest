//
//  File.swift
//  TonWalletContest
//
//  Created by Eldorbek Nusratov on 05/04/23.
//

import ComposableArchitecture
import SwiftyTON
import Foundation

struct RecoveryPhraseReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var key: Key
        var words: [String]
        var buildType: BuildType = .real
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
            
            return .none
        }
    }
}
