//
//  NotesListViewController.swift
//  todo_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 22/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData

class NotesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mTableView: UITableView!
    var mNavigationBarShadowImage: UIImage!
    var mNavigationBarIsTranslucent: Bool!
    var mNavigationBarTintColor: UIColor!
    var mNotes = [Notes]()
    let mContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var mMoveToButton: UIButton!
    let mCurrentDate: Date = Date()
    @IBOutlet weak var mLabel: UILabel!
    @IBOutlet weak var mDeleteButton: UIButton!
    var mNavigationTextAttributes: [NSAttributedString.Key: Any]!
    let mSearchController = UISearchController(searchResultsController: nil)
    let mWhiteImage = UIImage(named: "whitebackground")
    
    var mSelectedCategory: Categories?
    {
        didSet
        {
            self.title = mSelectedCategory?.category
            loadNotes()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewView()
        setNumberOfNotes()
        mTableView.allowsMultipleSelectionDuringEditing = true
        showSearchBar()
    }
    
    func setNumberOfNotes()
    {
        if mSelectedCategory?.notes?.count == 1
        {
            mLabel.text = "1 note"
        }
        else
        {
            mLabel.text = "\(mSelectedCategory?.notes?.count ?? 0) notes"
        }
    }
    
    func addNewView()
    {
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 250))
        headerView.imageView.image = UIImage(named: "header")
        self.mTableView.tableHeaderView = headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return mNotes.count
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "categoryCell")
        }
//        cell?.textLabel?.text = mNotes[indexPath.row].title
//        cell?.detailTextLabel?.text = mNotes[indexPath.row].desc
//        if  let date = mNotes[indexPath.row].date
//        {
//            if date >= mCurrentDate
//            {
//                cell?.backgroundColor = .red
//            }
//            if date < mCurrentDate, Calendar.current.date(byAdding: .day, value: -2, to: mCurrentDate)! < date
//            {
//                cell?.backgroundColor = .green
//            }
//        }
//        else
//        {
//            cell?.backgroundColor = .white
//        }
        cell?.textLabel?.text = "hello"
        cell?.detailTextLabel?.text = "hello"
//        let button = UIButton(type: .contactAdd)
//        button.tag = indexPath.row
//        button.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
//        cell?.accessoryView = button
        return cell!
    }
    
//    @objc func pressed(sender: UIButton!) {
//        print(sender.tag)
//    }
    
    func loadNotes() {
        let request: NSFetchRequest<Notes> = Notes.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parentCategory.category=%@", mSelectedCategory!.category!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.predicate = categoryPredicate

        do {
            mNotes = try mContext.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure the top constraint of the TableView/CollectionView/ScrollView is equal to Superview and not Safe Area
        mNavigationBarShadowImage = self.navigationController?.navigationBar.shadowImage
        mNavigationBarIsTranslucent = self.navigationController?.navigationBar.isTranslucent
        mNavigationBarTintColor = self.navigationController?.navigationBar.tintColor
        // Make the Navigation Bar background transparent
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        
        // Remove 'Back' text and Title from Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        mNavigationTextAttributes = self.navigationController?.navigationBar.largeTitleTextAttributes
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = mNavigationBarShadowImage
        self.navigationController?.navigationBar.isTranslucent = mNavigationBarIsTranslucent
        self.navigationController?.navigationBar.tintColor = mNavigationBarTintColor
        self.navigationController?.navigationBar.largeTitleTextAttributes = mNavigationTextAttributes
        
    }
    
    @IBAction func newNoteTapped(_ sender: Any) {
    }
    
    @IBAction func moveToTapped(_ sender: Any) {
    }
    
    @IBAction func mEditButtonTapped(_ sender: Any) {
        if mTableView.isEditing
        {
            mTableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: "mEditButtonTapped:")
            mMoveToButton.isHidden = true
            mDeleteButton.isHidden = true
        }
        else
        {
            mTableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: "mEditButtonTapped:")
            mMoveToButton.isHidden = false
            mDeleteButton.isHidden = false
        }
    }
    
    @IBAction func mDeleteButtontapped(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: nil, preferredStyle: .alert)
        let cancel_button = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        let delete_button = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            if let rows = self.mTableView.indexPathsForSelectedRows
            {
                self.mTableView.deleteRows(at: rows, with: .left)
                for indexpath in rows.reversed()
                {
                    self.mNotes.remove(at: indexpath.row)
                }
                self.save()
            }
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(cancel_button)
        alert.addAction(delete_button)
        
        present(alert, animated: true, completion: nil)
    }
    
    func save() {
        do {
            try mContext.save()
            loadNotes()
            mTableView.reloadData()
        } catch {
            print("Error saving folders \(error.localizedDescription)")
        }
    }
    
    func loadNotes(with request: NSFetchRequest<Notes> = Notes.fetchRequest(), predicate: NSPredicate) {
        let categoryPredicate = NSPredicate(format: "parentCategory.category=%@", mSelectedCategory!.category!)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
        request.predicate = compoundPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true)]
        do {
            mNotes = try mContext.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
        
        mTableView.reloadData()
    }
    
    func showSearchBar() {
        
        mSearchController.obscuresBackgroundDuringPresentation = false
        mSearchController.searchBar.placeholder = "Search Notes"
        navigationItem.searchController = mSearchController
        mSearchController.searchBar.delegate = self
        definesPresentationContext = true
    }
}

extension NotesListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerView = self.mTableView.tableHeaderView as! StretchyTableHeaderView
        headerView.scrollViewDidScroll(scrollView: scrollView)
        if scrollView.contentOffset.y > 5
        {
            self.navigationController?.navigationBar.tintColor = mNavigationBarTintColor
            self.navigationController?.navigationBar.largeTitleTextAttributes = mNavigationTextAttributes
        }
        else
        {
            self.navigationController?.navigationBar.tintColor = .white
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
}

extension NotesListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "category CONTAINS[cd] %@", searchBar.text!)
        loadNotes(predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if searchBar.text?.count == 0
        {
            loadNotes()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
