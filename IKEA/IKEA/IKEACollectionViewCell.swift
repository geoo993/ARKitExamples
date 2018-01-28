//
//  IKEACollectionViewCell.swift
//  IKEA
//
//  Created by GEORGE QUENTIN on 28/01/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import AppCore

@IBDesignable
public class IKEACollectionViewCell: UICollectionViewCell {
    
    // MARK: - Border
    
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    // MARK: - Shadow
    
    @IBInspectable public var shadowOpacity: CGFloat = 0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    @IBInspectable public var shadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable public var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable public var shadowOffsetY: CGFloat = 0 {
        didSet {
            layer.shadowOffset.height = shadowOffsetY
        }
    }
    
    // MARK: - Item details
    @IBOutlet weak var itemLabel: UILabel!
    
    private var _selectedColor: UIColor = UIColor.white
    @IBInspectable var selectedColor: UIColor {
        get {
            return _selectedColor
        }
        set {
            _selectedColor = newValue
        }
    }
    
    private var _deSelectedColor: UIColor = UIColor.white
    @IBInspectable var deSelectedColor: UIColor {
        get {
            return _deSelectedColor
        }
        set {
            _deSelectedColor = newValue
        }
    }
    
    @IBInspectable var shouldSelect: Bool = false {
        didSet {
            backgroundColor = shouldSelect ? _selectedColor : _deSelectedColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
