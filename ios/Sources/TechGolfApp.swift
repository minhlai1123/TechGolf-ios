import SwiftUI

@main
public struct TechGolfApp: App {
    @State private var isAuthenticated = false

    public init() {
        if AuthService().currentUserId != nil {
            _isAuthenticated = State(initialValue: true)
        }
    }

    public var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                CourseListView()
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
