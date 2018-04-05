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
import Crashlytics
import FirebaseDatabaseUI
import Firebase

class PoemHistoryViewController: UITableViewController, PoemCellDelegate {

    // MARK: Properties

    fileprivate let poemTableCellReuseIdentifier = "PoemCell"

    var poems: [Poem] = []

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Log Answers Custom Event.
        Answers.logCustomEvent(withName: "Viewed Poem History", customAttributes: nil)

        let myPoemsRef = Database.database().reference().child(Auth.auth().currentUser!.uid)
        let query = myPoemsRef.queryOrderedByKey()
        self.tableView.dataSource = self.tableView.bind(to: query) { tableView, indexPath, snapshot in
            // Dequeue cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            // Populate cell
            return cell
        }
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

    // MARK: UITableViewDataSource


    // MARK: PoemCellDelegate

    func poemCellWantsToSharePoem(_ poemCell: PoemCell) {
        // Find the poem displayed at this index path.
        let indexPath = tableView.indexPath(for: poemCell)
        let poem = poems[(indexPath?.row)!]

        // Generate the image of the poem.
        let poemImage = poemCell.capturePoemImage()

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
