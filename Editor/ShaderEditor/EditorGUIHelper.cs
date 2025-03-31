using System;
using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

public static class EditorGUIHelper
{
    /// 静态字典存储模块折叠状态
    private static Dictionary<string, bool> m_ModuleFoldoutStates = new Dictionary<string, bool>();

    // 获取模块当前折叠状态
    public static bool GetModuleFoldoutState(string moduleName)
    {
        return m_ModuleFoldoutStates.TryGetValue(moduleName, out bool state) ? state : false;
    }

    // 设置模块折叠状态
    public static void SetModuleFoldoutState(string moduleName, bool expanded)
    {
        m_ModuleFoldoutStates[moduleName] = expanded;
    }

    /// <summary>
    /// 绘制一个可折叠的模块，并在内部处理折叠状态
    /// </summary>
    /// <param name="moduleName">模块的名称</param>
    /// <param name="drawContent">用于绘制模块内容的回调方法</param>
    /// <param name="isFldout">是否启用折叠</param>
    /// <param name="height">模块标题按钮的高度，0表示不显示标题按钮</param>
    /// <param name="enableSetting">是否显示设置按钮</param>
    /// <param name="defaultExpanded">模块默认是否展开</param>
    public static void DrawModuleContent( string moduleName, Action drawContent, Action setting = null, bool isFldout = true, int height = 17, bool defaultExpanded = false,MaterialProperty debuger = null)
    {
        // 确保模块状态初始化
        if (!m_ModuleFoldoutStates.ContainsKey(moduleName))
        {
            m_ModuleFoldoutStates[moduleName] = defaultExpanded;
        }

        // 标题区域
        EditorGUILayout.BeginVertical();
        EditorGUILayout.BeginHorizontal();
        GUILayout.Space(-3); // 左侧偏移

        // 标题按钮区域
        EditorGUILayout.BeginHorizontal();
        bool shouldShowContent = m_ModuleFoldoutStates[moduleName];

        GUIStyle style = new GUIStyle(GUI.skin.button);
        // 禁用悬停效果 - 使悬停状态与正常状态相同
        style.hover.background = Texture2D.redTexture;
        style.hover.textColor = style.normal.textColor;
        // 设置点击状态
        // style.active.background = Texture2D.blackTexture;
        // style.active.textColor = Color.white;
        style.alignment = TextAnchor.MiddleLeft;

        if (height > 0)
        {
            if (debuger != null)
            {
                debuger.floatValue = GUILayout.Toggle(debuger.floatValue > 0, "调试", style, GUILayout.Height(height),GUILayout.Width(35)) ? 1 : 0;
            }
            GUILayout.Space(-3); // 左侧偏移
            if (GUILayout.Button(moduleName,style, GUILayout.Height(height)) && isFldout)
            {
                m_ModuleFoldoutStates[moduleName] = !m_ModuleFoldoutStates[moduleName];
                shouldShowContent = m_ModuleFoldoutStates[moduleName];
                GUI.changed = true; // 标记GUI发生变化，触发重绘
            }
        }
        else
        {
            // 不显示标题按钮时默认展开
            shouldShowContent = true;
        }

        if (setting != null)
        {
            GUILayout.Space(-3); // 左侧偏移
            if (GUILayout.Button("三", GUILayout.Width(40), GUILayout.Height(height > 0 ? height : 17)))
            {
                setting?.Invoke();
            }
        }
        
        EditorGUILayout.EndHorizontal();

        GUILayout.Space(-3); // 左侧偏移
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(-3); // 左侧偏移
        EditorGUILayout.EndVertical();

        // 内容区域 - 直接根据状态决定是否显示
        if (shouldShowContent && drawContent != null)
        {
            // 添加一点内容区域的间距
            EditorGUILayout.Space(2);
            // 调用回调绘制内容区域
            drawContent.Invoke();
        }
    }

}