# NewsFeed

A news feed iOS app built as a take-home assignment. Fetches top US headlines from [NewsAPI.org](https://newsapi.org), displays them in a paginated list, and supports offline reading via local cache.

---

## Tech Stack

- **Swift**
- **SwiftUI**

---

## Requirements

- Xcode 15+
- iOS 17.0+
- A free [NewsAPI.org](https://newsapi.org) API key

---

## Setup

The API key is stored in a `.env` file and injected at build time via a Run Script phase and `.xcconfig`. Neither file is committed to the repository.

1. Clone the repo
2. Create a `.env` file in the project root:
   ```
   API_KEY=your_api_key_here (key: 2c747af715ed4c1d993676b8fa3bbefc)
   ```
3. Open `NewsFeed.xcodeproj`
4. Build and run (`Cmd+R`)

The Run Script reads `.env` and writes the key into `.xcconfig`, which is referenced by `Info.plist` via `$(API_KEY)`. `Environment.swift` reads it at runtime using `Bundle.main.infoDictionary`.

---

## Architecture

The app follows **MVVM** with a clear separation of concerns across layers:

```
Views/
├── Components/         → Reusable UI components (banners, row views)
├── ArticleListView     → Article feed with pagination and offline state
├── ArticleDetailView   → Full article detail with external link
└── ArticleStatusView   → Fullscreen empty and error states

ViewModels/
└── ArticleListViewModel → State management, pagination, cache coordination

Repository/
└── ArticleRepository   → Fetches and maps API responses to domain models

Networking/
├── NetworkService      → URLSession wrapper, HTTP and decoding
└── NetworkError        → Typed network error enum

Utilities/
├── AppError            → Maps NetworkError to user-facing messages
├── ArticleCacheService → UserDefaults-backed article cache
└── Environment         → Safe API key access from Info.plist
```

**Key decisions:**

- **`@Observable`** (iOS 17) instead of `ObservableObject` — eliminates the need for `@Published` on every property and reduces boilerplate
- **Protocol-based dependencies** — `ArticleRepositoryProtocol` and `NetworkServiceProtocol` are both abstracted behind protocols, making them straightforward to mock in tests
- **Typed error handling** — `NetworkError` is thrown by the network layer, `AppError` maps it to user-facing messages at the ViewModel level, keeping presentation logic out of networking code
- **Fail-fast networking** — `URLSession` is configured with a 10s request timeout and `waitsForConnectivity = false` so the app reports a network failure immediately instead of waiting for the system timeout
- **Separated cached state** — `isShowingCachedData` controls the auto-dismissing toast banner (4s), while `isShowingCachedContent` controls the persistent refresh button at the bottom of the list, keeping their lifecycles independent

---

## Features

- Article list with title, source name, and formatted publish date
- Infinite scroll with bottom loading indicator
- Pull-to-refresh
- Fullscreen error state with retry button
- Empty state
- Offline support — last successful response is cached and shown when offline, with a toast banner and a persistent refresh button at the bottom of the list
- Article detail with title, author, date, description, and a link to the full article in the system browser

---

## Testing

Unit tests cover `ArticleListViewModel` using `MockArticleRepository`:

- Successful load populates `articles` and clears `errorMessage`
- Failed load sets `errorMessage` and leaves `articles` empty

---

## What I Would Improve With More Time

**Firebase Crashlytics** — the app has no crash reporting. In a production environment this would be one of the first integrations to add for visibility into real-world failures.

**Deep links** — `myapp://article/{id}` is not implemented. This would require assigning stable IDs to articles (the API does not provide them), handling the URL scheme via `onOpenURL`, and navigating directly to the detail screen.

**Better cache** — `UserDefaults` works for this scope but has no expiry mechanism. A proper solution would use `SwiftData` with a TTL so cached data older than a defined threshold is automatically invalidated and not shown as fresh content.

---

## What I Intentionally Left Out

**Firebase** — initializing the SDK without using any of its features felt like unnecessary noise. Crashlytics would be the first real integration in a production project.

**Fastlane** — excluded as it requires provisioning profile configuration that is not meaningful without a real team setup.

**Pixel-perfect design and animations** — the UI follows standard iOS patterns but visual polish was intentionally deprioritized in favour of architecture and error handling.
