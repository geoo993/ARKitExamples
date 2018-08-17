//
//  ShaderTypes.h
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 21/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
// https://stackoverflow.com/questions/38820120/is-it-possible-to-use-metal-data-types-in-objective-c

#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif
#import <simd/simd.h>

// --------- Buffers and Indexes --------
// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef NS_ENUM(NSInteger, BufferIndex)
{
    BufferIndexMeshVertices         = 0,
    BufferIndexMeshGenerics         = 1,
    BufferIndexMeshIndices          = 2,
    BufferIndexUniforms             = 3,
    BufferIndexInstances            = 4,
    BufferIndexCameraInfo           = 5,
    BufferIndexMaterialInfo         = 6,
    BufferIndexDirectionalLightInfo = 7,
    BufferIndexPointLightInfo       = 8,
    BufferIndexSpotLightInfo        = 9,
    BufferIndexConstants            = 10,
    BufferIndexFireBall             = 11,
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
    VertexAttributePosition = 0,
    VertexAttributeNormal   = 1,
    VertexAttributeTexcoord = 2,
};

typedef NS_ENUM(NSInteger, ImageVertexAttribute)
{
    ImageVertexAttributePosition = 0,
    ImageVertexAttributeTexcoord = 1,
};

// Texture index values shared between shader and C code to ensure Metal shader texture indices
//   match indices of Metal API texture set calls
typedef NS_ENUM(NSInteger, TextureIndex)
{
    TextureIndexBaseMap         = 0,
    TextureIndexNormalMap       = 1,
    TextureIndexDiffuseMap      = 2,
    TextureIndexSpecularMap     = 3,
    TextureIndexY               = 4,
    TextureIndexCbCr            = 5,
};

// Sampler index values shared between shader and C code to ensure Metal shader texture indices
//   match indices of Metal API texture set calls
// this tells what index the sampler state is in
typedef NS_ENUM(NSInteger, SamplerIndex)
{
    SamplerIndexMain            = 0,
};


// --------- Materials --------
typedef struct
{
    vector_float4 color;
    float shininess; //Shininess values typically range from 1 to 128. Higher values result in more focussed specular highlights.
    bool useTexture;
} MaterialInfo;


// --------- Matrix Uniform --------
// each model will declare a model constant struct and this matrix will be sent to the GPU
// to transform all the vertices of the model into camera space.
// An identiy matrix is sort of a neutral marix, multiply an identity matrix and you get the
// same matrix back
// uniform matrices and materials 3D attributes
//// Structure shared between shader and C code to ensure the layout of uniform data accessed in
// Metal shaders matches the layout of uniform data set in C code
typedef struct
{
    // Matrices attributes
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float3x3 normalMatrix;
} Uniform;

// --------- Instance Uniform --------
typedef struct {
    Uniform uniform;
    MaterialInfo material;
} InstanceUniform;

// --------- Camera --------
typedef struct {
    vector_float3 position;
    vector_float3 front;
} CameraInfo;

// --------- Light --------
#define NUMBER_OF_DIRECTIONAL_LIGHTS 1
#define NUMBER_OF_POINT_LIGHTS 5
#define NUMBER_OF_SPOT_LIGHTS 1

typedef struct
{
    vector_float3 color;
    float intensity;
    float ambient;
    float diffuse;
    float specular;
} BaseLight;

typedef struct
{
    float continual;
    float linear;
    float exponent;
} Attenuation;

typedef struct
{
    BaseLight base;
    vector_float3 direction;
} DirectionalLight;

typedef struct
{
    BaseLight base;
    Attenuation atten;
    vector_float3 position;
} PointLight;

typedef struct
{
    PointLight pointLight;
    vector_float3 direction;
    float cutOff;
    float outerCutOff;
} SpotLight;


// --------- Custom --------
typedef struct
{
    float time;
    float frequency;
    float explosion;
} FireBallConstants;


#endif /* ShaderTypes_h */
