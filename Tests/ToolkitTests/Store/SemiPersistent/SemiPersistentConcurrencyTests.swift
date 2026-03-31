//
//  SemiPersistentConcurrencyTests.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Testing
@testable import Toolkit
import Foundation

@Suite("SemiPersistentStore - Concurrency")
struct SemiPersistentConcurrencyTests {
    let sut: SemiPersistentDemoStore
    let actionBus: ActionBus
    let dispatcher: ActionDispatching
    let persistence: InMemoryPersistence<SemiPersistentDemoState>

    init() {
        actionBus = ActionBus()
        dispatcher = ActionDispatcher(actionBus)
        persistence = InMemoryPersistence()
        sut = SemiPersistentDemoStore(actionBus: actionBus, persistence: persistence)
    }

    // MARK: - Sequential dispatch preserves order
    @Test func sequentialDispatch_preservesOrder() async throws {
        for i in 0..<100 {
            dispatcher.dispatch(SemiPersistentDemoAction.setPersistentInt(i))
        }
        try await Task.sleep(for: .milliseconds(200))
        let state = await sut.currentState
        #expect(state.persistentDemoInt == 99)
    }

    @Test func sequentialDispatch_streamEmitsInOrder() async throws {
        let stream = await sut.stateStream()
        var iterator = stream.makeAsyncIterator()
        _ = await iterator.next()

        for i in 1...10 {
            dispatcher.dispatch(SemiPersistentDemoAction.setPersistentInt(i))
        }

        var observed: [Int] = []
        for _ in 1...10 {
            if let state = await iterator.next() {
                observed.append(state.persistentDemoInt)
            }
        }
        #expect(observed == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }

    // MARK: - Concurrent dispatch — no corruption
    @Test func concurrentDispatch_noCorruption() async throws {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setPersistentInt(i)) }
            }
        }
        try await Task.sleep(for: .milliseconds(300))
        let state = await sut.currentState
        #expect((0..<100).contains(state.persistentDemoInt))
    }

    @Test func concurrentMixedDispatch_noCorruption() async throws {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setInt(i)) }
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setString("s\(i)")) }
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setFlag(i % 2 == 0)) }
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setOptionalInt(i)) }
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setOptionalString("o\(i)")) }
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setOptionalFlag(i % 2 == 0)) }
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setPersistentInt(i)) }
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setPersistentString("p\(i)")) }
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setPersistentFlag(i % 2 == 0)) }
            }
        }
        try await Task.sleep(for: .milliseconds(300))
        let state = await sut.currentState
        #expect((0..<50).contains(state.demoInt))
        #expect((0..<50).map { "s\($0)" }.contains(state.demoString))
        #expect((0..<50).contains(state.optionalDemoInt!))
        #expect((0..<50).map { "o\($0)" }.contains(state.optionalDemoString!))
        #expect((0..<50).contains(state.persistentDemoInt))
        #expect((0..<50).map { "p\($0)" }.contains(state.persistentDemoString))
    }

    @Test func concurrentOverwrites_noPartialState() async throws {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<200 {
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setPersistentString("val_\(i)")) }
            }
        }
        try await Task.sleep(for: .milliseconds(300))
        let state = await sut.currentState
        #expect(state.persistentDemoString.hasPrefix("val_"))
        let num = Int(state.persistentDemoString.replacingOccurrences(of: "val_", with: ""))!
        #expect((0..<200).contains(num))
    }

    // MARK: - Concurrent non-persistent changes don't trigger persistence
    @Test func concurrentNonPersistentChanges_noSave() async throws {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setInt(i)) }
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setString("s\(i)")) }
                group.addTask { dispatcher.dispatch(SemiPersistentDemoAction.setOptionalInt(i)) }
            }
        }
        try await Task.sleep(for: .milliseconds(600))
        #expect(persistence.saveCount == 0)
    }
}
