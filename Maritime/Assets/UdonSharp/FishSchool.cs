
using UdonSharp;
using UnityEngine;

// Lightweight fish-schooling controller. One instance drives every fish in
// "fish" - no per-fish scripts. Uses velocity + inertia (not instant direction
// snapping) so fish glide instead of twitching, plus a simple O(n^2) separation
// pass (cheap at typical school sizes of 10-30) so bodies don't overlap.
// Drop the FishSchool prefab into a scene, resize the "schoolRadius" gizmo cube
// to the space you want it to roam in - fish are picked up automatically from
// this object's children.
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class FishSchool : UdonSharpBehaviour
{
    [Header("Setup (auto-fills from children if left empty)")]
    [SerializeField] private Transform[] fish;

    [Header("Roaming volume")]
    [SerializeField] private float schoolRadius = 5f;
    [SerializeField] private float verticalRatio = 0.5f; // roam volume is flattened vertically by this much

    [Header("Movement feel")]
    [SerializeField] private float swimSpeed = 1.0f;
    [SerializeField] private float speedVariance = 0.3f;
    [SerializeField] private float turnSpeed = 1.6f;
    [SerializeField] private float acceleration = 1.5f;
    [SerializeField] private float centerWanderSpeed = 0.08f;
    [SerializeField] private float individualWanderSpeed = 0.15f;
    [SerializeField] private float individualSpread = 1.8f;

    [Header("Separation (avoid overlapping bodies)")]
    [SerializeField] private float personalSpace = 0.6f;
    [SerializeField] private float separationStrength = 2f;

    [Header("Formation")]
    [SerializeField] private float formationSpread = 2.5f;

    private Vector3 homeCenter;
    private Vector3[] velocity;
    private Vector3[] slotOffset;
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
        velocity = new Vector3[n];
        slotOffset = new Vector3[n];
        speedSeed = new float[n];
        phaseX = new float[n];
        phaseY = new float[n];
        phaseZ = new float[n];

        // Give every fish its own persistent slot in the formation, spread on a
        // spiral (golden-angle) so they fan out evenly instead of all chasing
        // the same point and clumping into a ball.
        float golden = 2.39996f;
        for (int i = 0; i < n; i++)
        {
            float frac = n > 1 ? (float)i / (float)(n - 1) : 0f;
            float radius = Mathf.Sqrt(frac) * formationSpread;
            float angle = i * golden;
            slotOffset[i] = new Vector3(
                Mathf.Cos(angle) * radius,
                (frac - 0.5f) * formationSpread * verticalRatio,
                Mathf.Sin(angle) * radius);

            speedSeed[i] = Random.Range(-1f, 1f);
            phaseX[i] = Random.Range(0f, 100f);
            phaseY[i] = Random.Range(0f, 100f);
            phaseZ[i] = Random.Range(0f, 100f);
            velocity[i] = fish[i] != null ? fish[i].forward * 0.1f : Vector3.forward * 0.1f;
        }
    }

    private void Update()
    {
        if (fish == null || fish.Length == 0) return;

        float t = Time.time;
        float dt = Time.deltaTime;

        // The whole school drifts slowly around its home point using smooth noise
        // so it wanders instead of just circling.
        float cx = (Mathf.PerlinNoise(t * centerWanderSpeed, 0f) - 0.5f) * 2f;
        float cy = (Mathf.PerlinNoise(0f, t * centerWanderSpeed) - 0.5f) * 2f;
        float cz = (Mathf.PerlinNoise(t * centerWanderSpeed, t * centerWanderSpeed) - 0.5f) * 2f;
        Vector3 schoolCenter = homeCenter + new Vector3(
            cx * schoolRadius * 0.6f,
            cy * schoolRadius * 0.6f * verticalRatio,
            cz * schoolRadius * 0.6f);

        int n = fish.Length;
        for (int i = 0; i < n; i++)
        {
            Transform f = fish[i];
            if (f == null) continue;

            float ox = (Mathf.PerlinNoise(phaseX[i], t * individualWanderSpeed) - 0.5f) * 2f;
            float oy = (Mathf.PerlinNoise(phaseY[i], t * individualWanderSpeed) - 0.5f) * 2f;
            float oz = (Mathf.PerlinNoise(phaseZ[i], t * individualWanderSpeed) - 0.5f) * 2f;
            Vector3 target = schoolCenter + slotOffset[i] + new Vector3(
                ox * individualSpread,
                oy * individualSpread * verticalRatio,
                oz * individualSpread);

            Vector3 seek = (target - f.position).normalized;

            // Push apart from nearby schoolmates so bodies never overlap/clip.
            Vector3 separation = Vector3.zero;
            for (int j = 0; j < n; j++)
            {
                if (j == i) continue;
                Transform other = fish[j];
                if (other == null) continue;
                Vector3 away = f.position - other.position;
                float d = away.magnitude;
                if (d > 0.001f && d < personalSpace)
                {
                    separation += (away / d) * (1f - d / personalSpace);
                }
            }

            float speed = swimSpeed * (1f + speedSeed[i] * speedVariance);
            Vector3 desiredVelocity = (seek + separation * separationStrength).normalized * speed;

            velocity[i] = Vector3.Lerp(velocity[i], desiredVelocity, acceleration * dt);
            f.position += velocity[i] * dt;

            if (velocity[i].sqrMagnitude > 0.0004f)
            {
                Quaternion wantRot = Quaternion.LookRotation(velocity[i].normalized, Vector3.up);
                f.rotation = Quaternion.Slerp(f.rotation, wantRot, turnSpeed * dt);
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
