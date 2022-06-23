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
            ScrollView {
                let columns = [GridItem(.adaptive(minimum: 150, maximum: 300), alignment: .top)]
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.filteredCharacters) { character in
                        CharacterCell(character: character).onTapGesture {
                            viewModel.selectCharacter(withID: character.id)
                        }
                    }
                }
                .navigationTitle("Characters")
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
