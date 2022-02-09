//
//  CharactersList.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/2/22.
//

import SwiftUI

struct CharactersList: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            ScrollView {
                let columns = [GridItem(.adaptive(minimum: 150, maximum: 300), alignment: .top)]
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.filteredCharacters) { character in
                        if horizontalSizeClass == .compact {
                            // For horizontal compact, push the CharacterDetailView onto the navigation stack
                            NavigationLink {
                                CharacterDetailView(character: character)
                            } label: {
                                CharacterCell(character: character)
                            }
                        }
                        else {
                            // Present the CharacterDetailView as a sheet
                            let onDismiss = {
                                viewModel.deselectCharacter()
                            }
                            CharacterCell(character: character).onTapGesture {
                                viewModel.selectCharacter(withID: character.id)
                            }
                            .sheet(item: $viewModel.characterListSelection, onDismiss: onDismiss) {
                                character in
                                NavigationView {
                                    CharacterDetailView(character: character)
                                        .navigationBarTitleDisplayMode(.inline)
                                        .toolbar {
                                            Button("Done") {
                                                onDismiss()
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .searchable(text: $viewModel.charactersListSearchText)
            }
            .navigationTitle("Characters")
            Text("Select a character")
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
