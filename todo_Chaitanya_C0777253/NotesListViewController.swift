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

/// Protocol for Callback Functions to Add, Update and Delete a Note
protocol NoteCallBack {
    func NoteAddCallBack(title: String, description: String?, due: Date?, remindme: Bool)
    func NoteUpdateCallBack()
    func deleteNote(note: Notes)
}

/// Protocol for Callback Function to move Notes
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
    @IBOutlet weak var mSortButton: UIBarButtonItem!
    
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
    
    /// Function that checks Authorization for Event Use
    /// - Parameters:
    ///   - title: Title for the Event
    ///   - date: Date of the Event
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
    
    /// Sets the number of notes in label at the bottom of the screen
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
    
    /// Adds the Scretchy Header with Image
    func addNewView()
    {
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 250))
        headerView.imageView.image = UIImage(named: "header")
        self.mTableView.tableHeaderView = headerView
    }
    
    /// Loads All Notes for selected category in memory
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
    
    /// Loads All Notes with certain conditions for selected category in memory
    /// - Parameters:
    ///   - request: NSFetchRequest to fetch the data from Core Date
    ///   - predicate: Predicates to be applied on the Fetch Request
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
    
    /// Called when this View Controller is about to appear
    /// - Parameter animated: tells if the appearance is going to be animate
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        mNavigationBarShadowImage = self.navigationController?.navigationBar.shadowImage
        mNavigationBarIsTranslucent = self.navigationController?.navigationBar.isTranslucent
        mNavigationBarTintColor = self.navigationController?.navigationBar.tintColor
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        mNavigationTextAttributes = self.navigationController?.navigationBar.largeTitleTextAttributes
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        mSelectedNote = nil
    }
    
    /// Called when this View Controller is about to disappear
    /// - Parameter animated: tells if the disappearance is going to be animate
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = mNavigationBarShadowImage
        self.navigationController?.navigationBar.isTranslucent = mNavigationBarIsTranslucent
        self.navigationController?.navigationBar.tintColor = mNavigationBarTintColor
        self.navigationController?.navigationBar.largeTitleTextAttributes = mNavigationTextAttributes
    }
    
    /// Action Function for Move To Button. Adds Selected Rows in a array and shows the MoveToViewController
    /// - Parameter sender: Move To Button
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
    
    /// Action Function for Edit and Done Button. Toggles TableView between editing and not editing mode
    /// - Parameter sender: <#sender description#>
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
    
    /// Action Function for the Delete Button. Shows Confirmation Alert to delete the notes, if confirmed then deletes them
    /// - Parameter sender: Delete Button
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
    
    /// Saves the CoreData Data with Context
    func save() {
        do {
            try mContext.save()
            loadNotes()
            mTableView.reloadData()
        } catch {
            print("Error saving note \(error.localizedDescription) error: \(error)")
        }
    }
    
    /// Adds Search Bar in Navigation bar
    func showSearchBar() {
        mSearchController.obscuresBackgroundDuringPresentation = false
        mSearchController.searchBar.placeholder = "Search Notes"
        navigationItem.searchController = mSearchController
        mSearchController.searchBar.delegate = self
        mSearchController.searchBar.searchTextField.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.7)
        definesPresentationContext = true
    }
    
    /// Adds Events in Calendar
    /// - Parameters:
    ///   - store: EventStore to get Calendar
    ///   - title: Title of the Event
    ///   - date: Date of the Event
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
    
    /// Action Function for Sort Button. It toggles between Title ASC, Title DESC, Date ASC, Date DESC
    /// - Parameter sender: Sort Button
    @IBAction func sortTapped(_ sender: UIBarButtonItem)
    {
        if sender.tag == 0
        {
            mNotes.sort { (note1, note2) -> Bool in
                if note1.title! > note2.title!
                {
                    return true
                }
                return false
            }
            mCompletedNotes.sort { (note1, note2) -> Bool in
                if note1.title! > note2.title!
                {
                    return true
                }
                return false
            }
            mSortButton.title = "Title Desc"
            sender.tag += 1
        }
        else if sender.tag == 1
        {
            mNotes.sort { (note1, note2) -> Bool in
                if note1.created_date! < note2.created_date!
                {
                    return true
                }
                return false
            }
            mCompletedNotes.sort { (note1, note2) -> Bool in
                if note1.created_date! < note2.created_date!
                {
                    return true
                }
                return false
            }
            mSortButton.title = "Date Asc"
            sender.tag += 1
        }
        else if sender.tag == 2
        {
            mNotes.sort { (note1, note2) -> Bool in
                if note1.created_date! > note2.created_date!
                {
                    return true
                }
                return false
            }
            mCompletedNotes.sort { (note1, note2) -> Bool in
                if note1.created_date! > note2.created_date!
                {
                    return true
                }
                return false
            }
            mSortButton.title = "Date Desc"
            sender.tag += 1
        }
        else if sender.tag == 3
        {
            mNotes.sort { (note1, note2) -> Bool in
                if note1.title! < note2.title!
                {
                    return true
                }
                return false
            }
            mCompletedNotes.sort { (note1, note2) -> Bool in
                if note1.title! < note2.title!
                {
                    return true
                }
                return false
            }
            mSortButton.title = "Title Asc"
            sender.tag = 0
        }
        mTableView.reloadData()
    }
}

