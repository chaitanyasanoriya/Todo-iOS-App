//
//  NoteDetailsViewController.swift
//  todo_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 24/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

class NoteDetailsViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var mTitleTextField: UITextField!
    @IBOutlet weak var mDueDateButton: UIButton!
    @IBOutlet weak var mRemindMeSwitch: UISwitch!
    @IBOutlet weak var mDescTextView: UITextView!
    @IBOutlet weak var mCreatedDateLabel: UILabel!
    @IBOutlet weak var mCompletedButton: UIBarButtonItem!
    @IBOutlet weak var mDeleteButton: UIBarButtonItem!
    @IBOutlet weak var mSaveButton: UIBarButtonItem!
    
    var mSelectedNote: Notes?
    var mNoteCallBack: NoteCallBack!
    var mDueDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mSelectedNote == nil
        {
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.rightBarButtonItem = mSaveButton
            title = "New Note"
        }
        else
        {
            setData()
        }
        // Do any additional setup after loading the view.
    }
    
    /// Action Function  to Save or Update a note. Also performs Validations
    /// - Parameter sender: Save Button
    @IBAction func saveTapped(_ sender: Any) {
        var no_prob = false
        let title = mTitleTextField.text
        if (title != nil), (title != "")
        {
            if mSelectedNote != nil
            {
                mSelectedNote?.title = mTitleTextField.text
                var desc = mDescTextView.text
                if desc == "Add Description"
                {
                    desc = nil
                }
                mSelectedNote?.desc = desc
                mSelectedNote?.remindme = mRemindMeSwitch.isOn
                if let date = mDueDate
                {
                    mSelectedNote?.date = date
                }
                no_prob = checkReminder(remindme: mRemindMeSwitch.isOn, date: mSelectedNote?.date)
                if no_prob
                {
                    navigationController?.popViewController(animated: true)
                    mNoteCallBack.NoteUpdateCallBack()
                }
            }
            else
            {
                let title = mTitleTextField.text
                var desc = mDescTextView.text
                if desc == "Add Description"
                {
                    desc = nil
                }
                let remindme = mRemindMeSwitch.isOn
                no_prob = checkReminder(remindme: mRemindMeSwitch.isOn, date: mDueDate)
                if no_prob
                {
                    navigationController?.popViewController(animated: true)
                    mNoteCallBack.NoteAddCallBack(title: title!, description: desc, due: mDueDate, remindme: remindme)
                }
            }
        }
        else
        {
            showAlert(title: "Invalid Title", message: "Please enter a valid title for the note")
        }
    }
    
    /// Function to check if remind me is true and if so then due date is set
    /// - Parameters:
    ///   - remindme: if remind me is true
    ///   - date: due date
    /// - Returns: check if remind me is true and if so then due date is set
    func checkReminder(remindme: Bool, date: Date?) -> Bool
    {
        if remindme, date != nil
        {
            return true
        }
        if !remindme
        {
            return true
        }
        showAlert(title: "Due Date not Added", message: "Please add a due date for which you need to be reminded for")
        return false
    }
    
    /// Function to set Selected Note Data
    func setData()
    {
        mTitleTextField.text = mSelectedNote?.title
        if let date = mSelectedNote?.date
        {
            dateChanged(date: date)
        }
        mRemindMeSwitch.isOn = mSelectedNote!.remindme
        mDescTextView.text = mSelectedNote?.desc
        mCreatedDateLabel.text = "Created on "+formattedDate(date: mSelectedNote!.created_date!)
        if mSelectedNote!.completed
        {
            mCompletedButton.image = UIImage(systemName: "checkmark.circle.fill")
        }
    }
    
    /// Action Function for Complete Button. User completed a task
    /// - Parameter sender: Completed Button
    @IBAction func completedTapped(_ sender: Any) {
        mSelectedNote?.completed = !mSelectedNote!.completed
        mNoteCallBack.NoteUpdateCallBack()
        navigationController?.popViewController(animated: true)
    }
    
    /// Action Function for Add Due Date Button. Shows a Pop Over View to select a date
    /// - Parameter sender: Add Due Date Button
    @IBAction func addDueDateButtonTapped(_ sender: Any) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DatePopOverViewController") as! DatePopOverViewController
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: self.view.frame.width, height: 250)
        if let presentationController = vc.popoverPresentationController {
            presentationController.delegate = self
            presentationController.permittedArrowDirections = .up
            presentationController.sourceView = self.view
            presentationController.sourceRect = CGRect(x: 0, y: 200, width: 50, height: 50)
            vc.mDateCallBack = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    /// Action Function for Delete Button. To delete a Note
    /// - Parameter sender: Delete Button
    @IBAction func deletetapped(_ sender: Any) {
        mNoteCallBack.deleteNote(note: mSelectedNote!)
        navigationController?.popViewController(animated: true)
    }
    
    /// Function to set the Presentation style of PopOverView
    /// - Parameters:
    ///   - controller: Controller for which this function is being called for
    ///   - traitCollection: TraitCollection
    /// - Returns: Presentation style
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    /// Function to show Alert
    /// - Parameters:
    ///   - title: title of alert
    ///   - message: message of alert
    func showAlert(title: String, message: String?)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true,completion: nil)
    }
}

/// Protocol for date changed Callback function
protocol DateCallBack {
    func dateChanged(date: Date)
}

/// Extension for Date Change Callback
extension NoteDetailsViewController: DateCallBack
{
    /// When Due Date changed
    /// - Parameter date: due date
    func dateChanged(date: Date) {
        mDueDate = date
        self.mDueDateButton.setTitle(formattedDate(date: date), for: .normal)
    }
    
    /// Function to format date in a more user friendly manner
    /// - Parameter date: date to be formatted
    /// - Returns: formatted date
    func formattedDate(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        return dateFormatter.string(from: date)
    }
}

/// Class for Due Date PopOverView
class DatePopOverViewController: UIViewController
{
    var mDateCallBack: DateCallBack!
    
    @IBOutlet weak var mDoneButton: UIButton!
    var picker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker = UIDatePicker()
        picker.datePickerMode = UIDatePicker.Mode.date
        picker.minimumDate = Date()
        picker.addTarget(self, action: #selector(dueDateChanged), for: UIControl.Event.valueChanged)
        let pickerSize : CGSize = picker.sizeThatFits(CGSize.zero)
        picker.frame = CGRect(x: 0.0, y: 50, width: pickerSize.width, height: 230)
        // you probably don't want to set background color as black
        // picker.backgroundColor = UIColor.blackColor()
        self.view.addSubview(picker)
    }
    
    /// Function Call when Date Picker value changes
    /// - Parameter sender: Date Picker
    @objc func dueDateChanged(sender:UIDatePicker){
        mDateCallBack.dateChanged(date: sender.date)
    }
    
    /// Action Function for Done Button, sets last selected date as due date
    /// - Parameter sender: Done Button
    @IBAction func doneButtonTapped(_ sender: Any) {
        mDateCallBack.dateChanged(date: picker.date)
        dismiss(animated: true, completion: nil)
    }
}
