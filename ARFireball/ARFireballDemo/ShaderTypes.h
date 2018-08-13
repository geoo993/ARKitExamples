//
//  ShaderTypes.h
//  ARFireball
//
//  Created by GEORGE QUENTIN on 11/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

//
//  Header containing types and enum constants shared between Metal shaders and C/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif
#import <simd/simd.h>

#include <simd/simd.h>

/*
// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef enum BufferIndices {
    kBufferIndexMeshPositions    = 0,
    kBufferIndexMeshGenerics     = 1,
    kBufferIndexInstanceUniforms = 2,
    kBufferIndexSharedUniforms   = 3
} BufferIndices;

// Attribute index values shared between shader and C code to ensure Metal shader vertex
//   attribute indices match the Metal API vertex descriptor attribute indices
typedef enum VertexAttributes {
    kVertexAttributePosition  = 0,
    kVertexAttributeTexcoord  = 1,
    kVertexAttributeNormal    = 2
} VertexAttributes;

// Texture index values shared between shader and C code to ensure Metal shader texture indices
//   match indices of Metal API texture set calls
typedef enum TextureIndices {
    kTextureIndexColor    = 0,
    kTextureIndexY        = 1,
    kTextureIndexCbCr     = 2
} TextureIndices;

// Structure shared between shader and C code to ensure the layout of shared uniform data accessed in
//    Metal shaders matches the layout of uniform data set in C code
typedef struct {
    // Camera Uniforms
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    
    // Lighting Properties
    vector_float3 ambientLightColor;
    vector_float3 directionalLightDirection;
    vector_float3 directionalLightColor;
    float materialShininess;
} SharedUniforms;

// Structure shared between shader and C code to ensure the layout of instance uniform data accessed in
//    Metal shaders matches the layout of uniform data set in C code
typedef struct {
    matrix_float4x4 modelMatrix;
} InstanceUniforms;
*/

// --------- Buffers and Indexes --------
// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef NS_ENUM(NSInteger, BufferIndex)
{
    BufferIndexMeshPositions        = 0,
    BufferIndexUniforms             = 1,
    BufferIndexInstances            = 2,
    BufferIndexCameraInfo           = 3,
    BufferIndexMaterialInfo         = 4,
    BufferIndexDirectionalLightInfo = 5,
    BufferIndexPointLightInfo       = 6,
    BufferIndexSpotLightInfo        = 7,
    BufferIndexConstants            = 8,
    BufferIndexFireBall             = 10,
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
    VertexAttributePosition = 0,
    VertexAttributeTexcoord = 1,
    VertexAttributeColor    = 2,
    VertexAttributeNormal   = 3,
};

// Texture index values shared between shader and C code to ensure Metal shader texture indices
//   match indices of Metal API texture set calls
typedef NS_ENUM(NSInteger, TextureIndex)
{
    TextureIndexColor           = 0,
    TextureIndexMask            = 1,
    TextureIndexNormalMap       = 2,
    TextureIndexDiffuseMap      = 3,
    TextureIndexSpecularMap     = 4,
    TextureIndexY               = 5,
    TextureIndexCbCr            = 6,
};



// --------- Matrix Uniform --------
// each model will declare a model constant struct and this matrix will be sent to the GPU
// to transform all the vertices of the model into camera space.
// An identiy matrix is sort of a neutral marix, multiply an identity matrix and you get the
// same matrix back
// uniform matrices and materials 3D attributes
typedef struct
{
    // Matrices attributes
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float3x3 normalMatrix;
} Uniform;

typedef struct {
    matrix_float4x4 modelMatrix;
} InstanceUniform;

#endif /* ShaderTypes_h */
