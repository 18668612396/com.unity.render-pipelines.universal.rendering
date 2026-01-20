Shader "XEffect/EffectStandardNew"
{
    Properties
    {
        //=========================================================================
        // 通用参数 (Common)
        //=========================================================================
        [Toggle(_ENABLE_ALPHA_TEST)]_EnableAlphaTest              ("Enable Alpha Test", Float) = 0                      // 启用透明度裁剪（开启后根据裁剪阈值隐藏部分像素）
        _Cutoff                       ("Cutoff", Range(0, 1)) = 0.0                                   // 透明度裁剪阈值（高于该值显示，低于隐藏）
        [Toggle]_EnableScreenParticle                ("Enable Screen Particle", Float) = 0                  // 启用屏幕空间粒子（开启后粒子基于屏幕空间渲染）
        //=========================================================================
        // 主纹理参数 (Main)
        //=========================================================================
        _MainTex                      ("MainTex", 2D) = "white" {}         // 主纹理（基础纹理）
        _MainTexColor                 ("Color", Color) = (1,1,1,1)      // 主纹理颜色（乘法混合）
        _MainTexIntensity             ("Intensity", Range(0, 200)) = 1      // 主纹理强度（控制纹理显示浓度）
        _MainTexAlphaIntensity        ("Alpha Intensity", Range(0, 10)) = 1 // 主纹理透明度强度
        _MainRotationParams           ("_MainRotationParams", Vector) = (1,0,0,0)                       // 主纹理旋转参数（控制纹理旋转角度/方向）
        [Enum(Disable,0,CustomData01,1,CustomData02,2,Time,3)] _MainAnimation("Main Animation Source", Int) = 0  // 主纹理动画来源：0=禁用，1=CustomData01，2=CustomData02，3=时间
        _MainAnimationData01("Main Animation Data01", float) = 0                    //如果来源为CustomData01，则此数据为通道选择,如果来源为时间，则此数据为时间速度
        _MainAnimationData02("Main Animation Data02", float) = 0                    //如果来源为CustomData02，则此数据为通道选择,如果来源为时间，则此数据为时间偏移
        
        //=========================================================================
        // 次纹理参数 (Secondary)
        //=========================================================================
        [Toggle(_ENABLE_SECOND_ON)]   _EnableSecond("Second On", Float) = 0                         // 启用次纹理（开启后激活次纹理相关效果）
        _SecondMap                   ("SecondMap", 2D) = "white" {}                              // 次纹理遮罩（控制次纹理显示区域）
        _SecondRotationParams         ("_SecondRotationParams", Vector) = (1,0,0,1)                 // 次纹理旋转参数（控制次纹理旋转角度/方向）
        _SecondColor("Second Color", Color) = (1,1,1,1)                                         // 次纹理颜色（乘法混合）
        _SecondColorIntensity        ("Second Color Intensity", Range(0, 200)) = 1                // 次纹理颜色强度（控制次纹理颜色显示浓度）
        _SecondAlphaIntensity        ("Second Alpha Intensity", Range(0, 10)) = 1                  // 次纹理透明度强度（控制次纹理透明度显示浓度）
        [Enum(None,0,Multiply,1,Add,2,Mix,3)]_SecondColorBlendMode("Second Color Blend Mode", Float) = 1          // 次纹理颜色混合模式：0=乘法，1=叠加
        [Enum(None,0,Multiply,1,Add,2,Mix,3)]_SecondAlphaBlendMode("Second Alpha Blend Mode", Float) = 1          // 次纹理透明度混合模式：0=乘法，1=叠加
        [Enum(Disable,0,CustomData01,1,CustomData02,2,Time,3)] _SecondAnimation("Second Animation Source", Int) = 0          //次纹理动画来源：0=禁用，1=CustomData01，2=CustomData02，3=时间
        _SecondAnimationData01("Second Animation Data01", float) = 0                    //如果来源为CustomData01，则此数据为通道选择,如果来源为时间，则此数据为时间速度
        _SecondAnimationData02("Second Animation Data02", float) = 0                    //如果来源为CustomData02，则此数据为通道选择,如果来源为时间，则此数据为时间偏移
        _SecondDistortionIntensity("Second Distortion Intensity", Range(0, 1)) = 0            // 次纹理扭曲强度（控制次纹理扭曲效果明显程度）
        //=========================================================================
        // 第三层纹理参数 (Tertiary)
        //=========================================================================
        [Toggle(_ENABLE_TERTIARY_ON)]   _EnableThird("Tertiary On", Float) = 0                      // 启用第三层纹理（开启后激活第三层纹理相关效果）
        _ThirdMap                    ("ThirdMap", 2D) = "white" {}                               // 第三层纹理遮罩（控制第三层纹理显示区域）
        _ThirdRotationParams         ("_ThirdRotationParams", Vector) = (1,0,0,1)                // 第三层纹理旋转参数（控制第三层纹理旋转角度/方向）
        _ThirdColor("Third Color", Color) = (1,1,1,1)                                            // 第三层纹理颜色（乘法混合）
        _ThirdColorIntensity         ("Third Color Intensity", Range(0, 200)) = 1                // 第三层纹理颜色强度（控制第三层纹理颜色显示浓度）
        _ThirdAlphaIntensity         ("Third Alpha Intensity", Range(0, 10)) = 1                 // 第三层纹理透明度强度（控制第三层纹理透明度显示浓度）
        [Enum(None,0,Multiply,1,Add,2,Mix,3)]_ThirdColorBlendMode("Third Color Blend Mode", Float) = 1        // 第三层纹理颜色混合模式：0=乘法，1=叠加
        [Enum(None,0,Multiply,1,Add,2,Mix,3)]_ThirdAlphaBlendMode("Third Alpha Blend Mode", Float) = 1        // 第三层纹理透明度混合模式：0=乘法，1=叠加
        [Enum(Disable,0,CustomData01,1,CustomData02,2,Time,3)] _ThirdAnimation("Third Animation Source", Int) = 0           //第三层纹理动画来源：0=禁用，1=CustomData01，2=CustomData02，3=时间
        _ThirdAnimationData01("Third Animation Data01", float) = 0                     //如果来源为CustomData01，则此数据为通道选择,如果来源为时间，则此数据为时间速度
        _ThirdAnimationData02("Third Animation Data02", float) = 0                     //如果来源为CustomData02，则此数据为通道选择,如果来源为时间，则此数据为时间偏移
        _ThirdDistortionIntensity("Third Distortion Intensity", Range(0, 1)) = 0             // 第三层纹理扭曲强度（控制第三层纹理扭曲效果明显程度）

        //=========================================================================
        // 扭曲效果参数 (Distortion)
        //=========================================================================
        [Toggle(_ENABLE_DISTORTION_ON)]     _EnableDistortion("Distortion On", Float) = 0              // 启用流动效果（开启后激活纹理流动动画）
        [Enum(Normal,0,Factor,1)]_DistortionMode                  ("Distortion Mode", Float) = 0                                // 流动模式：0 : 黑白流动，1 : 法线流动
        [Enum(X,0,Y,1,Z,2,W,3)]_DistortionChannel                ("Distortion Channel", Float) = 3                              // 流动通道：0=X，1=Y，2=Z，3=W（基于材质RGBA输出）
        _DistortionTex                      ("DistortionTex", 2D) = "white" {}                         // 流动纹理（基础流动效果纹理）
        _DistortionRotationParams           ("_DistortionRotationParams", Vector) = (1,0,0,0)          // 流动纹理旋转参数（控制流动纹理旋转角度/方向）
        [Enum(Disable,0,CustomData01,1,CustomData02,2,Time,3)] _DistortionAnimation("Distortion Animation Source", Int) = 0  // 流动动画来源：0=禁用，1=CustomData01，2=CustomData02，3=时间
        _DistortionAnimationData01("Distortion Animation Data01", float) = 0                    //如果来源为CustomData01，则此数据为通道选择,如果来源为时间，则此数据为时间速度
        _DistortionAnimationData02("Distortion Animation Data02", float) = 0                    //如果来源为CustomData02，则此数据为通道选择,如果来源为时间，则此数据为时间偏移
        _MainDistortionIntensity("Main Distortion Intensity", Range(0, 1)) = 0                  // 主纹理扭曲强度

        //=========================================================================
        // 顶点动画参数 (Vertex Animation)
        //=========================================================================
        [Toggle(_ENABLE_VERTEXANIM_ON)]     _EnableVertexAnim("Vertex Animation On", Float) = 0        // 启用顶点动画（开启后激活顶点偏移效果）
        _VertexAnimTex                      ("VertexAnimTex", 2D) = "gray" {}                          // 顶点动画纹理（控制顶点偏移量）
        _VertexAnimRotationParams           ("_VertexAnimRotationParams", Vector) = (1,0,0,0)          // 顶点动画纹理旋转参数
        [Enum(Disable,0,CustomData01,1,CustomData02,2,Time,3)] _VertexAnimAnimation("Vertex Anim Animation Source", Int) = 0  // 顶点动画来源：0=禁用，1=CustomData01，2=CustomData02，3=时间
        _VertexAnimAnimationData01("Vertex Anim Animation Data01", float) = 0                   //如果来源为CustomData01，则此数据为通道选择,如果来源为时间，则此数据为时间速度
        _VertexAnimAnimationData02("Vertex Anim Animation Data02", float) = 0                   //如果来源为CustomData02，则此数据为通道选择,如果来源为时间，则此数据为时间偏移
        _VertexAnimDistortionIntensity("Vertex Anim Distortion Intensity", Range(0, 1)) = 0     // 顶点动画纹理扭曲强度
        [Enum(R,0,G,1,B,2,A,3)]             _VertexAnimChannel("Vertex Anim Channel", Int) = 0         // 顶点动画采样通道：0=R，1=G，2=B，3=A
        _VertexAnimIntensity                ("Vertex Anim Intensity", Range(0, 10)) = 1                // 顶点动画强度（控制顶点偏移幅度）

        //=========================================================================
        // 溶解效果参数 (Dissolve)
        //=========================================================================
        [Toggle(_ENABLE_DISSOLVE_ON)] _EnableDissolve("Dissolve On", Float) = 0             // 启用溶解效果（开启后激活全局溶解）
        _DissolveTex               ("DissolveTex", 2D) = "white" {}                            // 溶解纹理（控制全局溶解形状）
        _DissolveRotationParams    ("Dissolve Rotation Params", Vector) = (1, 0, 0, 0)         // 溶解纹理旋转参数（控制溶解纹理旋转角度/方向）
        [Enum(Disable,0,CustomData01,1,CustomData02,2,Time,3)] _DissolveAnimation("Dissolve Animation Source", Int) = 0 // 溶解动画来源：0=禁用，1=CustomData01，2=CustomData02，3=时间
        _DissolveAnimationData01("Dissolve Animation Data01", float) = 0                    //如果来源为CustomData01，则此数据为通道选择,如果来源为时间，则此数据为时间速度
        _DissolveAnimationData02("Dissolve Animation Data02", float) = 0                    //如果来源为CustomData02，则此数据为通道选择,如果来源为时间，则此数据为时间偏移
        _DissolveDistortionIntensity("Dissolve Distortion Intensity", Range(0, 1)) = 0      // 溶解纹理扭曲强度
        [Enum(R,0,G,1,B,2,A,3)]       _DissolveChannel("_DissolveChannel", int) = 0            // 溶解通道选择：0=R，1=G，2=B，3=A
        [HDR]                         _DissolveColor("Dissolve Color", Color) = (1,1,1,1)   // 溶解颜色（HDR格式，溶解边缘颜色）
        [Enum(Disable,0,UV_X,1,UV_Y,2)] _DissolveDirection("Dissolve Direction", int) = 0      // 溶解方向：0=禁用，1=UV_X方向，2=UV_Y方向
        [Enum(Properties,0,VertexColorAlpha,1,CustomData01,2,CustomData02,3)] _DissolveSource("_DissolveSource", Int) = 0  // 溶解来源：0=属性，1=顶点颜色Alpha，2=CustomData01，3=CustomData02
        _DissolveThreshold         ("_DissolveThreshold", Range(1,-1)) = 1                     // 溶解阈值：值越小溶解范围越大
        [Toggle]                      _DissolveBlendAlpha("Dissolve Blend Alpha", Float) = 1   // 溶解混合Alpha：开启后溶解与透明度叠加
        [Enum(X,0,Y,1,Z,2,W,3)]       _DissolveCustomDataChannel("_DissolveCustomDataChannel", Int) = 0  // 溶解CustomData通道：0=X，1=Y，2=Z，3=W
        _DissolveSoftness          ("Dissolve Softness", Range(0,1)) = 0.1                     // 溶解边缘柔化程度：值越大边缘越模糊
        //=========================================================================
        // 深度混合参数 (Depth)
        //=========================================================================
        [Toggle(_ENABLE_DEPTHBLEND_ON)] _EnableDepthBlend("Dissolution On", Float) = 0             // 启用深度混合（开启后与场景深度交互）
        [Enum(SoftParticle,0,HardParticle,1)] _DepthBlendMode("Depth Blend Mode", Float) = 0       // 深度混合模式：0=软粒子（边缘柔化），1=硬粒子（边缘锐利）
        [HDR]                         _DepthBlendColor("Depth Blend Color", Color) = (1,1,1,1)  // 深度混合颜色（HDR格式，与深度交互的颜色）
        _IntersectionSoftness         ("Intersection Softness", Range(0, 10)) = 0.1                 // 深度交叉柔化：值越大与场景交叉边缘越模糊

        //=========================================================================
        // 菲涅尔效果参数 (Fresnel)
        //=========================================================================
        [Toggle(_ENABLE_FRESNEL_ON)]  _EnableFresnel("Enable Fresnel", Float) = 0                 // 启用菲涅尔效果（开启后边缘高亮）
        _FresnelPower                 ("Fresnel Power", Range(0, 10)) = 1                         // 菲涅尔强度：值越大边缘高亮越集中
        [HDR]                         _FresnelColor("Fresnel Color", Color) = (1,1,1,1)        // 菲涅尔颜色（HDR格式，边缘高亮颜色）
        _FresnelColorIntensity        ("Fresnel Color Intensity", Range(0, 1)) = 1                // 菲涅尔颜色强度：值越小颜色越淡
        _FresnelColorPower            ("Fresnel Color Power", Range(0, 10)) = 1                   // 菲涅尔颜色衰减：值越大颜色衰减越快
        _FresnelColorSoftnessMin      ("Fresnel Color Softness Min", Range(0, 1)) = 0             // 菲涅尔颜色柔化最小值：控制高亮区域起始
        _FresnelColorSoftnessMax      ("Fresnel Color Softness Max", Range(0, 1)) = 1             // 菲涅尔颜色柔化最大值：控制高亮区域结束
        [Enum(Decrease,0,Increase,1)] _FresnelAlphaMode("Fresnel Alpha Mode", Float) = 0          // 菲涅尔Alpha模式：0=衰减（边缘透明），1=增强（边缘不透明）
        [Toggle]                      _EnableFresnelAlpha("Enable Fresnel Alpha", float) = 1      // 启用菲涅尔Alpha：开启后菲涅尔影响透明度
        _FresnelAlphaIntensity        ("Fresnel Alpha Intensity", Range(0, 1)) = 1                // 菲涅尔Alpha强度：值越小透明度影响越弱
        _FresnelAlphaPower            ("Fresnel Alpha Power", Range(0, 10)) = 1                   // 菲涅尔Alpha衰减：值越大透明度衰减越快
        _FresnelAlphaSoftnessMin      ("Fresnel Alpha Softness Min", Range(0, 1)) = 0             // 菲涅尔Alpha柔化最小值：控制透明度起始
        _FresnelAlphaSoftnessMax      ("Fresnel Alpha Softness Max", Range(0, 1)) = 1             // 菲涅尔Alpha柔化最大值：控制透明度结束

        //=========================================================================
        // 屏幕扭曲参数 (Screen Distortion)
        //=========================================================================
        [Toggle(_ENABLE_SCREENDISTORTION_ON)] _EnableScreenDistortion("Enable Screen Distortion", Float) = 0       // 启用屏幕扭曲（开启后扭曲背景）
        [Toggle]                      _EnableScreenDistortionNormal("Enable Screen Distortion Normal", Float) = 0  // 启用法线屏幕扭曲：基于法线方向扭曲
        _ScreenDistortionChannel      ("Screen Distortion Channel", Float) = 3                                     // 屏幕扭曲通道：0=X，1=Y，2=Z，3=W（基于材质RGBA输出）
        _ScreenDistortionIntensity    ("Screen Distortion Intensity", Range(0, 1)) = 0.5                           // 屏幕扭曲强度：值越大扭曲越明显

        //=========================================================================
        // 渲染状态参数 (Render State)
        //=========================================================================
        [Enum()]                      _BlendMode("BlendMode", Float) = 0               // 混合模式（控制纹理/颜色混合规则）
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", Float) = 4.0     // 深度测试模式（控制是否显示在其他物体前面）
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("_SrcBlend", Float) = 1.0    // 源混合因子（混合时的源颜色权重）
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("_DstBlend", Float) = 0.0    // 目标混合因子（混合时的目标颜色权重）
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendA("_SrcBlendA", Float) = 1.0  // 源Alpha混合因子（Alpha通道的源权重）
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendA("_DstBlendA", Float) = 0.0  // 目标Alpha混合因子（Alpha通道的目标权重）
        [Toggle]                      _ZWrite("_ZWrite", Float) = 0.0                  // 深度写入：开启后写入深度缓冲区（影响其他物体显示）
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Float) = 2       // 背面剔除模式：控制是否显示模型背面
        _RenderQueueOffset            ("Queue offset", Range(-20,20)) = 0.0            // 渲染队列偏移：调整材质的渲染顺序

        //=========================================================================
        // 模板测试参数 (Stencil) - 暂时禁用
        //=========================================================================
        [Header(Stencil)]
        _StencilComp                  ("Stencil Comparison", Float) = 8     // 模板测试比较规则（是否通过模板测试）
        _Stencil                      ("Stencil ID", Float) = 0             // 模板ID（与缓冲区中的模板值对比）
        _StencilOp                    ("Stencil Operation", Float) = 0      // 模板操作（通过测试后对缓冲区的操作）
        _StencilWriteMask             ("Stencil Write Mask", Float) = 255   // 模板写入掩码（控制哪些位可写入）
        _StencilReadMask              ("Stencil Read Mask", Float) = 255    // 模板读取掩码（控制哪些位可读取）
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
            #include "EffectStandard_Function.hlsl"
            #include "EffectStandard_Input.hlsl"
            #include "EffectStandard_Passes.hlsl"
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma shader_feature_local_fragment _ENABLE_ALPHA_TEST
            #pragma shader_feature_local_fragment _ENABLE_SECOND_ON
            #pragma shader_feature_local_fragment _ENABLE_TERTIARY_ON
            #pragma shader_feature_local_fragment _ENABLE_DISTORTION_ON
            #pragma shader_feature_local_vertex _ENABLE_VERTEXANIM_ON
            #pragma shader_feature_local_fragment _ENABLE_DISSOLVE_ON
            #pragma shader_feature_local_fragment _ENABLE_DEPTHBLEND_ON
            #pragma shader_feature_local_fragment _ENABLE_FRESNEL_ON
            ENDHLSL
        }
    }
    CustomEditor "EffectStandardShaderNewEditor"
}