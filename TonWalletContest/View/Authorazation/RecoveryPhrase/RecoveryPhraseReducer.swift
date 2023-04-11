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
        @PresentationState var testTime: TestTimeReducer.State?
        var id: UUID = .init()
        var isActive: Bool = false
        var buttonTappedAttempts: Int = 0
    }

    enum Action: Equatable {
        case testTime(PresentationAction<TestTimeReducer.Action>)
        case doneButtonTapped
        case startTimer
        case stopTimer
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .doneButtonTapped:
                state.buttonTappedAttempts += 1
                
                if state.isActive {
                    let words = state.words.enumerated().shuffled().map { TestTimeReducer.Word(key: $0, expectedWord: $1) }
                    guard words.count > 3 else {
                        return .none
                    }
                    
                    state.testTime = .init(testWords: IdentifiedArrayOf(uniqueElements: (words[0...2].sorted { $0.key < $1.key } )))
                } else if state.buttonTappedAttempts == 2 {
                    state.isActive = true
                } else {
                    
                }
                
                return .none
            case .testTime:
                return .none
            case .startTimer:
                guard state.isActive else { return .none }
                
                print("Start timer")
                return .run { send in
                    try await Task.sleep(nanoseconds: 30_000_000_000)
                    await send(.stopTimer)
                }
            case .stopTimer:
                print("Stop timer")
                state.isActive = true
                return .none
            }
        }
        .ifLet(\.$testTime, action: /Action.testTime) {
            TestTimeReducer()
        }
    }
}
