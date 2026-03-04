# NewsFeed

A take-home assignment built to simulate joining a team maintaining a production iOS app. The goal was not to build something impressive from scratch, but to demonstrate how I structure code, handle edge cases, and make decisions under realistic constraints.

---

## Tech Stack

- ** Swift **
- ** SwiftUI ** 

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
4. Build and run — `Cmd+R`

`Config.xcconfig` is already present in the project as a placeholder so Xcode can resolve the build configuration. The Pre-Action script overwrites it with your real key before every build. You do not need to touch any Xcode settings.

**NOTE:** API Key will be provided via email.

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

**Why MVVM and not Clean Architecture?**
Clean Architecture adds a Use Case layer that makes sense when business logic is complex or shared across multiple ViewModels. This app has one screen, one endpoint, and straightforward logic. Adding Use Cases here would be indirection without benefit.

**Why `@Observable` instead of `ObservableObject`?**
`@Observable` (iOS 17) tracks only the properties that are actually read in a given View body, which means fewer unnecessary re-renders. It also eliminates `@Published` on every property, which reduces boilerplate and makes the ViewModel easier to read.

**Why protocol-based dependencies?**
`ArticleRepositoryProtocol` and `NetworkServiceProtocol` allow the ViewModel to be tested without a real network. `MockArticleRepository` in the test suite is the direct result of this decision.

**How errors are handled**
There are two error types with distinct responsibilities. `NetworkError` is thrown by `NetworkService` and carries technical information — the `URLError` code, the HTTP status, the `DecodingError`. `AppError` lives at the ViewModel level and maps `NetworkError` into user-facing strings. This means the networking layer never knows about UI, and the ViewModel never has to inspect raw `URLError` codes.

`URLSession` is also configured with `waitsForConnectivity = false` and a 10 second request timeout. Without this, iOS waits up to 60 seconds before reporting a connectivity failure, which makes the app feel broken when there is no internet.

**How offline is handled**
When a network request fails due to connectivity, the app loads the last successful response from `UserDefaults` and shows it with a toast banner and a refresh button. If the failure is not connectivity-related — a server error, a decoding failure — the app shows the fullscreen error state instead, because cached articles are not relevant to those failures.

The stale data UI uses two separate state flags: `isShowingCachedData` drives the toast banner which auto-dismisses after 4 seconds, and `isShowingCachedContent` drives the persistent refresh button at the bottom of the list. They are independent because their lifecycles are different.

---

## What I Would Improve With More Time

**Cache expiry** — `UserDefaults` has no TTL mechanism. With more time I would move to `SwiftData` and attach a timestamp to each cached response so that data older than a defined threshold is treated as expired rather than shown as stale.

**Deep links** — `myapp://article/{id}` is not implemented. The blocker is that NewsAPI does not return stable article IDs, so there is nothing to put in the URL. A real implementation would require either generating a local ID or using the article URL as the identifier.

**Firebase Crashlytics** — there is no crash reporting. In a production app this would be one of the first things to add, because you cannot fix what you cannot observe.

---

## Bonus Features

Of the optional bonus items, I implemented **offline cache** as it directly improves the user experience the app shows the last successful response when there is no connectivity, with a clear indicator that the data may be stale.


## What I Intentionally Left Out

** Firebase ** and ** Fastlane ** were intentionally skipped. Both require real project  configuration to be meaningful, and an empty initialisation or a wrapper lane without proper signing setup would not demonstrate anything useful. I find it uncomfortable to leave code in a project that serves no real purpose it adds noise and gives a false impression of completeness.
