
using UdonSharp;
using UnityEngine;

// Lightweight fish-schooling controller. One instance drives every fish in
// "fish" - no per-fish scripts, no O(n^2) neighbor checks, so it stays cheap
// even with 20-30 fish. Drop the FishSchool prefab into a scene, resize the
// "schoolRadius" gizmo sphere to the space you want it to roam in, and it
// just works - fish are picked up automatically from this object's children.
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class FishSchool : UdonSharpBehaviour
{
    [Header("Setup (auto-fills from children if left empty)")]
    [SerializeField] private Transform[] fish;

    [Header("Roaming volume")]
    [SerializeField] private float schoolRadius = 5f;
    [SerializeField] private float verticalRatio = 0.5f; // roam volume is flattened vertically by this much

    [Header("Movement feel")]
    [SerializeField] private float swimSpeed = 1.2f;
    [SerializeField] private float speedVariance = 0.4f;
    [SerializeField] private float turnSpeed = 3f;
    [SerializeField] private float centerWanderSpeed = 0.15f;
    [SerializeField] private float individualWanderSpeed = 0.5f;
    [SerializeField] private float individualSpread = 1.5f;

    private Vector3 homeCenter;
    private float[] speedSeed;
    private float[] phaseX;
    private float[] phaseY;
    private float[] phaseZ;

    private void Start()
    {
        if (fish == null || fish.Length == 0)
        {
            int count = transform.childCount;
            fish = new Transform[count];
            for (int i = 0; i < count; i++) fish[i] = transform.GetChild(i);
        }

        homeCenter = transform.position;

        int n = fish.Length;
        speedSeed = new float[n];
        phaseX = new float[n];
        phaseY = new float[n];
        phaseZ = new float[n];
        for (int i = 0; i < n; i++)
        {
            speedSeed[i] = Random.Range(-1f, 1f);
            phaseX[i] = Random.Range(0f, 100f);
            phaseY[i] = Random.Range(0f, 100f);
            phaseZ[i] = Random.Range(0f, 100f);
        }
    }

    private void Update()
    {
        if (fish == null || fish.Length == 0) return;

        float t = Time.time;

        // The whole school drifts slowly around its home point using smooth noise
        // so it wanders instead of just circling.
        float cx = (Mathf.PerlinNoise(t * centerWanderSpeed, 0f) - 0.5f) * 2f;
        float cy = (Mathf.PerlinNoise(0f, t * centerWanderSpeed) - 0.5f) * 2f;
        float cz = (Mathf.PerlinNoise(t * centerWanderSpeed, t * centerWanderSpeed) - 0.5f) * 2f;
        Vector3 schoolCenter = homeCenter + new Vector3(
            cx * schoolRadius * 0.6f,
            cy * schoolRadius * 0.6f * verticalRatio,
            cz * schoolRadius * 0.6f);

        for (int i = 0; i < fish.Length; i++)
        {
            Transform f = fish[i];
            if (f == null) continue;

            float ox = (Mathf.PerlinNoise(phaseX[i], t * individualWanderSpeed) - 0.5f) * 2f;
            float oy = (Mathf.PerlinNoise(phaseY[i], t * individualWanderSpeed) - 0.5f) * 2f;
            float oz = (Mathf.PerlinNoise(phaseZ[i], t * individualWanderSpeed) - 0.5f) * 2f;
            Vector3 target = schoolCenter + new Vector3(
                ox * individualSpread,
                oy * individualSpread * verticalRatio,
                oz * individualSpread);

            Vector3 toTarget = target - f.position;
            float dist = toTarget.magnitude;
            if (dist > 0.01f)
            {
                Vector3 dir = toTarget / dist;
                float speed = swimSpeed * (1f + speedSeed[i] * speedVariance);
                f.position += dir * speed * Time.deltaTime;

                Quaternion wantRot = Quaternion.LookRotation(dir, Vector3.up);
                f.rotation = Quaternion.Slerp(f.rotation, wantRot, turnSpeed * Time.deltaTime);
            }
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(0.3f, 0.7f, 1f, 0.35f);
        Vector3 size = new Vector3(schoolRadius * 2f, schoolRadius * 2f * verticalRatio, schoolRadius * 2f);
        Gizmos.DrawWireCube(transform.position, size);
    }
}
