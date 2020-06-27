//
//  NoteDueViewController.swift
//  todo_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 26/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData

class NoteDueViewController: UIViewController
{
    
    var mNotesString = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// Action Function for Done Button, dismisses this view
    /// - Parameter sender: Done Button
    @IBAction func doneClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

/// Extension for Table Data Source and Delegate
extension NoteDueViewController: UITableViewDataSource, UITableViewDelegate
{
    /// Sets the number of rows in a section
    /// - Parameters:
    ///   - tableView: TableView for which this function is being called
    ///   - section: Index of Section
    /// - Returns: Number of rows in this section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mNotesString.count
    }
    
    /// Gives the TableView cell for each indexpath
    /// - Parameters:
    ///   - tableView: TableView for which this function is being called
    ///   - indexPath: IndexPath for the Cell
    /// - Returns: Cell for IndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "notecell")
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "notecell")
        }
        cell?.textLabel?.text = mNotesString[indexPath.row]
        return cell!
    }
    
    
}
