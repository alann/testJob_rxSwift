//
//  ResisetrInput.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import Foundation

struct ResisetrInput: Codable {
    
    let lastName: String
    let firstName: String
    let middleName: String
    let email: String
    let password: String
    let confirmPassword: String
}
