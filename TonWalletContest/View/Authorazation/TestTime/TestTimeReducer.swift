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
        var alert: AlertState<Action.Alert>?
        
        func isCorrectRecieveddWords() -> Bool {
            for word in testWords {
                if !word.isCorrectRecieveddWord() { return false }
            }
            
            return true
        }
    }
    
    enum Action: Equatable {
        case alert(Alert)
        case continueButtonTapped
        case wordChanged(id: Word.ID, value: String)
        case passcode(PasscodeReducer.Action)
        case dismissPasscodeView
        
        enum Alert: String, Equatable {
            case skip = "Skip"
            case dismiss = "Ok, Sorry"
        }
    }
    
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .continueButtonTapped:
                if state.isCorrectRecieveddWords() {
                    state.passcode = .init()
                } else {
                    state.alert = .init(
                        title: TextState("Title"),
                        message: TextState("Message"),
                        primaryButton: .cancel(TextState(Action.Alert.dismiss.rawValue), action: .send(.dismiss)),
                        secondaryButton: .default(TextState(Action.Alert.skip.rawValue), action: .send(.skip))
                    )
                }
                
                return .none
                
            case .alert(.skip):
                print("Ok Sorry tapped")
                return .none
            case .alert(.dismiss):
                state.alert = nil
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
}
