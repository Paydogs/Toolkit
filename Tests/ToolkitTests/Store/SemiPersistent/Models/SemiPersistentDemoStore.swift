//
//  SemiPersistentDemoStore.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Foundation
import Toolkit

public final class SemiPersistentDemoStore: ActionHandler {
    private let store: BaseStore<SemiPersistentDemoState, SemiPersistentDemoAction>

    public init(actionBus: ActionSource, persistence: (any StatePersisting<SemiPersistentDemoState>)? = nil, initialState: SemiPersistentDemoState = SemiPersistentDemoState()) {
        self.store = BaseStore(actionBus: actionBus, persistence: persistence, initialState: initialState)
        actionBus.register(SemiPersistentDemoAction.self, handler: self)
    }

    // MARK: - Read-only interface

    var currentState: SemiPersistentDemoState {
        get async { await store.currentState }
    }

    func stateStream() async -> AsyncStream<SemiPersistentDemoState> {
        await store.stateStream()
    }

    func stream<A: Equatable>(_ kp1: KeyPath<SemiPersistentDemoState, A>) async -> AsyncStream<SemiPersistentDemoState> {
        await store.stream(kp1)
    }

    func stream<A: Equatable, B: Equatable>(
        _ kp1: KeyPath<SemiPersistentDemoState, A>,
        _ kp2: KeyPath<SemiPersistentDemoState, B>
    ) async -> AsyncStream<SemiPersistentDemoState> {
        await store.stream(kp1, kp2)
    }

    func stream<A: Equatable, B: Equatable, C: Equatable>(
        _ kp1: KeyPath<SemiPersistentDemoState, A>,
        _ kp2: KeyPath<SemiPersistentDemoState, B>,
        _ kp3: KeyPath<SemiPersistentDemoState, C>
    ) async -> AsyncStream<SemiPersistentDemoState> {
        await store.stream(kp1, kp2, kp3)
    }

    // MARK: - Action handling

    public func handleAction(_ action: any Intent) async {
        guard let action = action as? SemiPersistentDemoAction else { return }
        switch action {
        case .setFlag(let value):
            await store.update { $0.demoFlag = value }
        case .setInt(let value):
            await store.update { $0.demoInt = value }
        case .setString(let value):
            await store.update { $0.demoString = value }
        case .setOptionalFlag(let value):
            await store.update { $0.optionalDemoFlag = value }
        case .setOptionalInt(let value):
            await store.update { $0.optionalDemoInt = value }
        case .setOptionalString(let value):
            await store.update { $0.optionalDemoString = value }
        case .setPersistentFlag(let value):
            await store.update { $0.persistentDemoFlag = value }
        case .setPersistentInt(let value):
            await store.update { $0.persistentDemoInt = value }
        case .setPersistentString(let value):
            await store.update { $0.persistentDemoString = value }
        }
    }
}
