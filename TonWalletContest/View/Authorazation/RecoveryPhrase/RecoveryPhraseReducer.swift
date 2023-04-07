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
        var testTime: TestTimeReducer.State?
        var id: UUID = .init()
        var key: Key
        var words: [String]
        var buildType: BuildType = .real
    }

    enum Action: Equatable {
        case testTime(TestTimeReducer.Action)
        case doneButtonTapped
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .doneButtonTapped:
            state.testTime = .init(key: state.key, words: state.words)
            return .none
//            return .run { [state] send in
//                let words = try await TonWalletManager.shared.words(key: state.key, buildType: state.buildType)
//                await send(.showWords(words))
//            }
        
        case .testTime:
            return .none
        }
    }
}
