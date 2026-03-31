//
//  StoreTests.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Testing
import Toolkit

@Suite("FullyPersistentStore")
struct FullyPersistentStoreTests {
    let sut: FullyPersistentDemoStore
    let actionBus: ActionBus
    let persistence: InMemoryPersistence<FullyPersistentDemoState>

    init() {
        actionBus = ActionBus()
        persistence = InMemoryPersistence()
        sut = FullyPersistentDemoStore(actionBus: actionBus, persistence: persistence)
    }

    // MARK: - Initial state
    @Test func initialState_defaultValues() async {
        let state = await sut.currentState
        #expect(state.demoFlag == false)
        #expect(state.demoInt == 0)
        #expect(state.demoString == "")
    }

    // MARK: - Action handling
    @Test func setFlag_updatesState() async {
        await sut.handleAction(FullyPersistentDemoAction.setFlag(true))
        let state = await sut.currentState
        #expect(state.demoFlag == true)
    }

    @Test func setInt_updatesState() async {
        await sut.handleAction(FullyPersistentDemoAction.setInt(42))
        let state = await sut.currentState
        #expect(state.demoInt == 42)
    }

    @Test func setString_updatesState() async {
        await sut.handleAction(FullyPersistentDemoAction.setString("hello"))
        let state = await sut.currentState
        #expect(state.demoString == "hello")
    }
    
    @Test func setOptionalFlag_updatesState() async {
        await sut.handleAction(FullyPersistentDemoAction.setOptionalFlag(true))
        let state = await sut.currentState
        #expect(state.optionalDemoFlag == true)
    }
    
    @Test func setOptionalInt_updatesState() async {
        await sut.handleAction(FullyPersistentDemoAction.setOptionalInt(42))
        let state = await sut.currentState
        #expect(state.optionalDemoInt == 42)
    }
    
    @Test func setOptionalString_updatesState() async {
        await sut.handleAction(FullyPersistentDemoAction.setOptionalString("hello"))
        let state = await sut.currentState
        #expect(state.optionalDemoString == "hello")
    }

    // MARK: - Sequential ordering
    @Test func multipleActions_appliedInOrder() async {
        await sut.handleAction(FullyPersistentDemoAction.setInt(1))
        await sut.handleAction(FullyPersistentDemoAction.setInt(2))
        await sut.handleAction(FullyPersistentDemoAction.setInt(3))
        let state = await sut.currentState
        #expect(state.demoInt == 3)
    }

    @Test func multipleActions_streamEmitsInOrder() async {
        let stream = await sut.stateStream()
        var iterator = stream.makeAsyncIterator()
        // consume initial
        _ = await iterator.next()

        await sut.handleAction(FullyPersistentDemoAction.setInt(10))
        await sut.handleAction(FullyPersistentDemoAction.setInt(20))
        await sut.handleAction(FullyPersistentDemoAction.setInt(30))

        let first = await iterator.next()
        let second = await iterator.next()
        let third = await iterator.next()
        #expect(first?.demoInt == 10)
        #expect(second?.demoInt == 20)
        #expect(third?.demoInt == 30)
    }

    @Test func mixedActions_appliedInOrder() async {
        await sut.handleAction(FullyPersistentDemoAction.setFlag(true))
        await sut.handleAction(FullyPersistentDemoAction.setInt(42))
        await sut.handleAction(FullyPersistentDemoAction.setString("done"))
        await sut.handleAction(FullyPersistentDemoAction.setOptionalFlag(true))
        await sut.handleAction(FullyPersistentDemoAction.setOptionalInt(99))
        await sut.handleAction(FullyPersistentDemoAction.setOptionalString("opt"))

        let state = await sut.currentState
        #expect(state.demoFlag == true)
        #expect(state.demoInt == 42)
        #expect(state.demoString == "done")
        #expect(state.optionalDemoFlag == true)
        #expect(state.optionalDemoInt == 99)
        #expect(state.optionalDemoString == "opt")
    }

    @Test func overwriteActions_lastWins() async {
        await sut.handleAction(FullyPersistentDemoAction.setString("a"))
        await sut.handleAction(FullyPersistentDemoAction.setString("b"))
        await sut.handleAction(FullyPersistentDemoAction.setString("c"))
        await sut.handleAction(FullyPersistentDemoAction.setOptionalInt(1))
        await sut.handleAction(FullyPersistentDemoAction.setOptionalInt(2))
        await sut.handleAction(FullyPersistentDemoAction.setOptionalInt(nil))

        let state = await sut.currentState
        #expect(state.demoString == "c")
        #expect(state.optionalDemoInt == nil)
    }

    // MARK: - Persistence
    @Test func persistence_savesAfterUpdate() async throws {
        await sut.handleAction(FullyPersistentDemoAction.setFlag(true))
        // debounce is 500ms
        try await Task.sleep(for: .milliseconds(600))
        #expect(persistence.saveCount > 0)
        let loaded = try await persistence.load()
        #expect(loaded?.demoFlag == true)
    }

    @Test func persistence_restoresState() async throws {
        let savedState = FullyPersistentDemoState(demoFlag: true, demoInt: 99, demoString: "restored")
        try await persistence.save(savedState)

        let restored = FullyPersistentDemoStore(actionBus: actionBus, persistence: persistence)
        // wait for async load
        try await Task.sleep(for: .milliseconds(100))
        let state = await restored.currentState
        #expect(state.demoFlag == true)
        #expect(state.demoInt == 99)
        #expect(state.demoString == "restored")
    }

    // MARK: - Stream
    @Test func stateStream_emitsOnChange() async {
        let stream = await sut.stateStream()
        var iterator = stream.makeAsyncIterator()

        // initial emission
        let initial = await iterator.next()
        #expect(initial?.demoInt == 0)

        await sut.handleAction(FullyPersistentDemoAction.setInt(77))
        let updated = await iterator.next()
        #expect(updated?.demoInt == 77)
    }
}
