using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using UnityEngine.Rendering.PostProcessing;

// Portable replacement for AQUAS_UnderWaterEffect (which relies on Unity image-effect
// callbacks not available to Udon). Approximates the underwater look using
// RenderSettings.fog, which every camera (including VRChat's) respects natively.
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class AquasUnderwaterTrigger : UdonSharpBehaviour
{
    [Header("Fog & Appearance")]
    [SerializeField] private Color  underwaterFogColor        = new Color(0.223f, 0.377f, 0.519f, 1f);
    [Tooltip("Fog/skybox tint at Max Fog Depth. Black = pure abyssal darkness.")]
    [SerializeField] private Color  underwaterFogColorDeep    = Color.black;
    [SerializeField] private float  underwaterFogDensityShallow = 0.045f;
    [SerializeField] private float  underwaterFogDensityDeep    = 0.14f;
    [SerializeField] private float  maxFogDepth               = 10f;
    [SerializeField] private Transform waterSurface;
    [Tooltip("Dark skybox swapped in while submerged so distant sightlines don't punch through to the starfield.")]
    [SerializeField] private Material underwaterSkybox;

    [Header("Depth Darkening")]
    [Tooltip("Ambient intensity at the surface (depth = 0).")]
    [SerializeField] private float ambientIntensityShallow = 1f;
    [Tooltip("Ambient intensity at Max Fog Depth — dims the scene toward black as you descend.")]
    [SerializeField] private float ambientIntensityDeep    = 0.15f;
    [Tooltip("PostProcessVolume (chromatic aberration + vignette) faded in with depth. Author the profile at full strength; only Weight is touched at runtime.")]
    [SerializeField] private PostProcessVolume deepPressureVolume;
    [Tooltip("Maximum Weight for the deep-pressure volume (0–1). Keep low (0.25–0.4) if the profile has aggressive darkening.")]
    [SerializeField] private float deepPressureMaxWeight = 0.3f;

    [Header("Audio")]
    [SerializeField] private AudioSource oneShotSource;
    [SerializeField] private AudioClip   diveSplashClip;
    [SerializeField] private AudioClip   surfaceSplashClip;
    [SerializeField] private AudioSource underwaterAmbience;

    [Header("Visuals")]
    [SerializeField] private ParticleSystem bubbleBurst;
    [SerializeField] private ParticleSystem splashSpray;

    [Header("Locomotion (Underwater)")]
    [Tooltip("VRChat default gravity is 1. Low values like 0.1–0.2 feel like drifting rather than plummeting.")]
    [SerializeField] private float underwaterGravityStrength = 0.15f;
    [SerializeField] private float underwaterWalkSpeed       = 2.5f;
    [SerializeField] private float underwaterRunSpeed        = 3.5f;
    [SerializeField] private float underwaterStrafeSpeed     = 2.5f;
    [Tooltip("Jump acts as a swim-up kick while submerged.")]
    [SerializeField] private float underwaterJumpImpulse     = 1.5f;

    [Header("Locomotion (Surface Defaults)")]
    [SerializeField] private float defaultGravityStrength = 1f;
    [SerializeField] private float defaultWalkSpeed       = 2f;
    [SerializeField] private float defaultRunSpeed        = 4f;
    [SerializeField] private float defaultStrafeSpeed     = 2f;
    [SerializeField] private float defaultJumpImpulse     = 3f;

    [Header("Zone Manager")]
    [Tooltip("Shared occupancy manager. Prevents overlapping zones (Harbor/OpenOcean/DeepSea) from fighting over RenderSettings and ensures only the most recently entered zone drives the effect.")]
    [SerializeField] private UnderwaterZoneManager zoneManager;

    private bool isUnderwater;
    // When true (elevator ride), physical OnPlayerTriggerExit is ignored.
    private bool forceActive;

    // -------------------------------------------------------------------------

    private void Update()
    {
        if (!isUnderwater) return;
        // Only the most recently entered zone writes RenderSettings each frame.
        if (zoneManager != null && !zoneManager.IsActiveZone(this)) return;

        VRCPlayerApi local = Networking.LocalPlayer;
        if (local == null) return;

        float surfaceY = waterSurface != null ? waterSurface.position.y : 0f;
        float depth    = surfaceY - local.GetPosition().y;
        float t        = Mathf.Clamp01(depth / maxFogDepth);

        RenderSettings.fogDensity     = Mathf.Lerp(underwaterFogDensityShallow, underwaterFogDensityDeep, t);
        RenderSettings.ambientIntensity = Mathf.Lerp(ambientIntensityShallow, ambientIntensityDeep, t);

        Color fogColor = Color.Lerp(underwaterFogColor, underwaterFogColorDeep, t);
        RenderSettings.fogColor = fogColor;
        if (underwaterSkybox != null) underwaterSkybox.SetColor("_SkyTint", fogColor);

        if (deepPressureVolume != null) deepPressureVolume.weight = t * deepPressureMaxWeight;
    }

    // Elevator passengers don't fire VRC trigger callbacks (stations disable the rider's
    // collider), so the vehicle calls these directly instead.
    public void ForceEnter()
    {
        VRCPlayerApi local = Networking.LocalPlayer;
        if (local == null) return;
        forceActive = true;
        OnPlayerTriggerEnter(local);
    }

    public void ForceExit()
    {
        VRCPlayerApi local = Networking.LocalPlayer;
        if (local == null) return;
        forceActive = false;
        OnPlayerTriggerExit(local);
    }

    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if (player == null || !player.isLocal) return;
        if (isUnderwater) return;
        isUnderwater = true;

        // isFirstEntry is false when crossing between overlapping zones mid-dive —
        // in that case skip splash/ambience but still apply this zone's settings.
        bool isFirstEntry = zoneManager != null ? zoneManager.EnterZone(this) : true;

        RenderSettings.fogColor   = underwaterFogColor;
        RenderSettings.fogDensity = underwaterFogDensityShallow;

        player.SetGravityStrength(underwaterGravityStrength);
        player.SetWalkSpeed(underwaterWalkSpeed);
        player.SetRunSpeed(underwaterRunSpeed);
        player.SetStrafeSpeed(underwaterStrafeSpeed);
        player.SetJumpImpulse(underwaterJumpImpulse);

        if (underwaterSkybox != null)
        {
            if (zoneManager != null) zoneManager.CacheSkyboxIfNeeded();
            RenderSettings.skybox = underwaterSkybox;
        }

        if (!isFirstEntry) return;

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
        if (splashSpray != null)
        {
            float surfaceY = waterSurface != null ? waterSurface.position.y : playerPos.y;
            splashSpray.transform.position = new Vector3(playerPos.x, surfaceY, playerPos.z);
            splashSpray.Play();
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
        // Elevator owns the effect during a forced ride; ignore physical exits.
        if (forceActive) return;
        isUnderwater = false;

        // isLastExit is false when leaving one overlapping zone while still inside another —
        // in that case skip surfacing cues and locomotion restore.
        bool isLastExit = zoneManager != null ? zoneManager.ExitZone(this) : true;
        if (!isLastExit) return;

        player.SetGravityStrength(defaultGravityStrength);
        player.SetWalkSpeed(defaultWalkSpeed);
        player.SetRunSpeed(defaultRunSpeed);
        player.SetStrafeSpeed(defaultStrafeSpeed);
        player.SetJumpImpulse(defaultJumpImpulse);

        Vector3 exitPos = player.GetPosition();
        if (oneShotSource != null)
        {
            oneShotSource.transform.position = exitPos;
            if (surfaceSplashClip != null) oneShotSource.PlayOneShot(surfaceSplashClip);
        }
        if (splashSpray != null)
        {
            float surfaceY = waterSurface != null ? waterSurface.position.y : exitPos.y;
            splashSpray.transform.position = new Vector3(exitPos.x, surfaceY, exitPos.z);
            splashSpray.Play();
        }
        if (underwaterAmbience != null) underwaterAmbience.Stop();
    }
}
