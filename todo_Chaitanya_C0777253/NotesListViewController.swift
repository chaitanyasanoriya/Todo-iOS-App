//
//  NotesListViewController.swift
//  todo_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 22/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import CoreData
import EventKit

protocol NoteCallBack {
    func NoteAddCallBack(title: String, description: String?, due: Date?, remindme: Bool)
    func NoteUpdateCallBack()
    func deleteNote(note: Notes)
}

protocol NoteMove {
    func moveNotes(to category: Categories)
}

class NotesListViewController: UIViewController{
    
    
    @IBOutlet weak var mTableView: UITableView!
    var mNavigationBarShadowImage: UIImage!
    var mNavigationBarIsTranslucent: Bool!
    var mNavigationBarTintColor: UIColor!
    var mNotes = [Notes]()
    var mCompletedNotes = [Notes]()
    let mContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var mMoveToButton: UIButton!
    let mCurrentDate: Date = Date()
    @IBOutlet weak var mLabel: UILabel!
    @IBOutlet weak var mDeleteButton: UIButton!
    var mNavigationTextAttributes: [NSAttributedString.Key: Any]!
    let mSearchController = UISearchController(searchResultsController: nil)
    var mSelectedNote: Notes?
    var mIsEditing: Bool = false
    var mSelectedNotes = [Notes]()
    
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
    
    func addEvent(title: String, date: Date)
    {
        let eventStore = EKEventStore()
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized: insertEvent(store: eventStore, title: title, date: date)
        case .denied:
            print("Access denied")
        case .notDetermined:
            // 3
            eventStore.requestAccess(to: .event, completion:
                {[weak self] (granted: Bool, error: Error?) -> Void in
                    if granted {
                        self!.insertEvent(store: eventStore, title: title, date: date)
                    } else {
                        print("Access denied")
                    }
            })
        default:
            print("Case default")
        }
    }
    
    func setNumberOfNotes()
    {
        if mNotes.count == 1
        {
            mLabel.text = "1 note"
        }
        else
        {
            mLabel.text = "\(mNotes.count) notes"
        }
    }
    
    func addNewView()
    {
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 250))
        headerView.imageView.image = UIImage(named: "header")
        self.mTableView.tableHeaderView = headerView
    }
    
    func loadNotes() {
        mNotes = []
        let request: NSFetchRequest<Notes> = Notes.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parentCategory.category=%@", mSelectedCategory!.category!)
        let notComplete = NSPredicate(format: "completed == NO", "")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,notComplete])
        
        do {
            mNotes = try mContext.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
        
        mCompletedNotes = []
        let complete = NSPredicate(format: "completed == YES", "")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,complete])
        
        do {
            mCompletedNotes = try mContext.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
    }
    
    func loadNotes(with request: NSFetchRequest<Notes> = Notes.fetchRequest(), predicate: NSCompoundPredicate) {
        mNotes = []
        let categoryPredicate = NSPredicate(format: "parentCategory.category= %@", mSelectedCategory!.category!)
        let notComplete = NSPredicate(format: "completed == NO", "")
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate, notComplete])
        request.predicate = compoundPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        do {
            mNotes = try mContext.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
        
        mCompletedNotes = []
        let complete = NSPredicate(format: "completed == YES", "")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,complete, predicate])
        do {
            mCompletedNotes = try mContext.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
        
        mTableView.reloadData()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ndvc = segue.destination as? NoteDetailsViewController
        {
            ndvc.mNoteCallBack = self
            if mSelectedNote != nil
            {
                ndvc.mSelectedNote = mSelectedNote
            }
        }
        if let mtvc = segue.destination as? MoveToViewController
        {
            mtvc.mNoteMove = self
            mtvc.mOriginalCategory = mSelectedCategory
        }
    }
    
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
        mSelectedNote = nil
        
        //        loadNotes()
        //        mTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = mNavigationBarShadowImage
        self.navigationController?.navigationBar.isTranslucent = mNavigationBarIsTranslucent
        self.navigationController?.navigationBar.tintColor = mNavigationBarTintColor
        self.navigationController?.navigationBar.largeTitleTextAttributes = mNavigationTextAttributes
        
    }
    
    @IBAction func moveToTapped(_ sender: Any) {
        mSelectedNotes.removeAll()
        if let indexes = mTableView.indexPathsForSelectedRows
        {
            for index in indexes
            {
                if index.section == 0
                {
                    mSelectedNotes.append(mNotes[index.row])
                }
                else
                {
                    mSelectedNotes.append(mCompletedNotes[index.row])
                }
            }
            self.performSegue(withIdentifier: "moveTo", sender: self)
        }
    }
    
    @IBAction func mEditButtonTapped(_ sender: Any) {
        if mTableView.isEditing
        {
            mTableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: "mEditButtonTapped:")
            mMoveToButton.isHidden = true
            mDeleteButton.isHidden = true
            mIsEditing = false
        }
        else
        {
            mTableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: "mEditButtonTapped:")
            mMoveToButton.isHidden = false
            mDeleteButton.isHidden = false
            mIsEditing = true
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
                for indexpath in rows.reversed()
                {
                    var note: Notes
                    if indexpath.section == 0
                    {
                        note = self.mNotes.remove(at: indexpath.row)
                    }
                    else
                    {
                        note = self.mCompletedNotes.remove(at: indexpath.row)
                    }
                    self.mContext.delete(note)
                }
                self.save()
                self.mTableView.reloadData()
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
            print("Error saving note \(error.localizedDescription) error: \(error)")
        }
    }
    
    func showSearchBar() {
        
        mSearchController.obscuresBackgroundDuringPresentation = false
        mSearchController.searchBar.placeholder = "Search Notes"
        navigationItem.searchController = mSearchController
        mSearchController.searchBar.delegate = self
        mSearchController.searchBar.searchTextField.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.7)
        definesPresentationContext = true
    }
    
    func insertEvent(store: EKEventStore, title: String, date: Date) {
        let calendars = store.calendars(for: .event)
        
        for calendar in calendars {
            let startDate = date.addingTimeInterval(-24*60*60)
            let endDate = startDate.addingTimeInterval(1 * 60 * 60)
            let event = EKEvent(eventStore: store)
            event.calendar = calendar
            
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            do {
                try store.save(event, span: .thisEvent)
                print("saved in \(calendar.title)")
                break
            }
            catch {
                print("Error saving event in calendar")             }
        }
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
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        let descpredicate = NSPredicate(format: "desc CONTAINS[cd] %@", searchBar.text!)
        loadNotes(predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [predicate,descpredicate]))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0
        {
            loadNotes()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            mTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadNotes()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        mTableView.reloadData()
    }
}

