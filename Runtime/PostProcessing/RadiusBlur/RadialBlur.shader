Shader "Hidden/Universal Render Pipeline/RadialBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LoopCount ("Loop Count", Range(1, 100)) = 10
        _Intensity ("Intensity", Range(0, 1)) = 0.5
        _CenterPoint ("Center", Vector) = (0.5, 0.5, 0, 0)
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"
        }
        LOD 100

        Pass
        {
            Name "RadialBlur"
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #pragma vertex   Vert
            #pragma fragment Fragment

            CBUFFER_START(UnityPerMaterial)
                int _LoopCount;
                float _Intensity;
                float4 _CenterPoint;
            CBUFFER_END

            float4 Unity_Universal_SampleBuffer_BlitSource_float(float2 uv)
            {
                uint2 pixelCoords = uint2(uv * _ScreenSize.xy);
                return LOAD_TEXTURE2D_X_LOD(_BlitTexture, pixelCoords, 0);
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // float2 uv = input.texcoord;
                // float4 cameraColor = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_PointClamp, uv) * _Intensity;
                // return half4(cameraColor.rgb, 1);

                float4 col = 0;
                float2 dir = (float2(_CenterPoint.x, _CenterPoint.y) - input.texcoord) * _Intensity * 0.02;
                for (int t = 0; t < _LoopCount; t++)
                {
                    col += SAMPLE_TEXTURE2D(_BlitTexture, sampler_PointClamp, input.texcoord + dir * t) / _LoopCount;
                }
                return col;
            }
            ENDHLSL
        }
    }
}