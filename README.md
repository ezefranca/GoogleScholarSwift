
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

## Usage

### Using the CLI (Command Line Interface)

`GoogleScholarSwift` can be easily used via its command-line interface. Here are some examples:

Fetch all publications for a given author ID:
```bash
swift run GoogleScholarSwiftCLI <author_id>
```

Fetch a specific number of publications for a given author ID:
```bash
swift run GoogleScholarSwiftCLI <author_id> --max <number_of_publications>
```

Sort results by pubdate/cited:
```bash
swift run GoogleScholarSwiftCLI <author_id> --sortby <pubdate/cited>
```

### Using as a Swift Package

You can also use `GoogleScholarFetcher` directly in your Swift code. Here's how:

```swift
import GoogleScholarFetcher

let fetcher = GoogleScholarFetcher()

// Fetch all publications for a given author ID
fetcher.fetchAllPublications(authorID: "<author_id>") { publications, error in
    if let error = error {
        print("Error fetching publications: \(error)")
    } else if let publications = publications {
        print(publications)
    }
}

// Fetch a specific number of publications for a given author ID
fetcher.fetchAllPublications(authorID: "<author_id>", maxPublications: <number_of_publications>) { publications, error in
    if let error = error {
        print("Error fetching publications: \(error)")
    } else if let publications = publications {
        print(publications)
    }
}

// Fetch all publications for a given author ID and sort by pubdate/cited
fetcher.fetchAllPublications(authorID: "<author_id>", sortBy: "<pubdate/cited>") { publications, error in
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

A python module that do the same: https://github.com/ezefranca/scholarly_publications

## License

`GoogleScholarFetcher` is released under the MIT License. See the LICENSE file for more details.
