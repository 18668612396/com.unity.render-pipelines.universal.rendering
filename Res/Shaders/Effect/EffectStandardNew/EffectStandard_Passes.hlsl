#ifndef EFFECT_STANDARD_PASSES_INCLUDED
#define EFFECT_STANDARD_PASSES_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// 顶点输入属性结构体
// 存储模型空间下的顶点数据，包括位置、颜色、法线等基础信息
struct Attributes
{
    float4 positionOS : POSITION; // 模型空间顶点位置
    float4 Color : COLOR; // 顶点颜色
    float4 normalOS : NORMAL; // 模型空间法线
    float4 tangentOS : TANGENT; // 模型空间切线
    float4 texcoord0 : TEXCOORD00; // 基础纹理坐标
    float4 custom01 : TEXCOORD01; // 自定义数据通道1
    float4 custom02 : TEXCOORD02; // 自定义数据通道2
};

// 顶点到片段的输出结构体
// 存储需要传递给片段着色器的插值数据
struct Varyings
{
    float4 positionCS : SV_POSITION; // 裁剪空间顶点位置
    float4 uv : TEXCOORD00; // 主纹理坐标
    float4 color : COLOR; // 顶点颜色（插值后）
    float2 dissolve_uv : DISSOLVE_UV; // 溶解纹理坐标
    float2 distortion_uv : DISTORTION_UV; // 流动纹理坐标
    float4 custom01 : TEXCOORD01; // 自定义数据1（插值后）
    float4 custom02 : TEXCOORD02; // 自定义数据2（插值后）
    float4 tangentWS : TEXCOORD03; // 世界空间切线（w分量存储世界位置x）
    float4 bitangentWS : TEXCOORD04; // 世界空间副切线（w分量存储世界位置y）
    float4 normalWS : TEXCOORD05; // 世界空间法线（w分量存储世界位置z）
    float4 screenPos : TEXCOORD06; // 屏幕空间位置
    float4 second_uv : TEXCOORD07; // 第二纹理坐标
    float4 third_uv : TEXCOORD10; // 第三层纹理坐标
    float2 base_uv : TEXCOORD08; // 基础纹理坐标（未经过动画处理）
    float2 vertexAnim_uv : TEXCOORD09; // 顶点动画纹理坐标
};

float2 GetAnimation(Attributes input, int animationSource, float channel01, float channel02)
{
    float2 animation = 0;

    // 从custom01通道获取动画偏移
    if (animationSource == 1)
    {
        animation.x = channel01 > 0 ? input.custom01[channel01 - 1] : 0;
        animation.y = channel02 > 0 ? input.custom01[channel02 - 1] : 0;
    }
    // 从custom02通道获取动画偏移
    else if (animationSource == 2)
    {
        animation.x = channel01 > 0 ? input.custom02[channel01 - 1] : 0;
        animation.y = channel02 > 0 ? input.custom02[channel02 - 1] : 0;
    }
    // 时间驱动的自动UV动画
    else if (animationSource == 3)
    {
        animation = frac(float2(channel01, channel02) * _Time.y);
    }
    return animation;
}


