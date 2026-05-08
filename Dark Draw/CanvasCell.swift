//
//  CanvasCell.swift
//  Dark Draw
//
//  Created by Shubham Kumar on 09/05/26.
//


import UIKit
import CoreData

class CanvasCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let previewView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        previewView.contentMode = .scaleAspectFit
        previewView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(previewView)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            previewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            previewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            previewView.heightAnchor.constraint(equalToConstant: 120),
            titleLabel.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(with canvas: CanvasModel) {
        titleLabel.text = canvas.title
        // Show the latest preview image from Core Data if available
        if let lastDesign = canvas.drawingsArray.last,
           let previewData = lastDesign.value(forKey: "previewImage") as? Data,
           let image = UIImage(data: previewData) {
            previewView.image = image
        } else {
            previewView.image = UIImage(systemName: "scribble")
        }
    }
}
