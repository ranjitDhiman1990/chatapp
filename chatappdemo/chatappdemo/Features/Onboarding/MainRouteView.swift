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
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    if authViewModel.state.id == "authenticated" {
                        ChatListView().environmentObject(authViewModel)
                    } else {
                        switch router.currentScreen() {
                        case .LoginView:
                            LoginView().environmentObject(authViewModel)
                        case .PhoneLoginView:
                            PhoneLoginView().environmentObject(authViewModel)
                        case .OTPView:
                            OTPView().environmentObject(authViewModel)
                        case .ChatListView:
                            ChatListView().environmentObject(authViewModel)
                        default:
                            OnboardingView()
                        }
                    }
                }
            }
            .environmentObject(router)
            .onChange(of: authViewModel.state) { newState in
                switch newState {
                case .authenticated:
                    router.reset(to: .ChatListView)
                case .unauthenticated:
                    router.reset(to: .LoginView)
                default:
                    router.reset(to: .OnboardingView)
                    break
                }
            }
            .onAppear {
                authViewModel.checkCurrentUser()
            }
        } else {
            ZStack {
                if authViewModel.state.id == "authenticated" {
                    ChatListView().environmentObject(authViewModel)
                } else {
                    switch router.stack.last ?? .OnboardingView {
                    case .LoginView:
                        LoginView().environmentObject(authViewModel)
                    case .PhoneLoginView:
                        PhoneLoginView().environmentObject(authViewModel)
                    case .OTPView:
                        OTPView().environmentObject(authViewModel)
                    case .ChatListView:
                        ChatListView().environmentObject(authViewModel)
                    default:
                        OnboardingView().environmentObject(authViewModel)
                    }
                }
            }
            .environmentObject(router)
            .onChange(of: authViewModel.state) { newState in
                switch newState {
                case .authenticated:
                    router.reset(to: .ChatListView)
                case .unauthenticated:
                    router.reset(to: .LoginView)
                default:
                    router.reset(to: .OnboardingView)
                    break
                }
            }
            .onAppear {
                authViewModel.checkCurrentUser()
            }
        }
    }
}
