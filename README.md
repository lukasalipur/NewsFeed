# NewsFeed

A take-home assignment built to simulate joining a team maintaining a production iOS app. The goal was not to build something impressive from scratch, but to demonstrate how I structure code, handle edge cases, and make decisions under realistic constraints.

---

## Tech Stack

- **Swift**
- **SwiftUI** 

---

## Requirements

- Xcode 15+
- iOS 17.0+
- A free API key from [newsapi.org](https://newsapi.org)

---

## Setup

The API key is never committed to the repository. It is stored in a `.env` file and injected into the app at build time through a Pre-Action script that writes it into `Config.xcconfig` before Xcode reads it.

1. Clone the repo
2. Create a `.env` file in the project root:

   ```
   API_KEY = your_api_key_here
   ```
3. Open `NewsFeed.xcodeproj`
4. Build and run - `Cmd+R`

`Config.xcconfig` is already present in the project as a placeholder so Xcode can resolve the build configuration. The Pre-Action script overwrites it with your real key before every build. You do not need to touch any Xcode settings.

> The API key will be shared separately via email.
---

## Architecture

The app follows MVVM with a strict separation between layers. Each layer has one responsibility and communicates only with the layer directly below it.

```
Views
  └── renders state, delegates actions to ViewModel

ViewModel
  └── owns all UI state, coordinates repository and cache

Repository
  └── fetches from network, maps response to domain model

Models
  └── Article, NewsAPIResponse — plain data structures, no logic

Networking
  └── URLSession wrapper, handles HTTP status codes and decoding

Utilities
  └── AppError, ArticleCacheService, Environment
```

---

## Architecture

MVVM with a strict separation between layers - Views render state, ViewModel owns all UI state and coordinates between repository and cache, Repository maps API responses to domain models, NetworkService handles HTTP and decoding.

**State management** - `@Observable` (iOS 17) tracks only the properties actually read in a given View body, which means SwiftUI re-renders only what changed. It also removes the need for `@Published` on every property, making the ViewModel cleaner and easier to follow.

**Testability** - `ArticleRepositoryProtocol` and `NetworkServiceProtocol` mean the ViewModel has no direct dependency on URLSession or the real network. The test suite uses `MockArticleRepository` to verify loading, error, and pagination behaviour in isolation.

**Error handling** - there are two distinct error types. `NetworkError` is thrown by `NetworkService` and carries raw technical information the `URLError` code, HTTP status, `DecodingError`. `AppError` sits at the ViewModel level and translates those into user-facing strings. This keeps presentation logic out of the networking layer entirely.

**Networking** - `URLSession` is configured with `waitsForConnectivity = false` and a 10 second request timeout. By default iOS waits up to 60 seconds before reporting a connectivity failure, which makes the app feel unresponsive. Failing fast lets the app immediately fall back to the cache and give the user useful feedback.

**Offline** - cached articles are shown only when the failure is connectivity-related. A server error or a decoding failure shows the fullscreen error state instead, because showing stale articles would be misleading the network was reachable, something else went wrong. The stale data UI uses two separate flags: `isShowingCachedData` drives a toast that auto dismisses after 4 seconds, `isShowingCachedContent` drives a persistent refresh button at the bottom of the list. They are independent because their lifecycles are different the toast is a one-time notification, the button stays until the user successfully refreshes.

## What I Would Improve With More Time

**Cache expiry** - `UserDefaults` has no TTL mechanism. With more time I would move to `SwiftData` and attach a timestamp to each cached response so that data older than a defined threshold is treated as expired rather than shown as stale.

**Deep links** - `myapp://article/{id}` is not implemented. The blocker is that NewsAPI does not return stable article IDs, so there is nothing to put in the URL. A real implementation would require either generating a local ID or using the article URL as the identifier.

**Firebase Crashlytics** - there is no crash reporting. In a production app this would be one of the first things to add, because you cannot fix what you cannot observe.

---

## Bonus Features

Of the optional bonus items, I implemented **offline cache** as it directly improves the user experience the app shows the last successful response when there is no connectivity, with a clear indicator that the data may be stale.


## What I Intentionally Left Out

**Firebase** and **Fastlane** were intentionally skipped. Both require real project  configuration to be meaningful, and an empty initialisation or a wrapper lane without proper signing setup would not demonstrate anything useful. I find it uncomfortable to leave code in a project that serves no real purpose it adds noise and gives a false impression of completeness.
