//
//  InMemoryPersistence.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Foundation
import Toolkit

final class InMemoryPersistence<State: Sendable & Codable>: StatePersisting, @unchecked Sendable {
    private var stored: Data?
    private(set) var saveCount = 0
    
    func save(_ state: State) async throws {
        stored = try JSONEncoder().encode(state)
        saveCount += 1
    }
    
    func load() async throws -> State? {
        guard let stored else { return nil }
        return try JSONDecoder().decode(State.self, from: stored)
    }
    
    func clear() async throws {
        stored = nil
    }
}
