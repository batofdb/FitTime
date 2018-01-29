//
//  RoundedCornerView.swift
//  FitTime
//
//  Created by Francis Bato on 1/28/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit

class RoundedCornerView: UIView {

    // MARK: Properties

    /// The color of the border line.
    @IBInspectable var borderColor: UIColor = UIColor.black

    /// The width of the border.
    @IBInspectable var borderWidth: CGFloat = 1 / UIScreen.main.scale

    /// The drawn corner radius.
    @IBInspectable var cornerRadius: CGFloat = 10

    /// The color that the rectangle will be filled with.
    @IBInspectable var fillColor: UIColor = UIColor.white

    override func draw(_ rect: CGRect) {
        let borderPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        borderColor.set()
        borderPath.fill()

        let fillRect = CGRect(x: borderWidth, y: borderWidth, width: bounds.width - (2 * borderWidth), height: bounds.height - (2 * borderWidth))
        let fillPath = UIBezierPath(roundedRect: fillRect, cornerRadius: cornerRadius)
        fillColor.set()
        fillPath.fill()
    }


}
