//
//  SceneDelegate.swift
//  CheckList
//
//  Created by Владислав on 20.01.2021.
//

import UIKit
import CoreData
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var dataStack: DataStack!
    private lazy var dbCommunicationService: DBCommunicationService = {
        let service = DBCommunicationService(dataStack: dataStack)
        service.unManager = unManager
        return service
    }()
    private lazy var unManager = UNManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        dataStack = (UIApplication.shared.delegate as! AppDelegate).dataStack
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.makeKeyAndVisible()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let _ = user {
                self.loadCheckListScreen()
                self.dbCommunicationService.start()
                
            } else {
                self.unManager.cancelAllNotifications()
                self.loadLoginScreen()
                self.dbCommunicationService.stop()
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.dataStack.saveContext()
    }


}

extension SceneDelegate {
    private func loadLoginScreen() {
        let storyboard = UIStoryboard(name: Globals.StoryboardNames.authentication,
                                      bundle: nil)
        guard let loginNavController = storyboard.instantiateInitialViewController() else {
            return
        }
        window?.rootViewController = loginNavController
    }
    
    private func loadCheckListScreen() {
        let storyboard = UIStoryboard(name: Globals.StoryboardNames.checkList,
                                      bundle: nil)
        guard let checkListNavController = storyboard.instantiateInitialViewController() as? UINavigationController,
              let checkListViewController = checkListNavController.viewControllers.first as? CheckListViewController else {
            return
        }
        checkListViewController.dataStack = dataStack
        checkListViewController.unManager = unManager
        window?.rootViewController = checkListNavController
    }
}

