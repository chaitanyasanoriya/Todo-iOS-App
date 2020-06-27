//
//  MoveToViewController.swift
//  todo_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 26/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData

class MoveToViewController: UIViewController {

    @IBOutlet weak var mTableView: UITableView!
    
    var mCategories = [Categories]()
    let mContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var mNoteMove: NoteMove?
    var mOriginalCategory: Categories?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        // Do any additional setup after loading the view.
    }
    
    /// Function to load all categories in memory and to present
    func loadCategories()
    {
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true)]
        do {
            mCategories = try mContext.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
    }
    
    
    /// Action Function for Cancel Button. Dismisses this view
    /// - Parameter sender: Cancel button
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension MoveToViewController: UITableViewDelegate, UITableViewDataSource
{
    /// Sets the number of rows in a section
    /// - Parameters:
    ///   - tableView: TableView for which this function is being called
    ///   - section: Index of Section
    /// - Returns: Number of rows in this section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mCategories.count
    }
    
    /// Gives the TableView cell for each indexpath
    /// - Parameters:
    ///   - tableView: TableView for which this function is being called
    ///   - indexPath: IndexPath for the Cell
    /// - Returns: Cell for IndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        }
        cell?.textLabel?.text = mCategories[indexPath.row].category
        if mOriginalCategory === mCategories[indexPath.row]
        {
            cell!.textLabel!.text! += " (Original Category)"
        }
        return cell!
    }
    
    /// Called when a Row of Table View is Selected / Tapped
    /// - Parameters:
    ///   - tableView: Table View whose row is tapped
    ///   - indexPath: IndexPath of the row tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mNoteMove?.moveNotes(to: mCategories[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    
    /// Function to set if a row is selectable. Sets Original Category to be non selectable
    /// - Parameters:
    ///   - tableView: TableView for which this function is being called
    ///   - indexPath: indexpath of the row for which this function is called
    /// - Returns: IndexPath of selectable rows
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if mOriginalCategory === mCategories[indexPath.row]
        {
            return nil
        }
        return indexPath
    }
    
    /// Function to set if a row can be highlighted when tapped. Sets Original Category to be non Highlightable
    /// - Parameters:
    ///   - tableView: TableView for which this function is being called
    ///   - indexPath: indexpath of the row for which this function is called
    /// - Returns: if row at this indexpath is highlightable
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if mOriginalCategory === mCategories[indexPath.row]
        {
            return false
        }
        return true
    }
}
