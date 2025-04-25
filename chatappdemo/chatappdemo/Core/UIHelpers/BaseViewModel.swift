//
//  BaseViewModel.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import SwiftUI

@MainActor
open class BaseViewModel: ObservableObject {
    private(set) var showLoader: Bool = false
    
    @Published var networkMonitor = NetworkMonitor()
    @Published public var toast: ToastView?
    @Published public var alert: AlertPrompt = .init(message: "")
    @Published public var showAlert: Bool = false

    public init() {}

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Use this method when you want to show alert with title and message and default title is empty **""**.
    public func showAlertFor(title: String = "", message: String) {
        alert = .init(title: title, message: message)
        showAlert = true
    }

    /// This will take AlertPrompt as argument in which you can manage buttons and it's actions.
    public func showAlertFor(alert item: AlertPrompt) {
        alert = item
        showAlert = true
    }

    /// Use this method to show error toast and it will show toast with title **Error** and message.
    public func showToastForError() {
        if !networkMonitor.isConnected {
            showToastFor(toast: .init(type: .error, title: "Error", message: "No internet connection!"))
        } else {
            showToastFor(toast: .init(type: .error, title: "Error", message: "Something went wrong."))
        }
    }

    /// Use this method to show toast with custom specifications like title message and duration for toast.
    public func showToastFor(toast item: ToastView) {
        toast = item
    }
}
