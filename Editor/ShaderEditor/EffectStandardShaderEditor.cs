using System;
using System.Collections.Generic;
using Nemo.Editor.ShaderUI;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

public enum DisableXYZWChannel
{
    Dissable = 0,
    X = 1,
    Y = 2,
    Z = 3,
    W = 4
}

public enum XYZWChannel
{
    X = 0,
    Y = 1,
    Z = 2,
    W = 3
}

public enum DisableXYZChannel
{
    Dissable = 0,
    X = 1,
    Y = 2,
    Z = 3
}

public enum XYZChannel
{
    X = 0,
    Y = 1,
    Z = 2
}

public enum ToggleEnum
{
    Disable = 0,
    Enable = 1
}

// 定义枚举类型
public enum SpaceMode
{
    法线空间 = 0,
    物体空间 = 1,
    世界空间 = 2
}

public class EffectStandardShaderEditor : ModularShaderEditor
{
    protected override string BeforeModuleName => "Before";
    protected override string MainModuleName => "Main";
    protected override string AfterModuleName => "After";

    protected override Dictionary<(string ModuleName, string PropertyName), Action<MaterialEditor>> ModuleProperties => new Dictionary<(string ModuleName, string PropertyName), Action<MaterialEditor>>
    {
        { ("第二层纹理", "_EnableSecond"), DrawSecondModule },
        { ("映射贴图", "_EnableRamp"), DrawRampModule },
        { ("法线", "_EnableNormalMap"), DrawNormalModule },
        { ("遮罩", "_EnableMask"), DrawMaskModule },
        { ("溶解", "_EnableDissolution"), DrawDissolveModule },
        { ("扰动", "_EnableFlow"), DrawFlowModule },
        { ("菲涅尔", "_EnableFresnel"), DrawFresnelModule },
        { ("深度混合", "_EnableDepthBlend"), DrawDepthBlendModule },
        { ("热扭曲", "_EnableScreenDistortion"), DrawScreenDistortionModule }
    };

    public readonly string[] s_BlendeModeNames = Enum.GetNames(typeof(RenderingBlendUtils.BlendMode));

    protected override void OnBeforeDefaultGUI(MaterialEditor materialEditor)
    {

        material.SetShaderPassEnabled("UniversalScreenDistortion", FindProperty("_EnableScreenDistortion").floatValue > 0.5f);
        material.SetShaderPassEnabled("UniversalForward", FindProperty("_EnableScreenDistortion").floatValue < 0.5f);

        UpdateRenderState(materialEditor);
        DoPopup(materialEditor, new GUIContent("混合模式"), FindProperty("_BlendMode"), s_BlendeModeNames);
        RenderingBlendUtils.BlendMode blendMode = (RenderingBlendUtils.BlendMode)FindProperty("_BlendMode").floatValue;
        if (blendMode == RenderingBlendUtils.BlendMode.Replace)
        {
            materialEditor.ShaderProperty(FindProperty("_Cutoff"), "Alpha 测试值");
        }

        materialEditor.ShaderProperty(FindProperty("_ZTest"), "Z测试");
        materialEditor.IntSliderShaderProperty(FindProperty("_RenderQueueOffset"), -20, 20, new GUIContent("渲染列队偏移"));
        materialEditor.ShaderProperty(FindProperty("_CullMode"), "剔除模式");

        materialEditor.ShaderProperty(FindProperty("_EffectBrightnessSource"), "整体亮度依据");
        if (FindProperty("_EffectBrightnessSource").floatValue > 0.5f)
        {
            materialEditor.ShaderProperty(FindProperty("_EffectBrightnessCustomDataChannel"), "自定义数据通道");
        }
        else
        {
            materialEditor.ShaderProperty(FindProperty("_EffectBrightness"), "亮度值");
        }
    }

