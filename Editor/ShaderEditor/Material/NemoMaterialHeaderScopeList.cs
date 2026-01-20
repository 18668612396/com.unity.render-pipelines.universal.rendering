using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace Nemo.Editor.ShaderUI
{
    /// <summary>
    /// Collection to store <see cref="NemoMaterialHeaderScopeItem"></see>
    /// </summary>
    public class NemoMaterialHeaderScopeList
    {
        readonly uint m_DefaultExpandedState;
        internal readonly List<NemoMaterialHeaderScopeItem> m_Items = new List<NemoMaterialHeaderScopeItem>();

        /// <summary>
        /// Constructor that initializes it with the default expanded state for the internal scopes
        /// </summary>
        /// <param name="defaultExpandedState">By default, everything is expanded</param>
        public NemoMaterialHeaderScopeList(uint defaultExpandedState = uint.MaxValue)
        {
            m_DefaultExpandedState = defaultExpandedState;
        }

        /// <summary>
        /// Registers a <see cref="NemoMaterialHeaderScopeItem"/> into the list
        /// </summary>
        public void RegisterHeaderScope<TEnum>(GUIContent title, TEnum expandable, Action<Material> action)
            where TEnum : struct, IConvertible
        {
            RegisterHeaderScope(title, expandable, action, null);
        }

        /// <summary>
        /// Registers a <see cref="NemoMaterialHeaderScopeItem"/> into the list with module name for menu button
        /// </summary>
        public void RegisterHeaderScope<TEnum>(GUIContent title, TEnum expandable, Action<Material> action, string moduleName)
            where TEnum : struct, IConvertible
        {
            m_Items.Add(new NemoMaterialHeaderScopeItem()
            {
                headerTitle = title,
                expandable = Convert.ToUInt32(expandable),
                drawMaterialScope = action,
                moduleName = moduleName,
            });
        }

        /// <summary>
        /// Draws all the <see cref="NemoMaterialHeaderScopeItem"/> with its information stored
        /// </summary>
        public void DrawHeaders(MaterialEditor materialEditor, Material material)
        {
            if (material == null)
                throw new ArgumentNullException(nameof(material));

            if (materialEditor == null)
                throw new ArgumentNullException(nameof(materialEditor));

            foreach (var item in m_Items)
            {
                using var header = new NemoMaterialHeaderScope(
                    this,
                    item.headerTitle,
                    item.expandable,
                    materialEditor,
                    defaultExpandedState: m_DefaultExpandedState,
                    documentationURL: item.url,
                    moduleName: item.moduleName);
                if (!header.expanded)
                    continue;

                item.drawMaterialScope(material);

                EditorGUILayout.Space();
            }
            
            EditorGUIUtility.labelWidth = 0;
        }

        // 使用 EditorPrefs 存储展开状态，key 基于 material 的 instanceID
        private static string GetPrefsKey(MaterialEditor editor)
        {
            if (editor == null || editor.target == null) return "NemoMaterialHeader_Default";
            return $"NemoMaterialHeader_{editor.target.GetInstanceID()}";
        }
        
        private MaterialEditor m_CachedEditor;
        private uint m_ExpanderState;
        private bool m_IsInitialized;
        
        public bool IsAreaExpanded(MaterialEditor editor, uint mask, uint defaultExpandedState = uint.MaxValue)
        {
            if (!m_IsInitialized || m_CachedEditor != editor)
            {
                m_CachedEditor = editor;
                m_ExpanderState = (uint)EditorPrefs.GetInt(GetPrefsKey(editor), (int)defaultExpandedState);
                m_IsInitialized = true;
            }
            return (m_ExpanderState & mask) > 0;
        }

        public void SetIsAreaExpanded(MaterialEditor editor, uint mask, bool value)
        {
            if (value)
                m_ExpanderState |= mask;
            else
                m_ExpanderState &= ~mask;
            
            EditorPrefs.SetInt(GetPrefsKey(editor), (int)m_ExpanderState);
        }
    }
}
