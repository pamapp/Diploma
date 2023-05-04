//
//  MemoriesSwiftUIApp.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import SwiftUI

@main
struct MemoriesSwiftUIApp: App {
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

//    // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
//    // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
//    let homeView = HomeView(viewModel: HomeView.ViewModel())
//        .environment(\.managedObjectContext, context)
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(chapterViewModel: .init(moc: persistenceController.container.viewContext))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.light)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
        
    static var orientationLock = UIInterfaceOrientationMask.all //By default you want all your views to rotate freely

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
