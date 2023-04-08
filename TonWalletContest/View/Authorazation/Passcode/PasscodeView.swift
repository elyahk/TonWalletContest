import SwiftUI
import ComposableArchitecture

struct PasscodeView: View {
    let store: StoreOf<PasscodeReducer>
    @State var isKeyboardShown = true
    
    init(store: StoreOf<PasscodeReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                ZStack {
                    CustomTextField(text: Binding(
                        get: { viewStore.password },
                        set: { value, _ in
                            viewStore.send(.passwordAdded(password: value))
                        }), isFirstResponder: true
                    )
                    .frame(maxWidth: .infinity, maxHeight: 60)

                    Button("Title") {
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background(Color.green)
                }
                
                Button("Options") { }
            }
        }
    }
}

struct PasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasscodeView(store: .init(
                initialState: .init(
                    key: .demoKey,
                    words: .words24
                ),
                reducer: PasscodeReducer()
            ))
        }
    }
}
