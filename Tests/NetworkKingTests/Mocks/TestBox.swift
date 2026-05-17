//
//  TestBox.swift
//

import Foundation

/// Mutable reference wrapper for sharing test-local state into @Sendable closures.
final class TestBox<T>: @unchecked Sendable {
    var value: T
    init(_ value: T) { self.value = value }
}
