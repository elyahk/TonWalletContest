import ComposableArchitecture
import SwiftyTON
import Foundation

struct TestTimeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var words: [String]
        var word1: String = ""
        var word2: String = ""
        var word3: String = ""
        var testWords: [Int: String] = [
            4: "hello",
            12: "goodbye",
            23: "tomorrow"
        ]
        var passcode: PasscodeReducer.State?
        var isActive: Bool = false
        var buttonTappedAttempts: Int = 0
}

    enum Action: Equatable {
        case continueButtonTapped
        case wordChanged(type: TextFieldType, value: String)
        case passcode(PasscodeReducer.Action)
        case dismissPasscodeView
    }
    
    enum TextFieldType {
        case word1
        case word2
        case word3
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .continueButtonTapped:
            if state.isActive {
                state.passcode = .init(key: .demoKey, words: state.words)
            } else if state.buttonTappedAttempts == 0 {
                // Show alert without skip button
            } else {
                // Show alert with skip button
            }
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
        case .dismissPasscodeView:
            state.passcode = nil
            
            return .none
        }
    }
}
