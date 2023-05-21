//
//  CongratulationReducer.swift
//  TonWalletContest
//
//  Created by Viacheslav on 04/04/23.
//

import Foundation
import ComposableArchitecture
import SwiftyTON

protocol AlwaysEquitable: Equatable { }
extension AlwaysEquitable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}

struct CongratulationReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        @PresentationState var recoveryPhrase: RecoveryPhraseReducer.State?
        var id: UUID = .init()
        var events: Events
        var words: [String]

        static let preview: State = .init(
            events: .init(createRecoveryState: { .preview   }),
            words: .words24_withTon
        )
    }
    
    struct Events: AlwaysEquitable {
        var createRecoveryState: () async ->  RecoveryPhraseReducer.State
    }

    enum Action: AlwaysEquitable {
        case recoveryPhrase(PresentationAction<RecoveryPhraseReducer.Action>)
        case proceedButtonTapped
        case destinationState(RecoveryPhraseReducer.State)
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .proceedButtonTapped:
                //                state.recoveryPhrase = .init(words: state.words)
                return .run { [events = state.events] send in
                    await send(.destinationState(await events.createRecoveryState()))
                }

            case .destinationState(let destinationState):
                state.recoveryPhrase = destinationState
                return .none

            case .recoveryPhrase:
                return .none
            }
        }
        .ifLet(\.$recoveryPhrase, action: /Action.recoveryPhrase) {
            RecoveryPhraseReducer()
        }
    }
}
