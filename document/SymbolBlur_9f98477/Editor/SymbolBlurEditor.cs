using UnityEditor;
using UnityEngine;

[CanEditMultipleObjects]
[CustomEditor(typeof(SymbolBlur))]
public sealed class SymbolBlurEditor : Editor
{
    private SerializedProperty _sourceSprite;
    private SerializedProperty _meshHeightMultiplier;
    private SerializedProperty _verticalBlur;
    private SerializedProperty _blurStrength;
    private SerializedProperty _antiBanding;
    private SerializedProperty _color;
    private SerializedProperty _raycastTarget;
    private SerializedProperty _raycastPadding;
    private SerializedProperty _maskable;

    private void OnEnable()
    {
        _sourceSprite = serializedObject.FindProperty("_sourceSprite");
        _meshHeightMultiplier = serializedObject.FindProperty("_meshHeightMultiplier");
        _verticalBlur = serializedObject.FindProperty("_verticalBlur");
        _blurStrength = serializedObject.FindProperty("_blurStrength");
        _antiBanding = serializedObject.FindProperty("_antiBanding");
        _color = serializedObject.FindProperty("m_Color");
        _raycastTarget = serializedObject.FindProperty("m_RaycastTarget");
        _raycastPadding = serializedObject.FindProperty("m_RaycastPadding");
        _maskable = serializedObject.FindProperty("m_Maskable");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        using (new EditorGUI.DisabledScope(true))
        {
            EditorGUILayout.ObjectField("Script", MonoScript.FromMonoBehaviour((SymbolBlur)target),
                typeof(MonoScript), false);
        }

        EditorGUILayout.PropertyField(_sourceSprite);
        EditorGUILayout.PropertyField(_meshHeightMultiplier);
        EditorGUILayout.PropertyField(_verticalBlur);
        EditorGUILayout.PropertyField(_blurStrength);
        EditorGUILayout.PropertyField(_antiBanding);
        EditorGUILayout.PropertyField(_color);
        EditorGUILayout.PropertyField(_raycastTarget);

        if (_raycastPadding != null)
        {
            EditorGUILayout.PropertyField(_raycastPadding);
        }

        if (_maskable != null)
        {
            EditorGUILayout.PropertyField(_maskable);
        }

        serializedObject.ApplyModifiedProperties();

        EditorGUILayout.Space();
        if (!GUILayout.Button("Set Native Size New"))
        {
            return;
        }

        foreach (Object selectedTarget in targets)
        {
            SymbolBlur symbolBlur = selectedTarget as SymbolBlur;
            if (symbolBlur == null)
            {
                continue;
            }

            Undo.RecordObject(symbolBlur.rectTransform, "Set Symbol Blur Native Size");
            symbolBlur.SetNativeSizeNew();
            EditorUtility.SetDirty(symbolBlur.rectTransform);
        }
    }
}
