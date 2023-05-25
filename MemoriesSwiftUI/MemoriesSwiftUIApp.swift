//
//  MemoriesSwiftUIApp.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import SwiftUI

let quickActionSettings = QuickActionVM()
var shortcutItemToProcess: UIApplicationShortcutItem?

@main
struct MemoriesSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var phase
    
    private var chapterVM = ChapterVM(moc: PersistenceController.shared.viewContext)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .environmentObject(chapterVM)
                .environmentObject(quickActionSettings)
                .onAppear {                
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    AppDelegate.orientationLock = .portrait
                }
        }
        .onChange(of: phase) { (newPhase) in
            switch newPhase {
            case .active :
                guard let name = shortcutItemToProcess?.userInfo?["name"] as? String else {
                    return
                }
                switch name {
                case "Private_mode":
                    quickActionSettings.enablePrivateMode()
                default:
                    print("default ")
                }
            case .inactive:
                print("App is inactive")
            case .background:
                print("App in Background")
                addQuickActions()
            @unknown default:
                print("default")
            }
        }
    }
    
    func addQuickActions() {
        var privateMode: [String: NSSecureCoding] {
            return ["name" : "Private_mode" as NSSecureCoding]
        }

        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(type: "Private_mode", localizedTitle: "Приватный режим", localizedSubtitle: "", icon: UIApplicationShortcutIcon(systemImageName: UI.Icons.eye_slash_fill), userInfo: privateMode),
        ]
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
       
    // MARK: - Device Orientation
    
    static var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    // MARK: - Quick actions
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            shortcutItemToProcess = shortcutItem
        }

        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self

        return sceneConfiguration
    }
    
//    // MARK: - NavigationBar
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        UINavigationBar.appearance().backgroundColor = UIColor(Color.cW)
//        return true
//    }
}
