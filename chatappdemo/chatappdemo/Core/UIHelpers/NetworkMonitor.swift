//
//  NetworkMonitor.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import SwiftUI
import Network

public class NetworkMonitor: ObservableObject {

    private var monitor: NWPathMonitor
    private let queue = DispatchQueue.global(qos: .background)

    @Published public var isConnected: Bool = true

    public init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
