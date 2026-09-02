using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

/// <summary>
/// Editor window that scatters rocks, plants, and trees across a terrain
/// using Poisson disk sampling for a natural-looking distribution.
///
/// Slope rules:
///   Rocks  → placed preferentially on steeper slopes
///   Plants → placed on moderate to flat areas
///   Trees  → placed only on flat areas
/// </summary>
public class TerrainDecoratorWindow : EditorWindow
{
    // ── Target ──────────────────────────────────────────────────────────────
    private Terrain _terrain;

    // ── Counts ───────────────────────────────────────────────────────────────
    private int _rockCount  = 80;
    private int _plantCount = 200;
    private int _treeCount  = 50;

    // ── Slope rules (degrees from horizontal) ────────────────────────────────
    private float _minSlopeRocks  = 15f;   // rocks prefer steeper terrain
    private float _maxSlopePlants = 35f;   // plants avoid cliffs
    private float _maxSlopeTrees  = 20f;   // trees only on flat ground

    // ── Height filter ────────────────────────────────────────────────────────
    private float _minHeight =   0f;
    private float _maxHeight = 500f;

    // ── Scale variation ───────────────────────────────────────────────────────
    private float _minScale = 0.75f;
    private float _maxScale = 1.50f;

    // ── Distribution ─────────────────────────────────────────────────────────
    private float _minSpacing = 3f;    // metres between any two objects

    // ── Scene organisation ───────────────────────────────────────────────────
    private string _parentName    = "TerrainDecorations";
    private bool   _clearPrevious = false;

    private Vector2 _scroll;

    // ── Prefab paths ─────────────────────────────────────────────────────────
    private static readonly string[] RockPaths =
    {
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Rocks/Boulder_8.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Rocks/Boulder_9.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Rocks/Boulder_10.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Rocks/Boulder_11.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Rocks/Boulder_12.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Rocks/Boulder_13.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Rocks/Boulder_14.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Rocks/Boulder_15.prefab",
    };

    private static readonly string[] PlantPaths =
    {
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/Aloe1.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/Aloe2.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/Aloe3.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/Blindweed.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/Cordyline1.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/Cordyline2.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/Cordyline3.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/Grass1.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/Grass2.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/Grass3.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/DryPalm1.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Plants/DryPalm2.prefab",
    };

    private static readonly string[] TreePaths =
    {
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Coconut1.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Coconut2.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Coconut3.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Coconut4.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Coconut5.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Coconut6.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Pandanace1.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Pandanace2.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Pandanace3.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Bush1.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Bush2.prefab",
        "Assets/ThirdParty/BK/PureNature_Islands/Prefabs/Trees/Bush3.prefab",
    };

    // ── Menu entry ───────────────────────────────────────────────────────────
    [MenuItem("Maritime Museum/Terrain Decorator")]
    public static void ShowWindow() =>
        GetWindow<TerrainDecoratorWindow>("Terrain Decorator");

