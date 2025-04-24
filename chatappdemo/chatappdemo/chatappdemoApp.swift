//
//  chatappdemoApp.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 23/04/25.
//

import SwiftUI

@main
struct chatappdemoApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainRouteView()
        }
    }
}
