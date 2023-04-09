import ComposableArchitecture
import SwiftyTON
import Foundation

struct TestTimeReducer: ReducerProtocol {
    struct Word: Identifiable, Equatable {
        var id: UUID = .init()
        var key: Int
        var expectedWord: String
        var recivedWord: String = ""
        
        func isCorrectRecieveddWord() -> Bool {
            expectedWord == recivedWord
        }
    }
    
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var testWords: IdentifiedArrayOf<Word>
        var passcode: PasscodeReducer.State?
        
        func isCorrectRecieveddWords() -> Bool {
            for word in testWords {
                if !word.isCorrectRecieveddWord() { return false }
            }
            
            return true
        }
    }

    enum Action: Equatable {
        case continueButtonTapped
        case wordChanged(id: Word.ID, value: String)
        case passcode(PasscodeReducer.Action)
        case dismissPasscodeView
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .continueButtonTapped:
            if state.isCorrectRecieveddWords() {
                state.passcode = .init()
            }
            
            return .none
            
        case let .wordChanged(id, value):
            state.testWords[id: id]?.recivedWord = value
            return .none
            
        case .passcode:
            return .none
            
        case .dismissPasscodeView:
            state.passcode = nil
            
            return .none
        }
    }
}
