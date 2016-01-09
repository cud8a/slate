//
//  BookmarksViewController.swift
//  ClickTranslate
//
//  Created by Tamas Bara on 09.01.16.
//  Copyright © 2016 Tamas Bara. All rights reserved.
//

import UIKit

class BookmarksViewController: UIViewController, UITableViewDataSource
{
    var bookmarks: [String] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "actionDone:")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let bookmarks = defaults.arrayForKey("bookmarks") as? [String]
        {
            self.bookmarks = bookmarks
        }
    }
    
    func actionDone(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "CloseViewController", object: nil))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: BookmarkTableViewCell!
        
        if let reuse = tableView.dequeueReusableCellWithIdentifier("BookmarkCell") as? BookmarkTableViewCell
        {
            cell = reuse
        }
        else
        {
            let nibs = NSBundle.mainBundle().loadNibNamed("BookmarkTableViewCell", owner: self, options: nil)
            cell = nibs[0] as! BookmarkTableViewCell
        }
        
        cell.bookmarkText.text = bookmarks[indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return bookmarks.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let bookmark = bookmarks[indexPath.row]
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "BookmarkSelected", object: bookmark))
    }
}
