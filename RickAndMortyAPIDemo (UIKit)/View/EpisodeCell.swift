//
//  EpisodeCell.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/18/22.
//

import UIKit

class EpisodeCell: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    
    private var stackView: UIStackView!
    private var codeLabel: UILabel!
    private var codeLabelBackgroundView: UIView!
    private var nameLabel: UILabel!
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        codeLabelBackgroundView = UIView()
        codeLabelBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(codeLabelBackgroundView)
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = UIStackView.spacingUseSystem
        addSubview(stackView)
        
        codeLabel = UILabel()
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeLabel.numberOfLines = 0
        codeLabel.lineBreakMode = .byWordWrapping
        codeLabel.textColor = UIColor.white
        codeLabel.setContentHuggingPriority(.required, for: .horizontal)
        codeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.addArrangedSubview(codeLabel)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.textColor = .link
        stackView.addArrangedSubview(nameLabel)
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1))
        constraints.append(trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1))
        constraints.append(stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1.5))
        constraints.append(bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1.5))
        NSLayoutConstraint.activate(constraints)
        
        configure(configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stackView.layoutIfNeeded()
        let point =  codeLabel.convert(CGPoint.zero, to: self)
        let width = point.x + codeLabel.bounds.maxX
        codeLabelBackgroundView.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
    }
        
    func configure(_ configuration: UIContentConfiguration) {
        guard let configuration = configuration as? EpisodeCellContentConfiguration else { return }
        
        codeLabel.text = configuration.episode.code
        let font = UIFont.preferredFont(forTextStyle: .callout)
        codeLabel.font = UIFont.monospacedSystemFont(ofSize: font.pointSize, weight: .regular)
        codeLabel.backgroundColor = codeColor(configuration.episode)
        nameLabel.text = configuration.episode.name
        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        codeLabelBackgroundView.backgroundColor = codeColor(configuration.episode)
    }
    
    func codeColor(_ episode: Episode) -> UIColor {
        let season = episode.code.prefix { $0 != "E" }
        switch season {
        case "S01":
            return .systemPink
        case "S02":
            return .systemOrange
        case "S03":
            return .systemYellow
        case "S04":
            return .systemMint
        case "S05":
            return .systemIndigo
        default:
            return .systemCyan
        }
    }
    
}

struct EpisodeCellContentConfiguration: UIContentConfiguration {
    
    var episode: Episode
    
    func makeContentView() -> UIView & UIContentView {
        return EpisodeCell(self)
    }
    
    func updated(for state: UIConfigurationState) -> EpisodeCellContentConfiguration {
        return self
    }
    
    
}