/// Extension to take control of Scrolling
extension NotesListViewController: UIScrollViewDelegate
{
    /// Called when Scroll View is scrolled. Used to change the tint and text color of navigation bar
    /// - Parameter scrollView: ScrollView that is being scrolled
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

/// Extension for Search bar delegate
extension NotesListViewController: UISearchBarDelegate {
    
    /// Called when the Search Button is clicked. Used to narrow the notes and reload table data
    /// - Parameter searchBar: Search bar for which this function is being called
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        let descpredicate = NSPredicate(format: "desc CONTAINS[cd] %@", searchBar.text!)
        loadNotes(predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [predicate,descpredicate]))
    }
    
    /// Called when text in search bar changes. Used to load all the notes in memory and reload table data when search bar is empty
    /// - Parameters:
    ///   - searchBar: Search Bar Object for which the text is changed
    ///   - searchText: Current text in search bar
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
    
    /// Called when cancel button of search bar is clicked. Used to load all the notes in memory and reload table data
    /// - Parameter searchBar: Search bar for which this function is being called
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadNotes()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        mTableView.reloadData()
    }
}

/// Extension for Note Call Back Functions
extension NotesListViewController: NoteCallBack
{
    
    /// Function to delete a particular Note
    /// - Parameter note: Note to be deleted
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
    
    /// Function to add a Note
    /// - Parameters:
    ///   - title: Title of the Note
    ///   - description: Description of the Note (optional)
    ///   - due: Due Date for the Note (optional)
    ///   - remindme: if the user has to be reminded or not
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
        mTableView.reloadData()
    }
    
    /// Function to update a note in CoreData
    func NoteUpdateCallBack() {
        if let cond = mSelectedNote?.completed, cond
        {
            mSelectedNote?.parentCategory = ViewController.mArchivedCategory
        }
        save()
    }
}

/// Extension for Table View Data Source and Table View Delegate
extension NotesListViewController:  UITableViewDataSource, UITableViewDelegate
{
    /// Function to get number of sections
    /// - Parameter tableView: TableView for which this
    /// - Returns: number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - section: <#section description#>
    /// - Returns: <#description#>
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
                if Calendar.current.isDate(mCurrentDate.addingTimeInterval(24*60*60), equalTo: date, toGranularity: .day)
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
        let addDate = UIContextualAction(style: .normal, title: "add day") { (action, view, completion) in
            if indexPath.section == 0
            {
                self.mNotes[indexPath.row].date = self.mNotes[indexPath.row].date?.addingTimeInterval(24*60*60)
            }
            else
            {
                self.mCompletedNotes[indexPath.row].date = self.mCompletedNotes[indexPath.row].date?.addingTimeInterval(24*60*60)
            }
            self.save()
            self.cellProperColor(indexpath: indexPath)
            completion(true)
        }
        moveNote.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        return UISwipeActionsConfiguration(actions: [moveNote, addDate])
    }
    
    func cellProperColor(indexpath: IndexPath)
    {
        let cell = mTableView.cellForRow(at: indexpath)
        if indexpath.section == 0
        {
            if let date = mNotes[indexpath.row].date
            {
                if date <= mCurrentDate
                {
                    cell?.backgroundColor = .red
                }
                else if Calendar.current.isDate(mCurrentDate.addingTimeInterval(24*60*60), equalTo: date, toGranularity: .day)
                {
                    cell?.backgroundColor = .green
                }
                else
                {
                    cell?.backgroundColor = .white
                }
            }
        }
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
