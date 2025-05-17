//
//  EventDetailViewController.swift
//  Eventio
//
//  Created by Om Lanke on 17/05/25.
//

import UIKit


class EventDetailViewController: UIViewController {
    
    var event: Event?
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let event = event {
            titleLabel.text = event.name
            dateLabel.text = formatDate(event.date)
            descriptionLabel.text = event.description
            loadImage(from: event.wideImage, into: eventImageView)
            if let ticketCollected = event.ticketCollected {
                if ticketCollected {
                    registerButton.setTitle("Registered", for: .normal)
                    registerButton.isEnabled = false
                }
            }
        }
    }
    
    private func formatDate(_ dateStr: String) -> String {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            guard let date = isoFormatter.date(from: dateStr) else { return dateStr }

            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, d MMM yyyy h:mm a"
            formatter.locale = Locale(identifier: "en_IN")
            formatter.timeZone = TimeZone.current
            return formatter.string(from: date)
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
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            return
        }
        
        guard let url = URL(string: "https://c8cd-2401-4900-8815-b3ed-40b0-901d-223d-f293.ngrok-free.app/events/register") else {
                print("Invalid URL")
                return
            }

        if let event = event {
            // Create the request body as a dictionary
            let parameters: [String: Any] = [
                "userId": userId,
                "eventId": event.id
            ]
            
            // Convert the parameters to JSON data
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                print("Failed to serialize JSON")
                return
            }
            
            // Create and configure the URLRequest
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = httpBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Perform the network request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Request error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }

                if (200...299).contains(httpResponse.statusCode) {
                    print("Successfully registered for event.")
                    DispatchQueue.main.async {
                        self.registerButton.setTitle("Registered", for: .normal)
                        self.registerButton.isEnabled = false
                        NotificationCenter.default.post(
                                name: NSNotification.Name("EventRegistered"),
                                object: nil,
                                userInfo: ["eventId": self.event?.id ?? ""]
                            )
                    }
                } else {
                    print("Server error with status code: \(httpResponse.statusCode)")
                }
            }

            task.resume()
        }
            
            
    }
    

}
