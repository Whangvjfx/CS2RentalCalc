import SwiftUI

@main
struct CS2RentalCalcApp: App {
    @StateObject private var store = SkinStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .tint(Theme.primary)
        }
    }
}
