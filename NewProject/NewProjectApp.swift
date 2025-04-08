
import SwiftUI
import SwiftData

@main
struct NewProjectApp: App {
    var body: some Scene {
        WindowGroup {
            CategoryListView()
                .modelContainer(for: [Task.self, Category.self])
        }
    }
}
