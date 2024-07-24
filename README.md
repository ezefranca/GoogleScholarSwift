# GoogleScholarSwift 

[![Build Status](https://github.com/ezefranca/GoogleScholarFetcher/actions/workflows/workflow.yml/badge.svg)](https://github.com/ezefranca/GoogleScholarFetcher/actions/workflows/workflow.yml)

The `GoogleScholarSwift` package provides an easy-to-use interface for fetching publication data from Google Scholar. It allows users to retrieve detailed information about an author's publications, including titles, publication years, links, and citation counts. This package is designed for academics, researchers, and anyone interested in programmatically analyzing scholarly publication data.

## Installation

To integrate `GoogleScholarSwift` into your Xcode project using Swift Package Manager, add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ezefranca/GoogleScholarFetcher.git", from: "1.0.0")
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
    authorID: String,
    maxPublications: Int? = nil,
    sortBy: String = "cited",
    completion: @escaping ([Publication]?, Error?) -> Void)
```

#### Parameters

- `authorID`: The Google Scholar author ID.
- `maxPublications`: The maximum number of publications to fetch. If `nil`, fetches all available publications.
- `sortBy`: The sorting criterion for publications. Can be `.cited` or `.pubdate`. Default is `.cited`.
- `completion`: A completion handler called with the fetched publications or an error.

#### Example Usage

```swift
let fetcher = GoogleScholarFetcher()

// Fetch all publications for a given author ID
fetcher.fetchAllPublications(authorID: "6nOPl94AAAAJ") { publications, error in
    if let error = error {
        print("Error fetching publications: \(error)")
    } else if let publications = publications {
        print(publications)
    }
}

// Fetch a specific number of publications for a given author ID
fetcher.fetchAllPublications(authorID: "6nOPl94AAAAJ", maxPublications: 10) { publications, error in
    if let error = error {
        print("Error fetching publications: \(error)")
    } else if let publications = publications {
        print(publications)
    }
}

// Fetch all publications for a given author ID and sort by pubdate
fetcher.fetchAllPublications(authorID: "6nOPl94AAAAJ", sortBy: "pubdate") { publications, error in
    if let error = error {
        print("Error fetching publications: \(error)")
    } else if let publications = publications {
        print(publications)
    }
}
```

### `fetchArticleDetails`

Fetches the detailed information for a specific article.

```swift
public func fetchArticleDetails(
    articleDetails: ArticleDetails,
    completion: @escaping (Article?, Error?) -> Void)
```

#### Parameters

- `articleDetails`: An `ArticleDetails` object containing the link to the article.
- `completion`: A completion handler called with the fetched article details or an error.

#### Example Usage

```swift
let fetcher = GoogleScholarFetcher()

let articleDetails = ArticleDetails(link: "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=6nOPl94AAAAJ&citation_for_view=6nOPl94AAAAJ:UebtZRa9Y70C")
fetcher.fetchArticleDetails(articleDetails: articleDetails) { article, error in
    if let error = error {
        print("Error fetching article details: \(error)")
    } else if let article = article {
        print(article)
    }
}
```

### Complete Example

```swift
import GoogleScholarFetcher

let fetcher = GoogleScholarFetcher()

// Fetch all publications for a given author ID
fetcher.fetchAllPublications(authorID: "6nOPl94AAAAJ") { publications, error in
    if let error = error {
        print("Error fetching publications: \(error)")
    } else if let publications = publications {
        print(publications)
        
        // Assuming we want to fetch details of the first publication
        if let firstPublication = publications.first {
            let articleDetails = ArticleDetails(link: firstPublication.link)
            fetcher.fetchArticleDetails(articleDetails: articleDetails) { article, error in
                if let error = error {
                    print("Error fetching article details: \(error)")
                } else if let article = article {
                    print(article)
                }
            }
        }
    }
}

// Fetch a specific number of publications for a given author ID
fetcher.fetchAllPublications(authorID: "6nOPl94AAAAJ", maxPublications: 10) { publications, error in
    if let error = error {
        print("Error fetching publications: \(error)")
    } else if let publications = publications {
        print(publications)
    }
}

// Fetch all publications for a given author ID and sort by pubdate
fetcher.fetchAllPublications(authorID: "6nOPl94AAAAJ", sortBy: "pubdate") { publications, error in
    if let error = error {
        print("Error fetching publications: \(error)")
    } else if let publications = publications {
        print(publications)
    }
}
```


## Contributing

We welcome contributions to `GoogleScholarFetcher`! If you have suggestions for improvements, please open an issue or a pull request.

## Similar projects

A python module that does the same: https://github.com/ezefranca/scholarly_publications

## License

`GoogleScholarFetcher` is released under the MIT License. See the LICENSE file for more details.

