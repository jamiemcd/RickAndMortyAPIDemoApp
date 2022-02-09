//
//  CharacterDetailView.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/4/22.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: Character
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        List {
            Section {
                VStack {
                    if let uiImage = viewModel.uiImage(for: character) {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                                .frame(maxWidth: 400)
                            Spacer()
                        }
                    }
                    else {
                        ProgressView()
                    }
                }
            }
            .listRowBackground(Color.clear)
            Section("Species") {
                Text(character.species)
            }
            Section("Gender") {
                Text(character.gender.rawValue)
            }
            if let type = character.type {
                Section("Type") {
                    Text(type)
                }
            }
            Section("Status") {
                Text(character.status.rawValue)
            }
            Section("Origin") {
                if let origin = character.origin {
                    Text(origin.name)
                }
                else {
                    Text("Unknown")
                }
            }
            Section("Last Known Location") {
                if let lastKnownLocation = character.lastKnownLocation {
                    Text(lastKnownLocation.name)
                }
                else {
                    Text("Unknown")
                }
            }
            Section("Episodes") {
                let episodes = viewModel.episodes(for: character.episodes)
                ForEach(episodes) { episode in
                    EpisodeRow(episode: episode) {
                        Task {
                            viewModel.selectTabView(.episodes)
                            viewModel.selectEpisode(withId: episode.id)
                        }
                    }
                }
            }
        }
        .navigationTitle(character.name)
    }
    

}


/*
struct CharacterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterDetailView()
    }
}
*/
