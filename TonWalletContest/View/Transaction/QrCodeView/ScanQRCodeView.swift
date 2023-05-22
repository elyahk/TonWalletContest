//
//  ScanQRCodeView.swift
//  TonWalletContest
//
//  Created by Viacheslav on 16/05/23.
//

import SwiftUI
import ComposableArchitecture
import CodeScanner
import AVFoundation

struct ScanQRCodeReducer: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var events: Events
        var id: UUID = .init()
        var isPermissionGiven: Bool = true
        var galleryPresented: Bool = false
        var isTourchOn: Bool = false

        init(events: Events) {
            self.events = events
        }

        static let preview: State = .init(events: .init())
    }

    enum Action: Equatable {
        case onAppear
        case requestPermission
        case onStatusChange(Bool)
        case scanSuccess(String)
        case scanFail
        case tappedGalleryButton
        case tappedTorchButton
        case noAction
    }

    struct Events: AlwaysEquitable {
    }

    @Dependency(\.dismiss) var presentationMode

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .noAction: return .none

            case .tappedGalleryButton:
                state.galleryPresented = true
                return .none
            case .tappedTorchButton:
                state.isTourchOn.toggle()
                return .none

            case .scanFail:
                return .none

            case .scanSuccess(let address):

                return .none
            case .requestPermission:

                return .run { send in
                    let status = await AVCaptureDevice.requestAccess(for: .video)
                    await send(.onStatusChange(status))
                }

            case .onStatusChange(let permitted):
                state.isPermissionGiven = permitted
                return .none
            case .onAppear:

                return .run { send in
                    let status = AVCaptureDevice.authorizationStatus(for: .video)
                    switch status {
                    case .authorized:
                        await send(.onStatusChange(true))
                    default:
                        await send(.onStatusChange(false))

                    }

                    await send(.requestPermission)
                }
            }
        }
    }
}

struct ScanQRCodeView: View {
    let store: StoreOf<ScanQRCodeReducer>

    init(store: StoreOf<ScanQRCodeReducer>) {
        self.store = store

    }

    var body: some View {
        WithViewStore.init(store, observe: { $0 }) { viewStore in
            ZStack {
                if viewStore.isPermissionGiven {
                    ZStack {
                        CodeScannerView(
                            codeTypes: [.qr],
                            scanMode: .oncePerCode,
                            isTorchOn: viewStore.isTourchOn,
                            isGalleryPresented: viewStore.binding(
                                get: { state in
                                    state.galleryPresented
                                }, send: { _ in
                                    return .noAction
                                })
                        ) { result in
                            switch result {
                            case .success(let found):
                                viewStore.send(.scanSuccess(found.string))
                            case .failure(let failure):
                                viewStore.send(.scanFail)
                            }
                        }

                        FocueCameraView {
                            Color
                                .black.opacity(0.5)
                        }

                        VStack(spacing: 0) {
                            let size = UIScreen.main.bounds.size
                            Text("Scan QR Code")
                                .fontWeight(.semibold)
                                .font(.title)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.top, (size.height - size.width + 66 * 2) / 2 - 32 - 44)

                            Color
                                .clear
                                .frame(height: (size.width - 66 * 2))
                                .padding([.top], 44)



                            HStack(spacing: 86) {
                                Button {
                                    viewStore.send(.tappedGalleryButton)
                                } label: {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .resizable()
                                        .foregroundColor(Color.black)
                                        .scaledToFit()
                                        .padding()
                                        .frame(width: 72, height: 72)
                                        .background(Color.init(UIColor(red: 0.463, green: 0.451, blue: 0.427, alpha: 1)))
                                        .cornerRadius(36)
                                }

                                Button {
                                    viewStore.send(.tappedTorchButton)
                                } label: {
                                    Image(systemName: "flashlight.on.fill")
                                        .resizable()
                                        .foregroundColor(Color.black)
                                        .scaledToFit()
                                        .padding()
                                        .frame(width: 72, height: 72)
                                        .background(Color.init(UIColor(red: 0.463, green: 0.451, blue: 0.427, alpha: 1)))
                                        .cornerRadius(36)
                                }

                            }
                            .padding([.top], 80)

                            Spacer()
                        }

                    }
                } else {
                    VStack {
                        Spacer()
                        Text("No Camera Access")
                            .fontWeight(.semibold)
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 12)
                        Text("TON Wallet doesn’t have access to the camera. Please enable camera access to scan QR codes.")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                        // Create My Wallet app
                        Button {

                        } label: {
                            Text("Open Settings")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color.accentColor)
                                .cornerRadius(12)
                                .padding([.leading, .trailing], 48)
                                .padding(.bottom, 124)
                        }
                    }
                    .background(Color.black)
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct ScanQRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScanQRCodeView(store: .init(initialState: .preview, reducer: ScanQRCodeReducer()))
        }
    }
}
