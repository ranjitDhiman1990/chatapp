//
//  LoaderView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//


import SwiftUI

import SwiftUI

struct LoaderView: View {
    var isLoading: Bool

    var body: some View {
        ZStack {
            if isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
    }
}
