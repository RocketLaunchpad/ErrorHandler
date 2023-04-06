//
//  ErrorHandlerExampleApp.swift
//  ErrorHandlerExample
//
//  Created by Paul Calnan on 4/5/23.
//

import ErrorHandler
import SwiftUI

@main
struct ErrorHandlerExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withErrorHandler()
        }
    }
}
