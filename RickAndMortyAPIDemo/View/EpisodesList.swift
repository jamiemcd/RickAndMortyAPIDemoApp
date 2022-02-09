//
//  EpisodesList.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/3/22.
//

import SwiftUI

struct EpisodesList: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.episodes) { episode in
                NavigationLink(tag: episode, selection: $viewModel.episodeListSelection) {
                    EpisodeDetailView(episode: episode)
                } label: {
                    VStack(alignment: .leading) {
                        Text(episode.name)
                        Text(episode.code)
                    }
                }
            }
            .navigationTitle("Episodes")
            Text("Select a location")
        }
        .tabItem {
            Label("Episodes", systemImage: "tv")
        }
    }
}

/*
struct EpisodesList_Previews: PreviewProvider {
    static var previews: some View {
        EpisodesList()
    }
}
 */
