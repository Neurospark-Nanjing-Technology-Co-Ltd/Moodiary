//
//  UserModel.swift
//  GuiLai
//
//  Created by YI HE on 2024/9/11.
//

import Foundation
import SwiftData

@Model
final class UserModel {
    var email: String
    var password: String
    var token: String
    
    init(email: String, password: String, token: String) {
        self.email = email
        self.password = password
        self.token = token
    }
}
