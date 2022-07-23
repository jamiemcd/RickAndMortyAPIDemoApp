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
    var imageHeight: CGFloat = 120
    var showEpisodeCount = true
    
    var body: some View {
        VStack(alignment: .center) {
            if let uiImage = viewModel.uiImage(for: character) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(height: imageHeight)
            }
            else {
                Color.clear
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        ProgressView()
                    }
                    .frame(height: imageHeight)
            }
            VStack(alignment: .center) {
                Text(character.name)
                    .foregroundColor(.primary)
                    .font(.body)
                if showEpisodeCount {
                    let episodesCount = character.episodes.count
                    if episodesCount == 1 {
                        Text("1 episode").foregroundColor(.secondary).font(.subheadline)
                    }
                    else {
                        Text("\(episodesCount) episodes").foregroundColor(.secondary).font(.subheadline)
                    }
                }
            }
            .padding(.horizontal, 6.0)
            .multilineTextAlignment(.center)
        }
        .onAppear {
            if !character.hasLocalImage {
                viewModel.downloadImage(for: character)
            }
        }
    }
}
