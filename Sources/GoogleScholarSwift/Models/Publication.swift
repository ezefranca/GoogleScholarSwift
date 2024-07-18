import Foundation

/// A structure representing a publication.
public struct Publication: Codable {
    public let title: String
    public let year: String
    public let link: String
    public let citations: String
}
