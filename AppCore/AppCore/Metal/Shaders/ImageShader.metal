//
//  ImageShader.metal
//  AppCore
//
//  Created by GEORGE QUENTIN on 13/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>

// Include header shared between this Metal shader code and C code executing Metal API commands
#include "Shader.h"


// Captured image vertex function
vertex VertexOut vertex_image_shader(const ImageVertexIn vertexIn [[stage_in]]) {
    VertexOut vertexOut;

    // Pass through the image vertex's position
    vertexOut.position = float4(vertexIn.position.x, vertexIn.position.y, 0.0f, 1.0f);

    // Pass through the texture coordinate
    vertexOut.textureCoordinate = vertexIn.textureCoordinate;

    return vertexOut;
}

// Captured image fragment function
fragment float4 fragment_image_shader(VertexOut fragmentIn [[stage_in]],
                                      texture2d<float, access::sample> capturedImageTextureY [[ texture(TextureIndexY) ]],
                                      texture2d<float, access::sample> capturedImageTextureCbCr [[ texture(TextureIndexCbCr) ]]) {

    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);

    const float4x4 ycbcrToRGBTransform = float4x4(
                                                  float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                                  float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                                  float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                                  float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
                                                  );

    // Sample Y and CbCr textures to get the YCbCr color at the given texture coordinate
    float4 ycbcr = float4(capturedImageTextureY.sample(colorSampler, fragmentIn.textureCoordinate).r,
                          capturedImageTextureCbCr.sample(colorSampler, fragmentIn.textureCoordinate).rg, 1.0);

    // Return converted RGB color
    return ycbcrToRGBTransform * ycbcr;
}
