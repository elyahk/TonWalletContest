import ComposableArchitecture
import SwiftUI
import SwiftyTON

struct PasscodeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var key: Key
        var words: [String]
        var buildType: BuildType = .real
        var password: String = ""
        var keyboard: Bool = true
    }

    enum Action: Equatable {
        case proceedButtonTapped
        case passwordAdded(password: String)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .proceedButtonTapped:
            
            return .none
        case let .passwordAdded(password):
            return .none
        }
    }
}
