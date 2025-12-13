//
//  ToolkitDI.swift
//  Toolkit
//
//  Created by Andras Olah on 2025. 12. 13..
//

public final class DIContainer {
    public typealias InitializerFactory<Service> = (DIContainer) -> Service
    
    public enum Scope {
        case shared
        case unique
    }
    
    private var factories: [ObjectIdentifier: (DIContainer) -> Any] = [:]
    private var scopes: [ObjectIdentifier: Scope] = [:]
    private var sharedInstances: [ObjectIdentifier: Any] = [:]
    
    public init() {
    }
}

// Registration
extension DIContainer {
    public func register<Service>(_ type: Service.Type, scope: Scope = .shared, factory: @escaping InitializerFactory<Service>) {
        let key = ObjectIdentifier(type)
        factories[key] = factory
        scopes[key] = scope
        sharedInstances[key] = nil
    }
    
    public func register<Service>(scope: Scope = .shared, factory: @escaping InitializerFactory<Service>) {
        register(Service.self, scope: scope, factory: factory)
    }
}

// Resolution
extension DIContainer {
    public func resolve<Service>(_ type: Service.Type = Service.self) -> Service {
        let key = ObjectIdentifier(type)
        
        guard let factory = factories[key] else {
            fatalError("No service registered for \(type)")
        }
        
        let scope = scopes[key] ?? .unique
        
        switch scope {
        case .shared:
            if let exitstingInstance = sharedInstances[key] as? Service {
                return exitstingInstance
            }
            
            guard let instance = factory(self) as? Service else {
                fatalError("Service factory did not return an instance of \(type)")
            }
            
            sharedInstances[key] = instance
            return instance
            
        case .unique:
            guard let instance = factory(self) as? Service else {
                fatalError("Service factory did not return an instance of \(type)")
            }
            
            return instance
        }
    }
}
