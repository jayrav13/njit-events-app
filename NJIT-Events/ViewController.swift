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
    
    let date : NSDateComponents = NSDateComponents()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Events at NJIT"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Bold", size: 24)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        
        let searchButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchEvents:")
        searchButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = searchButton
        
        tableView = UITableView(frame: self.view.frame)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.alpha = 0
        
        self.view.addSubview(self.tableView)
        
        let api : API = API()
        api.getData { (swiftyJSON) -> Void in
            self.data = swiftyJSON
            self.tableView.reloadData()
            self.tableView.alpha = 1
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        if let data = self.data {
            cell.textLabel?.text = data["response"][indexPath.row][0]["event_name"].stringValue.stringByRemovingPercentEncoding
            cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Light", size: 20)
            
            cell.detailTextLabel?.text = eventDate(data["response"][indexPath.row][0]["month"].stringValue, date: data["response"][indexPath.row][0]["date"].stringValue, year: data["response"][indexPath.row][0]["year"].stringValue) + ", " + timeSinceMidnight(data["response"][indexPath.row][0]["start"].doubleValue) + " - " + timeSinceMidnight(data["response"][indexPath.row][0]["end"].doubleValue)
            
            cell.detailTextLabel?.font = UIFont(name: "AppleSDGothicNeo-Light", size: 14)
            
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }

    func upvoteButton(sender: UIButton!) {
        print(sender.tag)
    }
    
    func eventDate(month : String, date : String, year : String) -> String {
        
        return "\(month)/\(date)/\(year)"
    }
    
    func timeSinceMidnight(minutes : Double) -> String {
        
        var period = "AM"
        
        var min : Int = Int(floor(minutes/60.0))
        
        let sec : Int = Int(minutes) - (min * 60)
        
        if min > 12 {
            min = min - 12
            period = "PM"
        }
        
        var strTime : [String] = [String(min), String(sec)]
        if strTime[1].characters.count == 1 {
            strTime[1] = "0" + strTime[1]
        }
        
        return "\(strTime[0]):\(strTime[1]) \(period)"
        
    }
    
    func searchEvents(sender: UIButton!) {
        
    }
    
}

