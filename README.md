# Error Handling for SwiftUI

This microframework simplifies reporting errors in a SwiftUI application.

Simply add the `.withErrorHandler()` view modifier to a view:

```swift
import ErrorHandler

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MyView()
                .withErrorHandler()
        }
    }
}
```

This injects an `ErrorHandler` object into your view via the environment. You can then use the `ErrorHandler` instance's `perform` and `task` methods to report errors to the user via a modal alert.

```swift
struct MyView: View {
    @EnvironmentObject
    private var errorHandler: ErrorHandler

    var body: some View {
        ...
    }

    private func doSomethingThatCanFail() {
        errorHandler.perform {
            try functionThatCanThrow()
        }
    }

    private func doSomethingAsyncThatCanFail() {
        errorHandler.task {
            try await asyncFunctionThatCanThrow()
        }
    }
}
```

Note that if you present a view modally (using, for example, the `.sheet` or `.fullScreenCover` view modifiers), you will need to add `.withErrorHandler()` somewhere in the modally presented view tree. Otherwise, the underlying `.alert` will not be shown, as you cannot present a modal when a modal is already presented.

## Acknowledgements

Inspired by [this blog post](https://www.ralfebert.com/swiftui/generic-error-handling/).