// 顶点着色器
// 处理顶点变换、UV动画、顶点动画等，输出插值数据到片段着色器
Varyings Vertex(Attributes input)
{
    Varyings output = (Varyings)0;

    // 计算主纹理UV动画（包含旋转和位移）
    float2 mainAnimation = GetAnimation(input, _MainAnimation, _MainAnimationData01, _MainAnimationData02);
    output.uv.xy = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _MainTex), _MainRotationParams) + mainAnimation;

    // 计算第二纹理UV动画
    float2 secondAnimation = GetAnimation(input, _SecondAnimation, _SecondAnimationData01, _SecondAnimationData02);
    output.second_uv.xy = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _SecondMap), _SecondRotationParams) + secondAnimation;
    // output.second_uv.zw = TRANSFORM_TEX(input.texcoord0, _SecondDissolveTex);

    // 计算第三层纹理UV动画
    float2 thirdAnimation = GetAnimation(input, _ThirdAnimation, _ThirdAnimationData01, _ThirdAnimationData02);
    output.third_uv.xy = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _ThirdMap), _ThirdRotationParams) + thirdAnimation;

    // 溶解纹理UV动画
    float2 dissolveAnimation = GetAnimation(input, _DissolveAnimation, _DissolveAnimationData01, _DissolveAnimationData02);
    output.dissolve_uv = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _DissolveTex), _DissolveRotationParams) + dissolveAnimation;

    // 流动纹理UV动画
    float2 distortionAnimation = GetAnimation(input, _DistortionAnimation, _DistortionAnimationData01, _DistortionAnimationData02);
    output.distortion_uv = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _DistortionTex), _DistortionRotationParams) + distortionAnimation;

    // 顶点动画纹理UV动画
    float2 vertexAnimAnimation = GetAnimation(input, _VertexAnimAnimation, _VertexAnimAnimationData01, _VertexAnimAnimationData02);
    output.vertexAnim_uv = RotateTextureUV(TRANSFORM_TEX(input.texcoord0, _VertexAnimTex), _VertexAnimRotationParams) + vertexAnimAnimation;

    // 顶点位置处理
    float3 positionOS = input.positionOS.xyz;

    // 顶点动画处理（仅在启用时）
    #if _ENABLE_VERTEXANIM_ON
    {
        half4 sample_vertexAnim = SAMPLE_TEXTURE2D_LOD(_VertexAnimTex, sampler_VertexAnimTex, output.vertexAnim_uv, 0);
        half vertexAnimValue = sample_vertexAnim[_VertexAnimChannel];
        // 将采样值从 [0,1] 转换到 [-0.5, 0.5] 范围，使 0.5 为中性值
        vertexAnimValue = vertexAnimValue - 0.5;
        // 沿法线方向偏移顶点
        positionOS += input.normalOS.xyz * vertexAnimValue * _VertexAnimIntensity;
    }
    #endif

    // 计算世界空间位置和法线
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
    float3 positionWS = vertexInput.positionWS;

    // 传递世界空间切线、副切线、法线（w分量存储世界位置）
    output.tangentWS = float4(normalInput.tangentWS, positionWS.x);
    output.bitangentWS = float4(normalInput.bitangentWS, positionWS.y);
    output.normalWS = float4(normalInput.normalWS, positionWS.z);

    // 传递基础数据
    output.color = input.Color;
    output.custom01 = input.custom01;
    output.custom02 = input.custom02;
    if (_EnableScreenParticle > 0.5)
    {
        float2 ndc_xy = input.texcoord0.xy * 2.0 - 1.0; // 2. 构建最终的裁剪空间位置
        #if UNITY_UV_STARTS_AT_TOP
        // 如果平台是 D3D (或其他 y 轴在顶部的)
        // 就翻转传递给片元着色器的 Y 轴
        ndc_xy.y *= -1.0;
        #endif
        // xy = 我们刚算好的NDC坐标
        // z = 0.0  (放在近裁剪平面上。对于粒子特效无所谓，0.5 也可以)
        // w = 1.0  (必须为1，这样 xy 就等于 NDC 坐标)
        output.positionCS = float4(ndc_xy, 0.0, 1.0);
    }
    else
    {
        output.positionCS = TransformWorldToHClip(positionWS); // 转换到裁剪空间
    }
    output.screenPos = ComputeScreenPos(output.positionCS); // 计算屏幕位置
    output.base_uv = input.texcoord0.xy; // 存储原始UV用于后续计算

    return output;
}

