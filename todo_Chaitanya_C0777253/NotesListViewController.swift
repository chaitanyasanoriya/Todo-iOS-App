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
    var mHeaderView: UIView!
    var mNewHeaderLayer: CAShapeLayer!
    
    private let mHeaderHeight: CGFloat = 420
    private let mHeaderCut: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
        // Do any additional setup after loading the view.
    }

    func updateView()
    {
        mTableView.backgroundColor = .white
        mHeaderView = mTableView.tableHeaderView
        mTableView.tableHeaderView = nil
        mTableView.rowHeight = UITableView.automaticDimension
        mTableView.addSubview(mHeaderView)
        
        mNewHeaderLayer = CAShapeLayer()
        mNewHeaderLayer.fillColor = UIColor.black.cgColor
        mHeaderView.layer.mask = mNewHeaderLayer
        
        let newHeight = mHeaderHeight - mHeaderCut / 2
        mTableView.contentInset = UIEdgeInsets(top: newHeight, left: 0, bottom: 0, right: 0)
        mTableView.contentOffset = CGPoint(x: 0, y: -newHeight)
        
        self.setupNewView()
    }
    
    func setupNewView()
    {
        let newheight = mHeaderHeight - mHeaderCut / 2
        var getheaderframe = CGRect(x: 0, y: -newheight, width: mTableView.bounds.width, height: mHeaderHeight)
        
        if mTableView.contentOffset.y < newheight
        {
            getheaderframe.origin.y = mTableView.contentOffset.y
            getheaderframe.size.height = -mTableView.contentOffset.y + mHeaderCut / 2
        }
        
        mHeaderView.frame = getheaderframe
        let cutdirection = UIBezierPath()
        cutdirection.move(to: CGPoint(x: 0, y: 0))
        cutdirection.addLine(to: CGPoint(x: getheaderframe.width, y: 0))
        cutdirection.addLine(to: CGPoint(x: getheaderframe.width, y: getheaderframe.height))
        cutdirection.addLine(to: CGPoint(x: 0, y: getheaderframe.height - mHeaderCut))
        mNewHeaderLayer.path = cutdirection.cgPath
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.mTableView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.setupNewView()
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

}
