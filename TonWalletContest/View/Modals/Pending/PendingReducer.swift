//
//  PendingReducer.swift
//  TonWalletContest
//
//  Created by Viacheslav on 28/04/23.
//

import ComposableArchitecture
import SwiftyTON
import Foundation

struct PendingReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
    }

    enum Action: Equatable {
        case destination
        case doneButtonTapped
        case viewMyWalletButtonTapped
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .doneButtonTapped:
                print("Done button tapped")
                return .none

            case .viewMyWalletButtonTapped:
                print("View my wallet button tapped")
                return .none

            case .destination:
                return .none
            }
        }
    }
}

