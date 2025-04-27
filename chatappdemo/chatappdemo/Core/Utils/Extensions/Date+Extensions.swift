//
//  Date+Extensions.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import Foundation

extension Date {
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
