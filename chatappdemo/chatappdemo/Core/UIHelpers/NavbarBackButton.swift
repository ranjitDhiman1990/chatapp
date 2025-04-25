//
//  NavbarBackButton.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 25/04/25.
//

import SwiftUI

struct NavbarBackButton: View {
    @EnvironmentObject var router: Router

    var body: some View {
        Button(action: {
            _ = router.pop()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                Text("Back")
                    .font(.body)
            }
        }
        .foregroundColor(.primary)
    }
}
