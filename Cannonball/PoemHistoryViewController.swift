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

class PoemHistoryViewController: UITableViewController, PoemCellDelegate {

    // MARK: Properties

    fileprivate let poemTableCellReuseIdentifier = "PoemCell"

    var poems: [Poem] = []

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child(Auth.auth().currentUser!.uid).queryOrdered(byChild: Poem.SerializationKeys.inverseTimestamp).observe(.value, with: { snapshot in
            var newPoems: [Poem] = []
            for item in snapshot.children {
                let poem = Poem(fromSnapshot: item as! DataSnapshot)
                newPoems.append(poem)
            }

            self.poems = newPoems
            self.tableView.reloadData()
        })

        // Log Analytics custom event.
        Analytics.logEvent(AnalyticsEventViewItemList,
                           parameters: [AnalyticsParameterItemCategory: "history"])

        // Customize the navigation bar.
        navigationController?.navigationBar.topItem?.title = ""

        // Remove the poem composer from the navigation controller if we're coming from it.
        if let previousController: AnyObject = navigationController?.viewControllers[1] {
            if previousController.isKind(of: PoemComposerViewController.self) {
                navigationController?.viewControllers.remove(at: 1)
            }
        }

        // Add a table header and computer the cell height so they perfectly fit the screen.
        let headerHeight: CGFloat = 15
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: headerHeight))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Make sure the navigation bar is not translucent when scrolling the table view.
        navigationController?.navigationBar.isTranslucent = false

        // Display a label on the background if there are no poems to display.
        let noPoemsLabel = UILabel()
        noPoemsLabel.text = "You have not composed any poems yet."
        noPoemsLabel.textAlignment = .center
        noPoemsLabel.textColor = UIColor.cannonballGreenColor()
        noPoemsLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(14))
        tableView.backgroundView = noPoemsLabel
        tableView.backgroundView?.isHidden = true
        tableView.backgroundView?.alpha = 0
        toggleNoPoemsLabel()
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.width * 0.75
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.poems.count
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let poem = poems[indexPath.row]
            Analytics.logEvent(AnalyticsParameterItemCategory,
                               parameters: [AnalyticsParameterItemCategory: poem.theme])
            poem.ref?.removeValue()
            // We don't need to delete the poem from our local poems array
            // Because the callback method defined in viewDidLoad will automatically synchronize it
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let poem = poems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: poemTableCellReuseIdentifier) as! PoemCell
        cell.configureWithPoem(poem)
        cell.delegate = self
        return cell
    }

    // MARK: PoemCellDelegate

    func poemCellWantsToSharePoem(_ poemCell: PoemCell) {

        // Generate the image of the poem.
        let poemImage = poemCell.capturePoemImage()
        let poem = poemCell.poem!

        Analytics.logEvent(AnalyticsEventShare,
                           parameters: [AnalyticsParameterContentType: "poem_image",
                                        AnalyticsParameterItemCategory: poem.theme,
                                        "method": "native_share",
                                        "length": poem.words.count,
                                        "picture": poem.picture])
        let activityViewController = UIActivityViewController(activityItems: [poemImage], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }

    // MARK: Utilities

    fileprivate func toggleNoPoemsLabel() {
        if tableView.numberOfRows(inSection: 0) == 0 {
            UIView.animate(withDuration: 0.15, animations: {
                self.tableView.backgroundView!.isHidden = false
                self.tableView.backgroundView!.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.15,
                animations: {
                    self.tableView.backgroundView!.alpha = 0
                },
                completion: { finished in
                    self.tableView.backgroundView!.isHidden = true
                }
            )
        }
    }

}
