import SwiftUI
import ComposableArchitecture

struct TestTimeView: View {
    
    let store: StoreOf<TestTimeReducer>
    
    init(store: StoreOf<TestTimeReducer>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text(viewStore.words.joined(separator: ", "))
        }
    }
}

struct TestTimeView_Previews: PreviewProvider {
    static var previews: some View {
        TestTimeView(store: .init(
            initialState: .init(
                key: .demoKey,
                words: .words24,
                buildType: .preview
            ),
            reducer: TestTimeReducer()
        ))
        
    }
}
