//
//  CouncilViewController.swift
//  Eventio
//
//  Created by Om Lanke on 18/05/25.
//

import UIKit

class CouncilViewController: UIViewController {
    
    @IBOutlet weak var councilTableView: UITableView!
    var councils: [Council] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "CouncilTableViewCell", bundle: nil)
            councilTableView.register(nib, forCellReuseIdentifier: "CouncilCell")
            councilTableView.delegate = self
            councilTableView.dataSource = self
            councilTableView.separatorStyle = .none
        
        fetchCouncils()
    }
    
    func fetchCouncils() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            return
        }
        
        guard let url = URL(string: "https://c8cd-2401-4900-8815-b3ed-40b0-901d-223d-f293.ngrok-free.app/events/councils") else { return }

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
                self.councils = try decoder.decode([Council].self, from: data)
                DispatchQueue.main.async {
                    self.councilTableView.reloadData()
                }
                print("COUNCILS - ", self.councils)
            } catch {
                print("❌ Decode error:", error.localizedDescription)
            }
        }
        task.resume()
    }
    
}

extension CouncilViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return councils.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CouncilCell", for: indexPath) as? CouncilTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: councils[indexPath.row])
        return cell
    }

    // Optional: spacing between cards
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12 // spacing between cells
    }
}
