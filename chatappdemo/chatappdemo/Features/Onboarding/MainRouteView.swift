//
//  OnboardRouteView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import SwiftUI

struct MainRouteView: View {
    @StateObject private var authViewModel = AuthViewModel(authService: AuthService())
    @StateObject private var router = Router()
    
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    contentView
                }
            } else {
                ZStack {
                    contentView
                }
            }
        }
        .environmentObject(router)
        .onChange(of: authViewModel.state, perform: handleAuthStateChange)
        .onAppear {
            authViewModel.checkCurrentUser()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if authViewModel.state.id == "authenticated" {
            ChatListView().environmentObject(authViewModel)
        } else {
            viewForCurrentRoute()
        }
    }
    
    @ViewBuilder
    private func viewForCurrentRoute() -> some View {
        screenView(for: currentScreen())
    }

    private func currentScreen() -> AppRoute {
        if #available(iOS 16.0, *) {
            return router.currentScreen()
        } else {
            return router.stack.last ?? .OnboardingView
        }
    }

    @ViewBuilder
    private func screenView(for screen: AppRoute) -> some View {
        switch screen {
        case .LoginView:
            LoginView().environmentObject(authViewModel)
        case .PhoneLoginView:
            PhoneLoginView().environmentObject(authViewModel)
        case .OTPView(let phoneNumber, let verificationID):
            OTPView(phoneNumber: phoneNumber, verificationID: verificationID)
                .environmentObject(authViewModel)
        case .ChatListView:
            ChatListView().environmentObject(authViewModel)
        default:
            OnboardingView()
        }
    }
    
    private func handleAuthStateChange(_ newState: AuthState) {
        switch newState {
        case .authenticated:
            router.reset(to: .ChatListView)
        case .unauthenticated:
            router.reset(to: .LoginView)
        case .needsPhoneVerification(let phoneNumber, let verificationID):
            router.push(.OTPView(phoneNumber: phoneNumber, verificationID: verificationID))
        default:
            break
        }
    }
}
