import Foundation

/// An enumeration representing the maximum number of publications to fetch.
public enum FetchQuantity {
    /// Fetch all available publications.
    case all
    /// Fetch a specific number of publications.
    case specific(Int)
}
