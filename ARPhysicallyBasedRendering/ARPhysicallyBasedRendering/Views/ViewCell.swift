//
//  ViewCell.swift
//  PBROrbs
//
//  Created by GEORGE QUENTIN on 22/08/2018.
//  Copyright © 2018 MediumBlog. All rights reserved.
//

import UIKit

@IBDesignable
public class ViewCell: UICollectionViewCell {
    @IBInspectable var cornerRadius: CGFloat {

        get{
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

public class ImageCell: ViewCell {
    @IBOutlet weak var imageView: UIImageView!

}

public class ObjectCell: ViewCell {
    @IBOutlet weak var label: UILabel!

}

