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
        NavigationStack {
            List(viewModel.filteredLocations) { location in
                LocationRow(location: location) {
                    viewModel.selectLocation(withID: location.id)
                }
            }
            .navigationTitle("Locations")
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
