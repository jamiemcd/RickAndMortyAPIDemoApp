//
//  LocationDetailView.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/23/22.
//

import SwiftUI

struct LocationDetailView: View {
    let location: Location
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text(location.name)
                            .font(.largeTitle)
                        DetailText(name: "Type", value: location.type, color: .purple)
                        DetailText(name: "Dimension", value: location.dimension, color: .blue)
                        DetailText(name: "Residents", value: "\(location.residents.count)", color: .red)
                    }
                    .padding()
                    let cellWidth = CharactersGrid.cellWidth(for: geometry)
                    let characters = viewModel.characters(for: location.residents)
                    CharactersGrid(characters: characters, cellWidth: cellWidth) { characterID in
                        viewModel.selectCharacter(withID: characterID)
                    }
                }
            }
        }
    }
}

/*
struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView()
    }
}
*/
