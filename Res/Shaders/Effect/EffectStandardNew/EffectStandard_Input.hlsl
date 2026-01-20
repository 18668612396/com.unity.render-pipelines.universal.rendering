#ifndef EFFECT_STANDARD_INPUT_INCLUDED
#define EFFECT_STANDARD_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    half _EnableScreenParticle; // 是否启用屏幕空间粒子效果（1=启用）
    // 基础渲染模式参数
    int _BlendMode; // 混合模式：控制透明度与颜色混合算法（0=正常,1=叠加等）
    float _Cutoff; // 裁剪阈值：用于Alpha Test，大于该值的像素可见
    // 主纹理（MainTex）参数
    float4 _MainTex_ST; // 主纹理缩放(xy)与偏移(zw)
    float4 _MainTexColor; // 主纹理叠加颜色（RGBA）
    float _MainTexIntensity; // 主纹理颜色强度（0=无效果,1=正常）
    float _MainTexAlphaIntensity; // 主纹理透明度强度
    float4 _MainRotationParams; // 主纹理旋转参数（x=角度,y=中心偏移）
    int _MainAnimation; // 主纹理动画源（0=禁用,1=CustomData01,2=CustomData02,3=时间）
    float _MainAnimationData01; // 主纹理动画数据01
    float _MainAnimationData02; // 主纹理动画数据02

    // 第二纹理与渐变控制
    float4 _SecondMap_ST; // 第二纹理缩放与偏移
    float4 _SecondRotationParams; // 第二纹理旋转参数（x=角
    float4 _SecondColor; // 第二纹理颜色（RGBA）
    half _SecondColorIntensity; // 第二纹理颜色强度（0=无效果
    half _SecondAlphaIntensity; // 第二纹理透明度强度（0=完全透明,1=正常）
    int _SecondColorBlendMode; // 第二纹理颜色混合模式（0= 乘法,1=叠加）
    int _SecondAlphaBlendMode; // 第二纹理透明度混合模式（0 = 乘法,1=叠加）
    int _SecondAnimation; // 第二纹理动画源（0=禁用, 1=自定义数据01,2=自定义数据02,3=时间）
    float _SecondAnimationData01;
    float _SecondAnimationData02;
    half _SecondDistortionIntensity; // 第二纹理扭曲强度（0

    // 第三层纹理参数
    float4 _ThirdMap_ST; // 第三层纹理缩放与偏移
    float4 _ThirdRotationParams; // 第三层纹理旋转参数
    float4 _ThirdColor; // 第三层纹理颜色（RGBA）
    half _ThirdColorIntensity; // 第三层纹理颜色强度
    half _ThirdAlphaIntensity; // 第三层纹理透明度强度
    int _ThirdColorBlendMode; // 第三层纹理颜色混合模式（0=乘法,1=叠加）
    int _ThirdAlphaBlendMode; // 第三层纹理透明度混合模式（0=乘法,1=叠加）
    int _ThirdAnimation; // 第三层纹理动画源（0=禁用,1=CustomData01,2=CustomData02,3=时间）
    float _ThirdAnimationData01; // 第三层纹理动画数据01
    float _ThirdAnimationData02; // 第三层纹理动画数据02
    half _ThirdDistortionIntensity; // 第三层纹理扭曲强度

    // 法线与光照参数
    float4 _NormalMap_ST; // 法线贴图缩放与偏移
    float _EnableNormalMap; // 是否启用法线贴图（1=启用）
    half _NormalMapIntensity; // 法线贴图强度（0=无凹凸,1=正常）
    float4 _LightColor; // 主光源颜色
    float4 _ShadowColor; // 阴影叠加颜色

    // 流动效果（Distortion）参数
    half _DistortionMode;
    half _DistortionChannel;
    float4 _DistortionTex_ST; // 流动纹理缩放与偏移
    float4 _DistortionRotationParams; // 流动纹理旋转参数
    int _DistortionAnimation; // 流动动画源（0=禁用,1=CustomData01,2=CustomData02,3=时间）
    float _DistortionAnimationData01; // 流动动画数据01
    float _DistortionAnimationData02; // 流动动画数据02
    half _MainDistortionIntensity; // 主纹理扭曲强度

    // 顶点动画（Vertex Animation）参数
    float4 _VertexAnimTex_ST; // 顶点动画纹理缩放与偏移
    float4 _VertexAnimRotationParams; // 顶点动画纹理旋转参数
    int _VertexAnimAnimation; // 顶点动画源（0=禁用,1=CustomData01,2=CustomData02,3=时间）
    float _VertexAnimAnimationData01; // 顶点动画数据01
    float _VertexAnimAnimationData02; // 顶点动画数据02
    half _VertexAnimDistortionIntensity; // 顶点动画纹理扭曲强度
    int _VertexAnimChannel; // 顶点动画采样通道（0=R,1=G,2=B,3=A）
    half _VertexAnimIntensity; // 顶点动画强度

    // 菲涅尔效果（边缘光）参数
    float _EnableFresnel; // 是否启用菲涅尔效果（1=启用）
    half4 _FresnelColor; // 菲涅尔边缘颜色
    half _FresnelColorIntensity; // 菲涅尔颜色强度
    half _FresnelColorPower; // 菲涅尔颜色衰减幂次（值越大范围越窄）
    half _FresnelAlphaMode; // 菲涅尔Alpha模式（0=叠加,1=替换）
    half _FresnelAlphaIntensity; // 菲涅尔Alpha强度
    half _FresnelAlphaPower; // 菲涅尔Alpha衰减幂次
    half _FresnelColorSoftnessMin; // 菲涅尔颜色柔和度最小值
    half _FresnelColorSoftnessMax; // 菲涅尔颜色柔和度最大值
    half _FresnelAlphaSoftnessMin; // 菲涅尔Alpha柔和度最小值
    half _FresnelAlphaSoftnessMax; // 菲涅尔Alpha柔和度最大值
    int _FresnelEdgeMode; // 菲涅尔边缘计算模式（0=视角依赖,1=固定范围）
    float _FresnelIntensity; // 菲涅尔整体强度缩放
    float _FresnelPower; // 菲涅尔基础衰减幂次
    float _FresnelInvert; // 是否反转菲涅尔效果（1=反转）

    // 溶解效果（Dissolve）参数
    float4 _DissolveTex_ST; // 溶解纹理缩放与偏移
    float4 _DissolveRotationParams; // 溶解纹理旋转参数
    int _DissolveAnimation; // 溶解动画源（0=禁用,1=CustomData01,2=CustomData02,3=时间）
    float _DissolveAnimationData01; // 溶解动画数据01
    float _DissolveAnimationData02; // 溶解动画数据02
    half _DissolveDistortionIntensity; // 溶解纹理扭曲强度
    int _DissolveChannel; // 溶解采样通道（0=R,1=G等）
    float _DissolveSoftness; // 溶解边缘柔和度
    int _DissolveDirection; // 溶解方向（0=垂直,1=水平,2=径向）
    half4 _DissolveColor; // 溶解边缘发光颜色
    int _DissolveSource; // 溶解数据源（0=纹理,1=自定义数据）
    float _DissolveThreshold; // 溶解阈值（0=完全溶解,1=不溶解）
    int _DissolveCustomDataChannel; // 溶解数据通道
    int _DissolveBlendAlpha; // 是否混合溶解Alpha（1=混合）

    // 屏幕扭曲效果参数
    int _ScreenDistortionChannel; // 扭曲采样通道（0=R,1=G等）
    float _EnableScreenDistortion; // 是否启用屏幕扭曲（1=启用）
    float _ScreenDistortionIntensity; // 扭曲强度（值越大扭曲越明显）

    // 深度混合效果参数
    int _DepthBlendMode; // 深度混合模式（0=交叉区域,1=深度测试失败区域）
    float4 _DepthBlendColor; // 深度混合叠加颜色
    float _IntersectionSoftness; // 交叉边缘柔和度
