//
//  EpisodeDetailView.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/23/22.
//

import SwiftUI

struct EpisodeDetailView: View {
    
    let episode: Episode
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text(episode.name)
                            .font(.largeTitle)
                        DetailText(name: "Code", value: episode.code, color: .purple)
                        DetailText(name: "Air Date", value: episode.formattedAirDate, color: .blue)
                        DetailText(name: "Characters Appearing", value: "\(episode.characters.count)", color: .red)
                    }
                    .padding()
                    
                    let cellWidth = CharactersGrid.cellWidth(for: geometry)
                    let characters = viewModel.characters(for: episode.characters)
                    CharactersGrid(characters: characters, cellWidth: cellWidth) { characterID in
                        viewModel.selectCharacter(withID: characterID)
                    }
                }
            }
        }
    }
        
}

/*
struct EpisodeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeDetailView()
    }
}
 */
