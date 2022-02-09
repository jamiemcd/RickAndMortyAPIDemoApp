//
//  LocationsList.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/3/22.
//

import SwiftUI

struct LocationsList: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.locations) { location in
                NavigationLink(tag: location, selection: $viewModel.locationListSelection) {
                    LocationDetailView(location: location)
                } label: {
                    Text(location.name)
                }
            }
            .navigationTitle("Locations")
            Text("Select a location")
        }
        .tabItem {
            Label("Locations", systemImage: "globe.americas")
        }
    }
}

/*
struct LocationsList_Previews: PreviewProvider {
    static var previews: some View {
        LocationsList()
    }
}
 */
