//
//  PlaceAnnotationView.swift
//  ARPlacesDemo
//
//  Created by GEORGE QUENTIN on 04/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation
import UIKit
import HDAugmentedReality
import SDWebImage

//1
protocol AnnotationViewDelegate {
    func didTouch(annotationView: PlaceAnnotationView)
}

//2
public class PlaceAnnotationView: ARAnnotationView {
    //3
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var placeImageView: UIImageView?
    var delegate: AnnotationViewDelegate?
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        loadUI()
    }
    
    //4
    public func loadUI() {
        titleLabel?.removeFromSuperview()
        distanceLabel?.removeFromSuperview()
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        distanceLabel = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20))
        distanceLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        distanceLabel?.textColor = UIColor.green
        distanceLabel?.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(distanceLabel!)
        
        placeImageView = UIImageView(frame: CGRect(x: 10 + self.frame.size.width, y: 0, width: 30, height: self.frame.size.height))
        self.addSubview(placeImageView!)
        
        if let annotation = annotation as? Place {
            titleLabel?.text = annotation.placeName
            distanceLabel?.text = String(format: "%.2f km", annotation.distanceFromUser / 1000)
            placeImageView?.sd_setImage(with: URL(string: annotation.imageURL ?? ""), completed: nil)
        }
    }
    
    //1
    override public func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30)
        distanceLabel?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20)
        placeImageView?.frame = CGRect(x: 10 + self.frame.size.width, y: 0, width: 30, height: self.frame.size.height)
    }
    
    //2
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }
    
}
