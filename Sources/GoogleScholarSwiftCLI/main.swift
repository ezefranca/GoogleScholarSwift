import Foundation
import GoogleScholarSwift

let fetcher = GoogleScholarFetcher()

guard CommandLine.arguments.count > 1 else {
    print("Usage: GoogleScholarCLI <author_id> [--max <max>] [--sortby <sortby>]")
    exit(1)
}

let authorID = CommandLine.arguments[1]
var maxPublications: Int? = nil
var sortBy: SortBy = .cited

if let maxIndex = CommandLine.arguments.firstIndex(of: "--max"), maxIndex + 1 < CommandLine.arguments.count {
    maxPublications = Int(CommandLine.arguments[maxIndex + 1])
}

if let sortByIndex = CommandLine.arguments.firstIndex(of: "--sortby"), sortByIndex + 1 < CommandLine.arguments.count {
    sortBy = SortBy(rawValue: CommandLine.arguments[sortByIndex + 1]) ?? .cited
}

fetcher.fetchAllPublications(authorID: authorID, maxPublications: maxPublications, sortBy: sortBy) { publications, error in
    if let error = error {
        print("Error fetching publications: \(error)")
        exit(1)
    }
    
    if let publications = publications {
        if let jsonData = try? JSONEncoder().encode(publications),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
    }
    exit(0)
}

RunLoop.main.run()
