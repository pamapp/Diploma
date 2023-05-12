//
//  MemoriesSwiftUIApp.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import SwiftUI

@main
struct MemoriesSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(chapterViewModel: .init(moc: persistenceController.container.viewContext))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.light)
                .onAppear {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    AppDelegate.orientationLock = .portrait
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
        
    static var orientationLock = UIInterfaceOrientationMask.all //By default you want all your views to rotate freely

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
