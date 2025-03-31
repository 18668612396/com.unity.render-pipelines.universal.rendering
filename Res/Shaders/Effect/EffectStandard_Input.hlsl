#ifndef NEMO_EFFECT_STANDARD_INPUT_INCLUDED
#define NEMO_EFFECT_STANDARD_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    float4 _MaskTex_ST;
    float4 _NoiseTex_ST;
    float4 _DissolveTex_ST;

    float4 _UVMoveSpeed1;
    float4 _UVMoveSpeed2;

    float4 _ClipBox;
    float4 _ClipSoftness;

    half4 _MainTexAlphaChannel;
    half4 _Color;

    half4 _MaskTexRGBChannel;
    half4 _MaskTexAlphaChannel;

    half4 _NoiseTexChannel;

    half4 _DissolveTexChannel;
    half4 _DissolveColor;

    half4 _FresnelColor;

    half4 _CombineParam1;
    half4 _CombineParam2;
    half4 _CombineParam3;
    half4 _CombineParam4;
    half4 _CombineParam5;
    half4 _CombineParam6;
CBUFFER_END

#define Combine_MainTexRGBChannel _CombineParam1.x
#define Combine_ColorScale _CombineParam1.y
#define Combine_MainTexUUseVertex _CombineParam1.z
#define Combine_MainTexVUseVertex _CombineParam1.w
#define Combine_AlphaScale _CombineParam2.x
#define Combine_FinalAlphaScale _CombineParam2.y
#define Combine_NoiseOffset _CombineParam2.z
#define Combine_NoiseScale _CombineParam2.w
#define Combine_DissolveAmount _CombineParam3.x
#define Combine_DissolveColorScale _CombineParam3.y
#define Combine_DissolveColorPercent _CombineParam3.z
#define Combine_DissolveEdgeWidth _CombineParam3.w
#define Combine_DissolveEdgeWidthInv _CombineParam4.x
#define Combine_DissolveSoftness _CombineParam4.y
#define Combine_FresnelBlendMode _CombineParam4.z
#define Combine_FresnelPower _CombineParam4.w
#define Combine_FresnelScale _CombineParam5.x
#define Combine_MainTexUSlantScale _CombineParam6.x
#define Combine_MainTexVSlantScale _CombineParam6.y
#define Combine_NoiseTexUSlantScale _CombineParam6.z
#define Combine_NoiseTexVSlantScale _CombineParam6.w

TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);
TEXTURE2D(_MaskTex);SAMPLER(sampler_MaskTex);
TEXTURE2D(_NoiseTex);SAMPLER(sampler_NoiseTex);
TEXTURE2D(_DissolveTex);SAMPLER(sampler_DissolveTex);

#endif