
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;

// Attached to the selection cube. Interacting with it directly starts the submersible
// elevator's descent without using a VRCStation (which would teleport/snap the player).
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class ElevatorSummonCube : UdonSharpBehaviour
{
    [SerializeField] private SubmersibleElevator elevator;

    private void Start()
    {
        InteractionText = "深海エレベーターに乗る";
    }

    public override void Interact()
    {
        if (elevator == null) return;
        VRCPlayerApi local = Networking.LocalPlayer;
        if (Utilities.IsValid(local)) elevator.StartDescent();
    }
}
