using System;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace Nemo.Editor.ShaderUI
{
    /// <summary>
    /// Create a toggleable header for material UI, must be used within a scope.
    /// </summary>
    public struct NemoMaterialHeaderScope : IDisposable
    {
        /// <summary>Indicates whether the header is expanded or not.</summary>
        public readonly bool expanded;
        bool spaceAtEnd;
        
        /// <summary>
        /// 菜单按钮点击回调
        /// </summary>
        public static Action<string> OnMenuButtonClicked;
        
        // 用于记录菜单按钮区域，跨帧使用
        private static Rect s_PendingMenuButtonRect;
        private static string s_PendingModuleName;
        private static bool s_MenuButtonClicked;

        /// <summary>
        /// Creates a material header scope to display the foldout in the material UI.
        /// </summary>
        public NemoMaterialHeaderScope(NemoMaterialHeaderScopeList scopeList, GUIContent title, uint bitExpanded, MaterialEditor materialEditor, bool spaceAtEnd = true, bool subHeader = false, uint defaultExpandedState = uint.MaxValue, string documentationURL = "", string moduleName = null)
        {
            if (title == null)
                throw new ArgumentNullException(nameof(title));

            bool beforeExpanded = scopeList.IsAreaExpanded(materialEditor, bitExpanded, defaultExpandedState);

            this.spaceAtEnd = spaceAtEnd;
            if (!subHeader)
                CoreEditorUtils.DrawSplitter();
            GUILayout.BeginVertical();

            bool saveChangeState = GUI.changed;
            bool menuClicked = false;
            
            // 在绘制 header 之前，检测菜单按钮点击
            // 使用上一帧记录的按钮位置来检测当前帧的点击
            if (!string.IsNullOrEmpty(moduleName) && s_PendingModuleName == moduleName)
            {
                if (Event.current.type == EventType.MouseDown && Event.current.button == 0)
                {
                    if (s_PendingMenuButtonRect.Contains(Event.current.mousePosition))
                    {
                        menuClicked = true;
                        s_MenuButtonClicked = true;
                        OnMenuButtonClicked?.Invoke(moduleName);
                        Event.current.Use();
                    }
                }
            }
            
            // 使用 CoreEditorUtils.DrawHeaderFoldout 绘制标准 header
            if (!menuClicked)
            {
                expanded = subHeader
                    ? CoreEditorUtils.DrawSubHeaderFoldout(title, beforeExpanded, isBoxed: false)
                    : CoreEditorUtils.DrawHeaderFoldout(title, beforeExpanded, documentationURL: documentationURL);
            }
            else
            {
                // 菜单按钮被点击，仍然绘制 header 但保持原状态
                bool dummy = subHeader
                    ? CoreEditorUtils.DrawSubHeaderFoldout(title, beforeExpanded, isBoxed: false)
                    : CoreEditorUtils.DrawHeaderFoldout(title, beforeExpanded, documentationURL: documentationURL);
                expanded = beforeExpanded;
            }
            
            // 在 header 绘制后，绘制菜单按钮并记录位置
            if (!string.IsNullOrEmpty(moduleName))
            {
                Rect lastRect = GUILayoutUtility.GetLastRect();
                // 按钮与标题栏高度对齐
                Rect menuButtonRect = new Rect(lastRect.xMax - 22, lastRect.y, 20, lastRect.height);
                
                // 记录按钮位置供下一帧使用
                if (Event.current.type == EventType.Repaint)
                {
                    s_PendingMenuButtonRect = menuButtonRect;
                    s_PendingModuleName = moduleName;
                }
                
                // 绘制带悬停效果的按钮
                GUIContent menuIcon = EditorGUIUtility.IconContent("_Menu");
                GUIStyle buttonStyle = new GUIStyle("IconButton");
                
                if (GUI.Button(menuButtonRect, menuIcon, buttonStyle))
                {
                    // Button 在 MouseUp 时触发，但此时展开状态已经改变
                    // 所以我们用上面的 MouseDown 检测来阻止展开
                }
                
                // 检测右键点击显示菜单
                if (Event.current.type == EventType.ContextClick && lastRect.Contains(Event.current.mousePosition))
                {
                    OnMenuButtonClicked?.Invoke(moduleName);
                    Event.current.Use();
                }
            }
            
            if (expanded ^ beforeExpanded)
            {
                scopeList.SetIsAreaExpanded(materialEditor, bitExpanded, expanded);
                saveChangeState = true;
            }
            GUI.changed = saveChangeState;
        }

        /// <summary>
        /// Creates a material header scope to display the foldout in the material UI.
        /// </summary>
        public NemoMaterialHeaderScope(NemoMaterialHeaderScopeList scopeList, string title, uint bitExpanded, MaterialEditor materialEditor, bool spaceAtEnd = true, bool subHeader = false)
            : this(scopeList, EditorGUIUtility.TrTextContent(title, string.Empty), bitExpanded, materialEditor, spaceAtEnd, subHeader)
        {
        }

        /// <summary>Disposes of the material scope header and cleans up any resources it used.</summary>
        void IDisposable.Dispose()
        {
            if (expanded && spaceAtEnd && (Event.current.type == EventType.Repaint || Event.current.type == EventType.Layout))
                EditorGUILayout.Space();

            GUILayout.EndVertical();
        }
    }
}
