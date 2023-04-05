//
//  StartReducer.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//
import Foundation
import ComposableArchitecture

struct StartReducer: ReducerProtocol {
    struct State: Equatable {
        var walletCreate: CongratulationReducer.State?
        var count: Int = 1
    }

    enum Action: Equatable {
        case createMyWalletTapped
        case importMyWalletTapped
        case createWallet(CongratulationReducer.Action)
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .createMyWalletTapped:
                state.walletCreate = .init()
                return .none
                
            case .importMyWalletTapped:
//                state.destination = .createWallet(.init())
                return .none
            case .createWallet:
                return .none
            }
        }
        .ifLet(\.walletCreate, action: /Action.createWallet) {
            CongratulationReducer()
        }
    }
}
