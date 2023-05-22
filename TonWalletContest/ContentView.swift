//
//  ContentView.swift
//  TonWalletContest
//
//  Created by eldorbek nusratov on 02/04/23.
//

import SwiftUI
import ComposableArchitecture
import SwiftyTON

struct TestReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
    }

    enum Action: Equatable {
    }

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
