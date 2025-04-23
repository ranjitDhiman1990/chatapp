//
//  OnboardingView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI

struct OnboardingView: View {
    @State var router = Router(root: AppRoute.OnboardingView)
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.65), Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("CHAT APP")
                    .font(.system(size: 36, weight: .bold))
                    .padding(.top, 50)
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Text("Chat with your loved ones")
                        .font(.system(size: 24, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Get Started button
                Button(action: {
                    self.router.push(.LoginView)
                }) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(25)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
