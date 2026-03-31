//
//  SemiPersistentStoreTests.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Testing
import Toolkit

@Suite("SemiPersistentStore")
struct SemiPersistentStoreTests {
    let sut: SemiPersistentDemoStore
    let actionBus: ActionBus
    let persistence: InMemoryPersistence<SemiPersistentDemoState>
    
    init() {
        actionBus = ActionBus()
        persistence = InMemoryPersistence()
        sut = SemiPersistentDemoStore(actionBus: actionBus, persistence: persistence)
    }
    
    // MARK: - Initial state
    @Test func initialState_defaultValues() async {
        let state = await sut.currentState
        #expect(state.persistentDemoFlag == false)
        #expect(state.persistentDemoInt == 0)
        #expect(state.persistentDemoString == "")
        #expect(state.demoFlag == false)
        #expect(state.demoInt == 0)
        #expect(state.demoString == "")
        #expect(state.optionalDemoFlag == nil)
        #expect(state.optionalDemoInt == nil)
        #expect(state.optionalDemoString == nil)
    }
    
    // MARK: - Action handling (non-persistent)
    @Test func setFlag_updatesState() async {
        await sut.handleAction(SemiPersistentDemoAction.setFlag(true))
        let state = await sut.currentState
        #expect(state.demoFlag == true)
    }
    
    @Test func setInt_updatesState() async {
        await sut.handleAction(SemiPersistentDemoAction.setInt(42))
        let state = await sut.currentState
        #expect(state.demoInt == 42)
    }
    
    @Test func setString_updatesState() async {
        await sut.handleAction(SemiPersistentDemoAction.setString("hello"))
        let state = await sut.currentState
        #expect(state.demoString == "hello")
    }
    
    @Test func setOptionalFlag_updatesState() async {
        await sut.handleAction(SemiPersistentDemoAction.setOptionalFlag(true))
        let state = await sut.currentState
        #expect(state.optionalDemoFlag == true)
    }
    
    @Test func setOptionalInt_updatesState() async {
        await sut.handleAction(SemiPersistentDemoAction.setOptionalInt(42))
        let state = await sut.currentState
        #expect(state.optionalDemoInt == 42)
    }
    
    @Test func setOptionalString_updatesState() async {
        await sut.handleAction(SemiPersistentDemoAction.setOptionalString("hello"))
        let state = await sut.currentState
        #expect(state.optionalDemoString == "hello")
    }
    
    // MARK: - Action handling (persistent)
    @Test func setPersistentFlag_updatesState() async {
        await sut.handleAction(SemiPersistentDemoAction.setPersistentFlag(true))
        let state = await sut.currentState
        #expect(state.persistentDemoFlag == true)
    }
    
    @Test func setPersistentInt_updatesState() async {
        await sut.handleAction(SemiPersistentDemoAction.setPersistentInt(42))
        let state = await sut.currentState
        #expect(state.persistentDemoInt == 42)
    }
    
    @Test func setPersistentString_updatesState() async {
        await sut.handleAction(SemiPersistentDemoAction.setPersistentString("hello"))
        let state = await sut.currentState
        #expect(state.persistentDemoString == "hello")
    }
    
    // MARK: - Persistence: only persistent fields trigger save
    @Test func nonPersistentChange_doesNotSave() async throws {
        await sut.handleAction(SemiPersistentDemoAction.setFlag(true))
        await sut.handleAction(SemiPersistentDemoAction.setInt(99))
        await sut.handleAction(SemiPersistentDemoAction.setString("changed"))
        await sut.handleAction(SemiPersistentDemoAction.setOptionalFlag(true))
        await sut.handleAction(SemiPersistentDemoAction.setOptionalInt(5))
        await sut.handleAction(SemiPersistentDemoAction.setOptionalString("opt"))
        try await Task.sleep(for: .milliseconds(600))
        #expect(persistence.saveCount == 0)
    }
    
    @Test func persistentChange_triggersSave() async throws {
        await sut.handleAction(SemiPersistentDemoAction.setPersistentFlag(true))
        try await Task.sleep(for: .milliseconds(600))
        #expect(persistence.saveCount > 0)
        let loaded = try await persistence.load()
        #expect(loaded?.persistentDemoFlag == true)
    }
    
    @Test func mixedChanges_onlyPersistentTriggersSave() async throws {
        await sut.handleAction(SemiPersistentDemoAction.setInt(99))
        try await Task.sleep(for: .milliseconds(600))
        #expect(persistence.saveCount == 0)
        
        await sut.handleAction(SemiPersistentDemoAction.setPersistentInt(77))
        try await Task.sleep(for: .milliseconds(600))
        #expect(persistence.saveCount > 0)
        let loaded = try await persistence.load()
        #expect(loaded?.persistentDemoInt == 77)
        // non-persistent value is saved in the snapshot but didn't trigger the save
        #expect(loaded?.demoInt == 99)
    }
    
    @Test func persistence_restoresState() async throws {
        let saved = SemiPersistentDemoState(
            persistentDemoFlag: true,
            persistentDemoInt: 88,
            persistentDemoString: "restored",
            demoFlag: true,
            demoInt: 5,
            demoString: "s"
        )
        try await persistence.save(saved)
        
        let restored = SemiPersistentDemoStore(actionBus: actionBus, persistence: persistence)
        try await Task.sleep(for: .milliseconds(100))
        let state = await restored.currentState
        #expect(state.persistentDemoFlag == true)
        #expect(state.persistentDemoInt == 88)
        #expect(state.persistentDemoString == "restored")
    }
    
    // MARK: - Stream
    @Test func stateStream_emitsOnChange() async {
        let stream = await sut.stateStream()
        var iterator = stream.makeAsyncIterator()
        _ = await iterator.next()
        
        await sut.handleAction(SemiPersistentDemoAction.setPersistentInt(77))
        let updated = await iterator.next()
        #expect(updated?.persistentDemoInt == 77)
    }
}
