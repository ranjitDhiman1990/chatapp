//
//  LoginView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var router: Router
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.65), Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // App name
                Text("CHAT APP")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                // Additional section
                VStack(spacing: 25) {
                    Text("Start To Find Your Ideal Relationship")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 40)
                        .lineLimit(10)
                    
                    // Login options
                    VStack(spacing: 15) {
                        Button(action: {
                            isLoading = true
                            Task {
                                defer {
                                    isLoading = false
                                }
                                
                                do {
                                    try await viewModel.signInWithApple()
                                } catch {
                                    debugPrint("Apple login error = \(error.localizedDescription)")
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Continue with Apple")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                        }
                        
                        Button(action: {
                            isLoading = true
                            Task {
                                defer {
                                    isLoading = false
                                }
                                
                                do {
                                    try await viewModel.signInWithGoogle()
                                } catch {
                                    debugPrint("Google login error = \(error.localizedDescription)")
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                Text("Continue with Google")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                        }
                        
                        Button(action: {
                            self.router.push(.PhoneLoginView)
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Continue with Phone")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
        .overlay(LoaderView(isLoading: isLoading))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavbarBackButton()
            }
        }
    }
}
