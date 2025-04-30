#ifndef EFFECT_STANDARD_PASSES_INCLUDED
#define EFFECT_STANDARD_PASSES_INCLUDED

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

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float4 uv : TEXCOORD00;
    float4 color : COLOR;
    float2 mask_uv : MASK_UV;
    float2 dissolution_uv : DISSOLUTION_UV;
    float2 flow_uv : FLOW_UV;
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

Varyings Vertex(Attributes input)
{
    Varyings output = (Varyings)0;

    float2 mainAnimation = ApplyUVAnimation(_MainAnimationSource, input.custom01, _MainAnimationCustomDataChannel01, input.custom02, _MainAnimationCustomDataChannel02, _MainTex_ST);
    output.uv.xy = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _MainTex), _MainRotationParams) + mainAnimation;
    float2 secondAnimation = ApplyUVAnimation(_SecondAnimationSource, input.custom01, _SecondAnimationCustomDataChannel01, input.custom02, _SecondAnimationCustomDataChannel02, _SecondTex_ST);
    output.second_uv.xy = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _SecondTex) + secondAnimation, _SecondRotationParams);
    output.second_uv.zw = TRANSFORM_TEX(input.texcoord0, _SecondDissolutionTex);
    float2 maskAnimation = ApplyUVAnimation(_MaskAnimationSource, input.custom01, _MaskAnimationCustomDataChannel01, input.custom02, _MaskAnimationCustomDataChannel02, _MaskTex_ST);
    output.mask_uv = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _MaskTex), _MaskRotationParams) + maskAnimation;
    output.dissolution_uv = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _DissolutionTex), _DissolutionRotationParams);
    //flow
    float2 flowAnimation = ApplyUVAnimation(_FlowAnimationSource, input.custom01, _FlowAnimationCustomDataChannel01, input.custom02, _FlowAnimationCustomDataChannel02, _FlowTex_ST);
    output.flow_uv = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _FlowTex), _FlowRotationParams) + flowAnimation;

    float flowVector = 0;
    if (_EnableFlow)
    {
        half sample_flow01 = SAMPLE_TEXTURE2D_LOD(_FlowTex, sampler_FlowTex, output.flow_uv.xy, 0).x;
        flowVector = sample_flow01 * 2 - 1;
    }
    float3 positionOS = input.positionOS.xyz;
    float4 vertexAnimationStrength = _VertexAnimationStrength;
    if (_VertexAnimationStrengthSource > 0.5 && _VertexAnimationStrengthSource < 1.5)
    {
        vertexAnimationStrength.x = input.custom01[_VertexAnimationStrengthCustomDataChannel01 - 1];
        vertexAnimationStrength.y = input.custom01[_VertexAnimationStrengthCustomDataChannel02 - 1];
        vertexAnimationStrength.z = input.custom01[_VertexAnimationStrengthCustomDataChannel03 - 1];
    }
    else if (_VertexAnimationStrengthSource > 1.5)
    {
        vertexAnimationStrength.x = input.custom02[_VertexAnimationStrengthCustomDataChannel01 - 1];
        vertexAnimationStrength.y = input.custom02[_VertexAnimationStrengthCustomDataChannel02 - 1];
        vertexAnimationStrength.z = input.custom02[_VertexAnimationStrengthCustomDataChannel03 - +1];
    }

    if (vertexAnimationStrength.w < 0.5) //小于0.5为法线
    {
        positionOS += input.normalOS.xyz * vertexAnimationStrength * flowVector;
    }
    else if (vertexAnimationStrength.w > 0.5 && vertexAnimationStrength.w < 1.5) // 为1时，则为自身空间坐标
    {
        positionOS += vertexAnimationStrength * flowVector;
    }
    //normal
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
    float3 positionWS = vertexInput.positionWS;
    if (vertexAnimationStrength.w > 1.5 && vertexAnimationStrength.w < 2.5) //为2时，则为世界空间坐标
    {
        positionWS += vertexAnimationStrength * flowVector;
    }

    output.tangentWS = float4(normalInput.tangentWS, positionWS.x);
    output.bitangentWS = float4(normalInput.bitangentWS, positionWS.y);
    output.normalWS = float4(normalInput.normalWS, positionWS.z);
    output.normal_uv = TRANSFORM_TEX(input.texcoord0, _NormalMap);

    output.color = input.Color;
    output.custom01 = input.custom01;
    output.custom02 = input.custom02;
    output.positionCS = TransformWorldToHClip(positionWS);
    output.screenPos = ComputeScreenPos(output.positionCS);
    output.base_uv = input.texcoord0.xy;

    output.ramp_uv = RotateTextureUV(input.texcoord0, _RampMapRotationParams);
    return output;
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
        half sample_flow = SAMPLE_TEXTURE2D(_FlowTex, sampler_FlowTex, input.flow_uv.xy)[_FlowTexChannel];
        flowVector = sample_flow - 1.0;
        if (_EnableFlowDebuger)
        {
            return half4(sample_flow.xxx, 1);
        }
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
            secondAlpha = secondColor.a;
        }
        finalRGB.rgb = lerp(finalRGB.rgb, secondColor, secondAlpha * input.color.a);
        if (_EnableMultiMainAlpha)
        {
            // finalAlpha = finalAlpha * secondAlpha;
        }
        else
        {
            finalAlpha = lerp(finalAlpha, secondColor.a, secondAlpha);
        }
    }

    if (_EnableRamp > 0.5)
    {
        float2 ramp_uv = input.ramp_uv;
        if (_RampMapSource > 0.5)
        {
            float4 source = float4(finalRGB,finalAlpha);
            ramp_uv = float2(source[_RampMapSource - 1] , 0.5);
        }
        half4 sample_ramp = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, ramp_uv);
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
        float fresnel = pow(saturate(dot(viewDir, input.normalWS.xyz)),_FresnelPower);

        half4 fresnelIntensity = half4(_FresnelColorIntensity.xxx, _FresnelAlphaIntensity);
        half4 fresnelSoftnessMin = half4(_FresnelColorSoftnessMin.xxx, _FresnelAlphaSoftnessMin);
        half4 fresnelSoftnessMax = half4(_FresnelColorSoftnessMax.xxx, _FresnelAlphaSoftnessMax);
        half4 fresnelPower = half4(_FresnelColorPower.xxx, _FresnelAlphaPower);

        half4 finalFresnel = smoothstep(fresnelSoftnessMin, fresnelSoftnessMax, fresnel) * fresnelIntensity;
        half4 fresnelColor = half4(_FresnelColor.rgb, _FresnelAlphaMode);
        half4 finalColor = half4(finalRGB, finalAlpha);
        finalColor = lerp(finalColor, fresnelColor, finalFresnel);

        finalRGB = finalColor.rgb;
        finalAlpha = finalColor.a;

        if (_EnableFresnelDebuger > 0.5)
        {
            return finalFresnel;
        }
    }

    //mask
    if (_EnableMask > 0.5)
    {
        float2 mask_uv = ApplyFlowDistortion(input.mask_uv.xy, flowVector, _FlowIntensityToMultiMap.z);
        half sample_mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, mask_uv)[_MaskAlphaChannel];
        finalAlpha *= lerp(1,lerp(sample_mask,1 - sample_mask,_InvertMask),_MaskIntensity) * input.color.w;
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
        if (_DepthBlendMode < 0.5)
        {
            // 应用相交因子到透明度
            finalAlpha *= intersectionFactor;
        }
        else
        {
            finalRGB = lerp(_DepthBlendColor.rgb * finalRGB,finalRGB,  intersectionFactor);
        }

    }

    half4 finalColor = 1;
    if (_EnableScreenDistortion > 0.5)
    {
        half4 temp = half4(finalRGB, finalAlpha);
        if (_EnableScreenDistortionNormal > 0.5)
        {
            half2 normal = lerp(0.5,half4(TransformWorldToViewNormal(input.normalWS).xy,1,1) * 0.5 + 0.5,_ScreenDistortionIntensity);
            return half4(normal,0,1);
        }
        else
        {
            half screenDistortion = saturate(temp[_ScreenDistortionChannel] );
            return half4(lerp(0.0,_ScreenDistortionIntensity,screenDistortion).xx,1,1) * 0.5 + 0.5;
        }
        
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

#endif
