
using UnityEngine;

namespace ConstellationObservation
{
    /// <summary>
    /// Data asset listing the constellations to present, in order.
    /// Kept as plain parallel arrays (rather than a wrapper class per entry) so that
    /// UdonSharp can read the fields directly at runtime.
    /// </summary>
    [CreateAssetMenu(fileName = "ConstellationLibrary", menuName = "Constellation Observation/Constellation Library")]
    public class ConstellationLibrary : ScriptableObject
    {
        [Tooltip("Display name for each constellation, in presentation order.")]
        public string[] constellationNames;

        [Tooltip("Root GameObject for each constellation's stars/lines, same order as Constellation Names.")]
        public GameObject[] targets;

        [Tooltip("Narration clip for each constellation, same order as Constellation Names. Leave empty to use the controller's fallback duration.")]
        public AudioClip[] narrationClips;

        [Header("Subtitles (auto-timed to narration clip pauses)")]
        [Tooltip("All subtitle clauses across every constellation, flattened in order (Constellation 0's clauses, then Constellation 1's, ...). Split/timed by analyzing silence gaps in each narration clip so lines change in sync with the voice.")]
        [TextArea(2, 4)]
        public string[] subtitleLines;

        [Tooltip("Start time (seconds from that constellation's narration clip start) for each entry in Subtitle Lines, same order/length.")]
        public float[] subtitleStartTimes;

        [Tooltip("How many consecutive entries in Subtitle Lines / Subtitle Start Times belong to each constellation, same order/length as Constellation Names.")]
        public int[] subtitleCounts;
    }
}
