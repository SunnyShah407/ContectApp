//
//  BorderTextField.swift
//  ContectTest
//
//  Created by Samir  on 27/12/16.
//  Copyright © 2016 STL. All rights reserved.
//

import UIKit

class BorderTextField: UITextField {

    override func draw(_ rect: CGRect) {
        
        let startingPoint   = CGPoint(x: rect.minX, y: rect.maxY)
        let endingPoint     = CGPoint(x: rect.maxX, y: rect.maxY)
        
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = 1.0
        
        tintColor.setStroke()
        
        path.stroke()
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