    protected override void OnMainDefaultGUI(MaterialEditor materialEditor)
    {
        materialEditor.ShaderProperty(FindProperty("_EnableMainTexColorAddition"), "启用主纹理颜色叠加");
        if (FindProperty("_EnableMainTexColorAddition").floatValue > 0.5f)
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("主纹理"), FindProperty("_MainTex"), FindProperty("_MainTexColor"), FindProperty("_MainTexColorAddition"));
        }
        else
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("主纹理"), FindProperty("_MainTex"), FindProperty("_MainTexColor"), FindProperty("_MainTexIntensity"));
        }

        materialEditor.TextureScaleOffsetProperty(FindProperty("_MainTex"));
        DrawRotationSlider("_MainRotationParams", "旋转角度");
        materialEditor.ShaderProperty(FindProperty("_MainAnimationSource"), "动画依据");
        if (FindProperty("_MainAnimationSource").floatValue > 0.0f && FindProperty("_MainAnimationSource").floatValue < 2.5f)
        {
            // materialEditor.ShaderProperty(FindProperty("_MainAnimationCustomDataChannel01"), "动画依据(U方向)");
            // 正确的转换方式
            FindProperty("_MainAnimationCustomDataChannel01").floatValue = (float)(int)(DisableXYZWChannel)EditorGUILayout.EnumPopup("动画依据(X方向)",
                (DisableXYZWChannel)((int)FindProperty("_MainAnimationCustomDataChannel01").floatValue));
            FindProperty("_MainAnimationCustomDataChannel02").floatValue = (float)(int)(DisableXYZWChannel)EditorGUILayout.EnumPopup("动画依据(Y方向)",
                (DisableXYZWChannel)((int)FindProperty("_MainAnimationCustomDataChannel02").floatValue));
        }
        else if (FindProperty("_MainAnimationSource").floatValue > 2.5f)
        {
            FindProperty("_MainAnimationCustomDataChannel01").floatValue = (float)(int)(ToggleEnum)EditorGUILayout.EnumPopup("动画依据(X方向)",
                (ToggleEnum)((int)FindProperty("_MainAnimationCustomDataChannel01").floatValue));
            FindProperty("_MainAnimationCustomDataChannel02").floatValue = (float)(int)(ToggleEnum)EditorGUILayout.EnumPopup("动画依据(Y方向)",
                (ToggleEnum)((int)FindProperty("_MainAnimationCustomDataChannel02").floatValue));
        }

        DrawFlowIntensityToMultiMap(0);
    }

    private void DrawSecondModule(MaterialEditor materialEditor)
    {
        // 临时禁用材质编辑器中的锁功能
        EditorGUIUtility.labelWidth += 16; // 增加标签宽度覆盖锁图标的位置
        // 绘制第二纹理模块的属性
        materialEditor.ShaderProperty(FindProperty("_EnableSecondGradient"), "启用次渐变");
        if (FindProperty("_EnableSecondGradient").floatValue > 0.5f)
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("次纹理"), FindProperty("_SecondTex"), FindProperty("_SecondColor01"), FindProperty("_SecondColor02"));
            materialEditor.ShaderProperty(FindProperty("_SecondGradientChannel"), "渐变通道");
        }
        else
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("次纹理"), FindProperty("_SecondTex"), FindProperty("_SecondColor01"));
        }

        DrawRotationSlider("_SecondRotationParams", "旋转角度");
        materialEditor.TextureScaleOffsetProperty(FindProperty("_SecondTex"));

        materialEditor.ShaderProperty(FindProperty("_SecondAnimationSource"), "动画依据");
        if (FindProperty("_SecondAnimationSource").floatValue > 0.0f)
        {
            materialEditor.ShaderProperty(FindProperty("_SecondAnimationCustomDataChannel01"), "动画依据(U方向)");
            materialEditor.ShaderProperty(FindProperty("_SecondAnimationCustomDataChannel02"), "动画依据(V方向)");
        }

        materialEditor.ShaderProperty(FindProperty("_EnableSecondDissolution"), "启用次溶解");
        if (FindProperty("_EnableSecondDissolution").floatValue > 0.5f)
        {
            materialEditor.TexturePropertySingleLine(new GUIContent("次溶解纹理"), FindProperty("_SecondDissolutionTex"), FindProperty("_SecondDissolutionColor"));
            materialEditor.TextureScaleOffsetProperty(FindProperty("_SecondDissolutionTex"));
            materialEditor.ShaderProperty(FindProperty("_SecondDissolutionSource"), "溶解依据");
            if (FindProperty("_SecondDissolutionSource").floatValue == 0)
            {
                materialEditor.ShaderProperty(FindProperty("_SecondDissolutionThreshold"), "溶解阈值");
            }
            else if (Mathf.Approximately(FindProperty("_SecondDissolutionSource").floatValue, 2) || Mathf.Approximately(FindProperty("_SecondDissolutionSource").floatValue, 3))
            {
                materialEditor.ShaderProperty(FindProperty("_SecondDissolutionCustomDataChannel"), "自定义数据通道");
            }

            materialEditor.ShaderProperty(FindProperty("_SecondDissolutionSoftness"), "软边度");
        }

        DrawFlowIntensityToMultiMap(1);
        EditorGUIUtility.labelWidth -= 16; // 恢复标签宽度
    }

    private void DrawRampModule(MaterialEditor materialEditor)
    {
        materialEditor.TexturePropertySingleLine(new GUIContent("映射贴图"), FindProperty("_RampMap"), FindProperty("_RampIntensity"));
        DrawRotationSlider("_RampMapRotationParams", "旋转角度");
    }

    private void DrawNormalModule(MaterialEditor materialEditor)
    {
        materialEditor.TexturePropertySingleLine(new GUIContent("法线贴图"), FindProperty("_NormalMap"), FindProperty("_NormalMapIntensity"));
        materialEditor.TextureScaleOffsetProperty(FindProperty("_NormalMap"));
        materialEditor.ShaderProperty(FindProperty("_LightColor"), "光照颜色");
        materialEditor.ShaderProperty(FindProperty("_ShadowColor"), "阴影颜色");
    }

    private void DrawMaskModule(MaterialEditor materialEditor)
    {
        // 绘制遮罩模块的属性
        materialEditor.TexturePropertySingleLine(new GUIContent("遮罩纹理"), FindProperty("_MaskTex"), FindProperty("_MaskAlphaChannel"));
        DrawRotationSlider("_MaskRotationParams", "旋转角度");
        materialEditor.TextureScaleOffsetProperty(FindProperty("_MaskTex"));

        materialEditor.ShaderProperty(FindProperty("_MaskAnimationSource"), "遮罩动画依据");
        if (FindProperty("_MaskAnimationSource").floatValue > 0.0f)
        {
            materialEditor.ShaderProperty(FindProperty("_MaskAnimationCustomDataChannel01"), "动画依据(U方向)");
            materialEditor.ShaderProperty(FindProperty("_MaskAnimationCustomDataChannel02"), "动画依据(V方向)");
        }

        DrawFlowIntensityToMultiMap(2);
    }

    private void DrawDissolveModule(MaterialEditor materialEditor)
    {
        // 绘制溶解模块的属性
        materialEditor.TexturePropertySingleLine(new GUIContent("溶解纹理"), FindProperty("_DissolutionTex"), FindProperty("_DissolutionColor"), FindProperty("_DissolutionChannel"));
        DrawRotationSlider("_DissolutionRotationParams", "旋转角度");
        materialEditor.TextureScaleOffsetProperty(FindProperty("_DissolutionTex"));
        materialEditor.ShaderProperty(FindProperty("_DissolutionDirection"), "溶解方向");
        materialEditor.ShaderProperty(FindProperty("_DissolutionBlendAlpha"), "混合Alpha");
        materialEditor.ShaderProperty(FindProperty("_DissolutionSource"), "溶解依据");
        if (FindProperty("_DissolutionSource").floatValue == 0)
        {
            materialEditor.ShaderProperty(FindProperty("_DissolutionThreshold"), "溶解阈值");
        }
        else if (Mathf.Approximately(FindProperty("_DissolutionSource").floatValue, 2) || Mathf.Approximately(FindProperty("_DissolutionSource").floatValue, 3))
        {
            materialEditor.ShaderProperty(FindProperty("_DissolutionCustomDataChannel"), "自定义数据通道");
        }

        materialEditor.ShaderProperty(FindProperty("_DissolutionSoftness"), "软边度");

        DrawFlowIntensityToMultiMap(3);
    }

    private int selectedTab = 0;

    private string[] tabNames = { "纹理扰动", "顶点扰动" };

