import SwiftUI
import ComposableArchitecture

struct PasscodeView: View {
    
    let store: StoreOf<PasscodeReducer>
    
    init(store: StoreOf<PasscodeReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("Text")
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
                    words: .words24,
                    buildType: .preview
                ),
                reducer: PasscodeReducer()
            ))
        }
    }
}
