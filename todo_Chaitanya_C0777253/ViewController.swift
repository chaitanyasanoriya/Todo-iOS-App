//
//  ViewController.swift
//  todo_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 22/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UITableViewController {
    
    static var mArchivedCategory: Categories!
    var mCategories = [Categories]()
    var mIndex: Int?
    var mNotesString = [String]()
    var mNotes = [Notes]()
    let mCurrentDate = Date()
    
    @IBOutlet var mTableView: UITableView!
    
    // create a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let mSearchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadCategories()
        showSearchBar()
        loadNotes()
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
    
    
    /// Gives the TableView cell for each indexpath
    /// - Parameters:
    ///   - tableView: TableView for which this function is being called
    ///   - indexPath: IndexPath for the Cell
    /// - Returns: Cell for IndexPath
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
    
    /// Action Function for Add Category button when Tapped
    /// - Parameter sender: Add Category Button
    @IBAction func addTapped(_ sender: Any) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let category_names = self.mCategories.map {$0.category}
            guard !category_names.contains(textField.text) else {self.showAlert(); return}
            if let title = textField.text, title != ""
            {
                let new_category = Categories(context: self.context)
                new_category.category = title
                self.mCategories.append(new_category)
                self.saveCategories()
            }
            else
            {
                self.showAlert(title: "Invalid Name", msg: "Please enter a valid name for category")
            }
            
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
    
    /// Shows Alert Dialog
    /// - Parameters:
    ///   - title: Title of Alert
    ///   - msg: Message of Alert
    func showAlert(title: String = "Name Taken", msg: String = "Please choose another name") {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        okAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// Called when a Row of Table View is Selected / Tapped
    /// - Parameters:
    ///   - tableView: Table View whose row is tapped
    ///   - indexPath: IndexPath of the row tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mIndex = indexPath.row
        performSegue(withIdentifier: "toNotesList", sender: self)
    }
    
    /// Called when a row is being editted
    /// - Parameters:
    ///   - tableView: TableView whose row is being editted
    ///   - editingStyle: Editing Style of the Row
    ///   - indexPath: IndexPath of the row being editted
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = mCategories[indexPath.row]
            context.delete(category)
            saveCategories()
            tableView.reloadData()
        }
    }
    
    /// Called when this View is going to appear
    /// - Parameter animated: Tells is the appearance is going to be animated
    override func viewWillAppear(_ animated: Bool) {
        mTableView.reloadData()
        mIndex = nil
    }
    
    /// Called when before segue is about to happen
    /// - Parameters:
    ///   - segue: Segue that is about to happen
    ///   - sender: Optional Object of sender
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNotesList", let nlvc = segue.destination as? NotesListViewController
        {
            nlvc.mSelectedCategory = mCategories[mIndex!]
        }
    }
    
    /// Adds the Search Bar in Navigation Bar
    func showSearchBar() {
        
        mSearchController.obscuresBackgroundDuringPresentation = false
        mSearchController.searchBar.placeholder = "Search Categories"
        navigationItem.searchController = mSearchController
        mSearchController.searchBar.delegate = self
        definesPresentationContext = true
    }
    
    /// Loads All the Categories with predicate to memory
    /// - Parameters:
    ///   - request: Request for data fetching
    ///   - predicate: Predicate to be applied
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
    
    /// Called when Search button or return is tapped. Used to narrow the categories and reload table data
    /// - Parameter searchBar: Search Bar Object
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "category CONTAINS[cd] %@", searchBar.text!)
        loadCategories(predicate: predicate)
        
    }
    
    /// Called when text in search bar changes. Used to load all the categories in memory and reload table data when search bar is empty
    /// - Parameters:
    ///   - searchBar: Search Bar Object for which the text is changed
    ///   - searchText: Current text in search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0
        {
            loadCategories()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    
    /// Called when cancel button of search bar is clicked. Used to load all the categories in memory and reload table data
    /// - Parameter searchBar: Search bar for which this function is being called
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadCategories()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        mTableView.reloadData()
    }
}


extension ViewController: UIPopoverPresentationControllerDelegate
{
    func showDueDateViewController()
    {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NoteDueViewController") as! NoteDueViewController
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: self.view.frame.width, height: 400)
        if let presentationController = vc.popoverPresentationController {
            presentationController.delegate = self
            presentationController.permittedArrowDirections = .up
            presentationController.sourceView = self.view
            presentationController.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            vc.mNotesString = mNotesString
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}


extension ViewController
{
    func loadNotes()
    {
        let request: NSFetchRequest<Notes> = Notes.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        do {
            mNotes = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        setupNotes()
    }
    
    func setupNotes()
    {
        for note in mNotes
        {
            if  let date = note.date, Calendar.current.isDate(mCurrentDate.addingTimeInterval(24*60*60), equalTo: date, toGranularity: .day)
            {
                mNotesString.append(note.title!)
            }
        }
        if mNotesString.count != 0
        {
            showDueDateViewController()
        }
    }
}
