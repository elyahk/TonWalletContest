import ComposableArchitecture
import SwiftUI

struct ConfirmPasscodeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var oldPasscode: String
        var passcode: String = ""
        var showKeyboad: Bool = true
        @PresentationState var faceID: FaceIDReducer.State?
    }

    enum Action: Equatable {
        case passwordAdded(password: String)
        case faceID(PresentationAction<FaceIDReducer.Action>)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .passwordAdded(passcode):
            if passcode == state.oldPasscode {
                state.faceID = .init()
            }
            return .none

        case .faceID:
            return .none
        }
    }
}

struct ConfirmPasscodeView: View {
    let store: StoreOf<ConfirmPasscodeReducer>

    init(store: StoreOf<ConfirmPasscodeReducer>) {
        self.store = store
    }

    struct ViewState: Equatable {
        var passcode: String = ""
        var showKeyboad: Bool = true
        @PresentationState var faceID: FaceIDReducer.State?

        init(state: ConfirmPasscodeReducer.State) {
            self.passcode = state.passcode
            self.showKeyboad = state.showKeyboad
            self.faceID = state.faceID
        }
    }

    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            VStack {
                NavigationLinkStore(
                    self.store.scope(state: \.$faceID, action: ConfirmPasscodeReducer.Action.faceID)
                ) {
                } destination: { store in
                    Text("Face ID")
                } label: {
                    Color.clear
                }
                Text("Confirm")
                ZStack {
                    TextField("", text: Binding(
                        get: { viewStore.passcode },
                        set: { viewStore.send(.passwordAdded(password: $0)) }
                    ))
                    .hidden()

                    LegacyTextField(
                        text: Binding(
                            get: { viewStore.passcode },
                            set: { value, _ in
                                viewStore.send(.passwordAdded(password: value))
                            }),
                        isFirstResponder: Binding(
                            get: { viewStore.showKeyboad },
                            set: { value, _ in

                            })
                    )
                    .frame(width: 10, height: 0)
                }
            }
        }
    }
}
