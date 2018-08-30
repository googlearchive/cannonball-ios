//
// Copyright (C) 2018 Google, Inc. and other contributors.
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
import Crashlytics
import Firebase
import FirebaseUI

class SignInViewController: UIViewController, UIAlertViewDelegate, FUIAuthDelegate {

    // MARK: Properties

    @IBOutlet weak var logoView: UIImageView!

    @IBOutlet weak var signInTwitterButton: UIButton!

    @IBOutlet weak var signInPhoneButton: UIButton!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIPhoneAuth(authUI: authUI!)
        ]
        authUI?.providers = providers

        // Color the logo.
        logoView.image = logoView.image?.withRenderingMode(.alwaysTemplate)
        logoView.tintColor = UIColor(red: 0, green: 167/255, blue: 155/255, alpha: 1)

        // Decorate the Sign In with Twitter and Phone buttons.
        let defaultColor = signInPhoneButton.titleLabel?.textColor
        decorateButton(signInPhoneButton, color: defaultColor!)

        // Add custom image to the Sign In with Phone button.
        let image = UIImage(named: "Phone")?.withRenderingMode(.alwaysTemplate)
        signInPhoneButton.setImage(image, for: UIControlState())
    }

    // MARK: IBActions


    @IBAction func signInWithPhone(_ sender: UIButton) {

        // Call Firebase UI Phone Auth
        let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as! FUIPhoneAuth
        phoneProvider.signIn(withPresenting:self, phoneNumber: nil)
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        switch error {
        case .some(let error as NSError) where UInt(error.code) == FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in")

        case .some(let error as NSError) where error.userInfo[NSUnderlyingErrorKey] != nil:
            print("Login error: \(error.userInfo[NSUnderlyingErrorKey]!)")

        case .some(let error):
            print("Login error: \(error.localizedDescription)")

        case .none:
            let userId : String = user!.uid
            Analytics.logEvent(AnalyticsEventLogin, parameters: [ "method": "phone"])
            Crashlytics.sharedInstance().setUserIdentifier(userId)
            let userDb = Firestore.firestore().collection("Users")
            userDb.document(userId).getDocument { (documentSnapshot, err) in
                if !documentSnapshot!.exists {
                    userDb.document(userId).setData([
                        "poems": []
                        ])
                }
            }
            DispatchQueue.main.async {
                // Navigate to the main app screen to select a theme.
                self.performSegue(withIdentifier: "ShowThemeChooser", sender: self)
            }
        }
    }

    @IBAction func skipSignIn(_ sender: AnyObject) {
        let anonAuthUI = FUIAuth.defaultAuthUI()!
        Auth.auth().signInAnonymously() { (authResult, error) in
            self.authUI(anonAuthUI, didSignInWith: authResult!.user, error: error)
        }
        Analytics.logEvent(AnalyticsEventLogin, parameters: [ "method": "anonymous"])

    }


    // MARK: Utilities

    fileprivate func decorateButton(_ button: UIButton, color: UIColor) {
        // Draw the border around a button.
        button.layer.masksToBounds = false
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 6
    }

}
