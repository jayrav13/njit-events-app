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
import CNPPopupController

/*
 *  Create new UIViewController with all Delegates and DataSources
 */
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, CNPPopupControllerDelegate {

    /*
     *  Instantiate variables for the ViewController.
     */
    var tableView : UITableView!
    var refreshControl : UIRefreshControl!
    var activityIndicator : UIActivityIndicatorView!
    var toolbarLabel : UILabel!
    var api : API!
    var data : JSON!
    var popupController : CNPPopupController!
    
    // fonts
    var appleFontBold : UIFont!
    var appleFontLight : UIFont!
    var arialFontSmall : UIFont!
    var arialFontLarge : UIFont!
    
    /*
     *  viewDidLoad()
     */
    override func viewDidLoad() {
        // super
        super.viewDidLoad()
        
        // fonts
        appleFontBold = UIFont(name: "AppleSDGothicNeo-Bold", size: 24)
        appleFontLight = UIFont(name: "AppleSDGothicNeo-Light", size: 24)
        arialFontSmall = UIFont(name: "ArialMT", size: 12)
        arialFontLarge = UIFont(name: "ArialMT", size: 16)
        
        // initialize self variables
        // title, textAttributes, backgroundColor, barTintColor
        self.title = "Events at NJIT"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: appleFontBold!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        self.navigationController?.setToolbarHidden(false, animated: true)
        
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
        self.toolbarLabel.font = arialFontSmall
        self.toolbarLabel.textAlignment = NSTextAlignment.Center
        self.toolbarItems = [flexibleSpace, UIBarButtonItem(customView: self.toolbarLabel), flexibleSpace]
        
        // activityIndicator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: screenWidth/2 - 10, y: screenHeight/2 - 10, width: 20, height: 20))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.startAnimating()
        activityIndicator.alpha = 1
        self.view.addSubview(activityIndicator)

        // make API call, return data and reload tableView.
        api = API()
        api.getData { (swiftyJSON) -> Void in
            self.data = swiftyJSON
            self.toolbarLabel.text = self.lastUpdated(self.data["current_date"].stringValue, timeString: self.data["current_time"].stringValue)
            self.tableView.reloadData()
            self.tableView.alpha = 1
            self.activityIndicator.stopAnimating()
            self.activityIndicator.alpha = 0
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
            cell.textLabel?.text = data["response"][indexPath.row]["name"].stringValue
            cell.textLabel?.font = appleFontLight
            
            if data["response"][indexPath.row]["datetime"]["currently_happening"].boolValue {
                cell.backgroundColor = UIColor(red: 102.0/255.0, green: 204.0/255.0, blue: 153.0/255.0, alpha: 1.0/1.0)
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
        self.showPopup(indexPath.row)
    }
    
    /*
     *  shareText
     *  Return string that should be used as the shareString.
     */
    func shareText(name : String, dateString : String, location : String, time : String) -> String {
        return "Check out \"" + name + "\", starting " + dateString + " at " + time + " in " + location + ". Cya there! via @EventsAtNJIT"
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
     *  refreshData
     *  Updates information on pull down.
     */
    func refreshData(sender: UIRefreshControl!) {
        self.api.getData { (swiftyJSON) -> Void in
            self.data = swiftyJSON
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.toolbarLabel.text = self.lastUpdated(self.data["current_date"].stringValue, timeString: self.data["current_time"].stringValue)
        }
    }
    
    /*
     *  lastUpdated
     *  Returns a standard "Last Updated on %s at %s" string for the footer.
     */
    func lastUpdated(dateString : String, timeString : String) -> String {
        return "Last Updated on " + dateString + " at " + timeString
    }

    /*
     *  showPopup
     *  Set up pop up elements and display.
     */
    func showPopup(index : Int) {
        
        // an array for all the elements
        var elements : [AnyObject] = []
        
        // set up paragraph style
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        
        // title label will ALWAYS exist
        let titleLabel : UILabel = generatePopupLabel(self.data["response"][index]["name"].stringValue, font: appleFontBold)
        elements.append(titleLabel)
        
        // add organization if one exists
        if (self.data["response"][index]["organization"] != nil) {
            let host : UILabel = generatePopupLabel("Hosted By:", font: arialFontSmall)
            let hostedLabel : UILabel = generatePopupLabel(self.data["response"][index]["organization"].stringValue, font: arialFontLarge)
            elements += [host, hostedLabel]
        }

        // add location if one exists
        if (self.data["response"][index]["location"] != nil)  {
            let location : UILabel = generatePopupLabel("Location:", font: arialFontSmall)
            let locationLabel : UILabel = generatePopupLabel(self.data["response"][index]["location"].stringValue, font: arialFontLarge)
            elements += [location, locationLabel]
        }
        
        // add time label based on when the event is
        let time : UILabel = generatePopupLabel("Time:", font: arialFontSmall)
        let timeLabel : UILabel!
        
        if(self.data["response"][index]["datetime"]["multiday"].boolValue) {
            timeLabel = generatePopupLabel(self.data["response"][index]["datetime"]["time_date_range_string"].stringValue, font: arialFontLarge)
        }
        else {
            timeLabel = generatePopupLabel(popupTimeLabel(index), font: arialFontLarge)
        }
        
        elements += [time, timeLabel]
        
        // add description if one exists
        if (self.data["response"][index]["description"] != nil) {
            let description : UILabel = generatePopupLabel("Description:", font: arialFontSmall)
            let descriptionLabel : UILabel = generatePopupLabel(self.data["response"][index]["description"].stringValue, font: arialFontLarge)
            elements += [description, descriptionLabel]
        }
        
        // add category if one exists
        if (self.data["response"][index]["category"] != nil) {
            let category : UILabel = generatePopupLabel("Category:", font: arialFontSmall)
            let categoryLabel : UILabel = generatePopupLabel(self.data["response"][index]["category"].stringValue, font: arialFontLarge)
            elements += [category, categoryLabel]
        }
        
        // create share button with selectionHandler
        let shareButton : CNPPopupButton = CNPPopupButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.6, height: 40))
        shareButton.setTitle("Share", forState: UIControlState.Normal)
        shareButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        shareButton.backgroundColor = UIColor.redColor()
        shareButton.layer.cornerRadius = 4
        shareButton.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            self.showActivityVC(index)
        }
        elements.append(shareButton)
        
        // initialize popupController as a centered alert, display
        popupController = CNPPopupController(contents: elements)
        popupController.theme = CNPPopupTheme.defaultTheme()
        popupController.theme.popupStyle = CNPPopupStyle.Centered
        popupController.delegate = self
        popupController.theme.shouldDismissOnBackgroundTouch = true
        popupController.presentPopupControllerAnimated(true)
    
    }
    
    /*
     *  popupTimeLabel
     *  Format for time string in the popup.
     */
    func popupTimeLabel(index : Int) -> String {
        var response : String!
        if (self.data["response"][index]["datetime"]["is_today"].boolValue) {
            response = "Today, "
        }
        else if (self.data["response"][index]["datetime"]["is_tomorrow"].boolValue) {
            response = "Tomorrow, "
        }
        else {
            response = self.data["response"][index]["datetime"]["start"]["common_formats"]["date"].stringValue + ", "
        }
        
        response = response + self.data["response"][index]["datetime"]["time_range_string"].stringValue
        return response
    }
    
    /*
     *  showActivityVC
     *  Generate text to share over Text, Email or Twitter. Open activityVC.
     */
    func showActivityVC(index : Int) {
        // determine what the date string will be based on event timing.
        var dateString : String!
        if(self.data["response"][index]["datetime"]["is_today"].boolValue) {
            dateString = "today"
        }
        else if(self.data["response"][index]["datetime"]["is_tomorrow"].boolValue) {
            dateString = "tmr"
        }
        else {
            dateString = "on " + self.data["response"][index]["datetime"]["start"]["common_formats"]["date"].stringValue
        }
        
        // establish share string, create activityViewController, present!
        let shareString : String = shareText(data["response"][index]["name"].stringValue, dateString: dateString, location: data["response"][index]["location"].stringValue, time: data["response"][index]["datetime"]["start"]["common_formats"]["time"].stringValue)
        let activityVC = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypePostToFacebook]
        self.presentViewController(activityVC, animated: true) { () -> Void in
            
        }
    }
    
    /*
     *  generatePopupLabel
     *  Specific function that returns a UILabel for each element in the CNPPopupController.
     */
    func generatePopupLabel(val : String, font : UIFont) -> UILabel {
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let title : NSAttributedString = NSAttributedString(string: val, attributes: [NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle])
        
        let titleLabel : UILabel = UILabel()
        titleLabel.numberOfLines = 3
        titleLabel.attributedText = title
        
        return titleLabel
    }

}

