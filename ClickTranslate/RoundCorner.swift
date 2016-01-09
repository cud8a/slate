//
//  RoundCorner.swift
//  ClickTranslate
//
//  Created by Tamas Bara on 09.01.16.
//  Copyright © 2016 Tamas Bara. All rights reserved.
//

import UIKit

class RoundCorner: UIView
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 5;
        layer.borderWidth = 1;
        layer.borderColor = UIColor.grayColor().CGColor
        
    }
}
