import ComposableArchitecture
import SwiftyTON
import Foundation

struct ImportFailureReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var testWords: IdentifiedArrayOf<Word> = IdentifiedArrayOf(uniqueElements: (1...24).map { Word(key: $0) })
        @PresentationState var destination: Destination.State?
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case continueButtonTapped
        case wordChanged(id: Word.ID, value: String)
        case autoFillCorrectWords

        enum Alert: Equatable {
            case seeWords
            case dismiss
        }
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .continueButtonTapped:
                //                if state.isCorrectRecieveddWords() {
                //                    state.destination = .passcode(.init())
                //                } else {
                //                    state.destination = .alert(.init(
                //                        title: TextState("Incorrect words"),
                //                        message: TextState("The secret words you have entered do not match the ones in the list."),
                //                        primaryButton: .default(TextState("See words"), action: .send(.seeWords)),
                //                        secondaryButton: .default(TextState("Try again"), action: .send(.dismiss))
                //                    ))
                //                }

                return .none

            case let .wordChanged(id, value):
                state.testWords[id: id]?.recivedWord = value
                return .none

            case .autoFillCorrectWords:

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

extension ImportFailureReducer {
    struct Word: Identifiable, Equatable {
        var id: UUID = .init()
        var key: Int
        var recivedWord: String = ""
    }
}

extension ImportFailureReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case passcode(PasscodeReducer.State)
            case alert(AlertState<ImportFailureReducer.Action.Alert>)

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
            case alert(ImportFailureReducer.Action.Alert)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.passcode, action: /Action.passcode) {
                PasscodeReducer()
            }
        }
    }
}