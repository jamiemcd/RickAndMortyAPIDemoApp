//
//  EpisodeRow.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/24/22.
//

import SwiftUI

struct EpisodeRow: View {
    
    let episode: Episode
    private(set) var action: (() -> Void)?
    
    var body: some View {
        Button {
            if let action = action { action() }
        } label: {
            HStack {
                Text(episode.code)
                    .padding(4)
                    .font(Font.callout.monospaced())
                    .foregroundColor(.white)
                    .frame(maxHeight: .infinity)
                    .background(codeColor)
                Text(episode.name)
                    .padding(.vertical, 4.0)
                Spacer()
            }
            
            
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var codeColor: Color {
        let season = episode.code.prefix { $0 != "E" }
        switch season {
        case "S01":
            return .pink
        case "S02":
            return .orange
        case "S03":
            return .yellow
        case "S04":
            return .mint
        case "S05":
            return .indigo
        default:
            return .cyan
        }
    }
}

struct EpisodeRow_Previews: PreviewProvider {
    static var previews: some View {
        let episode1 = Episode(id: 1, name: "Pilot", formattedAirDate: "12/2/2013", code: "S01E01", characters: [])
        let episode2 = Episode(id: 9, name: "Rick & Morty's Thanksploitation Spectacular", formattedAirDate: "7/25/2021", code: "S05E06", characters: [])
        Group {
            List {
                Section("Episodes") {
                    EpisodeRow(episode: episode1)
                    EpisodeRow(episode: episode2)
                }
            }
            .previewLayout(PreviewLayout.fixed(width: 320, height: 200))
            
            EpisodeRow(episode: episode2)
                .previewLayout(PreviewLayout.fixed(width: 320, height: 80))
        }
    }
}
