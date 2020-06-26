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
    
    var mSelectedNote: Notes?
    var mNoteCallBack: NoteCallBack!
    var mDueDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mSelectedNote == nil
        {
            self.navigationItem.rightBarButtonItems = nil
            title = "New Note"
        }
        else
        {
            setData()
        }
        // Do any additional setup after loading the view.
    }
    
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
    
    @IBAction func completedTapped(_ sender: Any) {
        mSelectedNote?.completed = !mSelectedNote!.completed
        mNoteCallBack.NoteUpdateCallBack()
        navigationController?.popViewController(animated: true)
    }
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
        //        popover.barButtonItem = sender
        
//        present(vc, animated: true, completion:nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
                mNoteCallBack.NoteUpdateCallBack()
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
                mNoteCallBack.NoteAddCallBack(title: title!, description: desc, due: mDueDate, remindme: remindme)
            }
        }
    }
    
    @IBAction func deletetapped(_ sender: Any) {
        mNoteCallBack.deleteNote(note: mSelectedNote!)
        navigationController?.popViewController(animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        print("hello")
        return .none
    }
    
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

protocol DateCallBack {
    func dateChanged(date: Date)
}

extension NoteDetailsViewController: DateCallBack
{
    func dateChanged(date: Date) {
        mDueDate = date
        
        self.mDueDateButton.setTitle(formattedDate(date: date), for: .normal)
    }
    
    func formattedDate(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        return dateFormatter.string(from: date)
    }
}

class DatePopOverViewController: UIViewController
{
    var mDateCallBack: DateCallBack!
    
    @IBOutlet weak var mDoneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let picker : UIDatePicker = UIDatePicker()
        picker.datePickerMode = UIDatePicker.Mode.date
        picker.minimumDate = Date()
        picker.addTarget(self, action: #selector(dueDateChanged), for: UIControl.Event.valueChanged)
        let pickerSize : CGSize = picker.sizeThatFits(CGSize.zero)
        picker.frame = CGRect(x: 0.0, y: 50, width: pickerSize.width, height: 230)
        // you probably don't want to set background color as black
        // picker.backgroundColor = UIColor.blackColor()
        self.view.addSubview(picker)
    }
    
    @objc func dueDateChanged(sender:UIDatePicker){
        mDateCallBack.dateChanged(date: sender.date)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
