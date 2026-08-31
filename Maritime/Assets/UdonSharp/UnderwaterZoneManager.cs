
using UdonSharp;
using UnityEngine;

// Shared occupancy counter for the AquasUnderwaterTrigger volumes. The dive path deliberately
// crosses several overlapping water-volume triggers (Harbor -> OpenOcean -> DeepSea) so there's
// never a gap in coverage. Without this manager each trigger cached/restored global RenderSettings
// (fog/skybox/ambient) independently, so leaving the outer zone while still inside an overlapping
// inner zone would force-restore the pre-underwater state and kill the effect mid-dive. Routing
// enter/exit through a reference count here means the global state is only restored once every
// zone has actually been exited.
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class UnderwaterZoneManager : UdonSharpBehaviour
{
    private int occupantCount;

    private bool cachedOriginal;
    private bool originalFogEnabled;
    private Color originalFogColor;
    private FogMode originalFogMode;
    private float originalFogDensity;

    private bool cachedSkybox;
    private Material originalSkybox;

    private bool cachedAmbient;
    private float originalAmbientIntensity;

    // Returns true only on the transition from "in no zone" to "in one zone" - callers use this
    // to gate one-shot dive splash/particle/ambience so overlapping zone boundaries crossed mid-dive
    // don't replay the "entering water" cues at depth.
    public bool EnterZone()
    {
        occupantCount++;
        bool isFirstEntry = occupantCount == 1;
        if (!isFirstEntry) return false;

        if (!cachedOriginal)
        {
            originalFogEnabled = RenderSettings.fog;
            originalFogColor = RenderSettings.fogColor;
            originalFogMode = RenderSettings.fogMode;
            originalFogDensity = RenderSettings.fogDensity;
            cachedOriginal = true;
        }
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Exponential;

        if (!cachedAmbient)
        {
            originalAmbientIntensity = RenderSettings.ambientIntensity;
            cachedAmbient = true;
        }
        return true;
    }

    // Returns true only on the transition from "in one zone" to "in no zone" - the real surfacing,
    // as opposed to stepping from one overlapping underwater volume into another.
    public bool ExitZone()
    {
        occupantCount = occupantCount > 0 ? occupantCount - 1 : 0;
        bool isLastExit = occupantCount == 0 && cachedOriginal;
        if (!isLastExit) return false;

        RenderSettings.fog = originalFogEnabled;
        RenderSettings.fogMode = originalFogMode;
        RenderSettings.fogColor = originalFogColor;
        RenderSettings.fogDensity = originalFogDensity;
        if (cachedSkybox) RenderSettings.skybox = originalSkybox;
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
