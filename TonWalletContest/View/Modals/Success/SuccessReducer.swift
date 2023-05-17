import ComposableArchitecture
import SwiftyTON
import Foundation

struct SuccessReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        var walletAddress: String
        var events: Events
        
        init(walletAddress: String, events: Events) {
            self.walletAddress = walletAddress
            self.events = events
        }
        
        static let preview: State = .init(
            walletAddress: "Walsdkfksldjfklsjadklfjklsdjfklsjdklfskdlfs",
            events: .init()
        )
    }

    
    enum Action: Equatable {
        case doneButtonTapped
    }
    
    struct Events: AlwaysEquitable {
        
    }
    
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .doneButtonTapped:
                return .run { _ in
                    await dismiss()
                }
                
            }
        }
    }
}
