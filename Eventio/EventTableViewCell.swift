//
//  EventTableViewCell.swift
//  Eventio
//
//  Created by Om Lanke on 16/05/25.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var card: UIView!
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var taglineLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var councilImageView: UIImageView!
    
    @IBOutlet weak var councilNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        card.layer.cornerRadius = 8
        eventImageView.layer.cornerRadius = 8
        eventImageView.clipsToBounds = true
        councilImageView.layer.cornerRadius = councilImageView.frame.height / 2
        councilImageView.clipsToBounds = true
    }
    
    func configure(with event: Event) {
            titleLabel.text = event.name
            taglineLabel.text = event.tagline
            councilNameLabel.text = event.council.name
            dateLabel.text = formatDate(event.date)

            loadImage(from: event.image, into: eventImageView)
            loadImage(from: event.council.image, into: councilImageView)
        }
    
    private func loadImage(from urlStr: String, into imageView: UIImageView) {
            guard let url = URL(string: urlStr) else { return }
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    
    private func formatDate(_ dateStr: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: dateStr) else {
            return dateStr
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy h:mm a" // Example: Sat, 12 Jul 2025 3:30 PM
        formatter.locale = Locale(identifier: "en_IN") // Use "en_IN" for Indian style formatting
        formatter.timeZone = TimeZone.current // or use TimeZone(identifier: "Asia/Kolkata")

        return formatter.string(from: date)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
