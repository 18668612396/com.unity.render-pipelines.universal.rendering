using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor.Rendering;
using Nemo.Editor.ShaderUI;

public abstract class ModularShaderEditor : ShaderGUI
{
    [Flags]
    protected enum Expandable
    {
        Base = 1 << 0,
        Main = 1 << 1,
        After = 1 << 2,
        Module0 = 1 << 4,
        Module1 = 1 << 5,
        Module2 = 1 << 6,
        Module3 = 1 << 7,
        Module4 = 1 << 8,
        Module5 = 1 << 9,
        Module6 = 1 << 10,
        Module7 = 1 << 11,
        Module8 = 1 << 12,
        Module9 = 1 << 13,
    }

    private MaterialEditor m_MaterialEditor;
    private MaterialProperty[] m_Properties;
    protected Material material;

    protected NemoMaterialHeaderScopeList m_MaterialScopeList;

    protected abstract string BeforeModuleName { get; }
    protected abstract string MainModuleName { get; }
    protected abstract string AfterModuleName { get; }

    protected abstract Dictionary<(string ModuleName, string PropertyName, string keyword), Action<MaterialEditor>> ModuleProperties { get; }

    protected abstract void OnBeforeDefaultGUI(MaterialEditor materialEditor);
    protected abstract void OnMainDefaultGUI(MaterialEditor materialEditor);
    protected abstract void OnAfterDefaultGUI(MaterialEditor materialEditor);

    private Dictionary<string, bool> m_ModuleStates = new Dictionary<string, bool>();

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        m_Properties = properties;
        m_MaterialEditor = materialEditor;
        material = materialEditor.target as Material;

        // 设置菜单按钮回调
        NemoMaterialHeaderScope.OnMenuButtonClicked = ShowModuleContextMenu;

        InitializeModuleStates();
        RebuildMaterialScopeList();

        // 绘制所有 headers
        if (m_MaterialScopeList != null)
        {
            m_MaterialScopeList.DrawHeaders(materialEditor, material);
        }

