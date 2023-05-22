//
//  SettingsView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 22/05/23.
//

import SwiftUI
import ComposableArchitecture
import SwiftyTON
import Foundation

struct SettingsReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID = .init()
        @PresentationState var destination: Destination.State?
        var events: Events
        var userSettings: UserSettings.Settings

        init(userSettings: UserSettings.Settings, destination: Destination.State? = nil, events: Events) {
            self.destination = destination
            self.events = events
            self.userSettings = userSettings
        }

        static let preview: State = .init(
            userSettings: UserSettings.Settings(),
            events: .init(
            createMainViewReducerState: { .preview }
        ))
    }

    enum ChangeType: Equatable {
        case notification(Bool)
        case activeAddress(ActiveAddress)
        case currency(ActiveCurrency)
        case faceIdOn(Bool)
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case destinationState(Destination.State)
        case changed(ChangeType)
    }

    struct Events: AlwaysEquitable {
        var createMainViewReducerState: () async ->  MainViewReducer.State
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .changed(type):
                switch type {
                case let .activeAddress(activeWalletAddress):
                    state.userSettings.activeAddress = activeWalletAddress
                case let .currency(currency):
                    state.userSettings.currency = currency
                case let .faceIdOn(isOn):
                    state.userSettings.faceId = isOn
                case let .notification(isOn):
                    state.userSettings.isNotificationOn = isOn
                }

                return .run { send in

                }
            case let .destinationState(destinationState):
                state.destination = destinationState

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

extension SettingsReducer {
    struct Destination: ReducerProtocol {
        enum State: Equatable, Identifiable {
            case recoveryPhrase(RecoveryPhraseReducer.State)
            case passcodeView(PasscodeReducer.State)

            var id: AnyHashable {
                switch self {
                case let .recoveryPhrase(state):
                    return state.id
                case let .passcodeView(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case recoveryPhrase(RecoveryPhraseReducer.Action)
            case passcodeView(PasscodeReducer.Action)
        }

        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.recoveryPhrase, action: /Action.recoveryPhrase) {
                RecoveryPhraseReducer()
            }
            Scope(state: /State.passcodeView, action: /Action.passcodeView) {
                PasscodeReducer()
            }
        }
    }
}


enum ActiveAddress: String, CaseIterable, Identifiable, Equatable, Codable {
    case v3R2
    case v4R2
    case v4R1

    var id: String { self.rawValue }
}

enum ActiveCurrency: String, CaseIterable, Identifiable, Equatable, Codable {
    case TON
    case USD
    case EUR
    case JPY

    var id: String { self.rawValue }
}

struct SettingsView: View {
    let store: StoreOf<SettingsReducer>

    init(store: StoreOf<SettingsReducer>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                Section {
                    Toggle(isOn: viewStore.binding(
                        get: { $0.userSettings.isNotificationOn },
                        send: { value in
                            return .changed(.notification(value))
                        })) {
                        Text("Notification")
                    }

                    Picker(
                        selection: viewStore.binding(
                            get: { $0.userSettings.activeAddress },
                            send: { value in
                                return .changed(.activeAddress(value))
                            })
                    ) {
                        ForEach(ActiveAddress.allCases) { address in
                            Text(address.rawValue).tag(address)
                        }
                    } label: {
                        Text("Active address")
                    }

                    Picker(
                        selection:  viewStore.binding(
                            get: { $0.userSettings.currency },
                            send: { value in
                                return .changed(.currency(value))
                            })
                    ) {
                        ForEach(ActiveCurrency.allCases) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    } label: {
                        Text("Primary currency")
                    }
                } header: {
                    Text("General")
                }

                Section {
                    NavigationLink {
                        //
                    } label: {
                        Text("Show recovery phrase")
                    }

                    NavigationLink {
                        //
                    } label: {
                        Text("Change passcode")
                    }

                    Toggle(
                        isOn: viewStore.binding(
                            get: { $0.userSettings.faceId },
                            send: { value in
                                return .changed(.faceIdOn(value))
                            })
                    ) {
                        Text("Face ID")
                    }
                } header: {
                    Text("Security")
                }
                Section {
                    Button {
                        //
                    } label: {
                        Text("Delete wallet")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Wallet Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(store: .init(initialState: .preview, reducer: SettingsReducer()))
        }
    }
}

