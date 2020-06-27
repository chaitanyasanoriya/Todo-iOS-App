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
    
    @IBAction func doneClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NoteDueViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mNotesString.count
    }
    
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