// 片段着色器
// 处理像素级效果，包括纹理采样、颜色混合、溶解、法线光照等
half4 Fragment(Varyings input) : SV_Target
{
    half3 finalRGB = 0;
    half finalAlpha = 1;

    // 流动向量计算（仅在启用时）
    float2 distortionVector = float2(0.0, 0.0);
    #if _ENABLE_DISTORTION_ON
    {
        //扭曲必须要是法线贴图
        half4 sample_distortion = SAMPLE_TEXTURE2D(_DistortionTex, sampler_DistortionTex, input.distortion_uv.xy);
        if (_DistortionMode < 0.5)
        {
            distortionVector = sample_distortion.xy * 2 - 1;
        }
        else
        {
            distortionVector = sample_distortion[_DistortionChannel];
        }
        // 流动调试模式：直接输出流动纹理采样结果
        if (_EnableDistortionDebuger)
        {
            return half4(sample_distortion);
        }
    }
    #endif

    // 主纹理采样与颜色计算
    float2 main_uv = ApplyDistortion(input.uv.xy, distortionVector, _MainDistortionIntensity);
    half4 sample_main = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, main_uv);
    // 主纹理颜色 = 纹理颜色 * 主色调 * 顶点颜色 * 强度
    finalRGB = sample_main.rgb * _MainTexColor.rgb * input.color.rgb * _MainTexIntensity;
    finalAlpha = saturate(sample_main.a * _MainTexColor.a * input.color.a * _MainTexAlphaIntensity);
    // 第二纹理处理（仅在启用时）
    #if _ENABLE_SECOND_ON
    {
        // 第二纹理UV（应用流动扭曲）
        float2 uv_second = ApplyDistortion(input.second_uv.xy, distortionVector, _SecondDistortionIntensity);
        half4 sample_second = SAMPLE_TEXTURE2D(_SecondMap, sampler_SecondMap, uv_second);

        // 第二纹理调试模式：直接输出第二纹理采样结果
        if (_EnableSecondDebuger)
        {
            return sample_second;
        }

        half4 secondColor = 1;
        secondColor.rgb = sample_second.rgb * _SecondColor.rgb * _SecondColorIntensity;
        secondColor.a = saturate(sample_second.a * _SecondColor.a * _SecondAlphaIntensity);
        if (_SecondColorBlendMode == 1)
        {
            finalRGB *= secondColor.rgb;
        }
        else if (_SecondColorBlendMode == 2)
        {
            finalRGB += secondColor.rgb;
        }
        else if (_SecondColorBlendMode == 3)
        {
            finalRGB = lerp(finalRGB, secondColor.rgb, secondColor.a);
        }

        if (_SecondAlphaBlendMode == 1)
        {
            finalAlpha *= secondColor.a;
        }
        else if (_SecondAlphaBlendMode == 2)
        {
            finalAlpha += secondColor.a;
        }
        else if (_SecondAlphaBlendMode == 3)
        {
            finalAlpha = lerp(finalAlpha, secondColor.a, secondColor.a);
        }
    }
    #endif

    // 第三层纹理处理（仅在启用时）
    #if _ENABLE_TERTIARY_ON
    {
        // 第三层纹理UV（应用流动扭曲）
        float2 uv_third = ApplyDistortion(input.third_uv.xy, distortionVector, _ThirdDistortionIntensity);
        half4 sample_third = SAMPLE_TEXTURE2D(_ThirdMap, sampler_ThirdMap, uv_third);

        // 第三层纹理调试模式：直接输出第三层纹理采样结果
        if (_EnableThirdDebuger)
        {
            return sample_third;
        }

        half4 thirdColor = 1;
        thirdColor.rgb = sample_third.rgb * _ThirdColor.rgb * _ThirdColorIntensity;
        thirdColor.a = saturate(sample_third.a * _ThirdColor.a * _ThirdAlphaIntensity);
        if (_SecondColorBlendMode == 1)
        {
            finalRGB *= thirdColor.rgb;
        }
        else if (_SecondColorBlendMode == 2)
        {
            finalRGB += thirdColor.rgb;
        }
        else if (_SecondColorBlendMode == 3)
        {
            finalRGB = lerp(finalRGB, thirdColor.rgb, thirdColor.a);
        }

        if (_SecondAlphaBlendMode == 1)
        {
            finalAlpha *= thirdColor.a;
        }
        else if (_SecondAlphaBlendMode == 2)
        {
            finalAlpha += thirdColor.a;
        }
        else if (_SecondAlphaBlendMode == 3)
        {
            finalAlpha = lerp(finalAlpha, thirdColor.a, thirdColor.a);
        }
    }
    #endif

    // 菲涅尔效果（仅在启用时）
    #if _ENABLE_FRESNEL_ON
    {
        // 从切线/法线的w分量重建世界空间位置
        float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
        float3 viewDir = normalize(_WorldSpaceCameraPos - positionWS); // 视角方向

        // 计算菲涅尔因子（基于视角与法线的夹角）
        float fresnel = saturate(dot(viewDir, input.normalWS.xyz));
        fresnel = pow(1 - fresnel, _FresnelPower);
        // 菲涅尔参数（强度、软化范围、幂次）
        half4 fresnelIntensity = half4(_FresnelColorIntensity.xxx, _FresnelAlphaIntensity);
        half4 fresnelSoftnessMin = half4(_FresnelColorSoftnessMin.xxx, _FresnelAlphaSoftnessMin);
        half4 fresnelSoftnessMax = half4(_FresnelColorSoftnessMax.xxx, _FresnelAlphaSoftnessMax);

        // 计算最终菲涅尔因子（带软化过渡）
        half4 finalFresnel = smoothstep(fresnelSoftnessMin, fresnelSoftnessMax, fresnel) * fresnelIntensity;
        half4 fresnelColor = half4(_FresnelColor.rgb, _FresnelAlphaMode);
        half4 finalColor = half4(finalRGB, finalAlpha);

        // 混合菲涅尔颜色到最终颜色
        finalColor = lerp(finalColor, fresnelColor, finalFresnel);
        finalRGB = finalColor.rgb;
        finalAlpha *= finalColor.a;

        // 菲涅尔调试模式
        if (_EnableFresnelDebuger > 0.5)
        {
            return finalFresnel;
        }
    }
    #endif

    // 溶解效果（仅在启用时）
    #if _ENABLE_DISSOLVE_ON
    {
        float dissolveValue;
        {
            // 溶解阈值来源（参数/顶点颜色/自定义数据）
            float4 source;
            source.x = _DissolveThreshold;
            source.y = input.color.a;
            source.z = input.custom01[_DissolveCustomDataChannel];
            source.w = input.custom02[_DissolveCustomDataChannel];
            dissolveValue = 1 - source[_DissolveSource];
        }

        // 溶解纹理UV（应用流动扭曲）
        float2 dissolve_uv = ApplyDistortion(input.dissolve_uv, distortionVector, _DissolveDistortionIntensity);
        half sample_dissolve = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, dissolve_uv)[_DissolveChannel];
        sample_dissolve = 1.0 - sample_dissolve; // 反转采样值以匹配溶解逻辑
        // 根据方向计算溶解因子
        half dissolve = 1;
        if (_DissolveDirection == 0)
        {
            dissolve = sample_dissolve; // 基于纹理本身
        }
        else if (_DissolveDirection == 1)
        {
            dissolve = input.base_uv.x + sample_dissolve; // 基于U方向
        }
        else if (_DissolveDirection == 2)
        {
            dissolve = input.base_uv.y + sample_dissolve; // 基于V方向
        }

        // 溶解颜色混合
        half4 dissolveColor = 0;
        dissolveColor.rgb = lerp(finalRGB.xyz, _DissolveColor.xyz, _DissolveColor.w);

        // 计算溶解因子（带边缘软化）
        float feather = max(_DissolveSoftness, 9.99999975e-05); // 避免软化值为0
        half factor = GetDissolveFactor(dissolve * lerp(1, finalAlpha, _DissolveBlendAlpha), dissolveValue, feather);
        finalRGB.rgb = lerp(dissolveColor, finalRGB, factor);
        clip(factor - 1); // 裁剪（AlphaTest）
        finalAlpha *= factor;
    }
    #endif

    // 深度混合效果（仅在启用时）
    #if _ENABLE_DEPTHBLEND_ON
    {
        // 计算屏幕空间UV
        float2 screenUV = input.screenPos.xy / input.screenPos.w;

        // 采样场景深度并转换为线性深度
        float sceneDepthRaw = SampleSceneDepth(screenUV);
        float sceneDepth = LinearEyeDepth(sceneDepthRaw, _ZBufferParams);

        // 当前片段在观察空间的深度
        float fragmentDepth = input.positionCS.w;

        // 计算深度差值并生成过渡因子
        float depthDifference = sceneDepth - fragmentDepth;
        float intersectionFactor = saturate(depthDifference / _IntersectionSoftness); // 软化边缘

        // 根据混合模式应用深度效果
        if (_DepthBlendMode < 0.5)
        {
            finalAlpha *= intersectionFactor; // 影响透明度
            finalRGB = lerp(_DepthBlendColor.rgb * finalRGB, finalRGB, intersectionFactor); // 影响颜色
        }
        else
        {
            finalRGB = lerp(_DepthBlendColor.rgb * finalRGB, finalRGB, intersectionFactor); // 影响颜色
        }
    }
    #endif

    // 最终颜色计算
    half4 finalColor = 1;

    // 根据混合模式输出最终颜色
    if (_BlendMode < 0.5)
    {
        finalColor = half4(finalRGB, finalAlpha); // 常规混合（带透明度）
    }
    else if (_BlendMode > 0.5 && _BlendMode < 1.5)
    {
        finalColor.rgb = finalRGB * finalAlpha; // 预乘透明度
    }
    else if (_BlendMode > 1.5)
    {
        finalColor.rgb = finalRGB;
        finalColor.a = 1; // 不透明输出
        // clip(finalAlpha - _Cutoff); // 裁剪（AlphaTest）
    }

    return finalColor;
}

#endif
