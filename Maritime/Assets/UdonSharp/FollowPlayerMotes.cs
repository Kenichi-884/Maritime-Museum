
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;

// Keeps a small drifting-mote particle system anchored just in front of the local
// player's view at all times, so there's always some near-field parallax cluttering the
// foreground (real murky water always has particulate matter close to your face, not just
// far-off haze). Only emits while RenderSettings.fog is on, which AquasUnderwaterTrigger
// toggles - a decent proxy for "currently submerged" without needing direct coupling.
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class FollowPlayerMotes : UdonSharpBehaviour
{
    [SerializeField] private ParticleSystem motes;
    [SerializeField] private Vector3 localOffset = new Vector3(0f, -0.2f, 0.6f);
    [SerializeField] private float followLerp = 6f;

    private bool emissionOn;

    private void Start()
    {
        if (motes != null)
        {
            var em = motes.emission;
            em.enabled = false;
            emissionOn = false;
        }
    }

    private void Update()
    {
        VRCPlayerApi local = Networking.LocalPlayer;
        if (local == null) return;

        VRCPlayerApi.TrackingData head = local.GetTrackingData(VRCPlayerApi.TrackingDataType.Head);
        Vector3 targetPos = head.position + head.rotation * localOffset;
        transform.position = Vector3.Lerp(transform.position, targetPos, Time.deltaTime * followLerp);

        bool shouldEmit = RenderSettings.fog;
        if (shouldEmit != emissionOn && motes != null)
        {
            var em = motes.emission;
            em.enabled = shouldEmit;
            emissionOn = shouldEmit;
        }
    }
}
