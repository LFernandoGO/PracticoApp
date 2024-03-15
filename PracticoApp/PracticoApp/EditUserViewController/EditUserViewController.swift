//
//  EditUserViewController.swift
//  PracticoApp
//
//  Created by Fernando Gutiérrez on 14/03/24.
//

import UIKit

protocol EditUserViewControllerDelegate: AnyObject {
    func didUpdateUser(user: UserModel)
}

class EditUserViewController: UIViewController {
    // Boton
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var participantDateLabel: UILabel!
    // Outlets y banderas para datos del usuario
    @IBOutlet weak var userTitleTextField: UITextField!
    @IBOutlet weak var validTitleLabel: UILabel!
    var titleIsValid = false
    @IBOutlet weak var userFirstTextField: UITextField!
    @IBOutlet weak var validFirstLabel: UILabel!
    var firstIsValid = false
    @IBOutlet weak var userLastTextField: UITextField!
    @IBOutlet weak var validLastLabel: UILabel!
    var lastIsValid = false
    @IBOutlet weak var userCityTextField: UITextField!
    @IBOutlet weak var validCityLabel: UILabel!
    var cityIsValid = false
    @IBOutlet weak var userStateTextField: UITextField!
    @IBOutlet weak var validStateLabel: UILabel!
    var stateIsValid = false
    @IBOutlet weak var userCountryTextField: UITextField!
    @IBOutlet weak var validCountryLabel: UILabel!
    var countryIsValid = false
    @IBOutlet weak var userPostcodeTextField: UITextField!
    @IBOutlet weak var validPostcodeLabel: UILabel!
    var postcodeIsValid = false
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var validEmailLabel: UILabel!
    var emailIsValid = false
    
    
    // Variables necesarias
    var inactivityTimer: Timer?
    let timeOfInactivity: TimeInterval = 180 // 180 segundos de inactividad
    var lastActivity: Date?
    
    // Para acceder al indice del arreglo para editar el usuario
    var indexArray = 0
    
    // Delegado para modificar la tabla
    var user: UserModel?
    weak var delegate: EditUserViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Editar"
        saveChangesButton.isEnabled = false
        updateFooter()
        
        // Configurar las notificaciones de la aplicación
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundEntry), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // Detener el temporizador cuando el controlador de vista se destruya
    deinit {
        inactivityTimer?.invalidate()
    }
    
    // Para aplicar los cambios
    @IBAction func saveChangesButton(_ sender: UIButton) {
        user?.name.title = userTitleTextField.text ?? ""
        user?.name.first = userFirstTextField.text ?? ""
        user?.name.last = userLastTextField.text ?? ""
        user?.location.city = userCityTextField.text ?? ""
        user?.location.state = userStateTextField.text ?? ""
        user?.location.country = userCountryTextField.text ?? ""
        user?.location.postcode = Int(userPostcodeTextField.text!)
        user?.email = userEmailTextField.text ?? ""
        delegate?.didUpdateUser(user: user!)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func titleTextFieldEditingChanged(_ sender: UITextField) {
        if containsOnlyLetters(userTitleTextField.text) {
            validTitleLabel.textColor = .systemGreen
            titleIsValid = true
        } else {
            validTitleLabel.textColor = .red
            titleIsValid = false
        }
        changeSaveButton()
    }
    
    @IBAction func firstTextFieldEditingChanged(_ sender: UITextField) {
        if containsOnlyLetters(userFirstTextField.text) {
            validFirstLabel.textColor = .systemGreen
            firstIsValid = true
        } else {
            validFirstLabel.textColor = .red
            firstIsValid = false
        }
        changeSaveButton()
    }
    
    @IBAction func lastTextFieldEditingChanged(_ sender: UITextField) {
        if containsOnlyLetters(userLastTextField.text) {
            validLastLabel.textColor = .systemGreen
            lastIsValid = true
        } else {
            validLastLabel.textColor = .red
            lastIsValid = false
        }
        changeSaveButton()
    }
    
    @IBAction func cityTextFieldEditingChanged(_ sender: UITextField) {
        if containsOnlyLetters(userCityTextField.text) {
            validCityLabel.textColor = .systemGreen
            cityIsValid = true
        } else {
            validCityLabel.textColor = .red
            cityIsValid = false
        }
        changeSaveButton()
    }
    
    @IBAction func stateTextFieldEditingChanged(_ sender: UITextField) {
        if containsOnlyLetters(userStateTextField.text) {
            validStateLabel.textColor = .systemGreen
            stateIsValid = true
        } else {
            validStateLabel.textColor = .red
            stateIsValid = false
        }
        changeSaveButton()
    }
    
    @IBAction func countryTextFieldEditingChanged(_ sender: UITextField) {
        if containsOnlyLetters(userCountryTextField.text) {
            validCountryLabel.textColor = .systemGreen
            countryIsValid = true
        } else {
            validCountryLabel.textColor = .red
            countryIsValid = false
        }
        changeSaveButton()
    }
    
    @IBAction func postcodeTextFieldEditingChanged(_ sender: UITextField) {
        if isValidPostalCode(userPostcodeTextField.text) {
            validPostcodeLabel.textColor = .systemGreen
            postcodeIsValid = true
        } else {
            validPostcodeLabel.textColor = .red
            postcodeIsValid = false
        }
        changeSaveButton()
    }
    
    @IBAction func emailTextFieldEditingChanged(_ sender: UITextField) {
        if isValidEmail(userEmailTextField.text) {
            validEmailLabel.textColor = .systemGreen
            emailIsValid = true
        } else {
            validEmailLabel.textColor = .red
            emailIsValid = false
        }
        changeSaveButton()
    }
}

