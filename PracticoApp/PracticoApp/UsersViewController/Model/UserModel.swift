//
//  User.swift
//  PracticoApp
//
//  Created by Fernando Gutiérrez on 13/03/24.
//

import Foundation

var usersArray: [UserModel] = []

struct UserModelResponse: Codable {
    let results: [UserModel]
}

struct UserModel: Codable {
    var gender: String
    var name: Name
    var location: Location
    var email: String
    let login: Login
    var phone, cell: String
    let picture: Picture
    let nat: String
}

struct Location: Codable {
    var street: Street
    var city, state, country: String
    var postcode: Int?
}

struct Street: Codable {
    var number: Int
    var name: String
}

struct Name: Codable {
    var title, first, last: String
}

struct Picture: Codable {
    let large, medium, thumbnail: String
}

struct Login: Codable {
    let uuid: String
}
