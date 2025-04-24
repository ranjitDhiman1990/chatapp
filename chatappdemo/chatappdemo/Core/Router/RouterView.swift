//
//  RouterView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import SwiftUI

class Router: ObservableObject {
    @Published public var stack: [AppRoute] = [.OnboardingView]

    func push(_ screen: AppRoute) {
        stack.append(screen)
    }

    func pop() -> AppRoute? {
        return stack.popLast()
    }

    func popTo(_ route: AppRoute) {
        if let index = stack.firstIndex(of: route) {
            stack = Array(stack.prefix(upTo: index + 1))
        }
    }

    func currentScreen() -> AppRoute {
        return stack.last!
    }
    
    func reset(to route: AppRoute) {
        stack = [route]
    }
}
