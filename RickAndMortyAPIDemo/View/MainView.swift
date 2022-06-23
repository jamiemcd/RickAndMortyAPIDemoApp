//
//  MainView.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/2/22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: ViewModel
        
    var body: some View {
        let onDismiss = {
            viewModel.removeRootModelItem()
        }
        TabView(selection: $viewModel.tabViewSelection) {
            CharactersList().tag(ViewModel.TabViewSelection.characters)
            LocationsList().tag(ViewModel.TabViewSelection.locations)
            EpisodesList().tag(ViewModel.TabViewSelection.episodes)
        }
        .task {
            await viewModel.getCharacters()
            await viewModel.getLocations()
            await viewModel.getEpisodes()
        }
        .searchable(text: $viewModel.searchText)
        .sheet(item: $viewModel.rootModelItem) { rootModelItem in
            NavigationStack(path: $viewModel.navigationPath) {
                Group {
                    switch rootModelItem {
                    case .character(let character):
                        CharacterDetailView(character: character)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                Button("Done") {
                                    onDismiss()
                                }
                            }
                    case .location(let location):
                        LocationDetailView(location: location)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                Button("Done") {
                                    onDismiss()
                                }
                            }
                    case .episode(let episode):
                        EpisodeDetailView(episode: episode)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                Button("Done") {
                                    onDismiss()
                                }
                            }
                    }
                }
                .navigationDestination(for: Character.self) { character in
                    CharacterDetailView(character: character)
                }
                .navigationDestination(for: Location.self) { location in
                    LocationDetailView(location: location)
                }
                .navigationDestination(for: Episode.self) { episode in
                    EpisodeDetailView(episode: episode)
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
