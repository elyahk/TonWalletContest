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
        case showTestTime
        case startTimer
        case stopTimer

        enum Alert: Equatable {
            case dismiss
            case skip
        }
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
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

            case .doneButtonTapped:
                state.buttonTappedAttempts += 1

                if state.isActive {

                    return .run { await $0(.showTestTime) }
                } else if state.buttonTappedAttempts == 1 {
                    state.destination = .alert(.reminderTime(showSkip: false))
                } else {
                    state.destination = .alert(.reminderTime(showSkip: true))
                }

                return .none

            case .showTestTime:
                let words = state.words.enumerated().shuffled().map { TestTimeReducer.Word(key: $0, expectedWord: $1) }
                guard words.count > 3 else {
                    return .none
                }

                state.destination = .testTime(.init(testWords: IdentifiedArrayOf(uniqueElements: (words[0...2].sorted { $0.key < $1.key } ))))
                return .none

            case .destination(.presented(.alert(.dismiss))):
                state.destination = nil
                return .none

            case .destination(.presented(.alert(.skip))):
                return .run { await $0(.showTestTime) }


            case .destination:
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

extension AlertState where Action == RecoveryPhraseReducer.Action.Alert {
    static func reminderTime(showSkip: Bool) -> Self {
        if #available(iOS 15, *) {
            return AlertState {
                TextState("Sure done?")
            } actions: {
                ButtonState(role: .cancel, action: .send(.dismiss, animation: .default)) {
                    TextState("Ok, sorry")
                }
                if showSkip {
                    ButtonState(role: .none, action: .send(.skip, animation: .default)) {
                        TextState("Skip")
                    }
                }
            } message: {
                TextState("You didn’t have enough time to write these words down.")
            }
        } else {
            return  AlertState(
                title: TextState("Sure done?"),
                message: TextState("You didn’t have enough time to write these words down."),
                primaryButton: ButtonState(role: .cancel, action: .send(.dismiss, animation: .default)) {
                    TextState("Ok, sorry")
                },
                secondaryButton: ButtonState(role: .none, action: .send(.skip, animation: .default)) {
                    TextState("Skip")
                }
            )
        }
    }
}
