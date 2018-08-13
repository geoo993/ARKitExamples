//
//  Types.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 27/06/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
import MetalKit
import simd

public enum SliderType: String {
    case slider_x0
    case slider_x2
    case slider_x1
    case slider_x3
    case slider_x4
    case slider_x5
}

public struct LightsUniforms {
    var dirLights: [DirectionalLight]
    var pointLights: [PointLight]
    var spotLights: [SpotLight]
};

public enum VertexFunction: String {
    case vertex_shader
    case vertex_instance_shader
    case vertex_fire_ball_shader
    case image_vertex_shader
}

public enum FragmentFunction: String {
    case fragment_shader
    case fragment_color
    case fragment_normal
    case fragment_texture_shader
    case fragment_textured_mask_shader
    case fragment_light_mix_shader
    case phong_fragment_shader
    case blinn_phong_fragment_shader
    case lighting_fragment_shader
    case fragment_toon_shader
    case fragment_fire_ball_shader
    case fragment_image_shader
}

public struct Vertex {
    var position: float3
    var texture: float2
    var color: float4
    var normal: float3
}
