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
        var destination: Destination?

    }

    enum Destination {
        case congratulationView
    }

    enum Action: Equatable {
        case createMyWalletTapped
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .createMyWalletTapped:
            state.destination = .congratulationView
            return .none
        }
    }
}
