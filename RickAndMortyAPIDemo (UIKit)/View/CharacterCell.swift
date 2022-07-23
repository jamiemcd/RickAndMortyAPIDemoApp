//
//  CharacterCell.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/13/22.
//

import UIKit

class CharacterCell: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    
    private var stackView: UIStackView!
    private var imageView: UIImageView!
    private var nameLabel: UILabel!
    private var episodesLabel: UILabel!
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        addSubview(stackView)
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        stackView.addArrangedSubview(imageView)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor.label
        stackView.addArrangedSubview(nameLabel)
        
        episodesLabel = UILabel()
        episodesLabel.translatesAutoresizingMaskIntoConstraints = false
        episodesLabel.numberOfLines = 0
        episodesLabel.lineBreakMode = .byWordWrapping
        episodesLabel.textAlignment = .center
        episodesLabel.textColor = UIColor.secondaryLabel
        stackView.addArrangedSubview(episodesLabel)
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(stackView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(stackView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor))
        let maximumWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 400)
        maximumWidthConstraint.priority = .defaultHigh
        constraints.append(maximumWidthConstraint)
        NSLayoutConstraint.activate(constraints)
        
        configure(configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ configuration: UIContentConfiguration) {
        guard let configuration = configuration as? CharacterCellContentConfiguration else { return }
        if !configuration.character.hasLocalImage {
            configuration.viewModel.downloadImage(for: configuration.character)
        }
        if let uiImage = configuration.viewModel.uiImage(for: configuration.character) {
            imageView.image = uiImage
        }
        else {
            imageView.image = nil
        }
        nameLabel.text = configuration.character.name
        switch configuration.style {
        case .standard:
            stackView.spacing = UIStackView.spacingUseDefault
            imageView.layer.cornerRadius = 0
            nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
            episodesLabel.isHidden = true
        case .standardWithEpisodeCount:
            stackView.spacing = UIStackView.spacingUseDefault
            imageView.layer.cornerRadius = 0
            nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
            episodesLabel.isHidden = false
        case .large:
            stackView.spacing = UIStackView.spacingUseSystem
            imageView.layer.cornerRadius = 12
            nameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            episodesLabel.isHidden = true
        }
        if configuration.character.episodes.count == 1 {
            episodesLabel.text = "1 episode"
        }
        else {
            episodesLabel.text = "\(configuration.character.episodes.count) episodes"
        }
        episodesLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    }

}

struct CharacterCellContentConfiguration: UIContentConfiguration {
    var character: Character
    var viewModel: ViewModel
    var style: Style = .standard
    enum Style {
        case standard
        case standardWithEpisodeCount
        case large
    }
    
    func makeContentView() -> UIView & UIContentView {
        return CharacterCell(self)
    }
    
    func updated(for state: UIConfigurationState) -> CharacterCellContentConfiguration {
        return self
    }
    
    
}
