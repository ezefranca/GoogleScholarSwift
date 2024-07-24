import Foundation

/// A structure representing a publication.
public struct Publication: Codable {
    /// The title of the publication.
    public let title: String
    /// The year the publication was released.
    public let year: String
    /// The URL link to the publication.
    public let link: String
    /// The number of citations the publication has received.
    public let citations: String
}
