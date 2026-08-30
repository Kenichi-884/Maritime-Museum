
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;

// Lightweight single-body reaction for individually placed creatures (not part of a
// FishSchool): drifts away when the local player gets close, then eases back toward its
// resting spot once left alone. Cheaper than a full schooling controller since there's
// only ever one body to simulate.
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class FleeFromPlayer : UdonSharpBehaviour
{
    [SerializeField] private float fleeRadius = 5f;
    [SerializeField] private float fleeSpeed = 3f;
    [SerializeField] private float returnSpeed = 0.4f;
    [SerializeField] private float turnSpeed = 2f;
    [Tooltip("How far from the home spot this creature is allowed to flee before it stops running (keeps it from swimming clean out of its zone).")]
    [SerializeField] private float maxWanderDistance = 12f;

    private Vector3 homePosition;
    private Vector3 velocity;

    private void Start()
    {
        homePosition = transform.position;
    }

    private void Update()
    {
        VRCPlayerApi local = Networking.LocalPlayer;
        Vector3 desired = Vector3.zero;
        float dt = Time.deltaTime;

        if (local != null)
        {
            Vector3 myPos = transform.position;
            Vector3 away = myPos - local.GetPosition();
            float dist = away.magnitude;

            if (dist < fleeRadius && dist > 0.001f)
            {
                float homeDist = Vector3.Distance(myPos, homePosition);
                float pull = Mathf.Clamp01(homeDist / maxWanderDistance);
                Vector3 fleeDir = away / dist;
                Vector3 homeDir = (homePosition - myPos).normalized;
                desired = Vector3.Lerp(fleeDir, homeDir, pull) * fleeSpeed;
            }
            else
            {
                Vector3 toHome = homePosition - myPos;
                if (toHome.magnitude > 0.2f) desired = toHome.normalized * returnSpeed;
            }
        }

        velocity = Vector3.Lerp(velocity, desired, dt * 2f);
        transform.position += velocity * dt;

        if (velocity.sqrMagnitude > 0.0004f)
        {
            Quaternion wantRot = Quaternion.LookRotation(velocity.normalized, Vector3.up);
            transform.rotation = Quaternion.Slerp(transform.rotation, wantRot, turnSpeed * dt);
        }
    }
}
