//
//  StartReducer.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//
import Foundation
import SwiftyTON
import ComposableArchitecture

struct StartReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var events: Events
        var isLoading: Bool = false
        
        static let preview: State = .init(
            events: .init(
                createCongratulationState: {
                    .preview
                },
                createImportPhraseState: {
                    .preview
                })
        )
    }

    struct Events: Equatable {
        static func == (lhs: StartReducer.Events, rhs: StartReducer.Events) -> Bool {
            true
        }

        var createCongratulationState: () async throws -> CongratulationReducer.State
        var createImportPhraseState: () async throws -> ImportPhraseReducer.State
    }

    enum Action: Equatable {
        case createMyWalletTapped
        case importMyWalletTapped
        case destinationState(Destination.State)
        case destination(PresentationAction<Destination.Action>)
        case loading(Bool)
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .loading(isLoading):
                state.isLoading = isLoading
                return .none

            case .destinationState(let destinationState):
                state.destination = destinationState
                return .none

            case .createMyWalletTapped:
                return .run { [events = state.events] send in
                    await send(.loading(true))
                    let state = try await events.createCongratulationState()
                    await send(.loading(false))
                    await send(.destinationState(.createWallet(state)))
                }

            case .importMyWalletTapped:
                return .run { [events = state.events] send in
                    let state = try await events.createImportPhraseState()
                    await send(.destinationState(.importWords(state)))
                }
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension StartReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case createWallet(CongratulationReducer.State)
            case importWords(ImportPhraseReducer.State)

            var id: AnyHashable {
                switch self {
                case let .createWallet(state):
                    return state.id
                case let .importWords(state):
                    return state.id
                }
            }
        }

        enum Action: Equatable {
            case createWallet(CongratulationReducer.Action)
            case importWords(ImportPhraseReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.createWallet, action: /Action.createWallet) {
                CongratulationReducer()
            }
            Scope(state: /State.importWords, action: /Action.importWords) {
                ImportPhraseReducer()
            }
        }
    }
}
