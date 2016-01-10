//
//  MainViewController.swift
//  ClickTranslate
//
//  Created by Tamas Bara on 24.12.15.
//  Copyright © 2015 Tamas Bara. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIWebViewDelegate, TranslateRequestDelegate, CustomWebViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var webView: CustomWebView!
    var doOnce = true
    var translator: TranslateRequest?
    
    @IBOutlet weak var lblTranslation: UILabel!
    @IBOutlet weak var positionTranslation: NSLayoutConstraint!
    @IBOutlet weak var viewTranslation: UIView!
    @IBOutlet weak var urlView: UITextField!
    
    @IBOutlet weak var btnBack: UIButton!

    var showingTranslation = false
    var selectedText = ""
    var translation = ""
    var timer: NSTimer?
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var positionMenu: NSLayoutConstraint!
    var showingMenu = false
    var timerMenu: NSTimer?
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var navigationView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        translator = TranslateRequest(delegate: self)
        
        if let url = NSURL(string: "http://www.desnivel.com")
        {
            webView.loadRequest(NSURLRequest(URL: url))
        }
        
        webView.customDelegate = self
        webView.delegate = self
        urlView.delegate = self
        
        positionTranslation.constant = -40
        btnBack.enabled = false
        
        positionMenu.constant = -120
        
        menuButton.layer.zPosition = 3
        navigationView.layer.zPosition = 2
        menuView.layer.zPosition = 1
    }
    
    @IBAction func goBack(sender: AnyObject)
    {
        webView.goBack()
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
        btnBack.enabled = webView.canGoBack
        
        let currentURL = webView.stringByEvaluatingJavaScriptFromString("window.location.href")
        urlView.text = currentURL
    }
    
    func webViewDidStartLoad(webView: UIWebView)
    {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Loading"
    }
    
    func translateRequestOk(translations: [String])
    {
        if translations.count > 0
        {
            AppDelegate.executeOnMainThread()
            {
                self.showTranslations(translations)
            }
        }
    }
    
    @IBAction func settingsClicked(sender: AnyObject)
    {
        hideMenu()
    }
    
    @IBAction func addBookmarkClicked(sender: AnyObject)
    {
        hideMenu()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var found = false
        if let newBookmark = urlView.text
        {
            var newBookmarks: [String] = []
            if let bookmarks = defaults.arrayForKey("bookmarks") as? [String]
            {
                for bookmark in bookmarks
                {
                    if bookmark == newBookmark
                    {
                        found = true
                    }
                    
                    newBookmarks.append(bookmark)
                }
            }
            
            if !found
            {
                newBookmarks.append(newBookmark)
            }
            
            defaults.setObject(newBookmarks, forKey: "bookmarks")
        }
    }
    
    @IBAction func bookmarksClicked(sender: AnyObject)
    {
        hideMenu()
        
        let nav = UINavigationController()
        let bookmarksView = BookmarksViewController(nibName: "BookmarksViewController", bundle: nil)
        
        bookmarksView.title = NSLocalizedString("Bookmarks", comment: "")
        nav.viewControllers = [bookmarksView]
        
        presentViewController(nav, animated: true, completion: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeViewController:", name: "CloseViewController", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bookmarkSelected:", name: "BookmarkSelected", object: nil)
    }
    
    func closeViewController(notification: NSNotification)
    {
        dismissViewControllerAnimated(true, completion: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CloseViewController", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "BookmarkSelected", object: nil)
    }
    
    func bookmarkSelected(notification: NSNotification)
    {
        dismissViewControllerAnimated(true, completion: nil)
    
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CloseViewController", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "BookmarkSelected", object: nil)
        
        if let bookmark = notification.object as? String
        {
            urlView.text = bookmark
            if let url = NSURL(string: bookmark)
            {
                webView.loadRequest(NSURLRequest(URL: url))
            }
        }
    }
    
    @IBAction func menuClicked(sender: AnyObject)
    {
        if !showingMenu
        {
            showingMenu = true
            showMenuAnimated()
        }
        else
        {
            hideMenu()
        }
    }
    
    private func hideMenu()
    {
        if self.timer != nil
        {
            self.timer!.invalidate()
        }
        
        hideMenuAnimated()
    }
    
    private func showTranslations(translations: [String])
    {
        translation = translations[0]
        
        if timer != nil
        {
            timer!.invalidate()
        }
        
        if !showingTranslation
        {
            showingTranslation = true
            showTranslationAnimated()
        }
        else
        {
            hideTranslationAnimated(true)
        }
    }
    
    private func showMenuAnimated()
    {
        UIView.animateWithDuration(0.5, animations:
        {
            self.positionMenu.constant = 52
            self.view.layoutIfNeeded()
        },
        completion:
        { _ in
            
            if self.timer != nil
            {
                self.timer!.invalidate()
            }
            
            self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "timerEventMenu", userInfo: nil, repeats: false)
        })
    }
    
    private func hideMenuAnimated()
    {
        showingMenu = false
        UIView.animateWithDuration(0.5, animations:
        {
            self.positionMenu.constant = -120
            self.view.layoutIfNeeded()
        })
    }
    
    private func showTranslationAnimated()
    {
        lblTranslation.text = "\(selectedText): \(translation)"
        
        UIView.animateWithDuration(1, animations:
        {
            self.positionTranslation.constant = 0
            self.view.layoutIfNeeded()
        },
        completion:
        { _ in
            self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "timerEvent", userInfo: nil, repeats: false)
        })
    }
    
    private func hideTranslationAnimated(showNext: Bool)
    {
        UIView.animateWithDuration(1, animations:
        {
            self.positionTranslation.constant = -40
            self.view.layoutIfNeeded()
        },
        completion:
        { _ in
            self.showingTranslation = showNext
            if showNext
            {
                self.showTranslationAnimated()
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if let text = textField.text
        {
            var checkedText = text
            if !text.hasPrefix("http://")
            {
                checkedText = "http://\(checkedText)"
                urlView.text = checkedText
            }
            
            if let url = NSURL(string: checkedText)
            {
                webView.loadRequest(NSURLRequest(URL: url))
            }
        }
        
        urlView.resignFirstResponder()
        
        return true
    }
    
    func translateRequestError(error: NSError)
    {
    }
    
    func textSelected(text: String)
    {
        print("textSelected: \(text)")
        translator!.sendAndReceive(text)
        selectedText = text
    }
    
    func timerEvent()
    {
        hideTranslationAnimated(false)
    }
    
    func timerEventMenu()
    {
        if showingMenu
        {
            hideMenuAnimated()
        }
    }
}
