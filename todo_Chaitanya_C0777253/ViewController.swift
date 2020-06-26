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
    
    static var mArchivedCategory: Categories!
    var mCategories = [Categories]()
    var mIndex: Int?
    @IBOutlet var mTableView: UITableView!
    
    // create a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let mSearchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadCategories()
        showSearchBar()
    }
    
    /// Loading All Categories in Memory
    func loadCategories()
    {
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true)]
        do {
            mCategories = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        tableView.reloadData()
        checkForArchived()
    }
    
    /// Checks if Archived Category already exists or not, if not then creates one
    func checkForArchived()
    {
        var notThere = true
        for category in mCategories
        {
            if category.category == "Archived"
            {
                ViewController.mArchivedCategory = category
                notThere = false
                break
            }
        }
        if notThere
        {
            print("creating new")
            let category = Categories(context: context)
            category.category = "Archived"
            ViewController.mArchivedCategory = category
            mCategories.append(category)
            saveCategories()
        }
    }
    
    /// Saves Categories in Core Data
    func saveCategories() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving folders \(error.localizedDescription)")
        }
    }
    
    /// Sets the number of rows in a section
    /// - Parameters:
    ///   - tableView: TableView for which this function is being called
    ///   - section: Index of Section
    /// - Returns: Number of rows in this section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mCategories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "categoryCell")
        }
        cell?.textLabel?.text = mCategories[indexPath.row].category
        cell?.detailTextLabel?.text = String(mCategories[indexPath.row].notes?.count ?? 0)
        return cell!
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mIndex = indexPath.row
        performSegue(withIdentifier: "toNotesList", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = mCategories[indexPath.row]
            context.delete(category)
            saveCategories()
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mTableView.reloadData()
        mIndex = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNotesList", let nlvc = segue.destination as? NotesListViewController
        {
            nlvc.mSelectedCategory = mCategories[mIndex!]
        }
    }
    
    func showSearchBar() {
        
        mSearchController.obscuresBackgroundDuringPresentation = false
        mSearchController.searchBar.placeholder = "Search Categories"
        navigationItem.searchController = mSearchController
        mSearchController.searchBar.delegate = self
        definesPresentationContext = true
    }
    
    func loadCategories(with request: NSFetchRequest<Categories> = Categories.fetchRequest(), predicate: NSPredicate? = nil) {
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true)]
        do {
            mCategories = try context.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "category CONTAINS[cd] %@", searchBar.text!)
        loadCategories(predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if searchBar.text?.count == 0
        {
            loadCategories()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}

