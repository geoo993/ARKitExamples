//
//  BasketBall.swift
//  ARHoops
//
//  Created by GEORGE QUENTIN on 10/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
import SceneKit

public class BasketBall : SCNNode {
    var tag : Int = 0

    public init (name: String, radius: CGFloat, tag: Int) {
        super.init()
        self.geometry = SCNSphere(radius: radius)
        self.name = name
        self.tag = tag
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
