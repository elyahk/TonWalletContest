import ComposableArchitecture
import SwiftUI
//import SwiftUINavigation

enum AlertAction<Action> {
    case dismiss
    case presented(Action)
}
extension AlertAction: Equatable where Action: Equatable {}

enum PresentationAction<Action> {
    case dismiss
    case presented(Action)
}
extension PresentationAction: Equatable where Action: Equatable {}

extension ReducerProtocol {
  func ifLet<ChildState: Identifiable, ChildAction>(
    _ stateKeyPath: WritableKeyPath<State, ChildState?>,
    action actionCasePath: CasePath<Action, PresentationAction<ChildAction>>
  ) -> some ReducerProtocolOf<Self>
  where ChildState: _EphemeralState
  {
    self.ifLet(stateKeyPath, action: actionCasePath) {
      EmptyReducer()
    }
  }

  func ifLet<ChildState: Identifiable, ChildAction>(
    _ stateKeyPath: WritableKeyPath<State, ChildState?>,
    action actionCasePath: CasePath<Action, PresentationAction<ChildAction>>,
    @ReducerBuilder<ChildState, ChildAction> child: () -> some ReducerProtocol<ChildState, ChildAction>
  ) -> some ReducerProtocolOf<Self> {
    let child = child()
    return Reduce<State, Action> { state, action in
      switch (state[keyPath: stateKeyPath], actionCasePath.extract(from: action)) {
      case (_, .none):
        let childStateBefore = state[keyPath: stateKeyPath]
        let effects = self.reduce(into: &state, action: action)
        let childStateAfter = state[keyPath: stateKeyPath]
        let cancelEffect: EffectTask<Action>
        if
          !(ChildState.self is _EphemeralState.Type),
          let childStateBefore,
          childStateBefore.id != childStateAfter?.id
        {
          cancelEffect = .cancel(id: childStateBefore.id)
        } else {
          cancelEffect = .none
        }
        let onFirstAppearEffect: EffectTask<Action>
        if
          !(ChildState.self is _EphemeralState.Type),
          let childStateAfter,
          childStateAfter.id != childStateBefore?.id
        {
          onFirstAppearEffect = .run { send in
            do {
              try await withTaskCancellation(id:  DismissID(id: childStateAfter.id)) {
                try await Task.never()
              }
            } catch is CancellationError {
              await send(actionCasePath.embed(.dismiss))
            }
          }
          .cancellable(id: childStateAfter.id)
        } else {
          onFirstAppearEffect = .none
        }
        return .merge(
          effects,
          cancelEffect,
          onFirstAppearEffect
        )
          
      case (.none, .some(.presented)), (.none, .some(.dismiss)):
        XCTFail("A sheet action was sent while child state was nil.")
        return self.reduce(into: &state, action: action)

      case (.some(var childState), .some(.presented(let childAction))):
        defer {
          if ChildState.self is _EphemeralState.Type {
            state[keyPath: stateKeyPath] = nil
          }
        }
        let childEffects = child
          .dependency(\.dismiss, DismissEffect { [id = childState.id] in
            Task.cancel(id:  DismissID(id: id))
          })
          .reduce(into: &childState, action: childAction)
        state[keyPath: stateKeyPath] = childState
        let effects = self.reduce(into: &state, action: action)
        return .merge(
          childEffects
            .map { actionCasePath.embed(.presented($0)) }
            .cancellable(id: childState.id),
          effects
        )

      case let (.some(childState), .some(.dismiss)):
        let effects = self.reduce(into: &state, action: action)
        state[keyPath: stateKeyPath] = nil
        return .merge(
          effects,
          .cancel(id: childState.id)
        )
      }
    }
  }
}

extension ReducerProtocol {
    func alert<Action>(
        state alertKeyPath: WritableKeyPath<State, AlertState<Action>?>,
        action alertCasePath: CasePath<Self.Action, AlertAction<Action>>
    ) -> some ReducerProtocolOf<Self> {
        Reduce { state, action in
            let effects = self.reduce(into: &state, action: action)
            if alertCasePath ~= action {
                state[keyPath: alertKeyPath] = nil
            }
            return effects
        }
    }
}

