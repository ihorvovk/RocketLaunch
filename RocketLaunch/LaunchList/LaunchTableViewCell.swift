//
//  LaunchTableViewCell.swift
//  RocketLaunch
//
//  Created by Ihor Vovk on 5/1/19.
//  Copyright © 2019 Ihor Vovk. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift
import RxCocoa

protocol LaunchTableViewCellDelegate: class {
    func launchTableViewCell(_ cell: LaunchTableViewCell, didToggleFavorite isFavorite: Bool)
}

class LaunchTableViewCell: UITableViewCell {

    private(set) var launchID: Int?
    
    override func prepareForReuse() {
        thumbnailImageView.af_cancelImageRequest()
    }
    
    func fill(rocketLaunch: RocketLaunch, delegate: LaunchTableViewCellDelegate) {
        guard !rocketLaunch.isInvalidated else { return }
        
        launchID = rocketLaunch.id
        nameLabel.text = rocketLaunch.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        if let net = rocketLaunch.net {
            launchTimeLabel.text = dateFormatter.string(from: net)
        } else {
            launchTimeLabel.text = nil
        }
        
        countryLabel.text = rocketLaunch.country
        statusLabel.text = rocketLaunch.statusDescription
        
        launchTimeView.isHidden = !rocketLaunch.isFullyLoaded
        countryView.isHidden = !rocketLaunch.isFullyLoaded
        statusView.isHidden = !rocketLaunch.isFullyLoaded
        activityIndicatorView.isHidden = rocketLaunch.isFullyLoaded
        
        if let thumbnailURLString = rocketLaunch.rocket?.imageURL, let thumbnailURL = URL(string: thumbnailURLString) {
            thumbnailImageView.af_setImage(withURL: thumbnailURL) { [weak self] response in
                if response.error != nil {
                    self?.thumbnailImageView.image = UIImage(named: "rocket")
                }
            }
        } else {
            thumbnailImageView.image = UIImage(named: "rocket")
        }
        
        favoriteButton.isSelected = rocketLaunch.isFavorite
        
        self.delegate = delegate
    }
    
    // MARK: - Implementation
    
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var launchTimeView: UIStackView!
    @IBOutlet private weak var launchTimeLabel: UILabel!
    @IBOutlet private weak var countryView: UIStackView!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var statusView: UIStackView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var activityIndicatorView: UIView!
    
    private weak var delegate: LaunchTableViewCellDelegate?
    
    @IBAction private func toggleFavorite(sender: UIButton) {
        delegate?.launchTableViewCell(self, didToggleFavorite: !sender.isSelected)
    }
}
