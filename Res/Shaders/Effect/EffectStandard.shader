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
        _ScreenDistortionTexture("Screen Distortion Texture", 2D) = "bump" {}
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
            Name "Unlit"
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendA] [_DstBlendA]
            BlendOp Add
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            Cull [_CullMode]

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma shader_feature_local ENABLE_MASK_ON
            #pragma shader_feature_local ENABLE_SECOND_ON
            #pragma shader_feature_local ENABLE_SECOND_ON
            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 Color : COLOR;
                float4 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 texcoord0 : TEXCOORD00;
                float4 custom01 : TEXCOORD01;
                float4 custom02 : TEXCOORD02;
            };

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
                float4 _FlowSpeed;
                float4 _FlowIntensityToMultiMap; //x :混合main,y：混合second, z:混合mask，w：混合dissolution
                // float _FlowIntensity;
                //fresnel
                float _EnableFresnel;
                float _EnableFresnelDebuger;
                int _FresnelEdgeMode;
                half4 _FresnelColor;
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
                float _EnableVertexAnimation;
                float _VertexAnimationStrength;
                int _DissolutionBlendAlpha;
                //屏幕扭曲
                half4 _ScreenDistortionTexture_ST;
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
            TEXTURE2D(_ScreenDistortionTexture);
            SAMPLER(sampler_ScreenDistortionTexture);
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD00;
                float4 color : COLOR;
                float2 mask_uv : MASK_UV;
                float2 dissolution_uv : DISSOLUTION_UV;
                float4 flow_uv : FLOW_UV;
                float2 normal_uv : NORMAL_UV;
                float4 custom01 : TEXCOORD01;
                float4 custom02 : TEXCOORD02;
                float4 tangentWS : TEXCOORD03;
                float4 bitangentWS : TEXCOORD04;
                float4 normalWS : TEXCOORD05;
                float4 screenPos : TEXCOORD06;
                float4 second_uv : TEXCOORD07;
                float2 base_uv : TEXCOORD08;
                float2 ramp_uv : TEXCOORD09;
            };

            float2 RotateTextureUV(float2 uv, float4 rotationParams)
            {
                return float2(
                    dot(uv, float2(rotationParams.x, rotationParams.y)) + rotationParams.z,
                    dot(uv, float2(-rotationParams.y, rotationParams.x)) + rotationParams.w
                );
            }

            float2 ApplyUVAnimation(Attributes input, int animationSource, int channel01, int channel02, float4 _ST = float4(1, 1, 0, 0))
            {
                float2 mainAnimation = 0;
                if (animationSource == 1)
                {
                    mainAnimation = float2(input.custom01[channel01 - 1], input.custom01[channel02 - 1]);
                }
                else if (animationSource == 2)
                {
                    mainAnimation = float2(input.custom02[channel01 - 1], input.custom02[channel02 - 1]);
                }
                else if (animationSource == 3)
                {
                    mainAnimation = _Time.y * _ST.zw * min(float2(channel01, channel02), 1);
                }
                return mainAnimation;
            }

            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                float2 mainAnimation = ApplyUVAnimation(input, _MainAnimationSource, _MainAnimationCustomDataChannel01, _MainAnimationCustomDataChannel02, _MainTex_ST);
                output.uv.xy = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _MainTex), _MainRotationParams) + mainAnimation;
                float2 secondAnimation = ApplyUVAnimation(input, _SecondAnimationSource, _SecondAnimationCustomDataChannel01, _SecondAnimationCustomDataChannel02, _SecondTex_ST);
                output.second_uv.xy = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _SecondTex) + secondAnimation, _SecondRotationParams);
                output.second_uv.zw = TRANSFORM_TEX(input.texcoord0, _SecondDissolutionTex);
                float2 maskAnimation = ApplyUVAnimation(input, _MaskAnimationSource, _MaskAnimationCustomDataChannel01, _MaskAnimationCustomDataChannel02, _MaskTex_ST);
                output.mask_uv = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _MaskTex), _MaskRotationParams) + maskAnimation;
                output.dissolution_uv = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _DissolutionTex), _DissolutionRotationParams);
                //flow
                output.flow_uv = input.texcoord0.xyxy * _FlowTex_ST.xyxy + _FlowTex_ST.zwzw + _FlowSpeed * _Time.y;
                float2 flowVector = float2(0.0, 0.0);
                if (_EnableFlow)
                {
                    half2 sample_flow01 = SAMPLE_TEXTURE2D_LOD(_FlowTex, sampler_FlowTex, output.flow_uv.xy, 0).xy;
                    half2 sample_flow02 = SAMPLE_TEXTURE2D_LOD(_FlowTex, sampler_FlowTex, output.flow_uv.zw, 0).xy;
                    half2 sample_flow = sample_flow01 + sample_flow02;
                    flowVector = sample_flow - 1.0;
                }
                float3 positionOS = input.positionOS.xyz + input.normalOS * flowVector.x * _VertexAnimationStrength * _EnableVertexAnimation;
                //normal
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
                output.tangentWS = float4(normalInput.tangentWS, vertexInput.positionWS.x);
                output.bitangentWS = float4(normalInput.bitangentWS, vertexInput.positionWS.y);
                output.normalWS = float4(normalInput.normalWS, vertexInput.positionWS.z);
                output.normal_uv = TRANSFORM_TEX(input.texcoord0, _NormalMap);

                output.color = input.Color;
                output.custom01 = input.custom01;
                output.custom02 = input.custom02;
                output.positionCS = vertexInput.positionCS;
                output.screenPos = ComputeScreenPos(output.positionCS);
                output.base_uv = input.texcoord0.xy;

                output.ramp_uv = RotateTextureUV(input.texcoord0, _RampMapRotationParams);
                return output;
            }

            float GetDissolutionFactor(float noise, float threshold, float feather)
            {
                float sMin;
                float sMax;

                float base = lerp(0 - feather, 1 + feather, threshold);
                sMin = base - feather;
                sMax = base + feather;
                float sValue = noise;
                float sFactor = smoothstep(sMin, sMax, sValue);
                return sFactor;
            }


            float2 ApplyFlowDistortion(float2 uv, float2 flowVector, float intensity)
            {
                return uv + flowVector * intensity;
            }

            half4 Fragment(Varyings input) : SV_Target
            {

                half3 finalRGB = 0;
                half finalAlpha = 1;

                //整体亮度控制器
                float brightness;
                {
                    float4 source = 0;
                    source.x = _EffectBrightness;
                    source.y = input.custom01[_EffectBrightnessCustomDataChannel];
                    source.z = input.custom02[_EffectBrightnessCustomDataChannel];
                    brightness = source[_EffectBrightnessSource];
                }

                float2 flowVector = float2(0.0, 0.0);
                if (_EnableFlow > 0.5)
                {
                    half2 sample_flow01 = SAMPLE_TEXTURE2D(_FlowTex, sampler_FlowTex, input.flow_uv.xy).xy;
                    half2 sample_flow02 = SAMPLE_TEXTURE2D(_FlowTex, sampler_FlowTex, input.flow_uv.zw).xy;
                    half2 sample_flow = sample_flow01 + sample_flow02;
                    flowVector = sample_flow - 1.0;
                }
                //main
                float2 main_uv = ApplyFlowDistortion(input.uv.xy, flowVector, _FlowIntensityToMultiMap.x);
                half4 sample_main = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, main_uv);

                finalRGB = sample_main.rgb * _MainTexColor.rgb * input.color.rgb * _MainTexIntensity;
                finalAlpha = sample_main.a * _MainTexColor.a * input.color.a;

                if (_EnableSecond > 0.5)
                {
                    //second
                    float2 second_uv = ApplyFlowDistortion(input.second_uv.xy, flowVector, _FlowIntensityToMultiMap.y);
                    half4 sample_second = SAMPLE_TEXTURE2D(_SecondTex, sampler_SecondTex, second_uv);
                    half4 secondColor = 1;
                    if (_EnableSecondGradient > 0.5)
                    {
                        secondColor = lerp(_SecondColor01, _SecondColor02, sample_second[_SecondGradientChannel]);
                    }
                    else
                    {
                        secondColor = sample_second * _SecondColor01;
                    }

                    half secondAlpha = 1;
                    if (_EnableSecondDissolution > 0.5)
                    {
                        float dissolutionValue;
                        {
                            //先将所有可能的放到另一个float3内，然后根据type进行区分，不使用if函数
                            float4 source;
                            source.x = _SecondDissolutionThreshold;
                            source.y = input.color.a;
                            source.z = input.custom01[_SecondDissolutionCustomDataChannel];
                            source.w = input.custom02[_SecondDissolutionCustomDataChannel];
                            dissolutionValue = 1 - source[_SecondDissolutionSource];
                        }
                        half4 dissolutionColor = 0;
                        dissolutionColor.rgb = lerp(secondColor.xyz, _SecondDissolutionColor.xyz, _SecondDissolutionColor.w);

                        // float threshold = dissolutionValue;
                        // float width = _SecondDissolutionSoftness;
                        //
                        // half dissolutionFactor = smoothstep(threshold, threshold + width, sample_second.a);
                        // // half4 finalDissolution = dissolutionColor * (1 - dissolutionFactor);
                        // // secondColor.rgb += finalDissolution.rgb;
                        float feather = max(_SecondDissolutionSoftness, 9.99999975e-05);
                        half factor = GetDissolutionFactor(sample_second.a, dissolutionValue, feather);
                        secondColor.rgb = lerp(dissolutionColor, secondColor, factor);
                        secondAlpha = factor;
                    }
                    else
                    {
                        secondAlpha = secondColor.w;
                    }
                    finalRGB.rgb = lerp(finalRGB.rgb, secondColor, secondAlpha);
                }

                if (_EnableRamp > 0.5)
                {
                    half4 sample_ramp = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, input.ramp_uv);
                    finalRGB.rgb = finalRGB.rgb * sample_ramp.rgb * _RampIntensity;
                    finalAlpha *= sample_ramp.a;
                    if (_EnableRampDebuger > 0.5)
                    {
                        return half4(sample_ramp.rgb, 1);
                    }
                }
                
                //normal
                if (_EnableNormalMap > 0.5)
                {
                    float3x3 TBN = float3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
                    half3 sample_normal = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.normal_uv.xy).xyz;
                    half3 normalTS = (sample_normal.xyz * 2.0 - 1.0) * _NormalMapIntensity;
                    normalTS.z = sqrt(1.0 - saturate(dot(normalTS.xy, normalTS.xy)));
                    half3 normalWS = normalize(mul(normalTS, TBN));
                    half3 lightDir = normalize(_MainLightPosition);
                    half NdotL = saturate(dot(normalWS, lightDir));
                    half3 lightColor = lerp(_ShadowColor, _LightColor, NdotL);
                    finalRGB += lightColor;
                }
                finalRGB *= brightness;
                if (_EnableFresnel > 0.5)
                {
                    float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                    float3 viewDir = normalize(_WorldSpaceCameraPos - positionWS);
                    float fresnel = saturate(dot(viewDir, input.normalWS.xyz));
                    if (_FresnelInvert)
                    {
                        fresnel = 1 - fresnel;
                    }
                    half4 fresnelColor = saturate(pow(fresnel, _FresnelPower)) * _FresnelColor * _FresnelIntensity;
                    finalRGB += fresnelColor.rgb;
                    if (_FresnelEdgeMode == 0)
                    {
                        finalAlpha += fresnelColor.a;
                    }
                    else
                    {
                        finalAlpha *= fresnelColor.a;
                    }

                    if (_EnableFresnelDebuger > 0.5)
                    {
                        return half4(saturate(pow(fresnel, _FresnelPower)).xxx,1);
                    }
                }
                
                //mask
                if (_EnableMask > 0.5)
                {
                    float2 mask_uv = ApplyFlowDistortion(input.mask_uv.xy, flowVector, _FlowIntensityToMultiMap.z);
                    half sample_mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, mask_uv)[_MaskAlphaChannel];
                    finalAlpha *= sample_mask * input.color.w;
                    if (_EnableMaskDebuger)
                    {
                        return half4(sample_mask.xxx, 1);
                    }
                }

                if (_EnableDissolution > 0.5)
                {
                    float dissolutionValue;
                    {
                        //先将所有可能的放到另一个float3内，然后根据type进行区分，不使用if函数
                        float4 source;
                        source.x = _DissolutionThreshold;
                        source.y = input.color.a;
                        source.z = input.custom01[_DissolutionCustomDataChannel];
                        source.w = input.custom02[_DissolutionCustomDataChannel];
                        dissolutionValue = 1 - source[_DissolutionSource];
                    }
                    // //disslution
                    float2 dissolution_uv = ApplyFlowDistortion(input.dissolution_uv, flowVector, _FlowIntensityToMultiMap.w);
                    half sample_dissolution = SAMPLE_TEXTURE2D(_DissolutionTex, sampler_DissolutionTex, dissolution_uv)[_DissolutionChannel];

                    half dissolution = 1;
                    if (_DissolutionDirection == 0)
                    {
                        dissolution = sample_dissolution;
                    }
                    else if (_DissolutionDirection == 1)
                    {
                        dissolution = input.base_uv.x + sample_dissolution;
                    }
                    else if (_DissolutionDirection == 2)
                    {
                        dissolution = input.base_uv.y + sample_dissolution;
                    }
                    //
                    //
                    half4 dissolutionColor = 0;
                    dissolutionColor.rgb = lerp(finalRGB.xyz, _DissolutionColor.xyz, _DissolutionColor.w);
                    // float Softness = max(_DissolutionSoftness, 9.99999975e-05);
                    //
                    // float threshold = lerp(-Softness, 1, dissolutionValue);
                    // float width = lerp(-threshold, 1, dissolutionValue);
                    // half dissolutionFactor = min(smoothstep(threshold, threshold + width, sample_dissolution), 1.0);
                    // half4 finalDissolution = dissolutionColor * (1 - dissolutionFactor);
                    // finalRGB.rgb += finalDissolution.rgb;
                    // finalAlpha *= smoothstep(dissolutionValue, dissolutionValue + 0.2, dissolutionFactor);
                    //
                    float feather = max(_DissolutionSoftness, 9.99999975e-05);
                    half factor = GetDissolutionFactor(dissolution * (lerp(1, finalAlpha, _DissolutionBlendAlpha)), dissolutionValue, feather);
                    finalRGB.rgb = lerp(dissolutionColor, finalRGB, factor);
                    finalAlpha *= factor;
                }

                if (_EnableDepthBlend > 0.5)
                {
                    // 获取屏幕空间UV
                    float2 screenUV = input.screenPos.xy / input.screenPos.w;

                    // 获取场景深度和当前片段深度
                    float sceneDepthRaw = SampleSceneDepth(screenUV);
                    float sceneDepth = LinearEyeDepth(sceneDepthRaw, _ZBufferParams);

                    // 当前片段在观察空间的深度
                    float fragmentDepth = input.positionCS.w;

                    // 计算深度差值
                    float depthDifference = sceneDepth - fragmentDepth;

                    // 应用软化因子，创建平滑过渡
                    float intersectionFactor = saturate(depthDifference / _IntersectionSoftness);

                    // 应用相交因子到透明度
                    finalAlpha *= intersectionFactor;
                }
                half4 finalColor = 1;
                if (_EnableScreenDistortion > 0.5)
                {
                    half4 distortionChannel = SAMPLE_TEXTURE2D(_ScreenDistortionTexture, sampler_ScreenDistortionTexture,input.base_uv * _ScreenDistortionTexture_ST.xy + _ScreenDistortionTexture_ST.zw * _Time.y) * 2 - 1;
                    // 获取屏幕空间UV
                    float2 screenUV = input.screenPos.xy / input.screenPos.w;
                    half4 sample_opaque = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenUV + distortionChannel.xy * finalAlpha * _ScreenDistortionIntensity);
                    finalColor.rgb = sample_opaque;
                    finalColor.a = 1;
                    return finalColor;
                }
                else
                {
                    if (_BlendMode < 0.5)
                    {
                        finalColor = half4(finalRGB, finalAlpha);
                    }
                    else if (_BlendMode > 0.5 && _BlendMode < 1.5)
                    {
                        finalColor.rgb = finalRGB * finalAlpha;
                    }
                    else if (_BlendMode > 1.5)
                    {
                        finalColor.rgb = finalRGB;
                        clip(finalAlpha - _Cutoff);
                    }
                }
                return finalColor;
            }
            ENDHLSL
        }
    }
    // Fallback "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "EffectStandardShaderEditor"
}