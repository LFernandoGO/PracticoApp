//
//  LogInViewController.swift
//  PracticoApp
//
//  Created by Fernando Gutiérrez on 13/03/24.
//

import UIKit

class LogInViewController: UIViewController {
    
    private let user = "Administrador"
    private let password = "Admin123"
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    var userIsValid = false
    var passwordIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.isEnabled = false
    }
    
    @IBAction func userTextEditingChanged(_ sender: UITextField) {
        userIsValid = userTextField.text == "" ? false : true
        changeButtonStatus()
    }
    
    @IBAction func passwordEditingChanged(_ sender: UITextField) {
        passwordIsValid = passwordTextField.text == "" ? false : true
        changeButtonStatus()
    }
    
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        if userTextField.text == user && passwordTextField.text == password {
            let usersViewController = UsersViewController(nibName: "UsersViewController", bundle: nil)
            usersViewController.userName = user
            self.navigationController?.pushViewController(usersViewController, animated: true)
        } else {
            let alert = UIAlertController(title: "No se pudo iniciar sesión", message: "El usuario o la contraseña son incorrectos, intentalo de nuevo", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "De acuerdo", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func changeButtonStatus() {
        logInButton.isEnabled = userIsValid && passwordIsValid ? true : false
    }
}


