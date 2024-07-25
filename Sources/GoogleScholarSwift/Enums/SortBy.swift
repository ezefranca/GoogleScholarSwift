import Foundation

/// Sorting criteria for publications.
public enum SortBy: String, Codable, Hashable, Equatable, CaseIterable, CustomStringConvertible {
    /// Sort by number of citations.
    case cited = "cited"
    /// Sort by publication date.
    case pubdate = "pubdate"
    
    public var description: String {
        return self.rawValue
    }
}