// 使用示例
    private int tabIndex = 0;

    GUIContent defaultTab = new GUIContent("Default");

    private void DrawFlowModule(MaterialEditor materialEditor)
    {
        // 绘制流动模块的属性
        materialEditor.TexturePropertySingleLine(new GUIContent("扰动纹理"), FindProperty("_FlowTex"));
        materialEditor.TextureScaleOffsetProperty(FindProperty("_FlowTex"));
        DrawRotationSlider("_FlowRotationParams", "旋转角度");
        materialEditor.ShaderProperty(FindProperty("_FlowAnimationSource"), "动画依据");
        if (FindProperty("_FlowAnimationSource").floatValue > 0.0f && FindProperty("_FlowAnimationSource").floatValue < 2.5f)
        {
            // materialEditor.ShaderProperty(FindProperty("_MainAnimationCustomDataChannel01"), "动画依据(U方向)");
            // 正确的转换方式
            FindProperty("_FlowAnimationCustomDataChannel01").floatValue = (float)(int)(DisableXYZWChannel)EditorGUILayout.EnumPopup("动画依据(X方向)",
                (DisableXYZWChannel)((int)FindProperty("_FlowAnimationCustomDataChannel01").floatValue));
            FindProperty("_FlowAnimationCustomDataChannel02").floatValue = (float)(int)(DisableXYZWChannel)EditorGUILayout.EnumPopup("动画依据(Y方向)",
                (DisableXYZWChannel)((int)FindProperty("_FlowAnimationCustomDataChannel02").floatValue));
        }
        else if (FindProperty("_FlowAnimationSource").floatValue > 2.5f)
        {
            FindProperty("_FlowAnimationCustomDataChannel01").floatValue = (float)(int)(ToggleEnum)EditorGUILayout.EnumPopup("动画依据(X方向)",
                (ToggleEnum)((int)FindProperty("_FlowAnimationCustomDataChannel01").floatValue));
            FindProperty("_FlowAnimationCustomDataChannel02").floatValue = (float)(int)(ToggleEnum)EditorGUILayout.EnumPopup("动画依据(Y方向)",
                (ToggleEnum)((int)FindProperty("_FlowAnimationCustomDataChannel02").floatValue));
        }

        EditorGUIHelper.BeginHeaderToggleGrouping("顶点偏移");
        Vector4 vertexAnimationStrengthPropValue = FindProperty("_VertexAnimationStrength").vectorValue;


        Vector3 vertexAnimationStrength = Vector3.zero;
        float vertexAnimationSpaceMode = 0;

        // 将枚举值转换为 float 值
        vertexAnimationSpaceMode = (float)(SpaceMode)EditorGUILayout.EnumPopup("偏移空间方向", (SpaceMode)(int)vertexAnimationStrengthPropValue.w);

        materialEditor.ShaderProperty(FindProperty("_VertexAnimationStrengthSource"), "顶点偏移强度依据");

        if (FindProperty("_VertexAnimationStrengthSource").floatValue < 0.5f)
        {
            // 绘制 XYZ 分量
            vertexAnimationStrength = EditorGUILayout.Vector3Field("顶点偏移强度", new Vector3(vertexAnimationStrengthPropValue.x, vertexAnimationStrengthPropValue.y, vertexAnimationStrengthPropValue.z));
        }
        else
        {
            // materialEditor.ShaderProperty(FindProperty("_MainAnimationCustomDataChannel01"), "动画依据(U方向)");
            // 正确的转换方式
            FindProperty("_VertexAnimationStrengthCustomDataChannel01").floatValue = (float)(int)(DisableXYZWChannel)EditorGUILayout.EnumPopup("动画依据(X方向)",
                (DisableXYZWChannel)((int)FindProperty("_VertexAnimationStrengthCustomDataChannel01").floatValue));
            FindProperty("_VertexAnimationStrengthCustomDataChannel02").floatValue = (float)(int)(DisableXYZWChannel)EditorGUILayout.EnumPopup("动画依据(Y方向)",
                (DisableXYZWChannel)((int)FindProperty("_VertexAnimationStrengthCustomDataChannel02").floatValue));
            FindProperty("_VertexAnimationStrengthCustomDataChannel03").floatValue = (float)(int)(DisableXYZWChannel)EditorGUILayout.EnumPopup("动画依据(Z方向)",
                (DisableXYZWChannel)((int)FindProperty("_VertexAnimationStrengthCustomDataChannel03").floatValue));
        }

        // 更新 Vector4 属性
        FindProperty("_VertexAnimationStrength").vectorValue = new Vector4(vertexAnimationStrength.x, vertexAnimationStrength.y, vertexAnimationStrength.z, vertexAnimationSpaceMode);
        EditorGUILayout.EndVertical();
    }

    private void DrawFresnelModule(MaterialEditor materialEditor)
    {
        // materialEditor.ShaderProperty(FindProperty("_FresnelEdgeMode"), "菲涅尔边缘模式");
        // materialEditor.ShaderProperty(FindProperty("_FresnelInvert"), "菲涅尔反转");
        //
        // materialEditor.ShaderProperty(FindProperty("_FresnelIntensity"), "菲涅尔强度");
        // materialEditor.ShaderProperty(FindProperty("_FresnelPower"), "菲涅尔Power");

        EditorGUIHelper.BeginHeaderToggleGrouping("菲涅尔颜色区域");
        materialEditor.ShaderProperty(FindProperty("_FresnelColor"), "菲涅尔颜色");
        materialEditor.ShaderProperty(FindProperty("_FresnelColorIntensity"), "菲涅尔颜色强度");
        materialEditor.ShaderProperty(FindProperty("_FresnelColorSoftnessMin"), "菲涅尔范围Min");
        materialEditor.ShaderProperty(FindProperty("_FresnelColorSoftnessMax"), "菲涅尔范围Max");
        EditorGUIHelper.EndHeaderToggleGrouping();

        EditorGUIHelper.BeginHeaderToggleGrouping("菲涅尔透明区域");
        materialEditor.ShaderProperty(FindProperty("_FresnelAlphaMode"), "菲涅尔透明模式");
        materialEditor.ShaderProperty(FindProperty("_FresnelAlphaIntensity"), "菲涅尔透明强度");
        materialEditor.ShaderProperty(FindProperty("_FresnelAlphaSoftnessMin"), "菲涅尔范围Min");
        materialEditor.ShaderProperty(FindProperty("_FresnelAlphaSoftnessMax"), "菲涅尔范围Max");
        EditorGUIHelper.EndHeaderToggleGrouping();
    }

    private void DrawDepthBlendModule(MaterialEditor materialEditor)
    {
        materialEditor.ShaderProperty(FindProperty("_IntersectionSoftness"), "交叉软边度");
    }

    private void DrawScreenDistortionModule(MaterialEditor materialEditor)
    {
        FindProperty("_ScreenDistortionChannel").floatValue = (float)(XYZWChannel)EditorGUILayout.EnumPopup(new GUIContent("扭曲通道", "使用当前材质球输出的RGBA做选择"), (XYZWChannel)FindProperty("_ScreenDistortionChannel").floatValue);
        materialEditor.ShaderProperty(FindProperty("_ScreenDistortionIntensity"), "热扭曲强度");
    }

    protected override void OnAfterDefaultGUI(MaterialEditor materialEditor)
    {
    }

    /// <summary>
    /// 绘制在其他模块上，用于绘制扰动模块的属性，只有打开了扰动模块才会显示
    /// </summary>
    /// <param name="materialEditor"></param>
    /// <param name="index">0 : main , 1: second, 2 : mask , 3: dissolution</param>
    private void DrawFlowIntensityToMultiMap(int index)
    {
        if (FindProperty("_EnableFlow").floatValue > 0.5f)
        {
            Vector4 flowValue = FindProperty("_FlowIntensityToMultiMap").vectorValue;
            flowValue[index] = EditorGUILayout.Slider("扰动强度", flowValue[index], 0, 1);
            FindProperty("_FlowIntensityToMultiMap").vectorValue = flowValue;
            GUI.enabled = true;
        }
    }

    protected float GetRotationFromMatrix(Vector4 matrix)
    {
        // 从旋转矩阵部分提取角度
        // matrix.x = cos, matrix.y = -sin
        float angle = Mathf.Atan2(-matrix.y, matrix.x);

        // 转换为角度并确保在0-360范围内
        float degrees = angle * Mathf.Rad2Deg;
        if (degrees < 0) degrees += 360f;

        return degrees;
    }

    protected Vector4 GetMatrixFromRotation(float degrees)
    {
        float radians = degrees * Mathf.Deg2Rad;

        float cos = Mathf.Cos(radians);
        float sin = Mathf.Sin(radians);

        // 计算中心点(0.5, 0.5)的平移
        float tx = 0.5f * (1 - cos) + 0.5f * sin;
        float ty = 0.5f * (1 - cos) - 0.5f * sin;

        return new Vector4(cos, -sin, tx, ty);
    }

    // 绘制旋转控制滑块的辅助方法
    protected void DrawRotationSlider(string matrixPropName, string label)
    {
        var matrixProp = FindProperty(matrixPropName);
        if (matrixProp != null)
        {
            EditorGUI.BeginChangeCheck();

            // 从当前矩阵中获取角度
            float currentAngle = GetRotationFromMatrix(matrixProp.vectorValue);

            // 绘制滑块
            float newAngle = EditorGUILayout.Slider(label, currentAngle, 0f, 359.9f);

            // 如果值发生改变，更新矩阵
            if (EditorGUI.EndChangeCheck())
            {
                matrixProp.vectorValue = GetMatrixFromRotation(newAngle);
            }
        }
    }

    private void UpdateRenderState(MaterialEditor materialEditor)
    {
        var mat = materialEditor.target as Material;
        if (!mat)
        {
            return;
        }

        int renderQueue = mat.shader.renderQueue;
        RenderingBlendUtils.BlendMode blendMode = (RenderingBlendUtils.BlendMode)FindProperty("_BlendMode").floatValue;
        if (blendMode == RenderingBlendUtils.BlendMode.Replace)
        {
            // bool alphaClip = m_NameToPropertyMap["_EnableAlphaTest"].floatValue > 0;
            // if (alphaClip)
            // {
            //     renderQueue = (int)RenderQueue.AlphaTest;
            //     mat.SetOverrideTag("RenderType", "TransparentCutout");
            // }
            // else
            {
                renderQueue = (int)RenderQueue.Geometry;
                mat.SetOverrideTag("RenderType", "Opaque");
            }

            RenderingBlendUtils.CalculateRenderBlendMode(RenderingBlendUtils.BlendMode.Replace,
                out var src, out var dst, out var srcA, out var dstA);
            FindProperty("_SrcBlend").floatValue = (float)src;
            FindProperty("_DstBlend").floatValue = (float)dst;
            FindProperty("_SrcBlendA").floatValue = (float)srcA;
            FindProperty("_DstBlendA").floatValue = (float)dstA;
            FindProperty("_ZWrite").floatValue = 1;
        }
        else // SurfaceType Transparent
        {
            renderQueue = (int)RenderQueue.Transparent;
            mat.SetOverrideTag("RenderType", "Transparent");

            RenderingBlendUtils.CalculateRenderBlendMode(blendMode,
                out var src, out var dst, out var srcA, out var dstA);
            FindProperty("_SrcBlend").floatValue = (float)src;
            FindProperty("_DstBlend").floatValue = (float)dst;
            FindProperty("_SrcBlendA").floatValue = (float)srcA;
            FindProperty("_DstBlendA").floatValue = (float)dstA;
            FindProperty("_ZWrite").floatValue = 0;
        }

        renderQueue += (int)FindProperty("_RenderQueueOffset").floatValue;
        if (renderQueue != mat.renderQueue)
            mat.renderQueue = renderQueue;

        mat.doubleSidedGI = false;
    }
}