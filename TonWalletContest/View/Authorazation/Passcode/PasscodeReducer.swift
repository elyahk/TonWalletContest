import ComposableArchitecture
import SwiftUI
import SwiftyTON

struct PasscodeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var key: Key
        var words: [String]
        var passcode: String = ""
        var showKeyboad: Bool = true
        var confirmPasscode: ConfirmPasscodeReducer.State?
    }

    enum Action: Equatable {
        case passwordAdded(password: String)
        case confirmPasscode(ConfirmPasscodeReducer.Action)
        case showConfirm(oldPasscode: String)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .passwordAdded(passcode):
            state.passcode = passcode
            if passcode.count == 4 {
                state.showKeyboad = false
                
                return .run { send in
                    try await Task.sleep(nanoseconds: 200_000_000)
                    await send(.showConfirm(oldPasscode: passcode))
                }
            }
            
            return .none
            
        case let .showConfirm(oldPasscode):
            state.confirmPasscode = .init(key: state.key, words: state.words, oldPasscode: oldPasscode)
            return .none
            
        case .confirmPasscode:
            return .none
        }
    }
}

struct ConfirmPasscodeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var key: Key
        var words: [String]
        var oldPasscode: String
        var passcode: String = ""
        var showKeyboad: Bool = true
    }

    enum Action: Equatable {
        case passwordAdded(password: String)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .passwordAdded(passcode):
            print(passcode)
            if passcode.count == 4 {
                state.passcode = ""
            }
            return .none
        }
    }
}

