using UdonSharp;
using UnityEngine;

// Shared manager for the overlapping AquasUnderwaterTrigger volumes
// (Harbor → OpenOcean → DeepSea). Responsibilities:
//   1. Reference-count zone occupancy so global RenderSettings are only
//      restored once every zone has been exited (not when stepping between
//      overlapping zones mid-dive).
//   2. Track the most recently entered zone so only that zone's Update()
//      writes RenderSettings each frame, preventing inter-zone fighting.
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class UnderwaterZoneManager : UdonSharpBehaviour
{
    private int occupantCount;
    private AquasUnderwaterTrigger activeZone;

    private bool    cachedOriginal;
    private bool    originalFogEnabled;
    private Color   originalFogColor;
    private FogMode originalFogMode;
    private float   originalFogDensity;

    private bool     cachedSkybox;
    private Material originalSkybox;

    private bool  cachedAmbient;
    private float originalAmbientIntensity;

    // Returns true if zone is the current RenderSettings driver.
    public bool IsActiveZone(AquasUnderwaterTrigger zone)
    {
        return activeZone == zone;
    }

    // Call on trigger enter. Returns true only on the very first zone entry
    // (surface → underwater), so callers can gate one-shot splash/ambience.
    public bool EnterZone(AquasUnderwaterTrigger zone)
    {
        activeZone = zone;
        occupantCount++;
        bool isFirstEntry = occupantCount == 1;
        if (!isFirstEntry) return false;

        if (!cachedOriginal)
        {
            originalFogEnabled = RenderSettings.fog;
            originalFogColor   = RenderSettings.fogColor;
            originalFogMode    = RenderSettings.fogMode;
            originalFogDensity = RenderSettings.fogDensity;
            cachedOriginal = true;
        }
        RenderSettings.fog     = true;
        RenderSettings.fogMode = FogMode.Exponential;

        if (!cachedAmbient)
        {
            originalAmbientIntensity = RenderSettings.ambientIntensity;
            cachedAmbient = true;
        }
        return true;
    }

    // Call on trigger exit. Returns true only when the last zone is exited
    // (underwater → surface), so callers can gate surfacing cues.
    public bool ExitZone(AquasUnderwaterTrigger zone)
    {
        if (activeZone == zone) activeZone = null;
        occupantCount = occupantCount > 0 ? occupantCount - 1 : 0;
        bool isLastExit = occupantCount == 0 && cachedOriginal;
        if (!isLastExit) return false;

        RenderSettings.fog              = originalFogEnabled;
        RenderSettings.fogMode          = originalFogMode;
        RenderSettings.fogColor         = originalFogColor;
        RenderSettings.fogDensity       = originalFogDensity;
        if (cachedSkybox)  RenderSettings.skybox          = originalSkybox;
        if (cachedAmbient) RenderSettings.ambientIntensity = originalAmbientIntensity;
        return true;
    }

    public void CacheSkyboxIfNeeded()
    {
        if (cachedSkybox) return;
        originalSkybox = RenderSettings.skybox;
        cachedSkybox = true;
    }
}
