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
        NavigationStack {
            List(viewModel.filteredEpisodes) { episode in
                EpisodeRow(episode: episode) {
                    viewModel.selectEpisode(withId: episode.id)
                }
            }
            .navigationTitle("Episodes")
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
