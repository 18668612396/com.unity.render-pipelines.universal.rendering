Shader "TestShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Intensity("Intensity", Range(0, 1)) = 1
        //Common
    }
    SubShader
    {
        LOD 200
        Tags
        {
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "ScreenDistortion"
            Tags
            {
                "LightMode" = "UniversalScreenDistortion"
            }

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #pragma vertex Vertex
            #pragma fragment Fragment


            CBUFFER_START(UnityPerMaterial)
            half4 _MainTex_ST;
            half _Intensity;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 texcoord0 : TEXCOORD0;
            };

            Varyings Vertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
                output.positionCS = vertexInput.positionCS;
                output.texcoord0 = TRANSFORM_TEX(input.texcoord0, _MainTex);
                return output;
            }

            half2 Fragment(Varyings input) : SV_Target
            {
                half2 sample_main = (SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.texcoord0.xy)) * _Intensity;
                half2 finalXY = sample_main * 0.5 + 0.5;
                return finalXY;
            }
            ENDHLSL
        }
    }
}