//
//  OnboardRouteView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import SwiftUI

struct OnboardRouteView: View {
    
    @State var router = Router(root: AppRoute.OnboardingView)
    
    var body: some View {
        RouterView(router: router) { route in
            switch route {
            case .LoginView:
                LoginView()
            default:
                OnboardingView(router: router)
            }
        }
    }
}
