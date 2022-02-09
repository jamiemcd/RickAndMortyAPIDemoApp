//
//  LocationDetailView.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/23/22.
//

import SwiftUI

struct LocationDetailView: View {
    let location: Location
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        // List was causing the cells in the Characters section to be cut off for some episodes. Switching to Form fixed this.
        // It has something to do with the multiline Text in the CharacterCell and I think it is a SwiftUI bug.
        Form {
            Section("Type") {
                Text(location.type)
            }
            Section("Dimension") {
                Text(location.dimension)
            }
            Section("Residents") {
                let characters = viewModel.characters(for: location.residents)
                let columns = [GridItem(.adaptive(minimum: 120, maximum: 240), alignment: .top)]
                LazyVGrid(columns: columns) {
                    ForEach(characters) { character in
                        CharacterCell(character: character, showEpisodeCount: false)
                    }
                }
            }
        }
        .navigationTitle(location.name)
    }
}

/*
struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView()
    }
}
*/
