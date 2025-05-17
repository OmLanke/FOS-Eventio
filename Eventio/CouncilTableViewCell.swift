//
//  CouncilTableViewCell.swift
//  Eventio
//
//  Created by Om Lanke on 18/05/25.
//

import UIKit

class CouncilTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var councilImageView: UIImageView!
    
    @IBOutlet weak var councilNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
                councilImageView.layer.cornerRadius = 30
                councilImageView.clipsToBounds = true

                containerView.layer.cornerRadius = 12
                containerView.layer.shadowColor = UIColor.black.cgColor
                containerView.layer.shadowOpacity = 0.1
                containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
                containerView.layer.shadowRadius = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with council: Council) {
            councilNameLabel.text = council.name
            if let url = URL(string: council.image) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.councilImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        }
    
}
