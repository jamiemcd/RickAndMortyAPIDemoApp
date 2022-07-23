//
//  DetailText.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 7/11/22.
//

import SwiftUI

struct DetailText: View {
    let name: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(4)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(value)
                .font(.subheadline)
        }
    }
}

struct DetailText_Previews: PreviewProvider {
    static var previews: some View {
        DetailText(name: "Type", value: "Planet", color: .purple)
    }
}
