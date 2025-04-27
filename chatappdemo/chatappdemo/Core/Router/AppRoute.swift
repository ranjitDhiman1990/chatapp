//
//  AppRoute.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

enum AppRoute: Hashable, Identifiable {
    
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        return lhs.id == rhs.id
    }
    
    case OnboardingView
    case LoginView
    case PhoneLoginView
    case OTPView(phoneNumber: String, verificationID: String)
    case ChatListView(authUser: AuthUser)
    case ChatView(currentUser: AuthUser, otherUser: AuthUser, conversation: UserConversation?)
    case CompleteProfileView
    case EditProfileView
    
    var id: String {
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
