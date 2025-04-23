//
//  EmptyRouteView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import SwiftUI

public struct EmptyRouteView: View {

    let routeName: any View

    public init(routeName: any View) {
        self.routeName = routeName
    }

    public var body: some View {
        VStack(spacing: 0) {

        }
        .onAppear {
            print("\(routeName): Route view is not available.")
        }
    }
}
