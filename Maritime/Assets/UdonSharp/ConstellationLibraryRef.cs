
using UnityEngine;

namespace ConstellationObservation
{
    /// <summary>
    /// Plain (non-UdonSharp) MonoBehaviour that just holds a reference to a ConstellationLibrary
    /// asset for editor authoring convenience. UdonSharpBehaviour fields cannot hold a reference
    /// to a plain ScriptableObject type at all (Udon's variable serializer rejects it), so this
    /// reference is kept outside the Udon-compiled component. Use the "Sync From Library" button
    /// on ConstellationTourController's inspector to copy this data into the arrays Udon actually
    /// reads at runtime.
    /// </summary>
    public class ConstellationLibraryRef : MonoBehaviour
    {
        public ConstellationLibrary library;
    }
}
