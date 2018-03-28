//
// Copyright (C) 2017 Google, Inc. and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit
import MoPub
import Firebase
import FirebaseAuthUI
import FirebasePhoneAuthUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Developers: Welcome! Get started with Fabric.app.
        let welcome = "Welcome to Cannonball! Please onboard with the Fabric Mac app. Check the instructions in the README file."
        assert(Bundle.main.object(forInfoDictionaryKey: "Fabric") != nil, welcome)

        // Register Crashlytics, Twitter, Digits and MoPub with Fabric.
        Fabric.with([Crashlytics.self, Twitter.self, MoPub.self])
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let signInViewController: AnyObject! = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
                self.window?.rootViewController = signInViewController as? UIViewController
            }
        }
        return true;
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        return self.handleOpenUrl(url, sourceApplication: sourceApplication)
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.handleOpenUrl(url, sourceApplication: sourceApplication)
    }
    
    
    func handleOpenUrl(_ url: URL, sourceApplication: String?) -> Bool {
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }

}

