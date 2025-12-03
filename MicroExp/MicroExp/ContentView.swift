//
//  ContentView.swift
//  MicroExp
//
//  Created by Vishal Paliwal on 03/12/25.
//

import SwiftUI

struct ComponentItem: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let addedAt: Date
    let destination: AnyView
}

struct ContentView: View {
    
    private var components: [ComponentItem] {
        [
            ComponentItem(
                name: "Heart Counter",
                symbol: "heart.fill",
                addedAt: Date(timeIntervalSince1970: 1_733_260_800), // 03 Dec 2025
                destination: AnyView(HeartCounterPreviewWrapper())
            ),
            ComponentItem(
                name: "Soft Switch",
                symbol: "switch.2",
                addedAt: Date(timeIntervalSince1970: 1_733_174_400), // 02 Dec 2025
                destination: AnyView(SoftSwitchPreviewWrapper())
            )
        ]
        .sorted { $0.addedAt > $1.addedAt }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("MicroExp Components (Newest)") {
                    ForEach(components) { item in
                        NavigationLink {
                            item.destination
                                .navigationTitle(item.name)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: item.symbol)
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(.primary)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.bar)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    
                                    Text(formatted(date: item.addedAt))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("MicroExp")
        }
    }
    
    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}


