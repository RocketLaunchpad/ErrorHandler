//
//  ContentView.swift
//  ErrorHandlerExample
//
//  Created by Paul Calnan on 4/5/23.
//

import ErrorHandler
import SwiftUI

struct ErrorMessage: Error, LocalizedError {
    var errorDescription: String?
}

struct ContentView: View {
    @EnvironmentObject
    private var errorHandler: ErrorHandler

    @State
    private var showingSheet = false

    var body: some View {
        VStack(spacing: 20) {
            Button("Raise error") {
                errorHandler.perform {
                    throw ErrorMessage(errorDescription: "An error was thrown")
                }
            }

            Button("Raise async error") {
                errorHandler.task {
                    try await Task.sleep(nanoseconds: 1000)
                    throw ErrorMessage(errorDescription: "An error was thrown")
                }
            }

            Button("Show sheet") {
                showingSheet = true
            }
        }
        .padding()
        .sheet(isPresented: $showingSheet) {
            SheetView()
                .withErrorHandler()
            // We have to attach another error handler to the modally-presented
            // sheet view. Otherwise, we get an error:
            //
            // "Attempt to present <...> on <...> (from <...>) which is already presenting <...>."
            // where "<...>" is a mangled Swift type identifier.
        }
    }
}

struct SheetView: View {
    @EnvironmentObject
    private var errorHandler: ErrorHandler

    var body: some View {
        Button("Raise error") {
            errorHandler.perform {
                throw ErrorMessage(errorDescription: "An error was thrown")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .withErrorHandler()
    }
}
