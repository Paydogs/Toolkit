//
//  SemiPersistentDemoState.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Foundation
import Toolkit

public struct SemiPersistentDemoState: StoreState {
    // Persistent
    public var persistentDemoFlag: Bool
    public var persistentDemoInt: Int
    public var persistentDemoString: String
    
    // Non-persistent
    public var demoFlag: Bool
    public var demoInt: Int
    public var demoString: String
    public var optionalDemoFlag: Bool?
    public var optionalDemoInt: Int?
    public var optionalDemoString: String?
    
    public init(persistentDemoFlag: Bool = false,
                persistentDemoInt: Int = 0,
                persistentDemoString: String = "",
                demoFlag: Bool = false,
                demoInt: Int = 0,
                demoString: String = "",
                optionalDemoFlag: Bool? = nil,
                optionalDemoInt: Int? = nil,
                optionalDemoString: String? = nil) {
        self.persistentDemoFlag = persistentDemoFlag
        self.persistentDemoInt = persistentDemoInt
        self.persistentDemoString = persistentDemoString
        self.demoFlag = demoFlag
        self.demoInt = demoInt
        self.demoString = demoString
        self.optionalDemoFlag = optionalDemoFlag
        self.optionalDemoInt = optionalDemoInt
        self.optionalDemoString = optionalDemoString
    }
    
    private enum CodingKeys: String, CodingKey {
        case demoFlag
        case demoInt
        case demoString
        case optionalDemoFlag
        case optionalDemoInt
        case optionalDemoString
        case persistentDemoFlag
        case persistentDemoInt
        case persistentDemoString
    }
    
    public func needsPersistence(comparedTo previous: SemiPersistentDemoState) -> Bool {
        self.persistentDemoFlag != previous.persistentDemoFlag ||
        self.persistentDemoInt != previous.persistentDemoInt ||
        self.persistentDemoString != previous.persistentDemoString
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        demoFlag = (try? container.decode(Bool.self, forKey: .demoFlag)) ?? false
        demoInt = (try? container.decode(Int.self, forKey: .demoInt)) ?? 0
        demoString = (try? container.decode(String.self, forKey: .demoString)) ?? ""
        optionalDemoFlag = (try? container.decode(Bool?.self, forKey: .optionalDemoFlag))
        optionalDemoInt = (try? container.decode(Int?.self, forKey: .optionalDemoInt))
        optionalDemoString = (try? container.decode(String?.self, forKey: .optionalDemoString))
        persistentDemoFlag = (try? container.decode(Bool.self, forKey: .persistentDemoFlag)) ?? false
        persistentDemoInt = (try? container.decode(Int.self, forKey: .persistentDemoInt)) ?? 0
        persistentDemoString = (try? container.decode(String.self, forKey: .persistentDemoString)) ?? ""
    }
}
