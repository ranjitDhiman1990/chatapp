//
//  UIApplication+Extensions.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
