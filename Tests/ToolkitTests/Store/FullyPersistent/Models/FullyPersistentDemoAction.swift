//
//  FullyPersistentDemoAction.swift
//  Toolkit
//
//  Created by Andras Olah on 2026. 03. 31..
//

import Foundation
import Toolkit

public enum FullyPersistentDemoAction: Intent {
    case setFlag(Bool)
    case setInt(Int)
    case setString(String)
    case setOptionalFlag(Bool?)
    case setOptionalInt(Int?)
    case setOptionalString(String?)
}
