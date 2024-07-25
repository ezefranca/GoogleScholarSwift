# GoogleScholarSwift 

[![Swift](https://github.com/ezefranca/GoogleScholarSwift/actions/workflows/swift.yml/badge.svg)](https://github.com/ezefranca/GoogleScholarSwift/actions/workflows/swift.yml)

The `GoogleScholarSwift` package provides an easy-to-use interface for fetching publication data from Google Scholar. It allows users to retrieve detailed information about an author's publications, including titles, publication years, links, and citation counts. This package is designed for academics, researchers, and anyone interested in programmatically analyzing scholarly publication data.

## Installation

To integrate `GoogleScholarSwift` into your Xcode project using Swift Package Manager, add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ezefranca/GoogleScholarSwift.git", from: "1.3.0")
]
```

Then add `GoogleScholarSwift` as a dependency in your target:

```swift
.target(
    name: "YourTargetName",
    dependencies: [
        .product(name: "GoogleScholarSwift", package: "GoogleScholarSwift")
    ]
)
```

## Methods

### `fetchAllPublications`

Fetches all publications for a given author from Google Scholar.

```swift
public func fetchAllPublications(
    authorID: GoogleScholarID,
    fetchQuantity: FetchQuantity = .all,
    sortBy: SortBy = .cited
) async throws -> [Publication]
```

#### Parameters

- `authorID`: The Google Scholar author ID.
- `fetchQuantity`: The quantity of publications to fetch. Can be `.all` or `.specific(Int)`. Default is `.all`.
- `sortBy`: The sorting criterion for publications. Can be `.cited` or `.pubdate`. Default is `.cited`.

#### Returns

- An array of `Publication` objects.

#### Throws

- An error if fetching or parsing fails.

#### Example Usage

```swift
let fetcher = GoogleScholarFetcher()

// Fetch all publications for a given author ID
let publications = try await fetcher.fetchAllPublications(authorID: GoogleScholarID("RefX_60AAAAJ"))
print(publications)

// Fetch a specific number of publications for a given author ID
let limitedPublications = try await fetcher.fetchAllPublications(authorID: GoogleScholarID("RefX_60AAAAJ"), fetchQuantity: .specific(10))
print(limitedPublications)

// Fetch all publications for a given author ID and sort by pubdate
let sortedPublications = try await fetcher.fetchAllPublications(authorID: GoogleScholarID("RefX_60AAAAJ"), sortBy: .pubdate)
print(sortedPublications)
```

### `fetchArticle`

Fetches the detailed information for a specific article.

```swift
public func fetchArticle(articleLink: ArticleLink) async throws -> Article
```

#### Parameters

- `articleLink`: An `ArticleLink` object containing the link to the article.

#### Returns

- An `Article` object.

#### Throws

- An error if fetching or parsing fails.

#### Example Usage

```swift
let fetcher = GoogleScholarFetcher()

let articleLink = ArticleLink(link: "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=RefX_60AAAAJ&citation_for_view=RefX_60AAAAJ:9yKSN-GCB0IC")
let article = try await fetcher.fetchArticle(articleLink: articleLink)
print(article)
```

### `fetchScientistDetails`

Fetches the scientist's details such as name, affiliation, and picture URL from Google Scholar.

```swift
public func fetchScientistDetails(scholarID: GoogleScholarID) async throws -> Scientist
```

#### Parameters

- `scholarID`: The Google Scholar author ID.

#### Returns

- A `Scientist` object containing the scientist's details.

#### Throws

- An error if fetching or parsing fails.

#### Example Usage

```swift
let fetcher = GoogleScholarFetcher()

let scientistDetails = try await fetcher.fetchScientistDetails(scholarID: GoogleScholarID("6nOPl94AAAAJ"))
print(scientistDetails)
```

### Complete Example

```swift
import GoogleScholarSwift

let fetcher = GoogleScholarFetcher()
let authorID = GoogleScholarID("RefX_60AAAAJ")

// Fetch all publications for a given author ID
let publications = try await fetcher.fetchAllPublications(authorID: authorID)
print("All Publications:", publications)

// Fetch a specific number of publications for a given author ID
let limitedPublications = try await fetcher.fetchAllPublications(authorID: authorID, fetchQuantity: .specific(10))
print("Limited Publications:", limitedPublications)

// Fetch all publications for a given author ID and sort by pubdate
let sortedPublications = try await fetcher.fetchAllPublications(authorID: authorID, sortBy: .pubdate)
print("Sorted Publications:", sortedPublications)

// Fetch article details for the first publication
if let firstPublication = publications.first {
    let articleLink = ArticleLink(link: firstPublication.link)
    let article = try await fetcher.fetchArticle(articleLink: articleLink)
    print("Article Details:", article)
}

// Fetch scientist details
let scientistDetails = try await fetcher.fetchScientistDetails(scholarID: authorID)
print("Scientist Details:", scientistDetails)
```

## Contributing

We welcome contributions to `GoogleScholarSwift`! If you have suggestions for improvements, please open an issue or a pull request.

## Disclaimer

This project is not affiliated with Google and is intended for educational purposes only. The responsibility for the use and interpretation of the data obtained through this project lies solely with the user. The developers and contributors of this project are not liable for any misuse or legal implications arising from the utilization of the data provided. Users are advised to ensure compliance with applicable laws and regulations when using this project.

## License

`GoogleScholarSwift` is released under the MIT License. See the LICENSE file for more details.
