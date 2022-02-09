//
//  MainView.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/2/22.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.tabViewSelection) {
            CharactersList().tag(ViewModel.TabViewSelection.characters)
            LocationsList().tag(ViewModel.TabViewSelection.locations)
            EpisodesList().tag(ViewModel.TabViewSelection.episodes)
        }
        .navigationViewStyle(.stack)
        .environmentObject(viewModel)
        .task {
            await viewModel.getCharacters()
            await viewModel.getLocations()
            await viewModel.getEpisodes()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