@_spi(Reflection) import CasePaths
private func isEphemeral<State>(_ state: State) -> Bool {
    if State.self is _EphemeralState.Type {
        return true
    } else if let metadata = EnumMetadata(State.self) {
        return metadata.associatedValueType(forTag: metadata.tag(of: state)) is _EphemeralState.Type
    }
    return false
}

protocol _EphemeralState {}
extension AlertState: _EphemeralState {}
extension ConfirmationDialogState: _EphemeralState {}

private struct DismissID: Hashable { let id: AnyHashable }

struct DismissEffect: Sendable {
    private var dismiss: @Sendable () async -> Void
    func callAsFunction() async {
        await self.dismiss()
    }
}
extension DismissEffect {
    init(_ dismiss: @escaping @Sendable () async -> Void) {
        self.dismiss = dismiss
    }
}
extension DismissEffect: DependencyKey {
    static var liveValue = DismissEffect(dismiss: {})
    static var testValue = DismissEffect(dismiss: {})
}
extension DependencyValues {
    var dismiss: DismissEffect {
        get { self[DismissEffect.self] }
        set { self[DismissEffect.self] = newValue }
    }
}

extension View {
    func sheet<DestinationState, DestinationAction, ChildState: Identifiable, ChildAction>(
        store: Store<DestinationState?, PresentationAction<DestinationAction>>,
        state toChildState: @escaping (DestinationState) -> ChildState?,
        action fromChildAction: @escaping (ChildAction) -> DestinationAction,
        @ViewBuilder child: @escaping (Store<ChildState, ChildAction>) -> some View
    ) -> some View {
        self.sheet(
            store: store.scope(
                state: { $0.flatMap(toChildState) },
                action: {
                    switch $0 {
                    case .dismiss:
                        return .dismiss
                    case let .presented(action):
                        return .presented(fromChildAction(action))
                    }
                }
            ),
            child: child
        )
    }
    
    func sheet<ChildState: Identifiable, ChildAction>(
        store: Store<ChildState?, PresentationAction<ChildAction>>,
        @ViewBuilder child: @escaping (Store<ChildState, ChildAction>) -> some View
    ) -> some View {
        WithViewStore(store, observe: { $0?.id }) { viewStore in
            self.sheet(
                item: Binding(
                    get: { viewStore.state.map { Identified($0, id: \.self) } },
                    set: { newState in
                        if viewStore.state != nil {
                            viewStore.send(.dismiss)
                        }
                    }
                )
            ) { _ in
                IfLetStore(
                    store.scope(
                        state: returningLastNonNilValue { $0 },
                        action: PresentationAction.presented
                    )
                ) { store in
                    child(store)
                }
            }
        }
    }
    
    func popover<DestinationState, DestinationAction, ChildState: Identifiable, ChildAction>(
        store: Store<DestinationState?, PresentationAction<DestinationAction>>,
        state toChildState: @escaping (DestinationState) -> ChildState?,
        action fromChildAction: @escaping (ChildAction) -> DestinationAction,
        @ViewBuilder child: @escaping (Store<ChildState, ChildAction>) -> some View
    ) -> some View {
        self.popover(
            store: store.scope(
                state: { $0.flatMap(toChildState) },
                action: {
                    switch $0 {
                    case .dismiss:
                        return .dismiss
                    case let .presented(action):
                        return .presented(fromChildAction(action))
                    }
                }
            ),
            child: child
        )
    }
    
    func popover<ChildState: Identifiable, ChildAction>(
        store: Store<ChildState?, PresentationAction<ChildAction>>,
        @ViewBuilder child: @escaping (Store<ChildState, ChildAction>) -> some View
    ) -> some View {
        WithViewStore(store, observe: { $0?.id }) { viewStore in
            self.popover(
                item: Binding(
                    get: { viewStore.state.map { Identified($0, id: \.self) } },
                    set: { newState in
                        if viewStore.state != nil {
                            viewStore.send(.dismiss)
                        }
                    }
                )
            ) { _ in
                IfLetStore(
                    store.scope(
                        state: returningLastNonNilValue { $0 },
                        action: PresentationAction.presented
                    )
                ) { store in
                    child(store)
                }
            }
        }
    }
    
