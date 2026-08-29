Shader "ConstellationObservation/SimpleNightSky"
{
    // Hand-written replacement for the OccaSoftware SuperSimpleSkybox export. That shader is
    // Shader-Graph-generated Built-in-target code, and it hits a known Unity bug where
    // UnityShaderVariables.cginc's GLOBAL_CBUFFER_START(UnityStereoGlobals) block - which only
    // exists in XR-capable builds - fails with "too few arguments to a macro call" at compile
    // time. That's a build-time define (any XR-capable build, not just an active VR session),
    // so no amount of trimming multi_compile keywords on our end could fix it. A plain
    // hand-written skybox shader doesn't pull in that broken code path at all.
    Properties
    {
        _SkyColorDay ("Sky Color (Day, Zenith)", Color) = (0.35, 0.55, 0.9, 1)
        _HorizonColorDay ("Horizon Color (Day)", Color) = (1, 0.93, 0.82, 1)
        _SkyColorNight ("Sky Color (Night, Zenith)", Color) = (0.01, 0.01, 0.02, 1)
        _HorizonColorNight ("Horizon Color (Night)", Color) = (0.02, 0.02, 0.04, 1)
        _DayNight ("Day <-> Night", Range(0, 1)) = 1
        _HorizonFalloff ("Horizon Falloff", Range(0.5, 8)) = 2.5
        _StarIntensity ("Star Intensity", Range(0, 3)) = 1.1
        _StarDensity ("Star Density", Range(50, 800)) = 300
        _StarSharpness ("Star Sharpness", Range(1, 64)) = 24
        _StarTwinkleSpeed ("Star Twinkle Speed", Range(0, 3)) = 0.6
    }
    SubShader
    {
        Tags { "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox" }
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _SkyColorDay;
            fixed4 _HorizonColorDay;
            fixed4 _SkyColorNight;
            fixed4 _HorizonColorNight;
            float _DayNight;
            float _HorizonFalloff;
            float _StarIntensity;
            float _StarDensity;
            float _StarSharpness;
            float _StarTwinkleSpeed;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 dir : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.dir = v.vertex.xyz;
                return o;
            }

            // Cheap hash noise for a procedural star field - no textures needed.
            float hash3(float3 p)
            {
                p = frac(p * 0.3183099 + 0.1);
                p *= 17.0;
                return frac(p.x * p.y * p.z * (p.x + p.y + p.z));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 dir = normalize(i.dir);

                fixed3 skyColor = lerp(_SkyColorNight.rgb, _SkyColorDay.rgb, _DayNight);
                fixed3 horizonColor = lerp(_HorizonColorNight.rgb, _HorizonColorDay.rgb, _DayNight);
                float horizonT = pow(saturate(1.0 - abs(dir.y)), _HorizonFalloff);
                fixed3 col = lerp(skyColor, horizonColor, horizonT);

                // Procedural stars: a starfield cell per direction, one bright point per cell,
                // gently twinkling. Fades out near the horizon and as day approaches.
                float3 cell = floor(dir * _StarDensity);
                float starRand = hash3(cell);
                float starCore = smoothstep(1.0 - (1.0 / _StarSharpness), 1.0, starRand);
                float twinkle = 0.6 + 0.4 * sin(starRand * 123.4 + _Time.y * _StarTwinkleSpeed * (1.0 + starRand));
                float aboveHorizon = smoothstep(-0.02, 0.1, dir.y);
                float starVisibility = (1.0 - _DayNight) * aboveHorizon;

                col += starCore * twinkle * _StarIntensity * starVisibility;

                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
