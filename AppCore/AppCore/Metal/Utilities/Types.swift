//
//  Types.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 27/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
import MetalKit
import simd

public enum VertexFunction: String {
    case vertex_shader
    case vertex_image_shader
    case vertex_anchor_shader
    case vertex_fireball_shader
}

public enum FragmentFunction: String {
    case fragment_shader
    case fragment_fireball_shader
    case fragment_image_shader
    case fragment_anchor_shader
}

public enum ObjectType: String {
    case model
    case cube
    case sphere
}
