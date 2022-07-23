//
//  CharactersGrid.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 7/4/22.
//

import SwiftUI

struct CharactersGrid: View {
    var characters: [Character]
    var cellWidth = Constants.idealCellWidth
    var showEpisodeCount = false
    var selectCharacterHandler: ((_ characterID: Int) -> Void)?
    
    private struct Constants {
        static let idealCellWidth: CGFloat = 150
        static let cellSpacing: CGFloat = 6
    }
    
    var body: some View {
        let columns = [GridItem(.adaptive(minimum: cellWidth, maximum: cellWidth), spacing: Constants.cellSpacing, alignment: .top)]
        LazyVGrid(columns: columns) {
            ForEach(characters) { character in
                CharacterCell(character: character, imageHeight: cellWidth, showEpisodeCount: showEpisodeCount).onTapGesture {
                    if let selectCharacterHandler = selectCharacterHandler {
                        selectCharacterHandler(character.id)
                    }
                }
            }
        }
    }
    
    static func cellWidth(for geometry: GeometryProxy) -> CGFloat {
        let width = geometry.size.width - geometry.safeAreaInsets.leading - geometry.safeAreaInsets.trailing
        let columnCount = max(1, Int(width / Constants.idealCellWidth))
        let totalCellSpacing = CGFloat(columnCount - 1) * Constants.cellSpacing
        let cellWidth = floor((width - totalCellSpacing) / CGFloat(columnCount))
        return max(0, cellWidth)
    }
    
}


