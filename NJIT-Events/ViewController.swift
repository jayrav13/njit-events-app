//
//  ViewController.swift
//  NJIT-Events
//
//  Created by Jay Ravaliya on 9/28/15.
//  Copyright © 2015 JRav. All rights reserved.
//

/*
 *  Import statements.
 */

import UIKit
import SwiftyJSON
import Social
import EventKit
import MessageUI

/*
 * Create new UIViewController with TableView Delegate and Data Source
 */
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    /*
     *  Instantiate variables for tableView and JSON Data from API call.
     */
    
    var tableView : UITableView!
    var data : JSON!
    var refreshControl : UIRefreshControl!
    var api : API!
    var toolbarLabel : UILabel!
    var date : NSDate!

    /*
     * viewDidLoad()
     */
    override func viewDidLoad() {
        // super
        super.viewDidLoad()
        
        // initialize self variables
        // title, textAttributes, backgroundColor, barTintColor
        self.title = "Events at NJIT"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Bold", size: 24)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        // create search button
        let searchButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "aboutUs:")
        searchButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = searchButton
        
        // create tableView
        tableView = UITableView(frame: self.view.frame)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.alpha = 0
        self.view.addSubview(self.tableView)
        
        // refreshControl
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        self.refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        // create flexSpace button
        let flexibleSpace : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        // create toolbarLabel for "last updated"
        self.toolbarLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        self.toolbarLabel.text = "Updating..."
        self.toolbarLabel.font = UIFont(name: "ArialMT", size: 12)
        self.toolbarLabel.textAlignment = NSTextAlignment.Center
        self.toolbarItems = [flexibleSpace, UIBarButtonItem(customView: self.toolbarLabel), flexibleSpace]
        
        // make API call, return data and reload tableView.
        api = API()
        api.getData { (swiftyJSON) -> Void in
            self.data = swiftyJSON
            self.toolbarLabel.text = self.getCurrentTime()
            self.tableView.reloadData()
            self.tableView.alpha = 1
        }
        
    }

    /*
     * didReceiveMemoryWarning()
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     * cellForRowAtIndexPath
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // create cell
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        // if the data exists
        if let data = self.data {
            
            // set textLabel text and font
            cell.textLabel?.text = data["response"][indexPath.row][0]["event_name"].stringValue.stringByRemovingPercentEncoding
            cell.textLabel?.font = UIFont(name: "AppleSDGothicNeo-Light", size: 20)
            
            // set detailedTextLabel text and fonts
            cell.detailTextLabel?.numberOfLines = 2
            let locationName : String = data["response"][indexPath.row][0]["location_name"].stringValue
            
            cell.detailTextLabel?.text = "\(locationName)\n" + eventDate(data["response"][indexPath.row][0]["month"].stringValue, date: data["response"][indexPath.row][0]["date"].stringValue, year: data["response"][indexPath.row][0]["year"].stringValue) + ", " + timeSinceMidnight(data["response"][indexPath.row][0]["start"].doubleValue) + " - " + timeSinceMidnight(data["response"][indexPath.row][0]["end"].doubleValue)
            cell.detailTextLabel?.font = UIFont(name: "AppleSDGothicNeo-Light", size: 12)
            
            if isCurrentlyHappening(indexPath.row) {
                cell.backgroundColor = UIColor(red: 102.0/255.0, green: 204.0/255.0, blue: 153.0/255.0, alpha: 1.0/1.0)
            }
            
            if isPastEvent(indexPath.row) {
                cell.contentView.alpha = 0.25
            }
            
        }
        
        // return cell
        return cell
        
    }
    
    /*
     * didSelectRowAtIndexPath
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // deselect row upon selection
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.openActionSheet(indexPath.row)
        
    }
    
    /*
     * numberOfRowsInSection
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // if the data is available, set the number of rows equal to the number of events
        // else, set it equal to 1
        if let data = self.data {
            return data["response"].count
        } else {
            return 1
        }
    }
    
    /*
     * heightForRowAtIndexPath
     */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }

    /*
     * upvoteButton(sender: UIButton!)
     * For future use, will be used for event goers to increment events they're at.
     */
    func upvoteButton(sender: UIButton!) {
        print(sender.tag)
    }
    
    /*
     * eventDate(month : String, date : String, year : String) -> String
     * Converts the month, date and year into a string for the tableView
     */
    func eventDate(month : String, date : String, year : String) -> String {
        
        return "\(month)/\(date)/\(year)"
    }
    
    /*
     * timeSinceMidnight( minutes : Double) -> String
     * Converts the number of minutes since midnight to a time string.
     */
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
    
    /*
     * searchEvents(sender: UIButton!)
     * Will be used for the search bar later on.
     */
    func searchEvents(sender: UIButton!) {
        
    }
    
    /*
     * aboutUs(sender: UIButton!)
     * Shows the user a UIViewController
     */
    func aboutUs(sender: UIButton!) {

        let alert : UIAlertController = UIAlertController(title: "About Us", message: "This app is currently in beta testing. It is not affiliated with NJIT. If you have any questions, please click \"Mail\" below to email us!", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelButton : UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action : UIAlertAction) -> Void in
            
        }
        alert.addAction(cancelButton)
        
        let mailButton : UIAlertAction = UIAlertAction(title: "Mail", style: UIAlertActionStyle.Default) { (action : UIAlertAction) -> Void in
            self.sendEmailToAdmin()
        }
        alert.addAction(mailButton)
        
        self.presentViewController(alert, animated: true) { () -> Void in
            
        }
        
    }
    
    
    func refreshData(sender: UIRefreshControl!) {
        self.api.getData { (swiftyJSON) -> Void in
            self.data = swiftyJSON
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.toolbarLabel.text = self.getCurrentTime()
        }
    }
    
    func getCurrentTime() -> String {
        var hourMinutes = getTimeComponents()
        var period = "AM"
        
        if hourMinutes[0] > 12 {
            hourMinutes[0] = hourMinutes[0] - 12
            period = "PM"
        }
        
        var hourMinutesString : [String] = [String(hourMinutes[0]), String(hourMinutes[1])]
        
        if hourMinutesString[1].characters.count == 1 {
            hourMinutesString[1] = "0" + hourMinutesString[1]
        }
        
        return "Last Updated: \(hourMinutesString[0]):\(hourMinutesString[1]) \(period)"
    }
    
    func isCurrentlyHappening(index : Int) -> Bool {
        let hourMinutes = getTimeComponents()
        
        let totalMinutes = hourMinutes[0] * 60 + hourMinutes[1]
        let startTime = Int(data["response"][index][0]["start"].doubleValue)
        let endTime = Int(data["response"][index][0]["end"].doubleValue)
        let eventDate = Int(data["response"][index][0]["date"].doubleValue)
        
        if(totalMinutes >= startTime && totalMinutes < endTime && hourMinutes[2] == eventDate) {
            return true
        }
        else {
            return false
        }
    }
    
    func getTimeComponents() -> [Int] {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Day], fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        let day = components.day
        
        return [hour, minutes, day]
    }
    
    func isPastEvent(index : Int) -> Bool {
        let hourMinutes = getTimeComponents()
        
        if data["response"][index][0]["end"].doubleValue < Double(hourMinutes[0] * 60 + hourMinutes[1]) && Double(hourMinutes[2]) == data["response"][index][0]["date"].doubleValue {
            return true
        }
        else {
            return false
        }
    }
    
    func tweetThisEvent(index : Int) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetSheet.setInitialText(data["response"][index][0]["event_name"].stringValue + " starts at " + timeSinceMidnight(data["response"][index][0]["start"].doubleValue) + ", taking place in " + data["response"][index][0]["location_name"].stringValue + ". Meet me there! via @EventsAtNJIT")
            self.presentViewController(tweetSheet, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    func addEventToCalendar(index : Int) {
        
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(EKEntityType.Event) { (granted: Bool, error : NSError?) -> Void in
            if granted {
                
            }
            else {
                
            }
        }
        
    }
    
    func openActionSheet(index : Int) {
        let menu : UIAlertController = UIAlertController(title: "Menu", message: "Choose Options", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let tweetEvent : UIAlertAction = UIAlertAction(title: "Tweet the Event", style: UIAlertActionStyle.Default) { (action : UIAlertAction) -> Void in
            self.tweetThisEvent(index)
        }
        menu.addAction(tweetEvent)
    
        /*let addToCalendar : UIAlertAction = UIAlertAction(title: "Add to Calendar", style: UIAlertActionStyle.Default) { (action : UIAlertAction) -> Void in
            self.addEventToCalendar(index)
        }
        menu.addAction(addToCalendar)*/
        
        let cancel : UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action : UIAlertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
        menu.addAction(cancel)
        
        self.presentViewController(menu, animated: true) { () -> Void in
            
        }
        
    }
    
    func sendEmailToAdmin() {
        let picker : MFMailComposeViewController = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("Hi there!")
        picker.setMessageBody("I think your app is awesome! :)", isHTML: true)
        picker.setToRecipients(["njit.events.app@gmail.com"])
        
        self.presentViewController(picker, animated: true) { () -> Void in
            
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
}

