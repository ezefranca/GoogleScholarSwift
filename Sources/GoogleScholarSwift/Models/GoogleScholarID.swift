import Foundation

/// Model type representing a Google Scholar ID.
public struct GoogleScholarID: Codable, Hashable, Equatable, CustomStringConvertible {
    /// The string value of the Google Scholar ID.
    public let value: String
    
    /// Initializes a new `GoogleScholarID` instance.
    ///
    /// - Parameter value: The string value of the Google Scholar ID.
    public init(_ value: String) {
        self.value = value
    }
    
    /// A textual representation of the Google Scholar ID.
    public var description: String {
        return value
    }
}
