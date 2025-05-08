//
//  ASAuthorizationAppleIDCredential.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 08/05/25.
//

import Foundation
import AuthenticationServices

protocol AppleIDCredentialProtocol {
    var user: String { get }
    var email: String? { get }
    var identityToken: Data? { get }
    var fullName: PersonNameComponents? { get }
}

extension ASAuthorizationAppleIDCredential: AppleIDCredentialProtocol {}
