//
//  FireBallShader.metal
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 28/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

#include <metal_stdlib>
#include "Shader.h"
using namespace metal;

float mod(float x, float y) {
    return x-y * floor(x / y);
}

float3 mod(float3 x, float3 y) {
    return float3(mod(x[0], y[0]), mod(x[1], y[1]), mod(x[2], y[2]));
}

float3 mod289(float3 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 mod289(float4 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 permute(float4 x)
{
    return mod289(((x*34.0)+1.0)*x);
}

float4 taylorInvSqrt(float4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}

float3 fade(float3 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}


// Classic Perlin noise
float cnoise(float3 P)
{
    float3 Pi0 = floor(P); // Integer part for indexing
    float3 Pi1 = Pi0 + float3(1.0); // Integer part + 1
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    float3 Pf0 = fract(P); // Fractional part for interpolation
    float3 Pf1 = Pf0 - float3(1.0); // Fractional part - 1.0
    float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    float4 iy = float4(Pi0.yy, Pi1.yy);
    float4 iz0 = Pi0.zzzz;
    float4 iz1 = Pi1.zzzz;

    float4 ixy = permute(permute(ix) + iy);
    float4 ixy0 = permute(ixy + iz0);
    float4 ixy1 = permute(ixy + iz1);

    float4 gx0 = ixy0 * (1.0 / 7.0);
    float4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    float4 gz0 = float4(0.5) - abs(gx0) - abs(gy0);
    float4 sz0 = step(gz0, float4(0.0, 0.0, 0.0, 0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);

    float4 gx1 = ixy1 * (1.0 / 7.0);
    float4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    float4 gz1 = float4(0.5) - abs(gx1) - abs(gy1);
    float4 sz1 = step(gz1, float4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);

    float3 g000 = float3(gx0.x,gy0.x,gz0.x);
    float3 g100 = float3(gx0.y,gy0.y,gz0.y);
    float3 g010 = float3(gx0.z,gy0.z,gz0.z);
    float3 g110 = float3(gx0.w,gy0.w,gz0.w);
    float3 g001 = float3(gx1.x,gy1.x,gz1.x);
    float3 g101 = float3(gx1.y,gy1.y,gz1.y);
    float3 g011 = float3(gx1.z,gy1.z,gz1.z);
    float3 g111 = float3(gx1.w,gy1.w,gz1.w);

    float4 norm0 = taylorInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    float4 norm1 = taylorInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;

    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, float3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, float3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, float3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, float3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);

    float3 fade_xyz = fade(Pf0);
    float4 n_z = mix(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
    float2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}


// Classic Perlin noise, periodic variant
float pnoise(float3 P, float3 rep)
{
    float3 Pi0 = mod(floor(P), rep); // Integer part, modulo period // mod — compute value of one parameter modulo another
    float3 Pi1 = mod(Pi0 + float3(1.0), rep); // Integer part + 1, mod period
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    float3 Pf0 = fract(P); // Fractional part for interpolation
    float3 Pf1 = Pf0 - float3(1.0); // Fractional part - 1.0
    float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    float4 iy = float4(Pi0.yy, Pi1.yy);
    float4 iz0 = Pi0.zzzz;
    float4 iz1 = Pi1.zzzz;

    float4 ixy = permute(permute(ix) + iy);
    float4 ixy0 = permute(ixy + iz0);
    float4 ixy1 = permute(ixy + iz1);

    float4 gx0 = ixy0 * (1.0 / 7.0);
    float4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    float4 gz0 = float4(0.5) - abs(gx0) - abs(gy0);
    float4 sz0 = step(gz0, float4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);

    float4 gx1 = ixy1 * (1.0 / 7.0);
    float4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    float4 gz1 = float4(0.5) - abs(gx1) - abs(gy1);
    float4 sz1 = step(gz1, float4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);

    float3 g000 = float3(gx0.x,gy0.x,gz0.x);
    float3 g100 = float3(gx0.y,gy0.y,gz0.y);
    float3 g010 = float3(gx0.z,gy0.z,gz0.z);
    float3 g110 = float3(gx0.w,gy0.w,gz0.w);
    float3 g001 = float3(gx1.x,gy1.x,gz1.x);
    float3 g101 = float3(gx1.y,gy1.y,gz1.y);
    float3 g011 = float3(gx1.z,gy1.z,gz1.z);
    float3 g111 = float3(gx1.w,gy1.w,gz1.w);

    float4 norm0 = taylorInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    float4 norm1 = taylorInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;

    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, float3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, float3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, float3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, float3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);

    float3 fade_xyz = fade(Pf0);
    float4 n_z = mix(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
    float2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}

float turbulence( float3 p ) {
    float t = -0.5;
    for (float f = 1.0f ; f <= 10.0f ; f++ ){
        float power = pow( 2.0f, f );
        t += abs( pnoise( float3( power * p ), float3( 10.0f, 10.0f, 10.0f ) ) / power );
    }
    return t;
}

//gl_FragCoord is vec3(vTexCoord,1.0) or vTexColour.xyz
// https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/gl_FragCoord.xhtml
// https://stackoverflow.com/questions/43471463/metal-shading-language-fragcoord-equivalent
float random(float3 gl_FragCoord, float3 scale, float seed ){
    // find out how to calculate gl_fragCoord
    return fract( sin( dot( gl_FragCoord + seed, scale ) ) * 43758.5453f + seed ) ;
}

vertex VertexOut vertex_fireball_shader(const VertexIn vertexIn [[ stage_in ]],
                                         constant FireBallConstants &constants [[ buffer(BufferIndexFireBall) ]],
                                         constant InstanceUniform *instanceUniforms [[ buffer(BufferIndexInstances) ]],
                                         ushort vertexId [[vertex_id]],
                                         ushort instanceId [[instance_id]]) {
    VertexOut vertexOut;

    Uniform uniform = instanceUniforms[instanceId].uniform;
    MaterialInfo material = instanceUniforms[instanceId].material;

    // get a turbulent 3d noise using the normal, normal to high freq
    float noise = 10.0f *  -0.10f * turbulence( 0.5f * vertexIn.normal + constants.time);

    // get a 3d noise using the position, low frequency
    float b = 5.0f * pnoise( 0.05f * vertexIn.position + float3( constants.explosion * constants.time ), float3(100.0f) );

    // compose both noises
    float displacement = - constants.frequency * noise + b;

     // move the position along the normal and transform it
    float3 newPosition = vertexIn.position + vertexIn.normal * displacement;

    // Make position a float4 to perform 4x4 matrix math on it
    float4 position = float4(newPosition.x, newPosition.y, newPosition.z, 1.0f);

    float4x4 projectionMatrix = uniform.projectionMatrix;
    float4x4 modelMatrix = uniform.modelMatrix;
    float3x3 normalMatrix = uniform.normalMatrix;
    float4x4 modelViewMatrix = uniform.viewMatrix * modelMatrix;

    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    vertexOut.position = projectionMatrix * modelViewMatrix * position;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;

    vertexOut.noise = noise;
    vertexOut.color = material.color;
    vertexOut.useTexture = material.useTexture;
    vertexOut.shininess = material.shininess;

    vertexOut.fragPosition = (modelMatrix * position).xyz; // model world position in the scene
    vertexOut.normal = normalMatrix * vertexIn.normal; // model world normal in the scene
    vertexOut.eyePosition = (modelViewMatrix * position);
    vertexOut.eyeNormal  = modelViewMatrix * float4(vertexIn.normal.x, vertexIn.normal.y, vertexIn.normal.z, 0.0f);

    return vertexOut;
}

fragment float4 fragment_fireball_shader(VertexOut vertexIn [[ stage_in ]],
                                          constant CameraInfo &camera [[ buffer(BufferIndexCameraInfo) ]],
                                          texture2d<float, access::sample> texture [[ texture(TextureIndexBaseMap) ]],
                                          sampler sampler2d [[sampler(SamplerIndexMain)]])
{

    // get a random offset
    float3 fragCoord = float3(vertexIn.textureCoordinates.x, vertexIn.textureCoordinates.y, 1.0);
    float r = 0.01f * random(fragCoord, float3( 12.9898f, 78.233f, 151.7182f ), 0.2f );
    // lookup vertically in the texture, using noise and offset
    // to get the right RGB colour
    float2 tPos = float2( 0.0f, 1.3f * vertexIn.noise + r );
    float3 textcolor = texture.sample(sampler2d, tPos).rgb;
    float3 baseColor = vertexIn.useTexture ? textcolor : vertexIn.color.xyz;

    return float4(baseColor.x, baseColor.y, baseColor.z, 1.0);
}
