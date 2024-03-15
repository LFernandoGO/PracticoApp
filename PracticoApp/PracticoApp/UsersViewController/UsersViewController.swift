//
//  UsersViewController.swift
//  PracticoApp
//
//  Created by Fernando Gutiérrez on 13/03/24.
//

import UIKit

class UsersViewController: UIViewController {
    
    // OUTLETS
    @IBOutlet weak var usersTableView: UITableView! {
        didSet {
            usersTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        }
    }
    @IBOutlet weak var participantDateLabel: UILabel!
    
    // Needed variables
    var inactivityTimer: Timer?
    let timeOfInactivity: TimeInterval = 180 // 180 segundos de inactividad
    var lastActivity: Date?
    var userName: String = "" // Nombre del usuario obtenido del LogIn
    var usersArray: [UserModel] = [] // Arreglo de usuarios
    
    // To access to the Network Manager
    var apiManager = APIManager()
    
    // Para acceder al controlador EditUserViewController
    let editUserViewController = EditUserViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Cargar elementos de la vista
        title = userName
        updateFooter()
        
        // Delegates
        apiManager.delegate = self
        usersTableView.delegate = self
        usersTableView.dataSource = self
        
        // Deshabilitar el botón de regreso del Navigation Bar
        self.navigationItem.hidesBackButton = true
        // Crear un boton de cerrado de sesion en su lugar
        let endSessionButton = UIBarButtonItem(title: "Cerrar sesión", style: .plain, target: self, action: #selector(endSession(_:)))
        self.navigationItem.rightBarButtonItem = endSessionButton
        
        // Configurar las notificaciones de la aplicación
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundEntry), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // Para hacer la consulta de la API
    @IBAction func getUserButton(_ sender: UIButton) {
        apiManager.fetchAPI()
    }
    
    // Funcion para cerrar sesion con boton
    @objc func endSession(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    // Detener el temporizador cuando el controlador de vista se destruya
    deinit {
        inactivityTimer?.invalidate()
    }
    
}

// MARK: - TableView Extensions
extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        let indexArray = usersArray[indexPath.row]
        cell.nameLabel.text = "Name: " + indexArray.name.title + " " + indexArray.name.first + " " + indexArray.name.last
        cell.genderLabel.text = "Gender: " + indexArray.gender
        cell.streetLabel.text = "State: " + indexArray.location.state
        cell.cityLabel.text = "City: " + indexArray.location.city
        cell.stateLabel.text = "State " + indexArray.location.state
        cell.countryLabel.text = "Country: " + indexArray.location.country
        cell.postcodeLabel.text = "Postcode: " + String(indexArray.location.postcode!)
        cell.emailLabel.text = "Email: " + indexArray.email
        cell.phoneLabel.text = "Phone: " + indexArray.phone
        cell.cellLabel.text = "Cell " + indexArray.cell
        cell.natLabel.text = "Nat: " + indexArray.nat
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = usersArray[indexPath.row] // Para obtener el usuario seleccionado
        let editUserViewController = EditUserViewController(nibName: "EditUserViewController", bundle: nil)
        editUserViewController.user = selectedUser
        editUserViewController.delegate = self
        self.navigationController?.pushViewController(editUserViewController, animated: true)
    }
}

// MARK: - Para actualizar datos en la tabla
extension UsersViewController: EditUserViewControllerDelegate {
    func didUpdateUser(user: UserModel) {
        if let index = usersArray.firstIndex(where: { $0.login.uuid == user.login.uuid }) {
            usersArray[index] = user
            // Recarga la fila correspondiente en la tabla
            usersTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}

// MARK: - Extensión para el manejo de cerrado de sesión por inactividad en segundo plano
extension UsersViewController {
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
extension UsersViewController {
    func updateFooter() {
        let actualDate = Date() // Obtener la fecha y hora actual
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss" // Formato de fecha y hora deseado
        let dateText = dateFormatter.string(from: actualDate) // Convertir la fecha y hora actual a texto
        participantDateLabel.text = "Fernando Gutierrez: \(dateText)" // Asignar el texto al UILabel
    }
}

// MARK: - APIManagerDelegate
extension UsersViewController: APIManagerDelegate {
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdateUserData(_ apiManager: APIManager, userModel: UserModel) {
        usersArray.append(UserModel(gender: userModel.gender, name: Name(title: userModel.name.title, first: userModel.name.first, last: userModel.name.last), location: Location(street: userModel.location.street, city: userModel.location.city, state: userModel.location.state, country: userModel.location.country, postcode: userModel.location.postcode), email: userModel.email, login: Login(uuid: userModel.login.uuid), phone: userModel.phone, cell: userModel.cell, picture: Picture(large: userModel.picture.large, medium: userModel.picture.medium, thumbnail: userModel.picture.thumbnail), nat: userModel.nat))
        DispatchQueue.main.async {
            self.usersTableView.reloadData()
        }
    }
}

