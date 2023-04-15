import ComposableArchitecture
import SwiftUI
import SwiftyTON

struct FaceIDReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
    }

    enum Action: Equatable {

    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {

        }
    }
}


