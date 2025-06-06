//
//  HomeVC.swift
//  Eventio
//
//  Created by Om Lanke on 13/05/25.
//

import UIKit

// MARK: - Models

struct Council: Codable {
    let id: Int
    let name: String
    let tagline: String
    let image: String
}

struct Event: Codable {
    let id: Int
    let name: String
    let tagline: String
    let image: String
    let wideImage: String
    let description: String
    let date: String // Keep as String since you're not decoding to Date
    let councilId: Int
    let council: Council
    let ticketCollected: Bool? // Make optional to avoid crash

    enum CodingKeys: String, CodingKey {
        case id, name, tagline, image, description, date, council
        case wideImage = "wide_image"
        case councilId = "councilId"
        case ticketCollected = "ticket_collected"
    }
}

// MARK: - HomeVC

class HomeVC: UIViewController {
    
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    var events: [Event] = []
    var filteredEvents: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set name from UserDefaults
        if let userName = UserDefaults.standard.string(forKey: "userName") {
            nameLabel.text = userName
        }
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.rowHeight = 150
        eventsTableView.estimatedRowHeight = 150
        eventsTableView.separatorStyle = .none

        // TableView setup
        let nib = UINib(nibName: "EventTableViewCell", bundle: nil)
        eventsTableView.register(nib, forCellReuseIdentifier: "EventCell")
        
        
        // Fetch events from backend
        fetchEvents()
    }
    
    // MARK: - Fetch Events

    func fetchEvents() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            return
        }
        
        guard let url = URL(string: "https://c8cd-2401-4900-8815-b3ed-40b0-901d-223d-f293.ngrok-free.app/events/event?userId="+userId) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Fetch error:", error.localizedDescription)
                return
            }
            guard let data = data else {
                print("❌ No data received")
                return
            }
            do {
                let decoder = JSONDecoder()
                self.events = try decoder.decode([Event].self, from: data)
                DispatchQueue.main.async {
                    self.eventsTableView.reloadData()
                }
                print("EVENTS - ", self.events)
            } catch {
                print("❌ Decode error:", error.localizedDescription)
            }
        }
        task.resume()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("events.count = \(events.count)")
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? EventTableViewCell else {
            return UITableViewCell()
        }
        let event = events[indexPath.row]
        cell.configure(with: event)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "EventDetailVC") as? EventDetailViewController else {
            return
        }

        detailVC.event = event
        detailVC.modalPresentationStyle = .pageSheet // .formSheet or .fullScreen also works
        if let sheet = detailVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        present(detailVC, animated: true, completion: nil)
    }

}
