//
//  AppDelegate.swift
//  PaikRecipes
//
//  Created by Tars on 7/18/19.
//  Copyright © 2019 sspog. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Firebase Realtime Database
    private var ref: DatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Firebase Realtime Database 사용하기
        FirebaseApp.configure()

        print("App Launched")
        ref = Database.database().reference()

        ref.child("recipes").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot

                let foodName = snap.key
                let foodImage = UIImage(named: "eggRoll")
                let snapDictionary = snap.value as! NSDictionary
                let difficulty = snapDictionary["난이도"]! as! String
                var ingredientsName:[String] = []
                var ingredientsQuantity:[String] = []
                for (key, value) in snapDictionary["재료"] as! [String:String] {
                    ingredientsName.append(key)
                    ingredientsQuantity.append(value)
                }
                let recipeURL = snapDictionary["URL"] as! String

                let recipe:Recipe = Recipe(foodName: foodName, foodImage: foodImage!, difficulty: difficulty, ingredientsName: ingredientsName, ingredientsQuantity: ingredientsQuantity, recipeURL: recipeURL)

                dataCenter.recipe.append(recipe)
            }
        }) { (error) in
            print(error.localizedDescription)
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