    // ── GUI ──────────────────────────────────────────────────────────────────
    private void OnGUI()
    {
        _scroll = EditorGUILayout.BeginScrollView(_scroll);

        EditorGUILayout.LabelField("Terrain Decorator", EditorStyles.boldLabel);
        EditorGUILayout.Space(4);

        _terrain = (Terrain)EditorGUILayout.ObjectField("Terrain", _terrain, typeof(Terrain), true);
        if (_terrain == null && GUILayout.Button("Auto-find Terrain in Scene"))
            _terrain = FindObjectOfType<Terrain>();

        EditorGUILayout.Space(8);
        EditorGUILayout.LabelField("Placement Counts", EditorStyles.boldLabel);
        _rockCount  = EditorGUILayout.IntSlider("Rocks",  _rockCount,  0, 400);
        _plantCount = EditorGUILayout.IntSlider("Plants", _plantCount, 0, 600);
        _treeCount  = EditorGUILayout.IntSlider("Trees",  _treeCount,  0, 200);

        EditorGUILayout.Space(8);
        EditorGUILayout.LabelField("Slope Rules (degrees)", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox(
            "Rocks:  placed on slopes ≥ min\nPlants: placed on slopes ≤ max\nTrees:  placed on slopes ≤ max",
            MessageType.None);
        _minSlopeRocks  = EditorGUILayout.Slider("Min slope – Rocks",  _minSlopeRocks,  0f, 70f);
        _maxSlopePlants = EditorGUILayout.Slider("Max slope – Plants", _maxSlopePlants, 0f, 70f);
        _maxSlopeTrees  = EditorGUILayout.Slider("Max slope – Trees",  _maxSlopeTrees,  0f, 45f);

        EditorGUILayout.Space(8);
        EditorGUILayout.LabelField("Height Filter (world Y)", EditorStyles.boldLabel);
        _minHeight = EditorGUILayout.FloatField("Min Height", _minHeight);
        _maxHeight = EditorGUILayout.FloatField("Max Height", _maxHeight);

        EditorGUILayout.Space(8);
        EditorGUILayout.LabelField("Scale Variation", EditorStyles.boldLabel);
        _minScale = EditorGUILayout.Slider("Min", _minScale, 0.1f, 1f);
        _maxScale = EditorGUILayout.Slider("Max", _maxScale, 1f,   3f);

        EditorGUILayout.Space(8);
        _minSpacing  = EditorGUILayout.Slider("Min Spacing (m)", _minSpacing, 0.5f, 30f);
        _parentName  = EditorGUILayout.TextField("Parent Object Name", _parentName);
        _clearPrevious = EditorGUILayout.Toggle("Clear Previous First", _clearPrevious);

        EditorGUILayout.Space(12);

        GUI.enabled = _terrain != null;
        if (GUILayout.Button("Place Decorations", GUILayout.Height(44)))
            PlaceDecorations();
        GUI.enabled = true;

        if (GUILayout.Button("Clear Decorations"))
            ClearDecorations();

        EditorGUILayout.EndScrollView();
    }

    // ── Placement logic ──────────────────────────────────────────────────────
    private void PlaceDecorations()
    {
        if (_terrain == null) return;
        if (_clearPrevious) ClearDecorations();

        var rocks  = LoadPrefabs(RockPaths);
        var plants = LoadPrefabs(PlantPaths);
        var trees  = LoadPrefabs(TreePaths);

        if (rocks.Count + plants.Count + trees.Count == 0)
        {
            Debug.LogWarning("[TerrainDecorator] No prefabs found. Check that BK/PureNature_Islands is imported.");
            return;
        }

        // Create / reuse parent GO
        GameObject parent = GameObject.Find(_parentName);
        if (parent == null)
        {
            parent = new GameObject(_parentName);
            Undo.RegisterCreatedObjectUndo(parent, "Terrain Decorations Parent");
        }

        TerrainData td          = _terrain.terrainData;
        Vector3     terrainPos  = _terrain.transform.position;
        float       tw          = td.size.x;
        float       td_depth    = td.size.z;
        int         hRes        = td.heightmapResolution - 1;

        // Generate candidate positions
        List<Vector2> points = PoissonDisk(terrainPos, tw, td_depth, _minSpacing);
        Shuffle(points);

        int rPlaced = 0, pPlaced = 0, tPlaced = 0;

        foreach (Vector2 pt in points)
        {
            float nx = (pt.x - terrainPos.x) / tw;
            float nz = (pt.y - terrainPos.z) / td_depth;
            if (nx < 0f || nx > 1f || nz < 0f || nz > 1f) continue;

            int hx = Mathf.RoundToInt(nx * hRes);
            int hz = Mathf.RoundToInt(nz * hRes);
            float worldY = terrainPos.y + td.GetHeight(hx, hz);

            if (worldY < _minHeight || worldY > _maxHeight) continue;

            Vector3 normal = td.GetInterpolatedNormal(nx, nz);
            float   slope  = Vector3.Angle(Vector3.up, normal);   // 0=flat, 90=vertical

            Vector3 worldPos = new Vector3(pt.x, worldY, pt.y);

            // Priority: rocks on slopes, trees on flat, plants otherwise
            if (rPlaced < _rockCount && slope >= _minSlopeRocks && rocks.Count > 0)
            {
                SpawnObject(rocks[Random.Range(0, rocks.Count)], worldPos, normal, parent, alignToSlope: true);
                rPlaced++;
            }
            else if (tPlaced < _treeCount && slope <= _maxSlopeTrees && trees.Count > 0)
            {
                SpawnObject(trees[Random.Range(0, trees.Count)], worldPos, normal, parent, alignToSlope: false);
                tPlaced++;
            }
            else if (pPlaced < _plantCount && slope <= _maxSlopePlants && plants.Count > 0)
            {
                SpawnObject(plants[Random.Range(0, plants.Count)], worldPos, normal, parent, alignToSlope: false);
                pPlaced++;
            }

            if (rPlaced >= _rockCount && pPlaced >= _plantCount && tPlaced >= _treeCount)
                break;
        }

        Debug.Log($"[TerrainDecorator] Placed {rPlaced} rocks, {pPlaced} plants, {tPlaced} trees  " +
                  $"(of {_rockCount}/{_plantCount}/{_treeCount} requested).");

        EditorUtility.SetDirty(parent);
    }

    private void SpawnObject(GameObject prefab, Vector3 pos, Vector3 normal, GameObject parent, bool alignToSlope)
    {
        GameObject go = (GameObject)PrefabUtility.InstantiatePrefab(prefab, parent.transform);
        Undo.RegisterCreatedObjectUndo(go, "Place " + prefab.name);

        go.transform.position = pos;

        float yRot = Random.Range(0f, 360f);

        if (alignToSlope)
        {
            // Tilt rock to follow terrain slope, add random variance
            Quaternion slopeRot = Quaternion.FromToRotation(Vector3.up, normal);
            Quaternion variance = Quaternion.Euler(Random.Range(-10f, 10f), yRot, Random.Range(-10f, 10f));
            go.transform.rotation = slopeRot * variance;
        }
        else
        {
            // Trees / plants stay upright, random Y rotation only
            go.transform.rotation = Quaternion.Euler(0f, yRot, 0f);
        }

        float s = Random.Range(_minScale, _maxScale);
        go.transform.localScale = Vector3.one * s;
    }

    private void ClearDecorations()
    {
        GameObject parent = GameObject.Find(_parentName);
        if (parent != null)
            Undo.DestroyObjectImmediate(parent);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private static List<GameObject> LoadPrefabs(string[] paths)
    {
        var list = new List<GameObject>();
        foreach (string path in paths)
        {
            var go = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (go != null) list.Add(go);
            else Debug.LogWarning($"[TerrainDecorator] Prefab not found: {path}");
        }
        return list;
    }

    /// <summary>
    /// Poisson disk sampling over the terrain footprint.
    /// Returns world-space XZ positions as Vector2(x, z).
    /// </summary>
    private static List<Vector2> PoissonDisk(Vector3 origin, float width, float depth, float radius)
    {
        float    cellSize = radius / Mathf.Sqrt(2f);
        int      cols     = Mathf.CeilToInt(width / cellSize);
        int      rows     = Mathf.CeilToInt(depth / cellSize);
        int[,]   grid     = new int[cols, rows];   // 0 = empty, else index+1 into result

        var result = new List<Vector2>();
        var active = new List<Vector2>();

        // Seed in the centre
        var seed = new Vector2(origin.x + width * 0.5f, origin.z + depth * 0.5f);
        result.Add(seed);
        active.Add(seed);
        grid[cols / 2, rows / 2] = 1;

        while (active.Count > 0)
        {
            int    ai      = Random.Range(0, active.Count);
            bool   placed  = false;

            for (int attempt = 0; attempt < 25; attempt++)
            {
                float   angle     = Random.value * Mathf.PI * 2f;
                float   dist      = Random.Range(radius, radius * 2f);
                Vector2 candidate = active[ai] + new Vector2(Mathf.Cos(angle) * dist, Mathf.Sin(angle) * dist);

                float lx = candidate.x - origin.x;
                float lz = candidate.y - origin.z;
                if (lx < 0f || lx >= width || lz < 0f || lz >= depth) continue;

                int gx = Mathf.FloorToInt(lx / cellSize);
                int gz = Mathf.FloorToInt(lz / cellSize);

                bool ok = true;
                for (int dx = -2; dx <= 2 && ok; dx++)
                for (int dz = -2; dz <= 2 && ok; dz++)
                {
                    int nx = gx + dx, nz2 = gz + dz;
                    if (nx < 0 || nx >= cols || nz2 < 0 || nz2 >= rows) continue;
                    int idx = grid[nx, nz2];
                    if (idx == 0) continue;
                    if (Vector2.SqrMagnitude(candidate - result[idx - 1]) < radius * radius)
                        ok = false;
                }

                if (ok)
                {
                    result.Add(candidate);
                    active.Add(candidate);
                    grid[gx, gz] = result.Count;
                    placed = true;
                    break;
                }
            }

            if (!placed) active.RemoveAt(ai);
        }

        return result;
    }

    private static void Shuffle<T>(List<T> list)
    {
        for (int i = list.Count - 1; i > 0; i--)
        {
            int j = Random.Range(0, i + 1);
            (list[i], list[j]) = (list[j], list[i]);
        }
    }
}
