#ifndef EFFECT_STANDARD_FUNCTION_INCLUDED
#define EFFECT_STANDARD_FUNCTION_INCLUDED


float2 RotateTextureUV(float2 uv, float4 rotationParams)
{
    return float2(
        dot(uv, float2(rotationParams.x, rotationParams.y)) + rotationParams.z,
        dot(uv, float2(-rotationParams.y, rotationParams.x)) + rotationParams.w
    );
}

float2 ApplyUVAnimation(int animationSource, half4 custom01, int channel01, half4 custom02, int channel02, float4 _ST = float4(1, 1, 0, 0))
{
    float2 mainAnimation = 0;
    if (animationSource == 1)
    {
        mainAnimation = float2(custom01[channel01 - 1], custom01[channel02 - 1]);
    }
    else if (animationSource == 2)
    {
        mainAnimation = float2(custom02[channel01 - 1], custom02[channel02 - 1]);
    }
    else if (animationSource == 3)
    {
        //这段代码是可以将UV限制在 -1到1之间，从而实现一个贴图的完整流动，当贴图为clamp的时候，会从一边完整的走到另一边，当贴图为repeat的时候，则跟之前没有任何区别
        // float2 speed = _ST.zw * min(float2(channel01, channel02), 1);
        // float2 result = sign(speed) * (frac(_Time.y * abs(speed)) * 2.0 - 1.0) * _ST.xy;
        // mainAnimation = result;
        mainAnimation = frac(_ST.zw * _Time.y) * min(float2(channel01, channel02), 1);
    }
    return mainAnimation;
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
#endif
