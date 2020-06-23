//
//  ViewController.swift
//  todo_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 22/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    var mCategories = [Categories]()
    var mNotes = [Notes]()
    
    // create a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadCategories()
    }
    
    func loadCategories()
    {
        
        let request1: NSFetchRequest<Notes> = Notes.fetchRequest()
        do {
            mNotes = try context.fetch(request1)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        
        
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        do {
            mCategories = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
    func saveCategories() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving folders \(error.localizedDescription)")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mCategories.count
//        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "categoryCell")
        }
        cell?.textLabel?.text = mCategories[indexPath.row].category
        cell?.detailTextLabel?.text = getNumberOfNotes(category: mCategories[indexPath.row])
        return cell!
    }
    
    private func getNumberOfNotes(category: Categories) -> String
    {
        var num = 0
        for note in mNotes
        {
            if note.parentFolder == category
            {
                num += 1
            }
        }
        return "\(num)"
    }
    
    @IBAction func addTapped(_ sender: Any) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let category_names = self.mCategories.map {$0.category}
            guard !category_names.contains(textField.text) else {self.showAlert(); return}
            let new_category = Categories(context: self.context)
            new_category.category = textField.text!
            self.mCategories.append(new_category)
            self.saveCategories()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // change the font color of cancel action
        cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Category Name"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Name Taken", message: "Please choose another name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        okAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

