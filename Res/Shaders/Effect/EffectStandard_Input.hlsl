#ifndef EFFECT_STANDARD_INPUT_INCLUDED
#define EFFECT_STANDARD_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


CBUFFER_START(UnityPerMaterial)
    int _BlendMode;
    float _Cutoff;
    //Common
    float _EffectBrightnessR;
    float _EffectBrightnessG;
    float _EffectBrightnessB;
    float _EffectBrightness;
    int _EffectBrightnessSource;
    int _EffectBrightnessCustomDataChannel;
    float _EnableVertexColorBlend;
    float4 _MainTex_ST;
    float4 _MainTexColor;
    float _MainTexIntensity;
    float4 _MainRotationParams;
    int _MainAnimationSource;
    int _MainAnimationCustomDataChannel01;
    int _MainAnimationCustomDataChannel02;
    float _EnableMainTexColorAddition;
    int _MainTexColorRampChannel;
    float4 _MainTexColorAddition;
    //second
    float _EnableSecondGradient;
    int _SecondGradientChannel;
    float4 _SecondColor01;
    float4 _SecondColor02;
    float4 _SecondTex_ST;
    float4 _SecondDissolutionTex_ST;
    float4 _SecondRotationParams;
    int _SecondAnimationSource;
    int _ApplySecondAlpha;
    int _SecondAnimationCustomDataChannel01;
    int _SecondAnimationCustomDataChannel02;
    float _EnableSecondDissolution;
    float4 _SecondDissolutionColor;
    int _SecondDissolutionSource;
    int _SecondDissolutionCustomDataChannel;
    float _SecondDissolutionThreshold;
    float _SecondDissolutionSoftness;
    //Normal
    float4 _NormalMap_ST;
    float _EnableNormalMap;
    half _NormalMapIntensity;
    float4 _LightColor;
    float4 _ShadowColor;

    //flow
    float4 _FlowTex_ST;
    float4 _FlowIntensityToMultiMap; //x :混合main,y：混合second, z:混合mask，w：混合dissolution
    int _FlowAnimationSource;
    int _FlowAnimationCustomDataChannel01;
    int _FlowAnimationCustomDataChannel02;
    // float _FlowIntensity;
    //fresnel
    float _EnableFresnel;
    float _EnableFresnelDebuger;
    half4 _FresnelColor;
    half _FresnelColorIntensity;
    half _FresnelColorPower;
    half _FresnelAlphaMode;
    half _FresnelAlphaIntensity;
    half _FresnelAlphaPower;
    half _FresnelColorSoftnessMin;
    half _FresnelColorSoftnessMax;
    half _FresnelAlphaSoftnessMin;
    half _FresnelAlphaSoftnessMax;


    int _FresnelEdgeMode;

    float _FresnelIntensity;
    float _FresnelPower;
    float _FresnelInvert;
    //mask
    int _MaskAlphaChannel;
    int _MaskAnimationSource;
    float4 _MaskTex_ST;
    half4 _MaskRotationParams; //用于旋转的参数，当值为float4(0.0, 1.0, -1.0, 0.0)时候，是一个标准的90度旋转
    int _MaskAnimationCustomDataChannel01;
    int _MaskAnimationCustomDataChannel02;
    //dissolution
    float4 _DissolutionTex_ST;
    float4 _DissolutionRotationParams;
    int _DissolutionChannel;
    float _DissolutionSoftness;
    int _DissolutionDirection;
    half4 _DissolutionColor;
    int _DissolutionSource;
    float _DissolutionThreshold;
    int _DissolutionCustomDataChannel;
    float4 _VertexAnimationStrength;
    int _DissolutionBlendAlpha;
    //屏幕扭曲
    int _ScreenDistortionChannel;
    float _EnableScreenDistortion;
    float _ScreenDistortionIntensity;
    //depth blend
    float _EnableDepthBlend;
    float _IntersectionSoftness;
    //Ramp
    float _EnableRamp;
    float _EnableRampDebuger;
    float4 _RampMapRotationParams;
    float _RampIntensity;
    //temp enable toggle
    float _EnableSecond;
    float _EnableMask;
    float _EnableMaskDebuger;
    float _EnableDissolution;
    float _EnableFlow;
    int _EnableFlowDebuger;
    float4 _FlowRotationParams;
    int _VertexAnimationStrengthSource;
    int _VertexAnimationStrengthCustomDataChannel01;
    int _VertexAnimationStrengthCustomDataChannel02;
    int _VertexAnimationStrengthCustomDataChannel03;
CBUFFER_END

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_SecondTex);
SAMPLER(sampler_SecondTex);
TEXTURE2D(_MaskTex);
SAMPLER(sampler_MaskTex);
TEXTURE2D(_DissolutionTex);
SAMPLER(sampler_DissolutionTex);
TEXTURE2D(_FlowTex);
SAMPLER(sampler_FlowTex);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_SecondDissolutionTex);
SAMPLER(sampler_SecondDissolutionTex);
TEXTURE2D(_RampMap);
SAMPLER(sampler_RampMap);
#endif
