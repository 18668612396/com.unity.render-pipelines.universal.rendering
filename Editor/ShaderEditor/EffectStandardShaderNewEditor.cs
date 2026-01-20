using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
public class EffectStandardShaderNewEditor : ModularShaderEditor
{
    protected override string BeforeModuleName => "Before";
    protected override string MainModuleName => "第一层纹理";
    protected override string AfterModuleName => "After";

// 1. 在类的顶部声明所有的 ShaderKeyword
    private static readonly string _KEYWORD_SECOND = new string("_ENABLE_SECOND_ON");
    private static readonly string _KEYWORD_TERTIARY = new string("_ENABLE_TERTIARY_ON");
    private static readonly string _ENABLE_DISSOLVE_ON = new string("_ENABLE_DISSOLVE_ON");
    private static readonly string _KEYWORD_DISTORTION = new string("_ENABLE_DISTORTION_ON");
    private static readonly string _KEYWORD_VERTEXANIM = new string("_ENABLE_VERTEXANIM_ON");
    private static readonly string _KEYWORD_FRESNEL = new string("_ENABLE_FRESNEL_ON");
    private static readonly string _KEYWORD_DEPTHBLEND = new string("_ENABLE_DEPTHBLEND_ON");
    // private static readonly string _KEYWORD_SCREENDISTORTION = new string("_ENABLE_SCREENDISTORTION_ON");

    // 假设这是你的属性字典
    protected override Dictionary<(string ModuleName, string PropertyName, string keyword), Action<MaterialEditor>> ModuleProperties => new Dictionary<(string ModuleName, string PropertyName, string keyword), Action<MaterialEditor>>
    {
        // 2. 在初始化元组时，传入对应的 ShaderKeyword 实例
        { ("第二层纹理", "_EnableSecond", _KEYWORD_SECOND), DrawSecondModule },
        { ("第三层纹理", "_EnableThird", _KEYWORD_TERTIARY), DrawThirdModule },
        { ("溶解", "_EnableDissolve", _ENABLE_DISSOLVE_ON), DrawDissolveModule },
        { ("扭曲", "_EnableDistortion", _KEYWORD_DISTORTION), DrawDistortionModule },
        { ("顶点动画", "_EnableVertexAnim", _KEYWORD_VERTEXANIM), DrawVertexAnimModule },
        { ("菲涅尔", "_EnableFresnel", _KEYWORD_FRESNEL), DrawFresnelModule },
        { ("深度混合", "_EnableDepthBlend", _KEYWORD_DEPTHBLEND), DrawDepthBlendModule },
        // { ("热扭曲", "_EnableScreenDistortion", _KEYWORD_SCREENDISTORTION), DrawScreenDistortionModule }
    };

    public readonly string[] s_BlendeModeNames = Enum.GetNames(typeof(RenderingBlendUtils.BlendMode));

    protected override void OnBeforeDefaultGUI(MaterialEditor materialEditor)
    {
        material.SetShaderPassEnabled("UniversalScreenDistortion", FindProperty("_EnableScreenDistortion").floatValue > 0.5f);
        material.SetShaderPassEnabled("UniversalForward", FindProperty("_EnableScreenDistortion").floatValue < 0.5f);

        UpdateRenderState(materialEditor);
        DoPopup(materialEditor, new GUIContent("混合模式"), FindProperty("_BlendMode"), s_BlendeModeNames);
        EditorGUI.BeginChangeCheck();
        RenderingBlendUtils.BlendMode blendMode = (RenderingBlendUtils.BlendMode)FindProperty("_BlendMode").floatValue;
        if (EditorGUI.EndChangeCheck())
        {
            if (blendMode == RenderingBlendUtils.BlendMode.Replace)
                FindProperty("_ZWrite").floatValue = 1;
            else
                FindProperty("_ZWrite").floatValue = 0;

            Debug.Log("OnChange");
        }

        if (blendMode == RenderingBlendUtils.BlendMode.Replace)
        {
            materialEditor.ShaderProperty(FindProperty("_EnableAlphaTest"), "启用Alpha测试");
            if (FindProperty("_EnableAlphaTest").floatValue > 0.5f)
            {
                materialEditor.ShaderProperty(FindProperty("_Cutoff"), "Alpha 测试值");
            }
        }
        else
        {
            materialEditor.IntSliderShaderProperty(FindProperty("_RenderQueueOffset"), -20, 20, new GUIContent("渲染列队偏移"));
        }

        materialEditor.ShaderProperty(FindProperty("_EnableScreenParticle"), "启用屏幕空间粒子");
        if (FindProperty("_EnableScreenParticle").floatValue > 0.5f)
        {
            //将ztest强制设置为any
            FindProperty("_ZTest").floatValue = (float)CompareFunction.Always;
            //cullmode设置为back
            FindProperty("_CullMode").floatValue = (float)UnityEngine.Rendering.CullMode.Back;
            //深度写入关闭
            FindProperty("_ZWrite").floatValue = 0;
        }
        else
        {
            materialEditor.ShaderProperty(FindProperty("_CullMode"), "剔除模式");
            materialEditor.ShaderProperty(FindProperty("_ZTest"), "Z测试");
            materialEditor.ShaderProperty(FindProperty("_ZWrite"), "开启深度写入");
            
        }
    }