CBUFFER_END

// 主纹理及其采样器
TEXTURE2D(_MainTex); // 主纹理：用于基础颜色、主图案显示，配合_MainTex_ST等参数控制缩放/偏移/动画
SAMPLER(sampler_MainTex); // 主纹理采样器：控制_MainTex的采样方式（过滤模式、寻址模式等）

// 第二纹理及其采样器
TEXTURE2D(_SecondMap); // 第二纹理：用于叠加次级图案或颜色，配合_SecondTex_ST等参数使用
SAMPLER(sampler_SecondMap); // 第二纹理采样器：控制_SecondTex的采样方式

// 第三层纹理及其采样器
TEXTURE2D(_ThirdMap); // 第三层纹理：用于叠加第三层图案或颜色
SAMPLER(sampler_ThirdMap); // 第三层纹理采样器

// 遮罩纹理及其采样器 - 已移除

// 溶解纹理及其采样器
TEXTURE2D(_DissolveTex); // 溶解纹理：用于主溶解效果的图案定义，通过_DissolutionThreshold控制溶解程度
SAMPLER(sampler_DissolveTex); // 溶解纹理采样器：控制_DissolutionTex的采样方式

// 流动纹理及其采样器
TEXTURE2D(_DistortionTex); // 流动纹理：用于实现流动效果（如液体、烟雾流动），配合_DistortionTex_ST和动画参数使用
SAMPLER(sampler_DistortionTex); // 流动纹理采样器：控制_DistortionTex的采样方式

// 顶点动画纹理及其采样器
TEXTURE2D(_VertexAnimTex); // 顶点动画纹理：用于控制顶点偏移量
SAMPLER(sampler_VertexAnimTex); // 顶点动画纹理采样器

// 第二溶解纹理及其采样器
TEXTURE2D(_SecondDissolveTex); // 第二溶解纹理：用于次级溶解效果的图案定义，配合第二溶解参数使用
SAMPLER(sampler_SecondDissolveTex); // 第二溶解纹理采样器：控制_SecondDissolutionTex的采样方式

#endif
