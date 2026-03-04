//
//  ToastErrorMessage.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 4. 3. 2026..
//

import SwiftUI

struct ToastErrorMessage: View {
    let lastUpdated: Date?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text("Showing cached data")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)

                if let date = lastUpdated {
                    Text("Last updated \(date.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.orange.gradient, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

#Preview {
    ToastErrorMessage(lastUpdated: Date())
}
