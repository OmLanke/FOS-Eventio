//
//  LoginVC.swift
//  Eventio
//
//  Created by Om Lanke on 16/05/25.
//

import UIKit

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginClicked(_ sender: Any) {
        guard let email = email.text, let password = password.text else { return }

        login(email: email, password: password)
    }
    
    func login(email: String, password: String) {
            guard let url = URL(string: "https://c8cd-2401-4900-8815-b3ed-40b0-901d-223d-f293.ngrok-free.app/auth/login") else {
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let parameters = ["email": email, "password": password]
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.showAlert("Error", message: error.localizedDescription)
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        self.showAlert("Error", message: "No response from server.")
                    }
                    return
                }

                if httpResponse.statusCode == 200 {
                    guard let data = data else {
                        DispatchQueue.main.async {
                            self.showAlert("Error", message: "No data received.")
                        }
                        return
                    }

                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let userId = json["id"] as? String, let userName = json["name"] as? String, let userEmail = json["email"] as? String {
                            // Save user ID
                            UserDefaults.standard.set(userId, forKey: "userId")
                            UserDefaults.standard.set(userName, forKey: "userName")
                            UserDefaults.standard.set(userEmail, forKey: "userEmail")
                            
                            // Present TabBarController on main thread
                            DispatchQueue.main.async {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as? UITabBarController {
                                    tabBarVC.modalPresentationStyle = .fullScreen
                                    self.present(tabBarVC, animated: true, completion: nil)
                                } else {
                                    self.showAlert("Error", message: "TabBarController not found.")
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert("Error", message: "Invalid server response.")
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.showAlert("Error", message: "Failed to parse response.")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert("Login Failed", message: "Invalid credentials.")
                    }
                }
            }
            task.resume()
        }
    
    func showAlert(_ title: String, message: String) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }

}
