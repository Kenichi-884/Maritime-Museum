
using UdonSharp;
using UnityEngine;

// Portable replacement for AQUAS_Caustics (a plain MonoBehaviour, not usable in VRChat).
// Cycles the Projector's caustics texture frames and keeps _WaterLevel/_DepthFade
// aligned to the water plane's transform, same as the original script did.
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class AquasCausticsAnimator : UdonSharpBehaviour
{
    [SerializeField] private Texture2D[] frames;
    [SerializeField] private float fps = 15f;
    [SerializeField] private Transform waterTransform;
    [SerializeField] private float maxCausticDepth = 10f;
    [SerializeField] private Material projectorMaterial;

    private int frameIndex;
    private float timer;

    private void Start()
    {
        ApplyFrame();
        ApplyWaterLevel();
    }

    private void Update()
    {
        if (frames == null || frames.Length == 0) return;
        timer += Time.deltaTime;
        float interval = fps > 0f ? 1f / fps : 1f;
        if (timer < interval) return;
        timer -= interval;
        frameIndex = (frameIndex + 1) % frames.Length;
        ApplyFrame();
        ApplyWaterLevel();
    }

    private void ApplyFrame()
    {
        if (projectorMaterial == null || frames == null || frames.Length == 0) return;
        projectorMaterial.SetTexture("_Texture", frames[frameIndex]);
    }

    private void ApplyWaterLevel()
    {
        if (projectorMaterial == null || waterTransform == null) return;
        float level = waterTransform.position.y;
        projectorMaterial.SetFloat("_WaterLevel", level);
        projectorMaterial.SetFloat("_DepthFade", level - maxCausticDepth);
    }
}
