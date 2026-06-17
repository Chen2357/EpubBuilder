# EpubBuilder

EpubBuilder is a Swift package that provides abstractions for building EPUB files.

## Overview

- The struct `EpubBook` is an abstract representation of an EPUB book which can be converted to an actual EPUB file using the `writeEpub(to:)` method.
- The struct `Book` represents the content of a simple book.
  It can be converted into an `EpubBook` using the `toEpub(builder:)` method which takes an `EpubBuilder` instance as a parameter.
- The protocol `EpubBuilder` defines the methods required to build an `EpubBook` from a `Book`.
  An `EpubBuilder` implementation is responsible for styling, navigation, and HTML generation of the contents.
  - The struct `MinimalEpubBuilder` is a simple implementation of the `EpubBuilder` protocol that provides basic styling and navigation for the generated EPUB book.
  - The struct `FancyVrtlEpubBuilder` is used for styling EPUB books with a vertical right-to-left layout.
  - The struct `MinimalMangaEpubBuilder` is used for manga with a prepaginated right-to-left layout.

## Usage

To use the `EpubBuilder` package, add it as a dependency in your Swift project:
```swift
.package(url: "https://github.com/Chen2357/EpubBuilder.git", from: "1.0.0")
```
