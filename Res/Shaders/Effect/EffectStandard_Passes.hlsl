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
            return half4(saturate(pow(fresnel, _FresnelPower)).xxx, 1);
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
        half4 distortionChannel = SAMPLE_TEXTURE2D(_ScreenDistortionTexture, sampler_ScreenDistortionTexture, input.base_uv * _ScreenDistortionTexture_ST.xy + _ScreenDistortionTexture_ST.zw * _Time.y) * 2 - 1;
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

#endif
