import Foundation

/// A class that holds the citation metrics for an author on Google Scholar.
public class CitationMetrics: Codable, Hashable, Identifiable, Equatable, CustomStringConvertible {
    
    /// Unique identifier for the author.
    public let id: GoogleScholarID
    
    /// Total number of citations received by the author.
    public let citedBy: Int
    
    /// The h-index of the author. The h-index is an author-level metric that measures both the productivity and citation impact of the author's publications.
    public let hIndex: Int
    
    /// The i10-index of the author. The i10-index indicates the number of publications that have been cited at least 10 times.
    public let i10Index: Int
    
    /// Initializes a new instance of `CitationMetrics`.
    ///
    /// - Parameters:
    ///   - id: The unique `GoogleScholarID` of the author.
    ///   - citedBy: The total number of citations the author has received.
    ///   - hIndex: The h-index of the author.
    ///   - i10Index: The i10-index of the author.
    public init(id: GoogleScholarID, citedBy: Int, hIndex: Int, i10Index: Int) {
        self.id = id
        self.citedBy = citedBy
        self.hIndex = hIndex
        self.i10Index = i10Index
    }
    
    /// A string description of the citation metrics.
    ///
    /// This is used for easier debugging and printing of the object's values.
    /// The output format is: "GoogleScholarID [id] citedBy(citations: [citedBy], hIndex: [hIndex], i10Index: [i10Index])".
    public var description: String {
        return "GoogleScholarID \(id.value) citedBy(citations: \(citedBy), hIndex: \(hIndex), i10Index \(i10Index)"
    }
    
    /// Equality operator for comparing two `CitationMetrics` instances.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `CitationMetrics` object.
    ///   - rhs: The right-hand side `CitationMetrics` object.
    /// - Returns: A boolean value indicating whether the two objects are equal (i.e., they have the same `GoogleScholarID`).
    public static func == (lhs: CitationMetrics, rhs: CitationMetrics) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Hash function for the `CitationMetrics` class.
    ///
    /// This is used to allow the class to be used in hashed collections like `Set` or as a dictionary key.
    /// - Parameter hasher: The hasher used to combine the object's hash values.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
