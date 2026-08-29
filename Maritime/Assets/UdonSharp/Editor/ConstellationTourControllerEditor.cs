
using UdonSharpEditor;
using UnityEditor;
using UnityEngine;

namespace ConstellationObservation.EditorTools
{
    [CustomEditor(typeof(ConstellationTourController))]
    public class ConstellationTourControllerEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            if (UdonSharpGUI.DrawDefaultUdonSharpBehaviourHeader(target, true, true)) return;

            DrawDefaultInspector();

            var controller = (ConstellationTourController)target;
            var libRef = controller.GetComponent<ConstellationLibraryRef>();

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Library (editor-only reference)", EditorStyles.boldLabel);
            if (libRef == null)
            {
                EditorGUILayout.HelpBox("No ConstellationLibraryRef found on this GameObject. Add one to pick a library asset.", MessageType.Info);
                if (GUILayout.Button("Add ConstellationLibraryRef"))
                {
                    Undo.AddComponent<ConstellationLibraryRef>(controller.gameObject);
                }
            }
            else
            {
                var so = new SerializedObject(libRef);
                var libProp = so.FindProperty("library");
                EditorGUILayout.PropertyField(libProp);
                so.ApplyModifiedProperties();

                if (GUILayout.Button("Sync From Library"))
                {
                    if (libRef.library == null)
                    {
                        EditorUtility.DisplayDialog("No Library Assigned", "Assign a ConstellationLibrary asset first.", "OK");
                    }
                    else
                    {
                        Undo.RecordObject(controller, "Sync Constellation Library");
                        controller.constellations = (GameObject[])libRef.library.targets.Clone();
                        controller.narrationClips = (AudioClip[])libRef.library.narrationClips.Clone();
                        controller.subtitleLines = (string[])libRef.library.subtitleLines.Clone();
                        controller.subtitleStartTimes = (float[])libRef.library.subtitleStartTimes.Clone();
                        controller.subtitleCounts = (int[])libRef.library.subtitleCounts.Clone();
                        EditorUtility.SetDirty(controller);
                    }
                }
            }
        }
    }
}
