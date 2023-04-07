import ComposableArchitecture
import SwiftyTON
import Foundation

struct TestTimeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var key: Key
        var words: [String]
        var buildType: BuildType = .real
        var word1: String = ""
        var word2: String = ""
        var word3: String = ""
        var passcode: PasscodeReducer.State?
    }

    enum Action: Equatable {
        case continueButtonTapped
        case wordChanged(type: TextFieldType, value: String)
        case passcode(PasscodeReducer.Action)
    }
    
    enum TextFieldType {
        case word1
        case word2
        case word3
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .continueButtonTapped:
            print("Passcode")
            state.passcode = .init(key: state.key, words: state.words)

            return .none
        case let .wordChanged(type, value):
            switch type {
            case .word1:
                state.word1 = value
            case .word2:
                state.word2 = value
            case .word3:
                state.word3 = value
            }
            return .none
            
        case .passcode:
            return .none
        }
    }
}

struct PasscodeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var key: Key
        var words: [String]
        var buildType: BuildType = .real
        var word1: String = ""
        var word2: String = ""
        var word3: String = ""
    }

    enum Action: Equatable {
        case proceedButtonTapped
        case wordChanged(type: TextFieldType, value: String)
    }
    
    enum TextFieldType {
        case word1
        case word2
        case word3
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .proceedButtonTapped:
            
            return .none
        case let .wordChanged(type, value):
            switch type {
            case .word1:
                state.word1 = value
            case .word2:
                state.word2 = value
            case .word3:
                state.word3 = value
            }
            return .none
        }
    }
}
