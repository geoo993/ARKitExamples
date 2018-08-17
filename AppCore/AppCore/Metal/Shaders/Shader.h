//
//  Shader.h
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 03/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#ifndef Shader_h
#define Shader_h

#include "AppCore/Metal/Shaders/ShaderTypes.h"
using namespace metal;

// input information to the shader
// note that each item in the struct has been given an attribute number
//
struct VertexIn {
    float3 position [[ attribute(VertexAttributePosition) ]];
    half3 normal [[ attribute(VertexAttributeNormal) ]];
    float2 textureCoordinate [[ attribute(VertexAttributeTexcoord) ]];
};

struct ImageVertexIn {
    float2 position [[attribute(ImageVertexAttributePosition)]];
    float2 textureCoordinate [[attribute(ImageVertexAttributeTexcoord)]];
};

// this tells the rasterisor, which of these data items contains, contains the vertex position or color value.
// This specifies whats passed down to the rasterisation stage and eventually to the fragment program.
struct VertexOut {
    float4 position [[ position ]];
    float2 textureCoordinate;
    float shininess;
    bool useTexture;
    float4 color;
    float3 normal;
    float3 fragPosition;
    float4 eyePosition;
    float4 eyeNormal;
    float noise;
};


#endif /* Shader_h */