    protected override void OnMainDefaultGUI(MaterialEditor materialEditor)
    {
        materialEditor.TexturePropertySingleLine(new GUIContent("主纹理"), FindProperty("_MainTex"), FindProperty("_MainTexColor"));
        materialEditor.TextureScaleOffsetProperty(FindProperty("_MainTex"));
        materialEditor.ShaderProperty(FindProperty("_MainTexIntensity"), "颜色强度");
        materialEditor.ShaderProperty(FindProperty("_MainTexAlphaIntensity"), "透明强度");
        DrawRotationSlider("_MainRotationParams", "旋转角度");
        materialEditor.ShaderProperty(FindProperty("_MainAnimation"), "动画依据");
        if (FindProperty("_MainAnimation").floatValue > 0.0f && FindProperty("_MainAnimation").floatValue < 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect popup1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect popup2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "动画依据:X/Y方向");
            FindProperty("_MainAnimationData01").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup1Rect, (DisableXYZWChannel)((int)FindProperty("_MainAnimationData01").floatValue));
            FindProperty("_MainAnimationData02").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup2Rect, (DisableXYZWChannel)((int)FindProperty("_MainAnimationData02").floatValue));
        }
        else if (FindProperty("_MainAnimation").floatValue > 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect field1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect field2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "时间速度");
            FindProperty("_MainAnimationData01").floatValue = EditorGUI.FloatField(field1Rect, FindProperty("_MainAnimationData01").floatValue);
            FindProperty("_MainAnimationData02").floatValue = EditorGUI.FloatField(field2Rect, FindProperty("_MainAnimationData02").floatValue);
        }

        // 绘制扭曲强度（独立参数）
        if (FindProperty("_EnableDistortion").floatValue > 0.5f)
        {
            materialEditor.ShaderProperty(FindProperty("_MainDistortionIntensity"), "扰动强度");
        }
    }

    private void DrawSecondModule(MaterialEditor materialEditor)
    {
        // 临时禁用材质编辑器中的锁功能
        EditorGUIUtility.labelWidth += 16; // 增加标签宽度覆盖锁图标的位置
        // 绘制第二纹理模块的属性
        materialEditor.TexturePropertySingleLine(new GUIContent("第二层纹理"), FindProperty("_SecondMap"), FindProperty("_SecondColor"));
        materialEditor.TextureScaleOffsetProperty(FindProperty("_SecondMap"));
        EditorGUILayout.BeginVertical("HelpBox");
        materialEditor.ShaderProperty(FindProperty("_SecondColorBlendMode"), "颜色混合模式");
        materialEditor.ShaderProperty(FindProperty("_SecondColorIntensity"), "颜色强度");
        EditorGUILayout.EndVertical();
        EditorGUILayout.BeginVertical("HelpBox");
        materialEditor.ShaderProperty(FindProperty("_SecondAlphaBlendMode"), "透明混合模式");
        materialEditor.ShaderProperty(FindProperty("_SecondAlphaIntensity"), "透明强度");
        EditorGUILayout.EndVertical();
        materialEditor.ShaderProperty(FindProperty("_SecondAnimation"), "动画依据");
        if (FindProperty("_SecondAnimation").floatValue > 0.0f && FindProperty("_SecondAnimation").floatValue < 2.5f)
        {
            // materialEditor.ShaderProperty(FindProperty("_MainAnimationCustomDataChannel01"), "动画依据(U方向)");
            // 正确的转换方式
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect popup1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect popup2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "动画依据:X/Y方向");
            FindProperty("_SecondAnimationData01").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup1Rect, (DisableXYZWChannel)((int)FindProperty("_SecondAnimationData01").floatValue));
            FindProperty("_SecondAnimationData02").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup2Rect, (DisableXYZWChannel)((int)FindProperty("_SecondAnimationData02").floatValue));

        }
        else if (FindProperty("_SecondAnimation").floatValue > 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect field1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect field2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "时间速度");
            FindProperty("_SecondAnimationData01").floatValue = EditorGUI.FloatField(field1Rect, FindProperty("_SecondAnimationData01").floatValue);
            FindProperty("_SecondAnimationData02").floatValue = EditorGUI.FloatField(field2Rect, FindProperty("_SecondAnimationData02").floatValue);
        }
        DrawRotationSlider("_SecondRotationParams", "旋转角度");
        
        // 绘制扭曲强度（独立参数）
        if (FindProperty("_EnableDistortion").floatValue > 0.5f)
        {
            materialEditor.ShaderProperty(FindProperty("_SecondDistortionIntensity"), "扰动强度");
        }
        EditorGUIUtility.labelWidth -= 16; // 恢复标签宽度
    }

    private void DrawThirdModule(MaterialEditor materialEditor)
    {
        // 临时禁用材质编辑器中的锁功能
        EditorGUIUtility.labelWidth += 16; // 增加标签宽度覆盖锁图标的位置
        // 绘制第三层纹理模块的属性
        materialEditor.TexturePropertySingleLine(new GUIContent("第三层纹理"), FindProperty("_ThirdMap"), FindProperty("_ThirdColor"));
        materialEditor.TextureScaleOffsetProperty(FindProperty("_ThirdMap"));
        EditorGUILayout.BeginVertical("HelpBox");
        materialEditor.ShaderProperty(FindProperty("_ThirdColorBlendMode"), "颜色混合模式");
        materialEditor.ShaderProperty(FindProperty("_ThirdColorIntensity"), "颜色强度");
        EditorGUILayout.EndVertical();
        EditorGUILayout.BeginVertical("HelpBox");
        materialEditor.ShaderProperty(FindProperty("_ThirdAlphaBlendMode"), "透明混合模式");
        materialEditor.ShaderProperty(FindProperty("_ThirdAlphaIntensity"), "透明强度");
        EditorGUILayout.EndVertical();
        materialEditor.ShaderProperty(FindProperty("_ThirdAnimation"), "动画依据");
        if (FindProperty("_ThirdAnimation").floatValue > 0.0f && FindProperty("_ThirdAnimation").floatValue < 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect popup1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect popup2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "动画依据:X/Y方向");
            FindProperty("_ThirdAnimationData01").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup1Rect, (DisableXYZWChannel)((int)FindProperty("_ThirdAnimationData01").floatValue));
            FindProperty("_ThirdAnimationData02").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup2Rect, (DisableXYZWChannel)((int)FindProperty("_ThirdAnimationData02").floatValue));
        }
        else if (FindProperty("_ThirdAnimation").floatValue > 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect field1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect field2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "时间速度");
            FindProperty("_ThirdAnimationData01").floatValue = EditorGUI.FloatField(field1Rect, FindProperty("_ThirdAnimationData01").floatValue);
            FindProperty("_ThirdAnimationData02").floatValue = EditorGUI.FloatField(field2Rect, FindProperty("_ThirdAnimationData02").floatValue);
        }
        DrawRotationSlider("_ThirdRotationParams", "旋转角度");

        // 绘制扭曲强度（独立参数，与Second一致）
        if (FindProperty("_EnableDistortion").floatValue > 0.5f)
        {
            materialEditor.ShaderProperty(FindProperty("_ThirdDistortionIntensity"), "扰动强度");
        }
        EditorGUIUtility.labelWidth -= 16; // 恢复标签宽度
    }

    private void DrawDissolveModule(MaterialEditor materialEditor)
    {
        // 绘制溶解模块的属性
        materialEditor.TexturePropertySingleLine(new GUIContent("溶解纹理"), FindProperty("_DissolveTex"), FindProperty("_DissolveColor"), FindProperty("_DissolveChannel"));
        materialEditor.TextureScaleOffsetProperty(FindProperty("_DissolveTex"));
        DrawRotationSlider("_DissolveRotationParams", "旋转角度");
        materialEditor.ShaderProperty(FindProperty("_DissolveAnimation"), "溶解动画依据");
        if (FindProperty("_DissolveAnimation").floatValue > 0.0f && FindProperty("_DissolveAnimation").floatValue < 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect popup1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect popup2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "动画依据:X/Y方向");
            FindProperty("_DissolveAnimationData01").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup1Rect, (DisableXYZWChannel)((int)FindProperty("_DissolveAnimationData01").floatValue));
            FindProperty("_DissolveAnimationData02").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup2Rect, (DisableXYZWChannel)((int)FindProperty("_DissolveAnimationData02").floatValue));
        }
        else if (FindProperty("_DissolveAnimation").floatValue > 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect field1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect field2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "时间速度");
            FindProperty("_DissolveAnimationData01").floatValue = EditorGUI.FloatField(field1Rect, FindProperty("_DissolveAnimationData01").floatValue);
            FindProperty("_DissolveAnimationData02").floatValue = EditorGUI.FloatField(field2Rect, FindProperty("_DissolveAnimationData02").floatValue);
        }
        
        // 绘制扭曲强度
        if (FindProperty("_EnableDistortion").floatValue > 0.5f)
        {
            materialEditor.ShaderProperty(FindProperty("_DissolveDistortionIntensity"), "扰动强度");
        }
        
        materialEditor.ShaderProperty(FindProperty("_DissolveDirection"), "溶解方向");
        materialEditor.ShaderProperty(FindProperty("_DissolveBlendAlpha"), "混合Alpha");
        materialEditor.ShaderProperty(FindProperty("_DissolveSource"), "溶解依据");
        if (FindProperty("_DissolveSource").floatValue == 0)
        {
            materialEditor.ShaderProperty(FindProperty("_DissolveThreshold"), "溶解阈值");
        }
        else if (Mathf.Approximately(FindProperty("_DissolveSource").floatValue, 2) || Mathf.Approximately(FindProperty("_DissolveSource").floatValue, 3))
        {
            materialEditor.ShaderProperty(FindProperty("_DissolveCustomDataChannel"), "自定义数据通道");
        }

        materialEditor.ShaderProperty(FindProperty("_DissolveSoftness"), "软边度");
    }

    private int selectedTab = 0;

    GUIContent defaultTab = new GUIContent("Default");

    private void DrawDistortionModule(MaterialEditor materialEditor)
    {
        // 绘制流动模块的属性
        materialEditor.ShaderProperty(FindProperty("_DistortionMode"), "扭曲模式");
        if (Mathf.Approximately(FindProperty("_DistortionMode").floatValue, 1))
        {
            materialEditor.ShaderProperty(FindProperty("_DistortionChannel"), "扭曲通道");
        }
        materialEditor.TexturePropertySingleLine(new GUIContent("扭曲纹理"), FindProperty("_DistortionTex"));
        materialEditor.TextureScaleOffsetProperty(FindProperty("_DistortionTex"));
        DrawRotationSlider("_DistortionRotationParams", "旋转角度");
        materialEditor.ShaderProperty(FindProperty("_DistortionAnimation"), "动画依据");
        if (FindProperty("_DistortionAnimation").floatValue > 0.0f && FindProperty("_DistortionAnimation").floatValue < 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect popup1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect popup2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "动画依据:X/Y方向");
            FindProperty("_DistortionAnimationData01").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup1Rect, (DisableXYZWChannel)((int)FindProperty("_DistortionAnimationData01").floatValue));
            FindProperty("_DistortionAnimationData02").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup2Rect, (DisableXYZWChannel)((int)FindProperty("_DistortionAnimationData02").floatValue));
        }
        else if (FindProperty("_DistortionAnimation").floatValue > 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect field1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect field2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "时间速度");
            FindProperty("_DistortionAnimationData01").floatValue = EditorGUI.FloatField(field1Rect, FindProperty("_DistortionAnimationData01").floatValue);
            FindProperty("_DistortionAnimationData02").floatValue = EditorGUI.FloatField(field2Rect, FindProperty("_DistortionAnimationData02").floatValue);
        }
    }

    private void DrawVertexAnimModule(MaterialEditor materialEditor)
    {
        // 绘制顶点动画模块的属性
        materialEditor.TexturePropertySingleLine(new GUIContent("顶点动画纹理"), FindProperty("_VertexAnimTex"));
        materialEditor.TextureScaleOffsetProperty(FindProperty("_VertexAnimTex"));
        DrawRotationSlider("_VertexAnimRotationParams", "旋转角度");
        materialEditor.ShaderProperty(FindProperty("_VertexAnimAnimation"), "动画依据");
        if (FindProperty("_VertexAnimAnimation").floatValue > 0.0f && FindProperty("_VertexAnimAnimation").floatValue < 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect popup1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect popup2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "动画依据:X/Y方向");
            FindProperty("_VertexAnimAnimationData01").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup1Rect, (DisableXYZWChannel)((int)FindProperty("_VertexAnimAnimationData01").floatValue));
            FindProperty("_VertexAnimAnimationData02").floatValue = (float)(int)(DisableXYZWChannel)EditorGUI.EnumPopup(popup2Rect, (DisableXYZWChannel)((int)FindProperty("_VertexAnimAnimationData02").floatValue));
        }
        else if (FindProperty("_VertexAnimAnimation").floatValue > 2.5f)
        {
            Rect totalRect = EditorGUILayout.GetControlRect(false, EditorGUIUtility.singleLineHeight);
            float labelWidth = EditorGUIUtility.labelWidth;
            float fieldWidth = (totalRect.width - labelWidth) / 2f;

            Rect labelRect = new Rect(totalRect.x, totalRect.y, labelWidth, totalRect.height);
            Rect field1Rect = new Rect(totalRect.x + labelWidth, totalRect.y, fieldWidth, totalRect.height);
            Rect field2Rect = new Rect(totalRect.x + labelWidth + fieldWidth, totalRect.y, fieldWidth, totalRect.height);

            EditorGUI.LabelField(labelRect, "时间速度");
            FindProperty("_VertexAnimAnimationData01").floatValue = EditorGUI.FloatField(field1Rect, FindProperty("_VertexAnimAnimationData01").floatValue);
            FindProperty("_VertexAnimAnimationData02").floatValue = EditorGUI.FloatField(field2Rect, FindProperty("_VertexAnimAnimationData02").floatValue);
        }
        
        // 绘制扭曲强度
        if (FindProperty("_EnableDistortion").floatValue > 0.5f)
        {
            materialEditor.ShaderProperty(FindProperty("_VertexAnimDistortionIntensity"), "扰动强度");
        }
        
        materialEditor.ShaderProperty(FindProperty("_VertexAnimChannel"), "采样通道");
        materialEditor.ShaderProperty(FindProperty("_VertexAnimIntensity"), "动画强度");
    }

    private void DrawFresnelModule(MaterialEditor materialEditor)
    {
        // materialEditor.ShaderProperty(FindProperty("_FresnelEdgeMode"), "菲涅尔边缘模式");
        // materialEditor.ShaderProperty(FindProperty("_FresnelInvert"), "菲涅尔反转");
        //
        // materialEditor.ShaderProperty(FindProperty("_FresnelIntensity"), "菲涅尔强度");
        // materialEditor.ShaderProperty(FindProperty("_FresnelPower"), "菲涅尔Power");
        materialEditor.ShaderProperty(FindProperty("_FresnelPower"), "菲涅尔Power");
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
        materialEditor.ShaderProperty(FindProperty("_DepthBlendMode"), "深度混合模式");
        if (FindProperty("_DepthBlendMode").floatValue > 0.5f)
        {
        }
            materialEditor.ShaderProperty(FindProperty("_DepthBlendColor"), "深度混合颜色");

        materialEditor.ShaderProperty(FindProperty("_IntersectionSoftness"), "交叉软边度");
    }

    /*
    private void DrawScreenDistortionModule(MaterialEditor materialEditor)
    {
        FindProperty("_ScreenDistortionChannel").floatValue = (float)(XYZWChannel)EditorGUILayout.EnumPopup(new GUIContent("扭曲通道", "使用当前材质球输出的RGBA做选择"), (XYZWChannel)FindProperty("_ScreenDistortionChannel").floatValue);
        materialEditor.ShaderProperty(FindProperty("_EnableScreenDistortionNormal"), "扭曲法线");
        materialEditor.ShaderProperty(FindProperty("_ScreenDistortionIntensity"), "热扭曲强度");
    }
    */

    protected override void OnAfterDefaultGUI(MaterialEditor materialEditor)
    {
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
        // materialEditor.ShaderProperty(FindProperty("_ZWrite"), "开启深度写入");
        if (blendMode == RenderingBlendUtils.BlendMode.Replace)
        {
            bool alphaClip = FindProperty("_EnableAlphaTest").floatValue > 0;
            if (alphaClip)
            {
                renderQueue = (int)RenderQueue.AlphaTest;
                mat.SetOverrideTag("RenderType", "TransparentCutout");
            }
            else
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
        }

        renderQueue += (int)FindProperty("_RenderQueueOffset").floatValue;
        if (renderQueue != mat.renderQueue)
            mat.renderQueue = renderQueue;

        mat.doubleSidedGI = false;
    }
}