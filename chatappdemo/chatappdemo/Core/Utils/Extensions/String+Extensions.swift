//
//  String+Extensions.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

extension String {
    public func getNumbersOnly() -> String {
        self.filter("0123456789".contains)
    }
}
