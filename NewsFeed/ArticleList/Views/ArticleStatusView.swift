//
//  ArticleStatusView.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 2. 3. 2026..
//

import SwiftUI

struct ArticleStatusState {
    let icon: String
    let title: String
    let subtitle: String
    
    static let empty = ArticleStatusState(
        icon: "newspaper",
        title: "No articles found",
        subtitle: "Check back later for the latest news."
    )
    
    static func error(_ message: String) -> ArticleStatusState {
        ArticleStatusState(
            icon: "exclamationmark.circle",
            title: "Something went wrong",
            subtitle: message
        )
    }
}

struct ArticleStatusView: View {
    let state: ArticleStatusState
    let onRetry: () async -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer(minLength: 80)
                
                Image(systemName: state.icon)
                    .font(.system(size: 52))
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 8) {
                    Text(state.title)
                        .font(.headline)
                    
                    Text(state.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button("Retry") {
                    Task { await onRetry() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .refreshable {
            await onRetry()
        }
    }
}

