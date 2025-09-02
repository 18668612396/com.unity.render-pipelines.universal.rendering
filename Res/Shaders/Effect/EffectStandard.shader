Shader "XEffect/EffectStandard"
{
    Properties
    {
        //Common
        [Toggle]_EnableVertexColorBlend("Enable Vertex Color Blend", Float) = 1
        _EffectBrightness("特效亮度", Range(0, 200)) = 1
        [Enum(Disable, 0, CustomData01, 1, CustomData02, 2)]_EffectBrightnessSource("亮度来源", Float) = 0
        [Enum(X,0,Y, 1, Z, 2, W, 3)]_EffectBrightnessCustomDataChannel("亮度CustomData01", Int) = 0
        _EffectTransparence("特效透明度", Range(0, 1)) = 1
        _Cutoff("Cutoff", Range(0, 1)) = 0.5
        //Main
        _MainTex("MainTex", 2D) = "white" {}
        _MainTexColor("Color", Color) = (1,1,1,1)
        _MainTexIntensity("Intensity", Range(0, 50)) = 1
        [Toggle]_EnableMainTexColorAddition("Enable MainTex Color Addition", Float) = 0
        [Enum(X, 0, Y, 1, Z, 2, W, 3)]_MainTexColorRampChannel("MainTex Color Ramp Channel", Float) = 0
        [HDR]_MainTexColorAddition("Color Addition", Color) = (0,0,0,0)
        _MainRotationParams("_MainRotationParams",Vector) = (1,0,0,0)
        [Enum(Disable, 0, CustomData01, 1, CustomData02, 2,Time,3)]_MainAnimationSource("Mask Animation Source", Int) = 0//根据什么来动画，0：不动，1：CustomData01，3：CustomData02
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_MainAnimationCustomDataChannel01("Mask CustomData Channel01", Int) = 0//U方向通道选择
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_MainAnimationCustomDataChannel02("Mask CustomData Channel02", Int) = 0//V方向通道选择
        _MainAnimationChannelAndSpeed("Main Animation Channel And Speed", Vector) = (0, 0, 0, 0)//X: X方向通道选择，Y: Y方向通道选择，Z: X方向速度，W: Y方向速度
        //Normal
        [Toggle(_ENABLE_NORMALMAP_ON)] _EnableNormalMap ("NormalMap On", Float) = 0
        _NormalMap("NormalMap", 2D) = "bump" {}
        _NormalMapIntensity ("NormalMap Intensity", Range(0, 5)) = 1
        _LightColor("Light Color", Color) = (1,1,1,1)
        _ShadowColor("Shadow Color", Color) = (0,0,0,1)
        //Secondary
        [Toggle(_ENABLE_SECOND_ON)] _EnableSecond ("Second On", Float) = 0
        [Toggle]_EnableMultiMainAlpha("Enable Multi Main Alpha", Float) = 0//是否启用主纹理的透明度乘以第二纹理的透明度
        _SecondTex("SecondTex", 2D) = "white" {}
        [HDR]_SecondColor01("SecondColor01", Color) = (1,1,1,1)
        [HDR]_SecondColor02("SecondColor02", Color) = (1,1,1,1)
        [Toggle]_EnableSecondGradient("Enable Second Gradient", Float) = 0
        [Enum(X,0,Y, 1, Z, 2, W, 3)]_SecondGradientChannel("Second Gradient Channel", Float) = 0
        [Toggle] _ApplySecondAlpha("Apply Second Alpha", Float) = 0
        _SecondRotationParams("_SecondRotationParams",Vector) = (1,0,0,0)
        [Enum(Disable, 0, CustomData01, 1, CustomData02, 2,Time,3)]_SecondAnimationSource("Mask Animation Source", Int) = 0//根据什么来动画，0：不动，1：CustomData01，3：CustomData02
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_SecondAnimationCustomDataChannel01("Mask CustomData Channel01", Int) = 0//U方向通道选择
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_SecondAnimationCustomDataChannel02("Mask CustomData Channel02", Int) = 0//V方向通道选择

        [Toggle]_EnableSecondDissolution("Second Dissolution", int) = 0
        _SecondDissolutionTex("Second DissolutionTex", 2D) = "white" {}
        [HDR]_SecondDissolutionColor ("Second Dissolution Color", Color) = (1,1,1,1)
        [Enum(Properties, 0, VertexColorAlpha, 1, CustomData01, 2,CustomData02,3)] _SecondDissolutionSource("_DissolutionSource",Int) = 0
        [Enum(X, 0, Y, 1, Z, 2, W, 3)] _SecondDissolutionCustomDataChannel("_DissolutionCustomDataChannel",Int) = 0
        _SecondDissolutionThreshold("Second Dissolution Threshold", Range(1, 0)) = 0.5
        _SecondDissolutionSoftness ("Second Dissolution Softness", Range(0, 1)) = 0.1
        //Ramp
        [Toggle(_ENABLE_RAMP_ON)] _EnableRamp ("Ramp On", Float) = 0
        _EnableRampDebuger("Enable Ramp Debuger", Float) = 0
        [Enum(UV,0,R, 1,G,2,B,3,A,4)]_RampMapSource("Ramp Channel", Float) = 0
        _RampMap("RampMap", 2D) = "white" {}
        _RampMapRotationParams("_SecondRotationParams",Vector) = (1,0,0,0)
        _RampIntensity("Ramp Intensity", Range(0, 100)) = 1
        //Flow
        [Toggle(_ENABLE_FLOW_ON)] _EnableFlow ("Flow On", Float) = 0
        _EnableFlowDebuger("Enable Flow Debuger", Float) = 0
        _FlowTex("FlowTex", 2D) = "white" {}
        _FlowIntensityToMultiMap("Flow Intensity To MultiMap",Vector) = (1,1,1,1)
        [Enum(X, 0, Y, 1, Z, 2, W, 3)]_FlowTexChannel("Flow Channel", Float) = 3//根据当前材质球输出的RGBA做选择
        _FlowRotationParams ("_FlowRotationParams",Vector) = (1,0,0,0)
        [Enum(Disable, 0, CustomData01, 1, CustomData02, 2,Time,3)]_FlowAnimationSource("Flow Animation Source", Int) = 0//根据什么来动画，0：时间，1：CustomData01，3：CustomData02
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_FlowAnimationCustomDataChannel01("Flow CustomData Channel01", Int) = 0//U方向通道选择
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_FlowAnimationCustomDataChannel02("Flow CustomData Channel02", Int) = 0//V方向通道选择
        [Enum(Properties, 0, CustomData01, 1, CustomData02, 2)]_VertexAnimationStrengthSource("Flow Animation Source", Int) = 0//根据什么来动画，0：时间，1：CustomData01，3：CustomData02
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_VertexAnimationStrengthCustomDataChannel01("Flow CustomData Channel01", Int) = 0//X方向通道选择
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_VertexAnimationStrengthCustomDataChannel02("Flow CustomData Channel02", Int) = 0//Y方向通道选择
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_VertexAnimationStrengthCustomDataChannel03("Flow CustomData Channel02", Int) = 0//Z方向通道选择
        _VertexAnimationStrength("Enable Vertex Animation Strength", Vector) = (0, 0, 0, 0)//XYZ : 自身空间偏移，W:法线朝向偏移
        //Mask
        [Toggle(_ENABLE_MASK_ON)] _EnableMask ("Mask On", Float) = 0
        [Toggle]_EnableMaskDebuger("Enable Mask Debuger", Float) = 0
        _MaskTex("MaskTex", 2D) = "white" {}
        _MaskIntensity("Mask Intensity", Range(0, 1)) = 1
        [Toggle]_InvertMask("Invert Mask", Float) = 0
        _MaskRotationParams("Mask Rotation Params", Vector) = (1, 0, 0, 0)
        [Enum(R, 0, G, 1, B, 2, A, 3)]_MaskAlphaChannel("Mask Alpha Channel", Float) = 0
        [Enum(Disable, 0, CustomData01, 1, CustomData02, 2,Time,3)]_MaskAnimationSource("Mask Animation Source", Int) = 0//根据什么来动画，0：时间，1：CustomData01，3：CustomData02
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_MaskAnimationCustomDataChannel01("Mask CustomData Channel01", Int) = 0//U方向通道选择
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_MaskAnimationCustomDataChannel02("Mask CustomData Channel02", Int) = 0//V方向通道选择

        //Dissolution
        [Toggle(_ENABLE_DISSOLUTION_ON)] _EnableDissolution ("Dissolution On", Float) = 0
        _DissolutionTex("DissolutionTex", 2D) = "white" {}
        [Enum(R, 0, G, 1, B, 2, A, 3)] _DissolutionChannel("_DissolutionChannel",int) = 0
        [HDR]_DissolutionColor("Dissolution Color", Color) = (1,1,1,1)
        [Enum(Disable,0,UV_X,1,UV_Y,2)]_DissolutionDirection("Dissolution Direction", int) = 0
        [Enum(Properties, 0, VertexColorAlpha, 1, CustomData01, 2,CustomData02,3)] _DissolutionSource("_DissolutionSource",Int) = 0
        _DissolutionThreshold("_DissolutionThreshold",Range(1,-1)) = 1
        [Toggle]_DissolutionBlendAlpha("Dissolution Blend Alpha", Float) = 1
        [Enum(X, 0, Y, 1, Z, 2, W, 3)] _DissolutionCustomDataChannel("_DissolutionCustomDataChannel",Int) = 0

        _DissolutionSoftness("Dissolution Softness", Range(0,1)) = 0.1
        _DissolutionRotationParams("Dissolution Rotation Params", Vector) = (1, 0, 0, 0)
        //Depth
        [Toggle(_ENABLE_DEPTHBLEND_ON)] _EnableDepthBlend ("Dissolution On", Float) = 0
        [Enum(SoftParticle, 0, HardParticle, 1)] _DepthBlendMode("Depth Blend Mode", Float) = 0
        [HDR]_DepthBlendColor("Depth Blend Color", Color) = (1,1,1,1)
        _IntersectionSoftness ("Intersection Softness", Range(0, 1)) = 0.1
        //fresnel
        [Toggle(_ENABLE_FRESNEL_ON)] _EnableFresnel("Enable Fresnel", Float) = 0
        [Toggle] _EnableFresnelDebuger("Enable Fresnel Debuger", Float) = 0
        _FresnelPower("Fresnel Power", Range(0, 10)) = 1
        [HDR]_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
        _FresnelColorIntensity("Fresnel Color Intensity", Range(0, 1)) = 1
        _FresnelColorPower("Fresnel Color Power", Range(0, 10)) = 1
        _FresnelColorSoftnessMin("Fresnel Color Softness Min", Range(0, 1)) = 0
        _FresnelColorSoftnessMax("Fresnel Color Softness Max", Range(0, 1)) = 1

        [Enum(Decrease, 0, Increase, 1)] _FresnelAlphaMode("Fresnel Alpha Mode", Float) = 0
        [Toggle]_EnableFresnelAlpha("Enable Fresnel Alpha", float) = 1
        _FresnelAlphaIntensity("Fresnel Alpha Intensity", Range(0, 1)) = 1
        _FresnelAlphaPower("Fresnel Alpha Power", Range(0, 10)) = 1
        _FresnelAlphaSoftnessMin("Fresnel Alpha Softness Min", Range(0, 1)) = 0
        _FresnelAlphaSoftnessMax("Fresnel Alpha Softness Max", Range(0, 1)) = 1

        //屏幕扭曲
        [Toggle(_ENABLE_SCREENDISTORTION_ON)]_EnableScreenDistortion("Enable Screen Distortion", Float) = 0
        [Toggle] _EnableScreenDistortionNormal("Enable Screen Distortion Normal", Float) = 0
        _ScreenDistortionChannel("Screen Distortion Channel", Float) = 3//根据当前材质球输出的RGBA做选择
        _ScreenDistortionIntensity("Screen Distortion Intensity", Range(0, 1)) = 0.5
        //渲染状态，通用
        [Enum()]_BlendMode("BlendMode", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest", Float) = 4.0
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend", Float) = 0.0
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlendA("_SrcBlendA", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlendA("_DstBlendA", Float) = 0.0
        [Toggle]_ZWrite("_ZWrite", Float) = 0.0
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Float) = 2
        _RenderQueueOffset("Queue offset", Range(-20,20)) = 0.0

        //模板测试，暂时禁用
        [Header(Stencil)]
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

    }
    //DummyShaderTextExporter
    SubShader
    {
        LOD 200
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
            "LightMode" = "UniversalForward"
        }
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        Pass
        {
            Name "EffectStandard"
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendA] [_DstBlendA]
            BlendOp Add
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            Cull [_CullMode]

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
            #include "EffectStandard_Input.hlsl"
            #include "EffectStaandard_Function.hlsl"
            #include "EffectStandard_Passes.hlsl"
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma shader_feature_local_fragment  _ENABLE_MASK_ON
            #pragma shader_feature_local_fragment _ENABLE_SECOND_ON
            #pragma shader_feature_local_fragment _ENABLE_RAMP_ON
            #pragma shader_feature_local_fragment _ENABLE_FLOW_ON
            #pragma shader_feature_local_fragment _ENABLE_DISSOLUTION_ON
            #pragma shader_feature_local_fragment _ENABLE_DEPTHBLEND_ON
            #pragma shader_feature_local_fragment _ENABLE_FRESNEL_ON
            #pragma shader_feature_local_fragment _ENABLE_NORMALMAP_ON
            ENDHLSL
        }
//        Pass
//        {
//            Name "ScreenDistortion"
//            Tags
//            {
//                "LightMode" = "UniversalScreenDistortion"
//            }
//
//            //            Blend [_SrcBlend] [_DstBlend], [_SrcBlendA] [_DstBlendA]
//            //            BlendOp Add
//            //            ZTest [_ZTest]
//            //            ZWrite [_ZWrite]
//            //            Cull [_CullMode]
//            HLSLPROGRAM
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
//            #include "EffectStandard_Input.hlsl"
//            #include "EffectStaandard_Function.hlsl"
//            #include "EffectStandard_Passes.hlsl"
//            #pragma vertex Vertex
//            #pragma fragment Fragment
//            #pragma shader_feature_local_fragment  _ENABLE_MASK_ON
//            #pragma shader_feature_local_fragment _ENABLE_SECOND_ON
//            #pragma shader_feature_local_fragment _ENABLE_RAMP_ON
//            #pragma shader_feature_local_fragment _ENABLE_FLOW_ON
//            #pragma shader_feature_local_fragment _ENABLE_DISSOLUTION_ON
//            #pragma shader_feature_local_fragment _ENABLE_DEPTHBLEND_ON
//            #pragma shader_feature_local_fragment _ENABLE_FRESNEL_ON
//            #pragma shader_feature_local_fragment _ENABLE_NORMALMAP_ON
//            ENDHLSL
//        }
    }
    // Fallback "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "EffectStandardShaderEditor"
}