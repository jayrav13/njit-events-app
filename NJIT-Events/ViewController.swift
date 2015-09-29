//
//  ViewController.swift
//  NJIT-Events
//
//  Created by Jay Ravaliya on 9/28/15.
//  Copyright © 2015 JRav. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView : UITableView!
    var data : JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Events at NJIT"
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        
        tableView = UITableView(frame: self.view.frame)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        let api : API = API()
        api.getData { (swiftyJSON) -> Void in
            self.data = swiftyJSON
            self.tableView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        if let data = self.data {
            cell.textLabel?.text = data["response"][indexPath.row][0]["event_name"].stringValue.stringByRemovingPercentEncoding
            cell.detailTextLabel?.text = data["response"][indexPath.row][0]["location_name"].stringValue
        } else {
            cell.textLabel?.text = "Test"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.data {
            return data["response"].count
        } else {
            return 1
        }
    }
    
    
    

}

