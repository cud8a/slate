//
//  CustomWebView.swift
//  ClickTranslate
//
//  Created by Tamas Bara on 25.12.15.
//  Copyright © 2015 Tamas Bara. All rights reserved.
//

import UIKit

protocol CustomWebViewDelegate
{
    func textSelected(text: String)
}

class CustomWebView: UIWebView
{
    var customDelegate: CustomWebViewDelegate?
    var lastSelection = ""
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool
    {
        if action.description == "cut:"
        {
            if let text = stringByEvaluatingJavaScriptFromString("window.getSelection().toString()")
            {
                if text != lastSelection && text.characters.count > 0
                {
                    customDelegate?.textSelected(text)
                }
                
                lastSelection = text
            }
            else
            {
                lastSelection = ""
            }
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
