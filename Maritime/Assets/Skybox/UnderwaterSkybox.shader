// Simple solid-color skybox for the underwater state.
// AquasUnderwaterTrigger calls material.SetColor("_SkyTint", ...) every frame to drive
// the color with depth - this shader just outputs that tint as a uniform sky.
Shader "Maritime/UnderwaterSkybox"
{
    Properties
    {
        _SkyTint ("Sky Tint", Color) = (0.01, 0.04, 0.1, 1)
    }
    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _SkyTint;

            struct appdata { float4 vertex : POSITION; };
            struct v2f    { float4 pos : SV_POSITION; };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(_SkyTint.rgb, 1);
            }
            ENDCG
        }
    }
}
