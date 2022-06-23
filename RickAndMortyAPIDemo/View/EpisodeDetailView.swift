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
        // List was causing the cells in the Characters section to be cut off for some episodes. Switching to Form fixed this.
        // It has something to do with the multiline Text in the CharacterCell and I think it is a SwiftUI bug.
        Form {
            Section("Code") {
                Text(episode.code)
            }
            Section("Air Date") {
                Text(episode.formattedAirDate)
            }
            Section("Characters") {
                let characters = viewModel.characters(for: episode.characters)
                let columns = [GridItem(.adaptive(minimum: 120, maximum: 240), alignment: .top)]
                LazyVGrid(columns: columns) {
                    ForEach(characters) { character in
                        CharacterCell(character: character, showEpisodeCount: false)
                            .onTapGesture {
                                viewModel.selectCharacter(withID: character.id)
                            }
                    }
                }
            }
        }
        .navigationTitle(episode.name)
    }
}

/*
struct EpisodeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeDetailView()
    }
}
 */
