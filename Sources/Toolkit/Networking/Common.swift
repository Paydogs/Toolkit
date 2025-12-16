//
//  Common.swift
//  Toolkit
//
//  Created by Andras Olah on 2025. 12. 16..
//

import Network

public enum NetworkProtocol: String {
    case tcp
    
    func nwParameter() -> NWParameters {
        switch self {
        case .tcp:
            return .tcp
        }
    }
}
