//
//  FullyPersistentDemoState.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Foundation
import Toolkit

public struct FullyPersistentDemoState: StoreState {
    public var demoFlag: Bool
    public var demoInt: Int
    public var demoString: String
    public var optionalDemoFlag: Bool?
    public var optionalDemoInt: Int?
    public var optionalDemoString: String?
    
    public init(demoFlag: Bool = false,
                demoInt: Int = 0,
                demoString: String = "",
                optionalDemoFlag: Bool? = nil,
                optionalDemoInt: Int? = nil,
                optionalDemoString: String? = nil) {
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
    }
    
    public func needsPersistence(comparedTo previous: FullyPersistentDemoState) -> Bool {
        self.demoFlag != previous.demoFlag ||
        self.demoInt != previous.demoInt ||
        self.demoString != previous.demoString ||
        self.optionalDemoFlag != previous.optionalDemoFlag ||
        self.optionalDemoInt != previous.optionalDemoInt ||
        self.optionalDemoString != previous.optionalDemoString
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        demoFlag = (try? container.decode(Bool.self, forKey: .demoFlag)) ?? false
        demoInt = (try? container.decode(Int.self, forKey: .demoInt)) ?? 0
        demoString = (try? container.decode(String.self, forKey: .demoString)) ?? ""
        optionalDemoFlag = (try? container.decode(Bool?.self, forKey: .optionalDemoFlag))
        optionalDemoInt = (try? container.decode(Int?.self, forKey: .optionalDemoInt))
        optionalDemoString = (try? container.decode(String?.self, forKey: .optionalDemoString))
    }
}
