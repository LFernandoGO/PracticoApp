//
//  APIManager.swift
//  PracticoApp
//
//  Created by Fernando Gutiérrez on 13/03/24.
//

import Foundation

protocol APIManagerDelegate {
    func didFailWithError(error: Error)
    func didUpdateUserData(_ apiManager: APIManager, userModel: UserModel)
}

struct APIManager {
    var delegate: APIManagerDelegate?
    
    func fetchAPI() {
        let urlString = "https://randomuser.me/api/"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        // 1.- CREATE A URL
        if let url = URL(string: urlString) {
            // 2.- CREATE A URL SESSION OBJECT
            let session = URLSession(configuration: .default)
            
            // 3.- CREATE A TASK
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                }
                
                if let safeData = data {
                    if let user = self.parseJSON(safeData) {
                        self.delegate?.didUpdateUserData(self, userModel: user)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ userData: Data) -> UserModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(UserModelResponse.self, from: userData)
            if let user = decodedData.results.first {
                let gender = user.gender
                // Name
                let title = user.name.title
                let first = user.name.first
                let last = user.name.last
                // Location
                    // Street
                let number = user.location.street.number
                let name = user.location.street.name
                let city = user.location.city
                let state = user.location.state
                let country = user.location.country
                let postcode = user.location.postcode
                // Login
                let uuid = user.login.uuid
                // Contact
                let email = user.email
                let phone = user.phone
                let cell = user.cell
                // Picture
                let large = user.picture.large
                let medium = user.picture.medium
                let thumbnail = user.picture.thumbnail
                let nat = user.nat
                let user = UserModel(gender: gender, name: Name(title: title, first: first, last: last), location: Location(street: Street(number: number, name: name), city: city, state: state, country: country, postcode: postcode), email: email, login: Login(uuid: uuid), phone: phone, cell: cell, picture: Picture(large: large, medium: medium, thumbnail: thumbnail), nat: nat)
                return user
                
            } else {
                return nil
            }
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}



