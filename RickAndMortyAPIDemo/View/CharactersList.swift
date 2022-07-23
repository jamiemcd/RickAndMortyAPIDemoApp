//
//  CharactersList.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/2/22.
//

import SwiftUI

struct CharactersList: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    let cellWidth = CharactersGrid.cellWidth(for: geometry)
                    CharactersGrid(characters: viewModel.filteredCharacters, cellWidth: cellWidth, showEpisodeCount: true) { characterID in
                        viewModel.selectCharacter(withID: characterID)
                    }
                    .navigationTitle("Characters")
                }
            }
        }
        .tabItem {
            Label("Characters", systemImage: "person.3")
        }
    }
}


/*
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CharactersList()
    }
}
 */
