//
//  LocationRow.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 6/19/22.
//

import SwiftUI

struct LocationRow: View {
    
    let location: Location
    private(set) var action: (() -> Void)?
    
    var body: some View {
        Button {
            if let action = action { action() }
        } label: {
            Text(location.name)
        }

    }
}

struct LocationRow_Previews: PreviewProvider {
    static var previews: some View {
        let location1 = Location(id: 1, name: "Earth", type: "Planet", dimension: "Prime Dimension", residents: [1,2,3])
        LocationRow(location: location1)
    }
}
