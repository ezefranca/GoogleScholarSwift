import Foundation
/// Model for a co-author's details, inheriting from `Author`.
public class CoAuthor: Author {
    /// Initializes a new `CoAuthor` instance.
    ///
    /// - Parameters:
    ///   - id: The Google Scholar author ID.
    ///   - name: The name of the co-author.
    ///   - affiliation: The affiliation of the co-author.
    ///   - pictureURL: The URL of the co-author's picture.
    public override init(id: GoogleScholarID, name: String, affiliation: String, pictureURL: String) {
        super.init(id: id, name: name, affiliation: affiliation, pictureURL: pictureURL)
    }
    
    required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
