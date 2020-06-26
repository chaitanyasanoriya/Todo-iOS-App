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
    

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MoveToViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mCategories.count
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mNoteMove?.moveNotes(to: mCategories[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if mOriginalCategory === mCategories[indexPath.row]
        {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if mOriginalCategory === mCategories[indexPath.row]
        {
            return false
        }
        return true
    }
}
