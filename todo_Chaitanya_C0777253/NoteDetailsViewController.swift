//
//  NoteDetailsViewController.swift
//  todo_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 24/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

class NoteDetailsViewController: UIViewController {

    @IBOutlet weak var mTitleTextField: UITextField!
    @IBOutlet weak var mDueDateButton: UIButton!
    @IBOutlet weak var mRemindMeSwitch: UISwitch!
    @IBOutlet weak var mDescTextView: UITextView!
    @IBOutlet weak var mCreatedDateLabel: UILabel!
    @IBOutlet weak var mCompletedButton: UIBarButtonItem!
    
    var mSelectedNote: Notes?
    var mNoteCallBack: NoteCallBack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mSelectedNote == nil
        {
            self.navigationItem.rightBarButtonItems = nil
            title = "New Note"
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func completedTapped(_ sender: Any) {
        
    }
    @IBAction func remindMeValueChanged(_ sender: Any) {
    }
    @IBAction func addDueDateButtonTapped(_ sender: Any) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let title = mTitleTextField.text
        if (title != nil), (title != "")
        {
            if mSelectedNote != nil
            {
                
            }
            else
            {
                
            }
        }
    }
    
    @IBAction func deletetapped(_ sender: Any) {
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
