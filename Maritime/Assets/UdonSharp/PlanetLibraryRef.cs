
using UnityEngine;

namespace ConstellationObservation
{
    /// <summary>
    /// Plain (non-UdonSharp) MonoBehaviour that just holds a reference to a PlanetLibrary
    /// asset for editor authoring convenience. See ConstellationLibraryRef for why this can't
    /// live directly on the UdonSharpBehaviour.
    /// </summary>
    public class PlanetLibraryRef : MonoBehaviour
    {
        public PlanetLibrary library;
    }
}
