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
        if case let .authenticated(user) = authViewModel.state {
            if router.currentScreen() == .OnboardingView {
                ChatListView(currentUser: user)
            } else {
                viewForCurrentRoute()
            }
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
        case .CompleteProfileView:
            CompleteProfileView().environmentObject(authViewModel)
        case .PhoneLoginView:
            PhoneLoginView().environmentObject(authViewModel)
        case .OTPView(let phoneNumber, let verificationID):
            OTPView(phoneNumber: phoneNumber, verificationID: verificationID)
                .environmentObject(authViewModel)
        case .EditProfileView:
            EditProfileView().environmentObject(authViewModel)
        case .ChatListView(let user):
            ChatListView(currentUser: user)
        case .ChatView(let currentUser, let otherUser, let conversation):
            ChatView(currentUser: currentUser, otherUser: otherUser, conversation: conversation)
        default:
            OnboardingView()
        }
    }
    
    private func handleAuthStateChange(_ newState: AuthState) {
        switch newState {
        case .authenticated(let user):
            router.reset(to: .ChatListView(authUser: user))
        case .incompleteProfile:
            router.reset(to: .CompleteProfileView)
        case .unauthenticated:
            router.reset(to: .LoginView)
        case .needsPhoneVerification(let phoneNumber, let verificationID):
            router.push(.OTPView(phoneNumber: phoneNumber, verificationID: verificationID))
        default:
            break
        }
    }
}