    func fullScreenCover<ChildState: Identifiable, ChildAction>(
        store: Store<ChildState?, PresentationAction<ChildAction>>,
        @ViewBuilder child: @escaping (Store<ChildState, ChildAction>) -> some View
    ) -> some View {
        WithViewStore(store, observe: { $0?.id }) { viewStore in
            self.fullScreenCover(
                item: Binding(
                    get: { viewStore.state.map { Identified($0, id: \.self) } },
                    set: { newState in
                        if viewStore.state != nil {
                            viewStore.send(.dismiss)
                        }
                    }
                )
            ) { _ in
                IfLetStore(
                    store.scope(
                        state: returningLastNonNilValue { $0 },
                        action: PresentationAction.presented
                    )
                ) { store in
                    child(store)
                }
            }
        }
    }
}

func returningLastNonNilValue<A, B>(
    _ f: @escaping (A) -> B?
) -> (A) -> B? {
    var lastValue: B?
    return { a in
        lastValue = f(a) ?? lastValue
        return lastValue
    }
}

extension View {
    @available(iOS 16.0, *)
    func navigationDestination<DestinationState, DestinationAction, ChildState: Identifiable, ChildAction>(
        store: Store<DestinationState?, PresentationAction<DestinationAction>>,
        state toChildState: @escaping (DestinationState) -> ChildState?,
        action fromChildAction: @escaping (ChildAction) -> DestinationAction,
        @ViewBuilder child: @escaping (Store<ChildState, ChildAction>) -> some View
    ) -> some View {
        self.navigationDestination(
            store: store.scope(
                state: { $0.flatMap(toChildState) },
                action: {
                    switch $0 {
                    case .dismiss:
                        return .dismiss
                    case let .presented(action):
                        return .presented(fromChildAction(action))
                    }
                }
            ),
            destination: child
        )
    }
    
    @available(iOS 16.0, *)
    func navigationDestination<ChildState, ChildAction>(
        store: Store<ChildState?, PresentationAction<ChildAction>>,
        @ViewBuilder destination: @escaping (Store<ChildState, ChildAction>) -> some View
    ) -> some View {
        WithViewStore(
            store,
            observe: { $0 },
            removeDuplicates: { ($0 != nil) == ($1 != nil) }
        ) { viewStore in
            self.navigationDestination(
                isPresented: Binding(
                    get: { viewStore.state != nil },
                    set: { isActive in
                        if !isActive, viewStore.state != nil {
                            viewStore.send(.dismiss)
                        }
                    }
                )
            ) {
                IfLetStore(
                    store.scope(
                        state: returningLastNonNilValue { $0 },
                        action: { .presented($0) }
                    )
                ) { store in
                    destination(store)
                }
            }
        }
    }
}


@available(*, deprecated)
struct NavigationLinkStore<ChildState: Identifiable, ChildAction, Destination: View, Label: View>: View {
    let store: Store<ChildState?, PresentationAction<ChildAction>>
    let id: ChildState.ID?
    let action: () -> Void
    @ViewBuilder let destination: (Store<ChildState, ChildAction>) -> Destination
    @ViewBuilder let label: Label
    
    var body: some View {
        WithViewStore(self.store, observe: { $0?.id }) { viewStore in
            NavigationLink(
                isActive: Binding(
                    get: { viewStore.state != nil },
                    set: { isActive in
                        if isActive {
                            self.action()
                        } else if (viewStore.state != nil) {
                            viewStore.send(.dismiss)
                        }
                    }
                ),
                destination: {
                    IfLetStore(
                        self.store.scope(state: { $0 }, action: { .presented($0) })
                    ) { store in
                        self.destination(store)
                    }
                },
                label: { self.label }
            )
        }
    }
}
