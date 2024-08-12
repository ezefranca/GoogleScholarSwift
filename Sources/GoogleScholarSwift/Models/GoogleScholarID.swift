import Foundation

/// Model type representing a Google Scholar ID.
public struct GoogleScholarID: Codable, Hashable, Equatable, CustomStringConvertible {
    public let value: String
    
    /// Initializes a new `GoogleScholarID` instance.
    ///
    /// - Parameter value: The string value of the Google Scholar ID.
    public init(_ value: String) {
        self.value = value
    }
    
    public var description: String {
        return value
    }
}
