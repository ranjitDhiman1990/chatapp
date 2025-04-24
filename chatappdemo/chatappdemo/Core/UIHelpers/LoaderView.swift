//
//  LoaderView.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//


import SwiftUI

struct LoaderView: View {

    @StateObject var viewModel: LoaderViewModel = .init()

    private let tintColor: Color
    private let scaleEffect: Double

    init(tintColor: Color = .secondaryText, scaleEffect: Double = 1) {
        self.tintColor = tintColor
        self.scaleEffect = scaleEffect
    }

    var body: some View {
        ZStack {
            if viewModel.isStillLoading {
                ProgressView()
                    .scaleEffect(scaleEffect, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
            }
        }
        .onAppear(perform: viewModel.onViewAppear)
    }
}

public class LoaderViewModel: ObservableObject {
    private let MIN_WAIT_TIME: TimeInterval = 0.4

    @Published var isStillLoading: Bool = false

    var timer: Timer?

    public init() {}

    deinit {
        stopTimer()
        stopLoader()
    }

    func onViewAppear() {
        startLoader()
    }

    func startLoader() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: MIN_WAIT_TIME, repeats: false, block: { [weak self] _ in
            self?.isStillLoading = true
            self?.stopTimer()
        })
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func stopLoader() {
        isStillLoading = false
    }
}