        // 添加模块按钮
        EditorGUILayout.Space();
        if (GUILayout.Button("添加模块", GUILayout.Height(30)))
        {
            ShowModuleSelector();
        }
    }

    private void RebuildMaterialScopeList()
    {
        uint defaultExpanded = (uint)Expandable.Base | (uint)Expandable.Main;
        m_MaterialScopeList = new NemoMaterialHeaderScopeList(defaultExpanded);

        // BeforeModule - null 表示跳过，空字符串使用 "No Name"
        if (BeforeModuleName != null)
        {
            string beforeName = string.IsNullOrEmpty(BeforeModuleName) ? "No Name" : BeforeModuleName;
            m_MaterialScopeList.RegisterHeaderScope(
                new GUIContent(beforeName),
                Expandable.Base,
                mat => OnBeforeDefaultGUI(m_MaterialEditor)
            );
        }

        if (!string.IsNullOrEmpty(MainModuleName))
        {
            m_MaterialScopeList.RegisterHeaderScope(
                new GUIContent(MainModuleName),
                Expandable.Main,
                mat => OnMainDefaultGUI(m_MaterialEditor)
            );
        }

        int moduleIndex = 0;
        var moduleExpandables = new[]
        {
            Expandable.Module0, Expandable.Module1, Expandable.Module2, Expandable.Module3,
            Expandable.Module4, Expandable.Module5, Expandable.Module6, Expandable.Module7,
            Expandable.Module8, Expandable.Module9
        };

        foreach (var module in ModuleProperties)
        {
            if (moduleIndex >= moduleExpandables.Length) break;

            string moduleName = module.Key.ModuleName;

            if (m_ModuleStates.ContainsKey(moduleName) && m_ModuleStates[moduleName])
            {
                var moduleAction = module.Value;
                var expandable = moduleExpandables[moduleIndex];
                string capturedModuleName = moduleName; // 捕获变量

                // 使用带 moduleName 参数的重载，以便显示菜单按钮
                m_MaterialScopeList.RegisterHeaderScope(
                    new GUIContent(moduleName),
                    expandable,
                    mat => moduleAction?.Invoke(m_MaterialEditor),
                    capturedModuleName
                );

                moduleIndex++;
            }
        }

        if (!string.IsNullOrEmpty(AfterModuleName))
        {
            m_MaterialScopeList.RegisterHeaderScope(
                new GUIContent(AfterModuleName),
                Expandable.After,
                mat => OnAfterDefaultGUI(m_MaterialEditor)
            );
        }
    }

    private void InitializeModuleStates()
    {
        m_ModuleStates.Clear();
        foreach (var module in ModuleProperties)
        {
            bool isEnabled = material.HasProperty(module.Key.PropertyName)
                             && material.GetFloat(module.Key.PropertyName) > 0.5f;
            m_ModuleStates[module.Key.ModuleName] = isEnabled;
            SetShaderKeyword(module.Key.keyword, isEnabled);
        }
    }

    private void ShowModuleSelector()
    {
        GenericMenu menu = new GenericMenu();

        bool hasAvailableModule = false;
        foreach (var module in ModuleProperties)
        {
            string moduleName = module.Key.ModuleName;
            if (!m_ModuleStates.ContainsKey(moduleName) || !m_ModuleStates[moduleName])
            {
                string capturedName = moduleName; // 捕获变量避免闭包问题
                menu.AddItem(new GUIContent(moduleName), false, () => AddModule(capturedName));
                hasAvailableModule = true;
            }
            else
            {
                menu.AddDisabledItem(new GUIContent(moduleName));
            }
        }

        if (hasAvailableModule || ModuleProperties.Count > 0)
        {
            menu.ShowAsContext();
        }
    }

    private void AddModule(string moduleName)
    {
        Undo.RegisterCompleteObjectUndo(material, "Add Module");
        m_ModuleStates[moduleName] = true;

        var moduleEntry = ModuleProperties.FirstOrDefault(x => x.Key.ModuleName == moduleName);
        if (moduleEntry.Value != null && material.HasProperty(moduleEntry.Key.PropertyName))
        {
            material.SetFloat(moduleEntry.Key.PropertyName, 1.0f);
            EditorUtility.SetDirty(material);
            Debug.Log($"Added module: {moduleName}, property: {moduleEntry.Key.PropertyName}");
        }
        else
        {
            Debug.LogWarning($"Cannot add module: {moduleName}, property {moduleEntry.Key.PropertyName} not found in material");
        }
        SetShaderKeyword(moduleEntry.Key.keyword, true);
    }

    private void RemoveModule(string moduleName)
    {
        Undo.RegisterCompleteObjectUndo(material, "Remove Module");
        m_ModuleStates[moduleName] = false;

        var moduleEntry = ModuleProperties.First(x => x.Key.ModuleName == moduleName);
        if (material.HasProperty(moduleEntry.Key.PropertyName))
        {
            material.SetFloat(moduleEntry.Key.PropertyName, 0.0f);
            EditorUtility.SetDirty(material);
        }
        SetShaderKeyword(moduleEntry.Key.keyword, false);
    }

    private void ShowModuleContextMenu(string moduleName)
    {
        GenericMenu menu = new GenericMenu();

        var activeModules = m_ModuleStates.Where(m => m.Value).Select(m => m.Key).ToList();
        int currentIndex = activeModules.IndexOf(moduleName);

        if (currentIndex > 0)
            menu.AddItem(new GUIContent("向上移动"), false, () => { });
        else
            menu.AddDisabledItem(new GUIContent("向上移动"));

        if (currentIndex < activeModules.Count - 1)
            menu.AddItem(new GUIContent("向下移动"), false, () => { });
        else
            menu.AddDisabledItem(new GUIContent("向下移动"));

        menu.AddSeparator("");
        menu.AddItem(new GUIContent("移除模块"), false, () => RemoveModule(moduleName));

        menu.ShowAsContext();
    }

    public void DoPopup(MaterialEditor materialEditor, GUIContent label, MaterialProperty property, string[] options)
    {
        DoPopup(label, property, options, materialEditor);
    }

    public void DoPopup(GUIContent label, MaterialProperty property, string[] options, MaterialEditor materialEditor)
    {
        if (property == null)
            throw new ArgumentNullException("property");

        EditorGUI.showMixedValue = property.hasMixedValue;

        var mode = property.floatValue;
        EditorGUI.BeginChangeCheck();
        mode = EditorGUILayout.Popup(label, (int)mode, options);
        if (EditorGUI.EndChangeCheck())
        {
            materialEditor.RegisterPropertyChangeUndo(label.text);
            property.floatValue = mode;
        }

        EditorGUI.showMixedValue = false;
    }

    #region Utility Methods

    private void SetShaderKeyword(string keyword, bool enable)
    {
        if (string.IsNullOrEmpty(keyword)) return;

        if (enable)
            material.EnableKeyword(keyword);
        else
            material.DisableKeyword(keyword);
    }

    protected MaterialProperty FindProperty(string propertyName)
    {
        var result = FindProperty(propertyName, m_Properties, false);
        if (result == null)
        {
            Debug.LogError($"没有找到参数 ： {propertyName} ");
            return null;
        }

        return result;
    }

    #endregion
}
