
#include <metal_stdlib>
#import "LYShaderTypes.h"

using namespace metal;

typedef struct
{
    float4 clipSpacePosition [[position]];
    
    float2 textureCoordinate;
    
} RasterizerData;

vertex RasterizerData
vertexShader(uint vertexID [[ vertex_id ]],
             constant LYVertex *vertexArray [[ buffer(LYVertexInputIndexVertices) ]]) {
    RasterizerData out;
    out.clipSpacePosition = vertexArray[vertexID].position;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    return out;
}

fragment float4
samplingShader(RasterizerData input [[stage_in]],
               texture2d<float> textureY [[ texture(LYFragmentTextureIndexTextureY) ]],
               texture2d<float> textureUV [[ texture(LYFragmentTextureIndexTextureUV) ]],
               constant LYConvertMatrix *convertMatrix [[ buffer(LYFragmentInputIndexMatrix) ]])
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    float3 yuv = float3(textureY.sample(textureSampler, input.textureCoordinate).r,
                          textureUV.sample(textureSampler, input.textureCoordinate).rg);
    
    float3 rgb = convertMatrix->matrix * (yuv + convertMatrix->offset);
        
    return float4(rgb, 1.0);
}
