//
//  User.swift
//  MarketAppSystem
//
//  Created by Bilal Müftüoğlu on 16.04.2023.
//

import Foundation

class User{
    var name:String?
    var surname:String?
    var email:String?
    var profileImageURL:String?
    var balance:Double?
    
    init(name: String? = nil, surname: String? = nil, email: String? = nil, profileImageURL: String? = nil, balance: Double? = nil) {
        self.name = name
        self.surname = surname
        self.email = email
        self.profileImageURL = profileImageURL
        self.balance = balance
    }
}
