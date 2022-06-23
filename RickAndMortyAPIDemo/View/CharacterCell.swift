//
//  CharacterCell.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 2/5/22.
//

import SwiftUI

struct CharacterCell: View {
    @EnvironmentObject var viewModel: ViewModel
    let character: Character
    var showEpisodeCount = true
    
    var body: some View {
        VStack(alignment: .center) {
            if let uiImage = viewModel.uiImage(for: character) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            else {
                Color.clear
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        ProgressView()
                    }
            }
            VStack(alignment: .center) {
                Text(character.name)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                if showEpisodeCount {
                    let episodesCount = character.episodes.count
                    if episodesCount == 1 {
                        Text("1 episode").foregroundColor(.secondary)
                    }
                    else {
                        Text("\(episodesCount) episodes").foregroundColor(.secondary)
                    }
                }
            }
            .font(.body)
            .padding(.horizontal, 6.0)
        }
        .onAppear {
            if !character.hasLocalImage {
                viewModel.downloadImage(for: character)
            }
        }
    }
}
