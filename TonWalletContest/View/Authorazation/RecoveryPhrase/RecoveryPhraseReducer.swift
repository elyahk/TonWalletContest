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
        @PresentationState var destination: Destination.State?
        var words: [String]
        var id: UUID = .init()
        var isActive: Bool = false
        var buttonTappedAttempts: Int = 0
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case doneButtonTapped
        case startTimer
        case stopTimer

        enum Alert: Equatable {
        }
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
                    
                    state.destination = .testTime(.init(testWords: IdentifiedArrayOf(uniqueElements: (words[0...2].sorted { $0.key < $1.key } ))))
                } else if state.buttonTappedAttempts == 2 {
                    state.isActive = true
                } else {
                    
                }
                
                return .none
            case .destination:
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
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension RecoveryPhraseReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case testTime(TestTimeReducer.State)
            case alert(AlertState<RecoveryPhraseReducer.Action.Alert>)
            
            var id: AnyHashable {
                switch self {
                case let .testTime(state):
                    return state.id
                case let .alert(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case testTime(TestTimeReducer.Action)
            case alert(RecoveryPhraseReducer.Action.Alert)
        }
        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.testTime, action: /Action.testTime) {
                TestTimeReducer()
            }
        }
    }
}
