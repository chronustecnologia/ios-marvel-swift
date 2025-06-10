//
//  EmptyStateView.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import UIKit

class EmptyStateView: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    private var buttonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .gray
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(image: UIImage?, title: String, message: String, buttonTitle: String?, action: (() -> Void)?) {
        imageView.image = image
        titleLabel.text = title
        messageLabel.text = message
        
        if let buttonTitle = buttonTitle {
            actionButton.setTitle(buttonTitle, for: .normal)
            actionButton.isHidden = false
            self.buttonAction = action
        } else {
            actionButton.isHidden = true
            self.buttonAction = nil
        }
    }
    
    @objc private func buttonTapped() {
        buttonAction?()
    }
}
