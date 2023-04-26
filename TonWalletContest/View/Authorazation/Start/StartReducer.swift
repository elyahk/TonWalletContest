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
    }

    enum Action: Equatable {
        case createMyWalletTapped
        case importMyWalletTapped
        case keyCreated(key: Key, words: [String])
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .createMyWalletTapped:
    
                return .run { send in
                    let key = try await TonWalletManager.shared.createKey()
                    let words = try await TonWalletManager.shared.words(key: key)
                    await send(.keyCreated(key: key, words: words))

                    let tonKeyStore = await TonKeyStore.shared
                    try await tonKeyStore.save(key: key)
                }
                
            case .importMyWalletTapped:
                state.destination = .importWords(.init())
                return .none
                
            case let .keyCreated(key: key, words: words):
                state.destination = .createWallet(.init(words: words))
                UserDefaults.standard.set(AppState.keyCreated.rawValue , forKey: "state")

                return .run { _ in
                    try await TonKeyStore.shared.save(key: key)
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
