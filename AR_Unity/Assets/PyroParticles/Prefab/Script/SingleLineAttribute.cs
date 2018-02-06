using UnityEngine;

#if UNITY_EDITOR

using UnityEditor;

#endif

namespace DigitalRuby.PyroParticles
{
    public class SingleLineAttribute : PropertyAttribute
    {
        public SingleLineAttribute(string tooltip) { Tooltip = tooltip; }

        public string Tooltip { get; private set; }
    }

#if UNITY_EDITOR

    [CustomPropertyDrawer(typeof(SingleLineAttribute))]
    public class SingleLineDrawer : PropertyDrawer
    {
        private void DrawIntTextField(Rect position, SerializedProperty prop)
        {
            EditorGUI.BeginChangeCheck();
            int value = EditorGUI.IntField(position, string.Empty, prop.intValue);
            if (EditorGUI.EndChangeCheck())
            {
                prop.intValue = value;
            }
        }

        private void DrawFloatTextField(Rect position, SerializedProperty prop)
        {
            EditorGUI.BeginChangeCheck();
            float value = EditorGUI.FloatField(position, string.Empty, prop.floatValue);
            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = value;
            }
        }

        private void DrawRangeField(Rect position, float labelWidth, float textFieldWidth, SerializedProperty prop, bool floatingPoint)
        {
            position.width = labelWidth;
            EditorGUI.LabelField(position, new GUIContent("Min", "Minimum value"));
            position.x += labelWidth;
            position.width = textFieldWidth;
            if (floatingPoint)
            {
                DrawFloatTextField(position, prop.FindPropertyRelative("Minimum"));
            }
            else
            {
                DrawIntTextField(position, prop.FindPropertyRelative("Minimum"));
            }
            position.x += textFieldWidth;
            position.width = labelWidth;
            EditorGUI.LabelField(position, new GUIContent("Max", "Maximum value"));
            position.x += labelWidth;
            position.width = textFieldWidth;
            if (floatingPoint)
            {
                DrawFloatTextField(position, prop.FindPropertyRelative("Maximum"));
            }
            else
            {
                DrawIntTextField(position, prop.FindPropertyRelative("Maximum"));
            }
        }

        public override void OnGUI(Rect position, SerializedProperty prop, GUIContent label)
        {
            EditorGUI.BeginProperty(position, label, prop);
            int indent = EditorGUI.indentLevel;
            EditorGUI.indentLevel = 0;
            position = EditorGUI.PrefixLabel(position, GUIUtility.GetControlID(FocusType.Passive), new GUIContent(label.text, (attribute as SingleLineAttribute).Tooltip));
            const float labelWidth = 32.0f;
            float widthAvailable = position.width - (labelWidth * 2.0f);
            float textFieldWidth = widthAvailable * 0.5f;

            switch (prop.type)
            {
                case "RangeOfIntegers":
                    DrawRangeField(position, labelWidth, textFieldWidth, prop, false);
                    break;

                case "RangeOfFloats":
                    DrawRangeField(position, labelWidth, textFieldWidth, prop, true);
                    break;
           
                default:
                    EditorGUI.HelpBox(position, "[Compact] doesn't work with type '" + prop.type + "'", MessageType.Error);
                    break;
            }

            EditorGUI.indentLevel = indent;
            EditorGUI.EndProperty();
        }
    }

#endif

}
