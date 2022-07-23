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
                        HStack(alignment: .top) {
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
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
                if let origin = character.origin, let location = viewModel.locations(for: [origin.id]).first {
                    LocationRow(location: location) {
                        viewModel.selectLocation(withID: location.id)
                    }
                    .rowWithDisclosureIndicator()
                }
                else {
                    Text("Unknown")
                }
            }
            Section("Last Known Location") {
                if let lastKnownLocation = character.lastKnownLocation, let location = viewModel.locations(for: [lastKnownLocation.id]).first {
                    LocationRow(location: location) {
                        viewModel.selectLocation(withID: location.id)
                    }
                    .rowWithDisclosureIndicator()
                }
                else {
                    Text("Unknown")
                }
            }
            Section("\(character.episodes.count) Episodes") {
                let episodes = viewModel.episodes(for: character.episodes)
                ForEach(episodes) { episode in
                    EpisodeRow(episode: episode) {
                        viewModel.selectEpisode(withId: episode.id)
                    }
                    .rowWithDisclosureIndicator()
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                }
            }
        }
    }
}

struct RowWithDisclosureIndicator: ViewModifier {
    func body(content: Content) -> some View {
        // This HStack with NavigationLink is needed to get the normal disclosure indicator indicating a push to the next screen.
        HStack(spacing: 0) {
            content.layoutPriority(1)
            NavigationLink("") { EmptyView() }.layoutPriority(0)
        }
    }
}

extension View {
    func rowWithDisclosureIndicator() -> some View {
        modifier(RowWithDisclosureIndicator())
    }
}

/*
struct CharacterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterDetailView()
    }
}
*/
