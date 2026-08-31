
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
    [SerializeField] private Color underwaterFogColor = new Color(0.223f, 0.377f, 0.519f, 1f);
    [Tooltip("Fog/skybox color at Max Fog Depth. Left black by default (pure abyssal black); set per-zone if a tinted deep color reads better.")]
    [SerializeField] private Color underwaterFogColorDeep = Color.black;
    [SerializeField] private float underwaterFogDensityShallow = 0.045f;
    [SerializeField] private float underwaterFogDensityDeep = 0.14f;
    [SerializeField] private float maxFogDepth = 10f;
    [SerializeField] private Transform waterSurface;

    [Tooltip("Shared occupancy manager. Required so overlapping water volumes (Harbor/OpenOcean/DeepSea, which deliberately overlap along the elevator's dive path) don't fight over global RenderSettings - leaving one zone while still inside another must not restore the pre-underwater state.")]
    [SerializeField] private UnderwaterZoneManager zoneManager;

    [Header("Audio (from AQUAS 2020/Audio/Resources)")]
    [SerializeField] private AudioSource oneShotSource;
    [SerializeField] private AudioClip diveSplashClip;
    [SerializeField] private AudioClip surfaceSplashClip;
    [SerializeField] private AudioSource underwaterAmbience;

    [Header("Visuals")]
    [SerializeField] private ParticleSystem bubbleBurst;
    [SerializeField] private ParticleSystem splashSpray;

    private bool isUnderwater;

    [Tooltip("Flat dark skybox material swapped in while submerged. Skyboxes never receive fog, so any sightline that never hits geometry (looking out past the terrain/water mesh edges) would otherwise punch straight through to the raw starfield, breaking the underwater illusion at range.")]
    [SerializeField] private Material underwaterSkybox;

    [Header("Depth Darkening")]
    [Tooltip("Ambient light intensity multiplier at the surface (depth = 0).")]
    [SerializeField] private float ambientIntensityShallow = 1f;
    [Tooltip("Ambient light intensity multiplier at Max Fog Depth - dims the whole scene toward black so deeper water actually reads as darker, not just foggier.")]
    [SerializeField] private float ambientIntensityDeep = 0.15f;

    [Tooltip("A dedicated 'deep pressure warp' PostProcessVolume (chromatic aberration + vignette) whose Weight is dialed up with depth, for a subtle refraction feel the deeper you go. Weight is the only PostProcessVolume field Udon can touch - the profile's own effect settings aren't exposed - so the profile itself should be authored with the desired full-strength look and just faded in/out here.")]
    [SerializeField] private PostProcessVolume deepPressureVolume;

    [Header("Buoyancy (swim vs. free-fall)")]
    [Tooltip("Player gravity while submerged. VRChat default is 1; a low value like 0.1-0.2 reads as sinking/drifting instead of plummeting.")]
    [SerializeField] private float underwaterGravityStrength = 0.15f;
    [SerializeField] private float underwaterWalkSpeed = 2.5f;
    [SerializeField] private float underwaterRunSpeed = 3.5f;
    [SerializeField] private float underwaterStrafeSpeed = 2.5f;
    [Tooltip("Jump acts as a swim-up kick while submerged - kept gentle since gravity is already weak.")]
    [SerializeField] private float underwaterJumpImpulse = 1.5f;

    [Tooltip("Player locomotion values restored on surfacing. These should match this world's normal (non-underwater) VRCPlayerApi settings.")]
    [SerializeField] private float defaultGravityStrength = 1f;
    [SerializeField] private float defaultWalkSpeed = 2f;
    [SerializeField] private float defaultRunSpeed = 4f;
    [SerializeField] private float defaultStrafeSpeed = 2f;
    [SerializeField] private float defaultJumpImpulse = 3f;

    private void Update()
    {
        if (!isUnderwater) return;
        VRCPlayerApi local = Networking.LocalPlayer;
        if (local == null) return;
        float surfaceY = waterSurface != null ? waterSurface.position.y : 0f;
        float depth = surfaceY - local.GetPosition().y;
        float t = Mathf.Clamp01(depth / maxFogDepth);
        RenderSettings.fogDensity = Mathf.Lerp(underwaterFogDensityShallow, underwaterFogDensityDeep, t);

        Color fogColorNow = Color.Lerp(underwaterFogColor, underwaterFogColorDeep, t);
        RenderSettings.fogColor = fogColorNow;
        if (underwaterSkybox != null) underwaterSkybox.SetColor("_SkyTint", fogColorNow);

        RenderSettings.ambientIntensity = Mathf.Lerp(ambientIntensityShallow, ambientIntensityDeep, t);

        if (deepPressureVolume != null) deepPressureVolume.weight = t;
    }

    // Seated passengers (e.g. the deep-sea elevator) don't fire VRC player-trigger callbacks -
    // stations disable the rider's own collider - so a vehicle carrying the player through the
    // water needs to drive this effect directly instead of relying on trigger collision.
    public void ForceEnter()
    {
        VRCPlayerApi local = Networking.LocalPlayer;
        if (local == null) return;
        OnPlayerTriggerEnter(local);
    }

    public void ForceExit()
    {
        VRCPlayerApi local = Networking.LocalPlayer;
        if (local == null) return;
        OnPlayerTriggerExit(local);
    }

    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if (player == null || !player.isLocal) return;
        if (isUnderwater) return;
        isUnderwater = true;
        // Only the real surface-to-water transition should play dive cues - stepping from one
        // overlapping underwater zone into another (mid-dive) must stay silent/effect-only.
        bool isFirstEntry = zoneManager != null ? zoneManager.EnterZone() : true;
        RenderSettings.fogColor = underwaterFogColor;
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
            // Spray erupts at the surface line, not at the player's submerged depth.
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
        isUnderwater = false;
        // Only the real water-to-surface transition should play surfacing cues - leaving one
        // overlapping underwater zone while still inside another must stay silent/effect-only.
        bool isLastExit = zoneManager != null ? zoneManager.ExitZone() : true;
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
