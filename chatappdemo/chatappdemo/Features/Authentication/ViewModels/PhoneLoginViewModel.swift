//
//  PhoneLoginViewModel.swift
//  chatappdemo
//
//  Created by Abhishek on 25/04/25.
//

import Foundation

final class PhoneLoginViewModel: BaseViewModel {
    @Published var phoneNumber: String = "" {
        didSet {
            isPhoneNumberValid = validatePhoneNumber(phoneNumber)
        }
    }
    
    @Published var isPhoneNumberValid: Bool = false
    
    var countries: [Country]
    var currentCountry: Country
    
    override init() {
        let allCountries = JSONReader.readJSONFromFile(fileName: "Countries", type: [Country].self) ?? []
        var currentLocal = ""
        if #available(iOS 16, *) {
            currentLocal = Locale.current.region?.identifier ?? "IN"
        } else {
            currentLocal = Locale.current.identifier
        }
        self.countries = allCountries
        self.currentCountry = allCountries.first(where: {$0.isoCode == currentLocal}) ?? (allCountries.first ?? Country(name: "India", dialCode: "+91", isoCode: "IN"))
        
        super.init()
    }
    
    private func validatePhoneNumber(_ number: String) -> Bool {
        let trimmed = number.trimmingCharacters(in: .whitespacesAndNewlines)
        let digitsOnly = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: trimmed))
        return digitsOnly && trimmed.count == 10
    }
    
    func validateForm() -> Bool {
        if phoneNumber.isEmpty {
            showAlertFor(title: "Validation Error", message: "Enter a phone number")
            return false
        } else if !isPhoneNumberValid {
            showAlertFor(title: "Validation Error", message: "Enter a valid phone number")
            return false
        }
        return true
    }
}
