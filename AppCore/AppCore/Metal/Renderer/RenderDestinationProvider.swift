//
//  RenderDestinationProvider.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 12/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Metal
import MetalKit
import ARKit

public protocol RenderDestinationProvider {
    var clearColor: MTLClearColor { get set }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
    var bundle: Bundle { get }
}
