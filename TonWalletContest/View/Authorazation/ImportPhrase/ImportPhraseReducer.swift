import ComposableArchitecture
import SwiftyTON
import Foundation

struct ImportPhraseReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var testWords: IdentifiedArrayOf<Word> = IdentifiedArrayOf(uniqueElements: (1...24).map { Word(key: $0) })
        @PresentationState var destination: Destination.State?

        func isFilledAllWords() -> Bool {
            for word in testWords {
                if word.recivedWord.isEmpty {
                    return false
                }
            }

            return true
        }
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case continueButtonTapped
        case wordChanged(id: Word.ID, value: String)
        case autoFillCorrectWords
        case failureButtonTapped
        case showAlert
        case successfullyImported(key: Key)
        case openMainView(wallet: Wallet3)

        enum Alert: Equatable {
            case seeWords
            case dismiss
        }
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .openMainView(let wallet):
//                state.destination = .mainView(.init())
                return .none
            case .successfullyImported(let key):
//                state.destination = .passcode(.init())

                return .run { send in
                    let wallet = try await TonWalletManager.shared.createWallet3(key: key)
                    await send(.openMainView(wallet: wallet))
                }

            case .showAlert:
                state.destination = .alert(.init(
                    title: TextState("Incorrect words"),
                    message: TextState("The secret words you have entered do not match the ones in the list."),
                    primaryButton: .default(TextState("See words"), action: .send(.seeWords)),
                    secondaryButton: .default(TextState("Try again"), action: .send(.dismiss))
                ))
                return .none

            case .failureButtonTapped:
                state.destination = .failurePhrase(.init())
                return .none

            case .continueButtonTapped:

                return .run { [state] send in
                    guard state.isFilledAllWords() else {
                        await send(.showAlert)
                        return
                    }
                    do {
                        let key = try await TonWalletManager.shared.importWords(state.testWords.map { $0.recivedWord })
                        await send(.successfullyImported(key: key))
                    } catch {
                        print(error)
                        await send(.showAlert)
                    }
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
            case passcode(PasscodeReducer.State)
            case failurePhrase(ImportFailureReducer.State)
            case alert(AlertState<ImportPhraseReducer.Action.Alert>)
            case mainView(MainViewReducer.State)

            var id: AnyHashable {
                switch self {
                case let .passcode(state):
                    return state.id
                case let .alert(state):
                    return state.id
                case let .failurePhrase(state):
                    return state.id
                case .mainView(let state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case passcode(PasscodeReducer.Action)
            case alert(ImportPhraseReducer.Action.Alert)
            case failurePhrase(ImportFailureReducer.Action)
            case mainView(MainViewReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.passcode, action: /Action.passcode) {
                PasscodeReducer()
            }
            Scope(state: /State.failurePhrase, action: /Action.failurePhrase) {
                ImportFailureReducer()
            }
            Scope(state: /State.mainView, action: /Action.mainView) {
                MainViewReducer()
            }
        }
    }
}
