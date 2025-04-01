Shader "Hidden/Universal Render Pipeline/ScreenDistortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //        _ScreenDistortionTexture ("Distortion Texture", 2D) = "white" {}
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
            Name "ScreenDistortion"
            //            Blend DstColor Zero
            //            ZTest Always
            //            ZWrite Off
            //            Cull Off

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #pragma vertex   Vert
            #pragma fragment Fragment
            TEXTURE2D(_ScreenDistortionTexture);
            SAMPLER(sampler_ScreenDistortionTexture);

            float4 Unity_Universal_SampleBuffer_BlitSource_float(float2 uv)
            {
                uint2 pixelCoords = uint2(uv * _ScreenSize.xy);
                return LOAD_TEXTURE2D_X_LOD(_BlitTexture, pixelCoords, 0);
            }

            half4 Fragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 distortion = SAMPLE_TEXTURE2D(_ScreenDistortionTexture, sampler_ScreenDistortionTexture, input.texcoord).rg * 2 - 1;
                float2 uv = input.texcoord + distortion;
                float4 cameraColor = SAMPLE_TEXTURE2D_X_LOD(_BlitTexture, sampler_PointClamp, uv,2);

                return half4(cameraColor.rgb, 1);
                // return pixelCoords.xyxy;
            }
            ENDHLSL
        }
    }
}