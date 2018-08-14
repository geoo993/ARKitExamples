//
//  RenderUniformProvider.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 14/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Metal
import MetalKit
import ARKit

public protocol RenderUniformProvider {
    var anchors: [ARAnchor] { get set }
    var sharedUniformBuffer: MTLBuffer! { get set }
    var anchorUniformBuffer: MTLBuffer! { get set }
    var uniformBufferIndex: Int  { get set }
    var sharedUniformBufferOffset: Int { get set }
    var anchorUniformBufferOffset: Int { get set }
    var sharedUniformBufferAddress: UnsafeMutableRawPointer! { get set }
    var anchorUniformBufferAddress: UnsafeMutableRawPointer! { get set }
    var anchorMaterialBufferAddress: UnsafeMutableRawPointer! { get set }
    var anchorInstanceCount: Int { get set }
}