extension NotesListViewController: NoteCallBack
{
    func deleteNote(note: Notes) {
        mNotes.removeAll { (Notes) -> Bool in
            return Notes == note
        }
        mCompletedNotes.removeAll { (Notes) -> Bool in
            return Notes == note
        }
        setNumberOfNotes()
        mContext.delete(note)
    }
    
    func NoteAddCallBack(title: String, description: String?, due: Date?, remindme: Bool) {
        let note = Notes(context: mContext)
        note.title = title
        note.parentCategory = mSelectedCategory
        note.desc = description
        note.created_date = Date()
        note.date = due
        note.remindme =  remindme
        note.completed = false
        save()
        if note.remindme, let date = note.date
        {
            addEvent(title: note.title!, date: date)
        }
    }
    
    func NoteUpdateCallBack() {
        save()
    }
}

extension NotesListViewController:  UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            setNumberOfNotes()
            return mNotes.count
        }
        else
        {
            return mCompletedNotes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "categoryCell")
        }
        if indexPath.section == 0
        {
            cell?.textLabel?.text = mNotes[indexPath.row].title
            cell?.detailTextLabel?.text = mNotes[indexPath.row].desc
            if  let date = mNotes[indexPath.row].date
            {
                if date <= mCurrentDate
                {
                    cell?.backgroundColor = .red
                }
                if Calendar.current.isDateInTomorrow(date)
                {
                    cell?.backgroundColor = .green
                }
            }
            else
            {
                cell?.backgroundColor = .white
            }
        }
        else
        {
            cell?.textLabel?.text = mCompletedNotes[indexPath.row].title
            cell?.detailTextLabel?.text = mCompletedNotes[indexPath.row].desc
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !mIsEditing
        {
            if indexPath.section  == 0
            {
                mSelectedNote = mNotes[indexPath.row]
            }
            else
            {
                mSelectedNote = mCompletedNotes[indexPath.row]
            }
            performSegue(withIdentifier: "NoteDetails", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1, mCompletedNotes.count > 0
        {
            return "Completed"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note: Notes
            if indexPath.section == 0
            {
                note = mNotes.remove(at: indexPath.row)
            }
            else
            {
                note = mCompletedNotes.remove(at: indexPath.row)
            }
            mContext.delete(note)
            save()
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let moveNote = UIContextualAction(style: .normal, title: "Move") { (action, view, completion) in
            self.mSelectedNotes.removeAll()
            if indexPath.section == 0
            {
                self.mSelectedNotes.append(self.mNotes[indexPath.row])
            }
            else
            {
                self.mSelectedNotes.append(self.mCompletedNotes[indexPath.row])
            }
            self.performSegue(withIdentifier: "moveTo", sender: self)
            completion(true)
        }
        moveNote.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        return UISwipeActionsConfiguration(actions: [moveNote])
    }
}

extension NotesListViewController: NoteMove
{
    func moveNotes(to category: Categories) {
        for note in mSelectedNotes
        {
            note.parentCategory = category
        }
        save()
        mTableView.reloadData()
    }
}
