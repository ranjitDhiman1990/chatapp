//
//  AuthUser.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import Foundation
import FirebaseAuth

struct AuthUser {
    let uid: String
    let email: String?
    let phoneNumber: String?
    let displayName: String?
    let photoURL: URL?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.displayName = user.displayName
        self.photoURL = user.photoURL
    }
}
