//
//  DetailCell.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/22/22.
//

import UIKit

class DetailCell: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    
    private var nameLabel: UILabel!
    private var firstLabel: PaddedLabel!
    private var firstValueLabel: UILabel!
    private var secondLabel: PaddedLabel!
    private var secondValueLabel: UILabel!
    private var thirdLabel: PaddedLabel!
    private var thirdValueLabel: UILabel!
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
                
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 16
        addSubview(stackView)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.textColor = .label
        stackView.addArrangedSubview(nameLabel)
        
        let createWrappedLabel: () -> (PaddedLabel, UILabel, UIView) = {
            let label = PaddedLabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            let valueLabel = UILabel()
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            valueLabel.numberOfLines = 0
            valueLabel.lineBreakMode = .byWordWrapping
            valueLabel.textColor = .label
            valueLabel.setContentCompressionResistancePriority(.defaultHigh + 2, for: .horizontal)
            // The UIView wrapper is needed for the UILabel to take up the full width.
            // See https://stackoverflow.com/questions/34386528/multiline-label-in-uistackview
            let valueLabelWrapperView = UIView()
            valueLabelWrapperView.translatesAutoresizingMaskIntoConstraints = false
            valueLabelWrapperView.addSubview(valueLabel)
            let stackView = UIStackView(arrangedSubviews: [label, valueLabelWrapperView])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.spacing = UIStackView.spacingUseSystem
            
            var constraints: [NSLayoutConstraint] = []
            constraints.append(valueLabel.leadingAnchor.constraint(equalTo: valueLabelWrapperView.leadingAnchor))
            constraints.append(valueLabel.trailingAnchor.constraint(equalTo: valueLabelWrapperView.trailingAnchor))
            constraints.append(valueLabel.topAnchor.constraint(equalTo: valueLabelWrapperView.topAnchor))
            constraints.append(valueLabel.bottomAnchor.constraint(equalTo: valueLabelWrapperView.bottomAnchor))
            NSLayoutConstraint.activate(constraints)
            
            return (label, valueLabel, stackView)
        }
                
        let (firstLabel, firstValueLabel, firstStackView) = createWrappedLabel()
        firstLabel.backgroundColor = .systemPurple
        self.firstLabel = firstLabel
        self.firstValueLabel = firstValueLabel
        stackView.addArrangedSubview(firstStackView)

        let (secondLabel, secondValueLabel, secondStackView) = createWrappedLabel()
        secondLabel.backgroundColor = .systemBlue
        self.secondLabel = secondLabel
        self.secondValueLabel = secondValueLabel
        stackView.addArrangedSubview(secondStackView)
        
        let (thirdLabel, thirdValueLabel, thirdStackView) = createWrappedLabel()
        thirdLabel.backgroundColor = .systemRed
        self.thirdLabel = thirdLabel
        self.thirdValueLabel = thirdValueLabel
        stackView.addArrangedSubview(thirdStackView)
        
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
    
    func configure(_ configuration: UIContentConfiguration) {
        guard let configuration = configuration as? DetailCellContentConfiguration else { return }
        
        nameLabel.text = configuration.name
        firstLabel.text = configuration.firstText
        firstValueLabel.text = configuration.firstValue
        secondLabel.text = configuration.secondText
        secondValueLabel.text = configuration.secondValue
        thirdLabel.text = configuration.thirdText
        thirdValueLabel.text = configuration.thirdValue
        
        nameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        firstLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        firstValueLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        secondLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        secondValueLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        thirdLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        thirdValueLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
    
}

struct DetailCellContentConfiguration: UIContentConfiguration {
    
    var name: String
    var firstText: String
    var firstValue: String
    var secondText: String
    var secondValue: String
    var thirdText: String
    var thirdValue: String
    
    func makeContentView() -> UIView & UIContentView {
        return DetailCell(self)
    }
    
    func updated(for state: UIConfigurationState) -> DetailCellContentConfiguration {
        return self
    }

}

private class PaddedLabel: UILabel {

    var contentInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInitializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInitializer()
    }

    private func sharedInitializer() {
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        textColor = .white
        layer.cornerRadius = 4
        clipsToBounds = true
        setContentHuggingPriority(.defaultHigh + 2, for: .horizontal)
        setContentHuggingPriority(.defaultHigh + 2, for: .vertical)
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: contentInsets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        return addInsets(to: super.intrinsicContentSize)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return addInsets(to: super.sizeThatFits(size))
    }

    private func addInsets(to size: CGSize) -> CGSize {
        let width = size.width + contentInsets.left + contentInsets.right
        let height = size.height + contentInsets.top + contentInsets.bottom
        return CGSize(width: width, height: height)
    }

}


