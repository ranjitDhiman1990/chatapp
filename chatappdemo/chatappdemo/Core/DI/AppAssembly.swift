//
//  AppAssembly.swift
//  chatappdemo
//
//  Created by Dhiman Ranjit on 24/04/25.
//

import Swinject

public class AppAssembly: Assembly {

    public init() { }

    public func assemble(container: Container) {

        container.register(AppPreference.self) { _ in
            AppPreference.init()
        }.inObjectScope(.container)
    }
}
