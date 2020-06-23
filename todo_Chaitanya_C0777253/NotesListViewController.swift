//
//  NotesListViewController.swift
//  todo_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 22/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit

class NotesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mTableView: UITableView!
    var mNavigationBarBackgroundImage: UIImage!
    var mNavigationBarShadowImage: UIImage!
    var mNavigationBarIsTranslucent: Bool!
    var mNavigationBarTintColor: UIColor!
    
    var mSelectedCategory: Categories?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNewView()
    }
    
    func addNewView()
    {
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 250))
        // Image from unsplash: https://unsplash.com/photos/iVPWGCbFwd8
        headerView.imageView.image = UIImage(named: "header")
        self.mTableView.tableHeaderView = headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")
        if cell == nil
        {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "categoryCell")
        }
        cell?.textLabel?.text = "hello"
        //        cell?.textLabel?.text = mCategories[indexPath.row].category
        //        cell?.detailTextLabel?.text = String(mCategories[indexPath.row].notes?.count ?? 0)
        return cell!
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
        mNavigationBarBackgroundImage = self.navigationController?.navigationBar.backgroundImage(for: .default)
        mNavigationBarShadowImage = self.navigationController?.navigationBar.shadowImage
        mNavigationBarIsTranslucent = self.navigationController?.navigationBar.isTranslucent
        mNavigationBarTintColor = self.navigationController?.navigationBar.tintColor
        // Make the Navigation Bar background transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        
        // Remove 'Back' text and Title from Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(mNavigationBarBackgroundImage, for: .default)
        self.navigationController?.navigationBar.shadowImage = mNavigationBarShadowImage
        self.navigationController?.navigationBar.isTranslucent = mNavigationBarIsTranslucent
        self.navigationController?.navigationBar.tintColor = mNavigationBarTintColor
    }
    
}

extension NotesListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerView = self.mTableView.tableHeaderView as! StretchyTableHeaderView
        headerView.scrollViewDidScroll(scrollView: scrollView)
    }
}
