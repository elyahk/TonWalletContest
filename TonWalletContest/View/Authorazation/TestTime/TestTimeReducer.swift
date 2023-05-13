import ComposableArchitecture
import SwiftyTON
import Foundation

struct TestTimeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var testWords: IdentifiedArrayOf<Word>
        @PresentationState var destination: Destination.State?
        var events: Events
        
        init(testWords: IdentifiedArrayOf<Word>, destination: Destination.State? = nil, events: Events) {
            self.testWords = testWords
            self.destination = destination
            self.events = events
        }
        
        var presentableTestNumbers: String {
            "\(testWords[0].key + 1), \(testWords[1].key + 1) and \(testWords[2].key + 1)"
        }

        func isCorrectRecieveddWords() -> Bool {
            for word in testWords {
                if !word.isCorrectRecieveddWord() { return false }
            }
            
            return true
        }
        
        static let preview: State = .init(
            testWords: .words3(),
            events: .init(createPasscodeReducerState: { .preview }))
    }
    
    struct Events: AlwaysEquitable {
        var createPasscodeReducerState: () async ->  PasscodeReducer.State
    }
    
    
    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case continueButtonTapped
        case wordChanged(id: Word.ID, value: String)
        case autoFillCorrectWords
        case destinationState(Destination.State)
        
        enum Alert: Equatable {
            case seeWords
            case dismiss
        }
    }

    @Dependency(\.dismiss) var presentationMode
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .destinationState(destinationState):
                state.destination = destinationState
                return .none
                
            case .continueButtonTapped:
                if state.isCorrectRecieveddWords() {
                    return .run { [events = state.events] send in
                        await send(.destinationState(.passcode(await events.createPasscodeReducerState())))
                    }
                } else {
                    state.destination = .alert(.init(
                        title: TextState("Incorrect words"),
                        message: TextState("The secret words you have entered do not match the ones in the list."),
                        primaryButton: .default(TextState("See words"), action: .send(.seeWords)),
                        secondaryButton: .default(TextState("Try again"), action: .send(.dismiss))
                    ))
                }
                
                return .none

            case let .wordChanged(id, value):
                state.testWords[id: id]?.recivedWord = value
                return .none

            case .autoFillCorrectWords:
                state.testWords[0].recivedWord = state.testWords[0].expectedWord
                state.testWords[1].recivedWord = state.testWords[1].expectedWord
                state.testWords[2].recivedWord = state.testWords[2].expectedWord
                
                return .none

            case .destination(.presented(.alert(.seeWords))):
                return .fireAndForget { await self.presentationMode() }

            case .destination(.presented(.alert(.dismiss))):
                state.destination = nil
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension TestTimeReducer {
    struct Word: Identifiable, Equatable {
        var id: UUID = .init()
        var key: Int
        var expectedWord: String
        var recivedWord: String = ""

        func isCorrectRecieveddWord() -> Bool {
            expectedWord == recivedWord
        }
    }
}

extension TestTimeReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case passcode(PasscodeReducer.State)
            case alert(AlertState<TestTimeReducer.Action.Alert>)

            var id: AnyHashable {
                switch self {
                case let .passcode(state):
                    return state.id
                case let .alert(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case passcode(PasscodeReducer.Action)
            case alert(TestTimeReducer.Action.Alert)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.passcode, action: /Action.passcode) {
                PasscodeReducer()
            }
        }
    }
}
