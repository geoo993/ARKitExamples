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
struct VertexIn {
    float3 position [[ attribute(VertexAttributePosition) ]];
    float2 textureCoordinates [[ attribute(VertexAttributeTexcoord) ]];
    float4 color [[ attribute(VertexAttributeColor) ]];
    float3 normal [[ attribute(VertexAttributeNormal) ]];
};

struct ImageVertexIn {
    float2 position [[attribute(VertexAttributePosition)]];
    float2 textureCoordinates [[attribute(VertexAttributeTexcoord)]];
};

// this tells the rasterisor, which of these data items contains, contains the vertex position or color value
struct VertexOut {
    float4 position [[ position ]];
    float2 textureCoordinates;
    float4 color;
    float3 normal;
    float3 fragPosition;
    float4 eyePosition;
    float4 eyeNormal;
    float noise;
};


#endif /* Shader_h */
