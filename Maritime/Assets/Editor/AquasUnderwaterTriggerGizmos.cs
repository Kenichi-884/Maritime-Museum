// Editor-only gizmo drawer for AquasUnderwaterTrigger.
// Kept in Assets/Editor/ so UdonSharp never parses it.
// Shows the trigger volume (zone-color-coded), water surface line, max-fog-depth marker,
// and per-zone fog density labels in the Scene view.
using UnityEditor;
using UnityEngine;

// Zone color: Harbor=teal, OpenOcean=sky-blue, DeepSea=navy, unknown=blue.
internal static class ZoneGizmoColor
{
    internal static Color For(string goName)
    {
        if (goName.Contains("Harbor"))    return new Color(0.20f, 0.85f, 0.65f, 1f);
        if (goName.Contains("OpenOcean")) return new Color(0.20f, 0.60f, 1.00f, 1f);
        if (goName.Contains("DeepSea"))   return new Color(0.05f, 0.20f, 0.65f, 1f);
        return new Color(0.10f, 0.50f, 1.00f, 1f);
    }
}

[CustomEditor(typeof(AquasUnderwaterTrigger))]
public class AquasUnderwaterTriggerEditor : Editor
{
    private void OnSceneGUI()
    {
        AquasUnderwaterTrigger t = (AquasUnderwaterTrigger)target;

        SerializedObject so = new SerializedObject(t);
        Transform waterSurface = so.FindProperty("waterSurface").objectReferenceValue as Transform;
        float maxFogDepth      = so.FindProperty("maxFogDepth").floatValue;
        float densityShallow   = so.FindProperty("underwaterFogDensityShallow").floatValue;
        float densityDeep      = so.FindProperty("underwaterFogDensityDeep").floatValue;

        float surfY = waterSurface != null ? waterSurface.position.y : t.transform.position.y;
        float deepY = surfY - maxFogDepth;
        Color zc    = ZoneGizmoColor.For(t.gameObject.name);
        float cx    = t.transform.position.x;
        float cz    = t.transform.position.z;

        // ── 3D: 縦バーのみ（線1本 + 端点ディスク）──────────────────────
        // 複数ゾーンが重なっていても線1本なら最小限の被りで済む
        Handles.color = new Color(zc.r, zc.g, zc.b, 0.9f);
        Handles.DrawLine(new Vector3(cx, surfY, cz), new Vector3(cx, deepY, cz));
        Handles.DrawWireDisc(new Vector3(cx, surfY, cz), Vector3.up, 1.0f);
        Handles.DrawWireDisc(new Vector3(cx, deepY, cz), Vector3.up, 0.6f);

        // ── 2D: スクリーンスペースのパネル（被りゼロ）──────────────────
        // ゾーン名でパネルのY位置をずらしてマルチ選択時も読める
        int zoneIndex = t.gameObject.name.Contains("Harbor")    ? 0
                      : t.gameObject.name.Contains("OpenOcean") ? 1
                      : t.gameObject.name.Contains("DeepSea")   ? 2 : 3;
        float panelY = 10f + zoneIndex * 115f;

        Color prev = GUI.color;
        Handles.BeginGUI();
        GUI.color = new Color(zc.r, zc.g, zc.b, 1f);
        GUILayout.BeginArea(new Rect(10, panelY, 230, 105), GUI.skin.box);
        GUI.color = prev;

        GUIStyle bold = new GUIStyle(EditorStyles.boldLabel);
        bold.normal.textColor = new Color(zc.r * 1.2f, zc.g * 1.2f, zc.b * 1.2f);
        GUILayout.Label(t.gameObject.name, bold);

        GUILayout.Label($"水面 density   : {densityShallow:F3}");
        GUILayout.Label($"深部 density   : {densityDeep:F3}");
        GUILayout.Label($"maxFogDepth : {maxFogDepth} u");
        GUILayout.Label($"深度範囲       : Y {surfY:F1} → {deepY:F1}");

        GUILayout.EndArea();
        Handles.EndGUI();
    }
}

// Draws a zone-color-coded volume outline even when not selected.
public static class AquasUnderwaterTriggerGizmos
{
    [DrawGizmo(GizmoType.Selected | GizmoType.NonSelected | GizmoType.Pickable)]
    static void DrawGizmo(AquasUnderwaterTrigger trigger, GizmoType gizmoType)
    {
        bool selected = (gizmoType & GizmoType.Selected) != 0;
        Collider col = trigger.GetComponent<Collider>();
        if (col == null) return;

        Color zc = ZoneGizmoColor.For(trigger.gameObject.name);

        BoxCollider box = col as BoxCollider;
        if (box != null)
        {
            Gizmos.matrix = Matrix4x4.TRS(trigger.transform.position, trigger.transform.rotation, trigger.transform.lossyScale);
            Gizmos.color = selected
                ? new Color(zc.r, zc.g, zc.b, 0.18f)
                : new Color(zc.r, zc.g, zc.b, 0.05f);
            Gizmos.DrawCube(box.center, box.size);
            Gizmos.color = selected
                ? new Color(zc.r, zc.g, zc.b, 0.85f)
                : new Color(zc.r, zc.g, zc.b, 0.30f);
            Gizmos.DrawWireCube(box.center, box.size);
            Gizmos.matrix = Matrix4x4.identity;
        }
        else
        {
            Gizmos.color = selected
                ? new Color(zc.r, zc.g, zc.b, 0.50f)
                : new Color(zc.r, zc.g, zc.b, 0.20f);
            Gizmos.DrawWireSphere(col.bounds.center, col.bounds.extents.magnitude);
        }

        // Zone name label (always visible, at volume top-center)
        Handles.Label(col.bounds.center + Vector3.up * col.bounds.extents.y,
            trigger.gameObject.name);
    }
}