// MARK: - Validaciones
extension EditUserViewController {
    func containsOnlyLetters(_ text: String?) -> Bool {
        guard let text = text else { return false }

        // Expresión regular para validar si el texto contiene solo letras
        let lettersRegex = "^[a-zA-Z]+$"

        let lettersPredicate = NSPredicate(format: "SELF MATCHES %@", lettersRegex)
        return lettersPredicate.evaluate(with: text)
    }
    
    func isValidPostalCode(_ postalCode: String?) -> Bool {
        guard let postalCode = postalCode else { return false }

        // Expresión regular para validar un código postal de 5 dígitos
        let postalCodeRegex = "^[0-9]{5}$"

        let postalCodePredicate = NSPredicate(format: "SELF MATCHES %@", postalCodeRegex)
        return postalCodePredicate.evaluate(with: postalCode)
    }
    
    // Funcion para verificar la expresion regular del email
    func isValidEmail(_ email: String?) -> Bool {
        guard let email = email else { return false }

        // Expresión regular para validar el formato del email
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Habilitar el boton una vez que todos los campos sean validos
    func changeSaveButton() {
        saveChangesButton.isEnabled = titleIsValid && firstIsValid && lastIsValid && cityIsValid && stateIsValid && countryIsValid && postcodeIsValid && emailIsValid ? true : false
    }
}

// MARK: - Extensión para el manejo de cerrado de sesión por inactividad en segundo plano
extension EditUserViewController {
    // Función para manejar la entrada en segundo plano de la aplicación
    @objc func backgroundEntry() {
        lastActivity = Date()
    }
    
    // Función para manejar el regreso desde segundo plano de la aplicación
    @objc func returnFromBackground() {
        // Verificar si ha pasado tiempo desde la última actividad
        if let lastActivity = lastActivity, Date().timeIntervalSince(lastActivity) > timeOfInactivity {
            // Si ha pasado el tiempo de inactividad, mostrar la alerta y regresar a la vista de inicio de sesión
            showInactivityAlert()
        }
    }
    
    // Función para mostrar la alerta de inactividad
    @objc func showInactivityAlert() {
        let alertController = UIAlertController(title: "Alerta", message: "Ha pasado mucho tiempo sin actividad. Vuelva a iniciar sesión", preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Aceptar", style: .default) { _ in
            // Cerrar sesion
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(acceptAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Para el footer
extension EditUserViewController {
    func updateFooter() {
        let actualDate = Date() // Obtener la fecha y hora actual
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss" // Formato de fecha y hora deseado
        let dateText = dateFormatter.string(from: actualDate) // Convertir la fecha y hora actual a texto
        participantDateLabel.text = "Fernando Gutierrez: \(dateText)" // Asignar el texto al UILabel
    }
}


