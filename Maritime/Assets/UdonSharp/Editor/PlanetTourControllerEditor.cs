
using UdonSharpEditor;
using UnityEditor;
using UnityEngine;

namespace ConstellationObservation.EditorTools
{
    [CustomEditor(typeof(PlanetTourController))]
    public class PlanetTourControllerEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            if (UdonSharpGUI.DrawDefaultUdonSharpBehaviourHeader(target, true, true)) return;

            DrawDefaultInspector();

            var controller = (PlanetTourController)target;
            var libRef = controller.GetComponent<PlanetLibraryRef>();

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Library (editor-only reference)", EditorStyles.boldLabel);
            if (libRef == null)
            {
                EditorGUILayout.HelpBox("No PlanetLibraryRef found on this GameObject. Add one to pick a library asset.", MessageType.Info);
                if (GUILayout.Button("Add PlanetLibraryRef"))
                {
                    Undo.AddComponent<PlanetLibraryRef>(controller.gameObject);
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
                        EditorUtility.DisplayDialog("No Library Assigned", "Assign a PlanetLibrary asset first.", "OK");
                    }
                    else
                    {
                        Undo.RecordObject(controller, "Sync Planet Library");
                        controller.targets = (Transform[])libRef.library.targets.Clone();
                        controller.planetNames = (string[])libRef.library.planetNames.Clone();
                        controller.highlightLights = (Light[])libRef.library.highlightLights.Clone();
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
