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
        var words: [String]
        var testTime: TestTimeReducer.State?
        var id: UUID = .init()
        var isActive: Bool = false
        var buttonTappedAttempts: Int = 0
    }

    enum Action: Equatable {
        case testTime(TestTimeReducer.Action)
        case doneButtonTapped
        case startTimer
        case stopTimer
        case dismissTestTimerView
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .doneButtonTapped:
            state.buttonTappedAttempts += 1

            if state.isActive {
                state.testTime = .init(key: .demoKey, words: state.words)
            } else if state.buttonTappedAttempts == 2 {
                state.isActive = true
            } else {
                
            }

            return .none
        case .testTime:
            return .none
        case .startTimer:
            print("Start timer")
            return .run { send in
                try await Task.sleep(nanoseconds: 30_000_000_000)
                await send(.stopTimer)
            }
        case .stopTimer:
            print("Stop timer")
            state.isActive = true
            return .none
        case .dismissTestTimerView:
            state.testTime = nil
            return .none
        }
    }
}
