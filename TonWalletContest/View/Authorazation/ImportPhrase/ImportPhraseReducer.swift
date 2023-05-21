import ComposableArchitecture
import SwiftyTON
import Foundation

struct ImportPhraseReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        @PresentationState var destination: Destination.State?
        var events: Events
        var id: UUID = .init()
        var testWords: IdentifiedArrayOf<Word> = IdentifiedArrayOf(uniqueElements: (1...24).map { Word(key: $0) })
        
        init(destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
        }

        func isFilledAllWords() -> Bool {
            for word in testWords {
                if word.recivedWord.isEmpty {
                    return false
                }
            }

            return true
        }
        
        static let preview: State = .init(events: .init(
            createImportSuccessReducer: {  .preview },
            createImportFailureReducer: { .preview },
            isSecretWordsImported: { words in true }
        ))
    }
    
    struct Events: AlwaysEquitable {
        var createImportSuccessReducer: () async -> ImportSuccessReducer.State
        var createImportFailureReducer: () async -> ImportFailureReducer.State
        var isSecretWordsImported: (IdentifiedArrayOf<Word>) async -> Bool
    }
    
    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case continueButtonTapped
        case wordChanged(id: Word.ID, value: String)
        case autoFillCorrectWords
        case failureButtonTapped
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
            case .destinationState(let destinationState):
                state.destination = destinationState
                
                return .none
                
            case .failureButtonTapped:
    
                return .run { [events = state.events] send in
                    await send(.destinationState(.failurePhrase(await events.createImportFailureReducer())))
                }

            case .continueButtonTapped:

                return .run { [state] send in
                    guard state.isFilledAllWords(), await state.events.isSecretWordsImported(state.testWords) else {
                        await send(.destinationState(.alert(.init(
                            title: TextState("Incorrect words"),
                            message: TextState("The secret words you have entered do not match the ones in the list."),
                            primaryButton: .default(TextState("See words"), action: .send(.seeWords)),
                            secondaryButton: .default(TextState("Try again"), action: .send(.dismiss))
                        ))))
                                   
                        return
                    }
                    
                    await send(.destinationState(.successPhrase(state.events.createImportSuccessReducer())))
                }

            case let .wordChanged(id, value):
                state.testWords[id: id]?.recivedWord = value
                return .none

            case .autoFillCorrectWords:
                for (index, _) in state.testWords.enumerated() {
                    state.testWords[index].recivedWord = Array<String>.words24_withTon[index]
                }

                return .run { await $0.send(.continueButtonTapped) }

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

extension ImportPhraseReducer {
    struct Word: Identifiable, Equatable {
        var id: UUID = .init()
        var key: Int
        var recivedWord: String = ""
    }
}

extension ImportPhraseReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case successPhrase(ImportSuccessReducer.State)
            case failurePhrase(ImportFailureReducer.State)
            case alert(AlertState<ImportPhraseReducer.Action.Alert>)

            var id: AnyHashable {
                switch self {
                case let .successPhrase(state):
                    return state.id
                case let .alert(state):
                    return state.id
                case let .failurePhrase(state):
                    return state.id
                
                }
            }
        }
        enum Action: Equatable {
            case successPhrase(ImportSuccessReducer.Action)
            case alert(ImportPhraseReducer.Action.Alert)
            case failurePhrase(ImportFailureReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.successPhrase, action: /Action.successPhrase) {
                ImportSuccessReducer()
            }
            Scope(state: /State.failurePhrase, action: /Action.failurePhrase) {
                ImportFailureReducer()
            }
        }
    }
}
