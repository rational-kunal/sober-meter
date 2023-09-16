//
//  UIImage+Background.swift
//  SoberMeter
//
//  Created by Kunal Kamble on 13/09/23.
//

import UIKit

extension UIImage {
    func blackBackground() -> UIImage {
        return withBackground(color: .black)
    }

    func withBackground(color: UIColor) -> UIImage {
        let imageSize = self.size
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!
        color.setFill()
        context.fill(CGRect(origin: .zero, size: imageSize))
        self.draw(in: CGRect(origin: .zero, size: imageSize))

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
