//
//  FullyPersistentDemoStore.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Foundation
import Toolkit

public final class FullyPersistentDemoStore: ActionHandler {
    private let store: BaseStore<FullyPersistentDemoState, FullyPersistentDemoAction>
    
    public init(actionBus: ActionSource, persistence: (any StatePersisting<FullyPersistentDemoState>)? = nil, initialState: FullyPersistentDemoState = FullyPersistentDemoState()) {
        self.store = BaseStore(actionBus: actionBus, persistence: persistence, initialState: initialState)
        actionBus.register(FullyPersistentDemoAction.self, handler: self)
    }
    
    // MARK: - Read-only interface
    
    var currentState: FullyPersistentDemoState {
        get async { await store.currentState }
    }
    
    func stateStream() async -> AsyncStream<FullyPersistentDemoState> {
        await store.stateStream()
    }
    
    func stream<A: Equatable>(_ kp1: KeyPath<FullyPersistentDemoState, A>) async -> AsyncStream<FullyPersistentDemoState> {
        await store.stream(kp1)
    }
    
    func stream<A: Equatable, B: Equatable>(
        _ kp1: KeyPath<FullyPersistentDemoState, A>,
        _ kp2: KeyPath<FullyPersistentDemoState, B>
    ) async -> AsyncStream<FullyPersistentDemoState> {
        await store.stream(kp1, kp2)
    }
    
    func stream<A: Equatable, B: Equatable, C: Equatable>(
        _ kp1: KeyPath<FullyPersistentDemoState, A>,
        _ kp2: KeyPath<FullyPersistentDemoState, B>,
        _ kp3: KeyPath<FullyPersistentDemoState, C>
    ) async -> AsyncStream<FullyPersistentDemoState> {
        await store.stream(kp1, kp2, kp3)
    }
    
    // MARK: - Action handling
    
    public func handleAction(_ action: any Intent) async {
        guard let action = action as? FullyPersistentDemoAction else { return }
        switch action {
        case .setFlag(let value):
            await store.update { state in
                state.demoFlag = value
            }
        case .setInt(let value):
            await store.update { state in
                state.demoInt = value
            }
        case .setString(let value):
            await store.update { state in
                state.demoString = value
            }
        case .setOptionalFlag(let value):
            await store.update { state in
                state.optionalDemoFlag = value
            }
        case .setOptionalInt(let value):
            await store.update { state in
                state.optionalDemoInt = value
            }
        case .setOptionalString(let value):
            await store.update { state in
                state.optionalDemoString = value
            }
        }
    }
}
