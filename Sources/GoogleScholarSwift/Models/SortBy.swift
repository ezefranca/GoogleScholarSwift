import Foundation

/// Enum representing the sorting criteria for publications.
public enum SortBy: String {
    /// Sort by number of citations.
    case cited = "cited"
    /// Sort by publication date.
    case pubdate = "pubdate"
}
