
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;

// Portable replacement for AQUAS_UnderWaterEffect (which relies on Unity image-effect
// callbacks not available to Udon). Approximates the underwater look using
// RenderSettings.fog, which every camera (including VRChat's) respects natively.
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class AquasUnderwaterTrigger : UdonSharpBehaviour
{
    [SerializeField] private Color underwaterFogColor = new Color(0.223f, 0.377f, 0.519f, 1f);
    [SerializeField] private float underwaterFogDensityShallow = 0.045f;
    [SerializeField] private float underwaterFogDensityDeep = 0.14f;
    [SerializeField] private float maxFogDepth = 10f;
    [SerializeField] private Transform waterSurface;

    [Header("Audio (from AQUAS 2020/Audio/Resources)")]
    [SerializeField] private AudioSource oneShotSource;
    [SerializeField] private AudioClip diveSplashClip;
    [SerializeField] private AudioClip surfaceSplashClip;
    [SerializeField] private AudioSource underwaterAmbience;

    [Header("Visuals")]
    [SerializeField] private ParticleSystem bubbleBurst;

    private bool isUnderwater;
    private bool cachedOriginal;
    private bool originalFogEnabled;
    private Color originalFogColor;
    private FogMode originalFogMode;
    private float originalFogDensity;

    private void CacheOriginalIfNeeded()
    {
        if (cachedOriginal) return;
        originalFogEnabled = RenderSettings.fog;
        originalFogColor = RenderSettings.fogColor;
        originalFogMode = RenderSettings.fogMode;
        originalFogDensity = RenderSettings.fogDensity;
        cachedOriginal = true;
    }

    private void Update()
    {
        if (!isUnderwater) return;
        VRCPlayerApi local = Networking.LocalPlayer;
        if (local == null) return;
        float surfaceY = waterSurface != null ? waterSurface.position.y : 0f;
        float depth = surfaceY - local.GetPosition().y;
        float t = Mathf.Clamp01(depth / maxFogDepth);
        RenderSettings.fogDensity = Mathf.Lerp(underwaterFogDensityShallow, underwaterFogDensityDeep, t);
    }

    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if (player == null || !player.isLocal) return;
        if (isUnderwater) return;
        isUnderwater = true;
        CacheOriginalIfNeeded();
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Exponential;
        RenderSettings.fogColor = underwaterFogColor;
        RenderSettings.fogDensity = underwaterFogDensityShallow;

        Vector3 playerPos = player.GetPosition();
        if (oneShotSource != null)
        {
            oneShotSource.transform.position = playerPos;
            if (diveSplashClip != null) oneShotSource.PlayOneShot(diveSplashClip);
        }
        if (bubbleBurst != null)
        {
            bubbleBurst.transform.position = playerPos;
            bubbleBurst.Play();
        }
        if (underwaterAmbience != null)
        {
            underwaterAmbience.loop = true;
            underwaterAmbience.Play();
        }
    }

    public override void OnPlayerTriggerExit(VRCPlayerApi player)
    {
        if (player == null || !player.isLocal) return;
        if (!isUnderwater) return;
        isUnderwater = false;
        if (!cachedOriginal) return;
        RenderSettings.fog = originalFogEnabled;
        RenderSettings.fogMode = originalFogMode;
        RenderSettings.fogColor = originalFogColor;
        RenderSettings.fogDensity = originalFogDensity;

        if (oneShotSource != null)
        {
            oneShotSource.transform.position = player.GetPosition();
            if (surfaceSplashClip != null) oneShotSource.PlayOneShot(surfaceSplashClip);
        }
        if (underwaterAmbience != null) underwaterAmbience.Stop();
    }
}
