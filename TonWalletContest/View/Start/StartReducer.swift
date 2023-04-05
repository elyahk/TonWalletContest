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
        var importWallet: CongratulationReducer.State?
    }

    enum Action: Equatable {
        case createMyWalletTapped
        case importMyWalletTapped
        case createWallet(CongratulationReducer.Action)
        case importWallet(CongratulationReducer.Action)
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .createMyWalletTapped:
                state.walletCreate = .init()
                return .none
                
            case .importMyWalletTapped:
//                state.destination = .createWallet(.init())
                #warning("Implement opening import wallet screen")
                return .none
            case .createWallet, .importWallet:
                return .none
            }
        }
        .ifLet(\.walletCreate, action: /Action.createWallet) {
            CongratulationReducer()
        }
    }
}
