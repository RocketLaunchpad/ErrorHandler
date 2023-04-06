//
//  ErrorHandler.swift
//  ErrorHandler
//
//  Copyright (c) 2023 DEPT Digital Products, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import SwiftUI

internal struct IdentifiableError: Identifiable {
    var id = UUID()
    var error: Error
}

/// An `ErrorHandler` instance is injected into a view via the environment
/// after applying the `.withErrorHandler()` view modifier. You use the
/// `ErrorHandler` instance to report errors, as well as perform throwing blocks
/// and asynchronous tasks.
///
@MainActor
public final class ErrorHandler: ObservableObject {

    @Published
    internal var errorWrapper: IdentifiableError?

    /// Reports the specified error by presenting a modal alert.
    ///
    public func report(error: Error) {
        self.errorWrapper = IdentifiableError(error: error)
    }

    /// Performs the specified block directly and reports any errors that may
    /// occur.
    ///
    public func perform(_ block: () throws -> Void) {
        do {
            try block()
        }
        catch {
            report(error: error)
        }
    }

    /// Creates and starts a task to execute the specified asynchronous block
    /// and reports any errors that may occur.
    ///
    public func task(_ block: @escaping () async throws -> Void) {
        Task {
            do {
                try await block()
            }
            catch {
                report(error: error)
            }
        }
    }
}

private struct AlertErrorHandlerViewModifier: ViewModifier {
    @StateObject
    private var errorHandler = ErrorHandler()

    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandler)

            // You cannot have multiple alert modifiers on the same view. To
            // prevent us from clobbering an existing alert modifier on content,
            // we add an empty view to the background and attach the alert
            // there.
            //
            // See: https://sarunw.com/posts/how-to-show-multiple-alerts-on-the-same-view-in-swiftui/
            .background(
                EmptyView()
                    .alert(item: $errorHandler.errorWrapper) { errorWrapper in
                        Alert(
                            title: Text("Error"),
                            message: Text(errorWrapper.error.localizedDescription),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            )
    }
}

public extension View {
    /// Attaches an error handler to a view and injects it via the environment.
    ///
    func withErrorHandler() -> some View {
        modifier(AlertErrorHandlerViewModifier())
    }
}
