//
//  FirebaseManager.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import FirebaseCore
import FirebaseAuth

public class FirebaseManager {
    public static var auth: Auth = .auth()
    public static var phoneAuthProvider: PhoneAuthProvider = .provider()
    public static func configureFirebase() {
        FirebaseApp.configure()
    }
}
