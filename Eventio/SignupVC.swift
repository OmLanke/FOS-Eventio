//
//  SignupVC.swift
//  Eventio
//
//  Created by Om Lanke on 16/05/25.
//

import UIKit

class SignupVC: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var name: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signupClicked(_ sender: Any) {
        guard let email = email.text, !email.isEmpty,
                      let password = password.text, !password.isEmpty,
                      let name = name.text, !name.isEmpty else {
                    showAlert(title: "Missing Info", message: "Please fill in all fields.")
                    return
                }

                guard let url = URL(string: "https://c8cd-2401-4900-8815-b3ed-40b0-901d-223d-f293.ngrok-free.app/auth/signup") else {
                    return
                }

                let parameters: [String: Any] = [
                    "email": email,
                    "password": password,
                    "name": name
                ]

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to encode signup data.")
                    }
                    return
                }

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Network Error", message: error.localizedDescription)
                        }
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: "Invalid server response.")
                        }
                        return
                    }

                    if httpResponse.statusCode == 200 {
                        guard let data = data else {
                            DispatchQueue.main.async {
                                self.showAlert(title: "Error", message: "No data received.")
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
                                
                                DispatchQueue.main.async {
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as? UITabBarController {
                                        tabBarVC.modalPresentationStyle = .fullScreen
                                        self.present(tabBarVC, animated: true, completion: nil)
                                    } else {
                                        self.showAlert(title: "Error", message: "TabBarController not found.")
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Error", message: "Invalid response format.")
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.showAlert(title: "Error", message: "Failed to parse response.")
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Signup Failed", message: "Status code: \(httpResponse.statusCode)")
                        }
                    }
                }

                task.resume()
            }


    func showAlert(title: String, message: String, onClose: (() -> Void)? = nil) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in onClose?() })
            present(alert, animated: true)
        }
}

