//
//  AsyncAwait+Toolkit.swift
//  Toolkit
//
//  Created by Andras Olah on 2025. 12. 17..
//

@discardableResult
public func runOnMainThreadAfter(
    seconds: Double,
    operation: @MainActor @escaping () -> Void
) -> Task<Void, Never> {
    Task { @MainActor in
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        guard !Task.isCancelled else { return }
        operation()
    }
}


extension Task where Success == Void, Failure == Never {
    @discardableResult
    public static func runOnMainThreadAfter(
        seconds: Double,
        onSuccess: @MainActor @escaping () -> Void,
        onCancelled: (@MainActor () -> Void)? = nil
    ) -> Task<Void, Never> {
        Task { @MainActor in
            do {
                try await Task<Never, Never>.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                onSuccess()
            } catch {
                onCancelled?()
            }
        }
    }
}

extension Task where Success == Void, Failure == Never {
    @discardableResult
    public static func runAfter(
        seconds: Double,
        onSuccess: @Sendable @escaping () -> Void,
        onCancelled: (@Sendable () -> Void)? = nil
    ) -> Task<Void, Never> {
        Task {
            do {
                try await Task<Never, Never>.sleep(
                    nanoseconds: UInt64(seconds * 1_000_000_000)
                )
                onSuccess()
            } catch {
                onCancelled?()
            }
        }
    }
}
