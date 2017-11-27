//
//  BorderedView.swift
//  FaceCounter
//
//  Created by Leo Tsuchiya on 11/26/17.
//  Copyright © 2017 Leo Tsuchiya. All rights reserved.
//

import Foundation
import UIKit

class BorderedView:UIView {
    
    init(color: UIColor, frame:CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = color.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
