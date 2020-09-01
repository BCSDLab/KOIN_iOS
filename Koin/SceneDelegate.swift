//
//  SceneDelegate.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/08.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import Alamofire
import CryptoKit
import CryptoTokenKit
import Foundation
import UIKit



class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        
        // 유저 정보가 있는 오브젝트 생성 및 초기화
        //let settings = UserSettings()
        let config = UserConfig()
        // 첫 시작 화면 생성
        let startView = StartView()
        // 탭 정보가 있는 오브젝트 생성 및 초기화
        let viewRouter = ViewRouter(initialIndex: 1, customItemIndex: 2)
        
        setupRemoteConfigDefaults()
        fetchRemoteConfig()
        

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let window = UIWindow(windowScene: windowScene)
            // 상단바 색 변경을 위해 기존 UIHostingController에서 커스터마이징한 HostingController로 변경
            // 첫 시작 화면을 startView로 하고, 유저정보와 탭 정보를 같이 보내준다.
            window.rootViewController = UIHostingController(rootView: startView.environmentObject(viewRouter).environmentObject(config).environment(\.managedObjectContext, managedObjectContext))
            self.window = window
            window.makeKeyAndVisible()
            
            NotificationCenter.default.addObserver(self, selector: #selector(popToRoot(notification:)), name: Notification.Name("popToRoot"), object: nil)
        }
    }

    @objc func popToRoot(notification: NSNotification) {
        if let navigationController = self.findNavigationController(withinController: self.window!.rootViewController!) {
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    private func findNavigationController(withinController controller: UIViewController) -> UINavigationController? {
        for child in controller.children {
            if child is UINavigationController {
                return child as? UINavigationController
            } else {
                return findNavigationController(withinController: child)
            }
        }
        return nil
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func setupRemoteConfigDefaults() {
        let defaultValue = ["build_number": false as NSObject, "is_force_update":false as NSObject]
        remoteConfig.setDefaults(defaultValue)
    }
    
    func fetchRemoteConfig(){
        remoteConfig.fetch(withExpirationDuration: 0) { (status, error) in
            guard error == nil else { return }
            print("Got the value from Remote Config!")
            remoteConfig.activate()
            self.checkUpdate()
        }}
    
    func checkUpdate(){
        let updateBuildNumber = Int(truncating: remoteConfig.configValue(forKey: "build_number").numberValue ?? 0)
        let isForce = remoteConfig.configValue(forKey: "is_force_update").boolValue
        let currentBuildNumber = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        print("UpdateBuildNumber : \(updateBuildNumber)")
        print("currentBuildNumber : \(currentBuildNumber)")
        print("isForce : \(isForce)")
        
        var alertController = UIAlertController(title: "업데이트 알림", message: "새로운 업데이트가 있습니다.", preferredStyle: .alert)
        var okAction = UIAlertAction(title: "업데이트", style: UIAlertAction.Style.default) {
            UIAlertAction in
            let url: NSURL = URL(string: "https://apps.apple.com/us/app/id1500848622")! as NSURL
            UIApplication.shared.open(url as URL)
        }
        var cancelAction = UIAlertAction(title: "나중에", style: UIAlertAction.Style.destructive) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        
        if(updateBuildNumber > currentBuildNumber) {
            if(isForce) {
                alertController.addAction(okAction)
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            } else {
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
    }


}

struct StartView: View {
    //@EnvironmentObject var settings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var config: UserConfig
    
    
    var body: some View {
        // 만약 로그인이 되어있는 상태이면
        if self.config.isLogin {
            // 메인 화면으로 보여주고
            return AnyView(BetaContentView())
            
        } else { // 아니면
            // 로그인 페이지를 보여준다.
            return AnyView(LoginView().environmentObject(self.config))
        }
    }
}
