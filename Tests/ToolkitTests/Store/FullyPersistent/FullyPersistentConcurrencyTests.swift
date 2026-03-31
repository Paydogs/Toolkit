//
//  FullyPersistentConcurrencyTests.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Testing
@testable import Toolkit
import Foundation

@Suite("FullyPersistentStore - Concurrency")
struct FullyPersistentConcurrencyTests {
    let sut: FullyPersistentDemoStore
    let actionBus: ActionBus
    let dispatcher: ActionDispatching
    let persistence: InMemoryPersistence<FullyPersistentDemoState>

    init() {
        actionBus = ActionBus()
        dispatcher = ActionDispatcher(actionBus)
        persistence = InMemoryPersistence()
        sut = FullyPersistentDemoStore(actionBus: actionBus, persistence: persistence)
    }

    // MARK: - Sequential dispatch preserves order
    @Test func sequentialDispatch_preservesOrder() async throws {
        for i in 0..<100 {
            dispatcher.dispatch(FullyPersistentDemoAction.setInt(i))
        }
        // bus processes async — wait for drain
        try await Task.sleep(for: .milliseconds(200))
        let state = await sut.currentState
        #expect(state.demoInt == 99)
    }

    @Test func sequentialDispatch_streamEmitsInOrder() async throws {
        let stream = await sut.stateStream()
        var iterator = stream.makeAsyncIterator()
        _ = await iterator.next() // initial

        for i in 1...10 {
            dispatcher.dispatch(FullyPersistentDemoAction.setInt(i))
        }

        var observed: [Int] = []
        for _ in 1...10 {
            if let state = await iterator.next() {
                observed.append(state.demoInt)
            }
        }
        #expect(observed == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }

    // MARK: - Concurrent dispatch — no corruption, no ordering guarantee
    @Test func concurrentDispatch_noCorruption() async throws {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask { dispatcher.dispatch(FullyPersistentDemoAction.setInt(i)) }
            }
        }
        try await Task.sleep(for: .milliseconds(300))
        let state = await sut.currentState
        #expect((0..<100).contains(state.demoInt))
    }

    @Test func concurrentMixedDispatch_noCorruption() async throws {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask { dispatcher.dispatch(FullyPersistentDemoAction.setInt(i)) }
                group.addTask { dispatcher.dispatch(FullyPersistentDemoAction.setString("s\(i)")) }
                group.addTask { dispatcher.dispatch(FullyPersistentDemoAction.setFlag(i % 2 == 0)) }
                group.addTask { dispatcher.dispatch(FullyPersistentDemoAction.setOptionalInt(i)) }
                group.addTask { dispatcher.dispatch(FullyPersistentDemoAction.setOptionalString("o\(i)")) }
                group.addTask { dispatcher.dispatch(FullyPersistentDemoAction.setOptionalFlag(i % 2 == 0)) }
            }
        }
        try await Task.sleep(for: .milliseconds(300))
        let state = await sut.currentState
        #expect((0..<50).contains(state.demoInt))
        #expect((0..<50).map { "s\($0)" }.contains(state.demoString))
        #expect((0..<50).contains(state.optionalDemoInt!))
        #expect((0..<50).map { "o\($0)" }.contains(state.optionalDemoString!))
    }

    @Test func concurrentOverwrites_noPartialState() async throws {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<200 {
                group.addTask { dispatcher.dispatch(FullyPersistentDemoAction.setString("val_\(i)")) }
            }
        }
        try await Task.sleep(for: .milliseconds(300))
        let state = await sut.currentState
        #expect(state.demoString.hasPrefix("val_"))
        let num = Int(state.demoString.replacingOccurrences(of: "val_", with: ""))!
        #expect((0..<200).contains(num))
    }
}
