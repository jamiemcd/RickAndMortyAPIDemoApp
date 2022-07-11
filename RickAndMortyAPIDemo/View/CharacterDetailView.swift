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
                VStack(spacing: 4) {
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
                    Text(character.name)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
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
                if let lastKnownLocation = character.lastKnownLocation, let location = viewModel.locations(for: [lastKnownLocation.id]).first {
                    // This is needed to get the normal disclosure indicator indicating a push to the next screen
                    ZStack(alignment: .leading) {
                        NavigationLink("") { EmptyView() }
                        LocationRow(location: location) {
                            viewModel.selectLocation(withID: location.id)
                        }
                    }
                }
                else {
                    Text("Unknown")
                }
            }
            Section("\(character.episodes.count) Episodes") {
                let episodes = viewModel.episodes(for: character.episodes)
                ForEach(episodes) { episode in
                    // This is needed to get the normal disclosure indicator indicating a push to the next screen
                    ZStack(alignment: .leading) {
                        NavigationLink("") { EmptyView() }
                        EpisodeRow(episode: episode) {
                            viewModel.selectEpisode(withId: episode.id)
                        }
                    }
                }
            }
        }
    }
    

}


/*
struct CharacterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterDetailView()
    }
}
*/
