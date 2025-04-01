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
        _MainTexIntensity("Intensity", Range(0, 10)) = 1
        [Toggle]_EnableMainTexColorAddition("Enable MainTex Color Addition", Float) = 0
        [Enum(X, 0, Y, 1, Z, 2, W, 3)]_MainTexColorRampChannel("MainTex Color Ramp Channel", Float) = 0
        [HDR]_MainTexColorAddition("Color Addition", Color) = (0,0,0,0)
        _MainRotationParams("_MainRotationParams",Vector) = (1,0,0,0)
        [Enum(Disable, 0, CustomData01, 1, CustomData02, 2,Time,3)]_MainAnimationSource("Mask Animation Source", Int) = 0//根据什么来动画，0：不动，1：CustomData01，3：CustomData02
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_MainAnimationCustomDataChannel01("Mask CustomData Channel01", Int) = 0//U方向通道选择
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_MainAnimationCustomDataChannel02("Mask CustomData Channel02", Int) = 0//V方向通道选择
        //Normal
        [Toggle(ENABLE_NORMALMAP_ON)] _EnableNormalMap ("NormalMap On", Float) = 0
        _NormalMap("NormalMap", 2D) = "bump" {}
        _NormalMapIntensity ("NormalMap Intensity", Range(0, 5)) = 1
        _LightColor("Light Color", Color) = (1,1,1,1)
        _ShadowColor("Shadow Color", Color) = (0,0,0,1)
        //Secondary
        [Toggle(ENABLE_SECOND_ON)] _EnableSecond ("Second On", Float) = 0
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
        [Toggle(ENABLE_RAMP_ON)] _EnableRamp ("Ramp On", Float) = 0
        _EnableRampDebuger("Enable Ramp Debuger", Float) = 0
        _RampMap("RampMap", 2D) = "white" {}
        _RampMapRotationParams("_SecondRotationParams",Vector) = (1,0,0,0)
        _RampIntensity("Ramp Intensity", Range(0, 100)) = 1
        //Flow
        [Toggle(ENABLE_FLOW_ON)] _EnableFlow ("Flow On", Float) = 0
        _FlowTex("FlowTex", 2D) = "white" {}
        _FlowSpeed("Flow Params", Vector) = (1, 0, 0, 1)//xy 第一层，zw 第二层
        _FlowIntensityToMultiMap("Flow Intensity To MultiMap",Vector) = (1,1,1,1)
        [Toggle]_EnableVertexAnimation("Enable Vertex Animation", Float) = 0//开启顶点动画
        _VertexAnimationStrength("Enable Vertex Animation Strength", Range(0,1)) = 0//开启顶点动画强度

        //Mask
        [Toggle(ENABLE_MASK_ON)] _EnableMask ("Mask On", Float) = 0
        [Toggle]_EnableMaskDebuger("Enable Mask Debuger", Float) = 0
        _MaskTex("MaskTex", 2D) = "white" {}
        _MaskRotationParams("Mask Rotation Params", Vector) = (1, 0, 0, 0)
        [Enum(R, 0, G, 1, B, 2, A, 3)]_MaskAlphaChannel("Mask Alpha Channel", Float) = 0
        [Enum(Disable, 0, CustomData01, 1, CustomData02, 2,Time,3)]_MaskAnimationSource("Mask Animation Source", Int) = 0//根据什么来动画，0：时间，1：CustomData01，3：CustomData02
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_MaskAnimationCustomDataChannel01("Mask CustomData Channel01", Int) = 0//U方向通道选择
        [Enum(Disable,0,X, 1, Y, 2, Z, 3, W, 4)]_MaskAnimationCustomDataChannel02("Mask CustomData Channel02", Int) = 0//V方向通道选择

        //Dissolution
        [Toggle(ENABLE_DISSOLUTION_ON)] _EnableDissolution ("Dissolution On", Float) = 0
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
        [Toggle(ENABLE_DEPTHBLEND_ON)] _EnableDepthBlend ("Dissolution On", Float) = 0
        _IntersectionSoftness ("Intersection Softness", Range(0, 1)) = 0.1
        //fresnel
        [Toggle] _EnableFresnel("Enable Fresnel", Float) = 0
        [Toggle] _EnableFresnelDebuger("Enable Fresnel Debuger", Float) = 0
        [Toggle] _FresnelInvert("Fresnel Invert", Float) = 0
        [Enum(HardEdge, 0, SoftEdge, 1)] _FresnelEdgeMode("Fresnel Edge Type", Float) = 0
        _FresnelColor("Fresnel Color", Color) = (1,1,1,1)
        _FresnelIntensity("Fresnel Intensity", Range(0, 10)) = 1
        _FresnelPower("Fresnel Power", Range(0, 10)) = 1
        //屏幕扭曲
        [Toggle]_EnableScreenDistortion("Enable Screen Distortion", Float) = 0
        _ScreenDistortionChannel("Screen Distortion Channel", Float) = 3//根据当前材质球输出的RGBA做选择
        _ScreenDistortionIntensity("Screen Distortion Intensity", Range(0, 10)) = 0
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
            #pragma shader_feature_local ENABLE_MASK_ON
            #pragma shader_feature_local ENABLE_SECOND_ON
            #pragma shader_feature_local ENABLE_SECOND_ON
            ENDHLSL
        }
        Pass
        {
            Name "ScreenDistortion"
            Tags
            {
                "LightMode" = "UniversalScreenDistortion"
            }

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
            #pragma shader_feature_local ENABLE_MASK_ON
            #pragma shader_feature_local ENABLE_SECOND_ON
            #pragma shader_feature_local ENABLE_SECOND_ON
            ENDHLSL
        }
    }
    // Fallback "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "EffectStandardShaderEditor"
}