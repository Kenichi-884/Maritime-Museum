
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRCStation = VRC.SDK3.Components.VRCStation;

// Attached to the single remaining selection cube. Interacting with it seats the local
// player directly into the deep-sea submersible elevator's station, which then begins its
// scripted descent (see SubmersibleElevator.OnStationEntered) without requiring the player
// to walk over and sit down themselves.
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class ElevatorSummonCube : UdonSharpBehaviour
{
    [SerializeField] private VRCStation elevatorStation;

    private void Start()
    {
        InteractionText = "深海エレベーターに乗る";
    }

    public override void Interact()
    {
        if (elevatorStation == null) return;
        VRCPlayerApi local = Networking.LocalPlayer;
        if (Utilities.IsValid(local)) elevatorStation.UseStation(local);
    }
}
