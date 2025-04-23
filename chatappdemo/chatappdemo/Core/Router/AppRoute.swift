//
//  AppRoute.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

enum AppRoute: Hashable {
    
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        return lhs.key == rhs.key
    }
    
    case OnboardingView
    case LoginView
    case PhoneLoginView
    case OTPView
    case ChatListView
    case ChatView
    case CompleteProfileView
    case EditProfileView
    
    var key: String {
        switch self {
        case .OnboardingView:
            "OnboardingView"
        case .LoginView:
            "LoginView"
        case .PhoneLoginView:
            "PhoneLoginView"
        case .OTPView:
            "OTPView"
        case .ChatListView:
            "ChatListView"
        case .ChatView:
            "ChatView"
        case .CompleteProfileView:
            "CompleteProfileView"
        case .EditProfileView:
            "EditProfileView"
        }
    }
}
