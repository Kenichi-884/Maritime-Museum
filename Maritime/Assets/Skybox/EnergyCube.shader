Shader "ConstellationObservation/EnergyCube"
{
    Properties
    {
        _Color ("Base Color", Color) = (0.05, 0.05, 0.08, 1)
        _EmissionColor ("Emission Color", Color) = (0, 0, 0, 1)
        _FresnelColor ("Fresnel Rim Color", Color) = (1, 1, 1, 1)
        _FresnelPower ("Fresnel Power", Range(0.5, 8)) = 2.5
        _FresnelIntensity ("Fresnel Intensity", Range(0, 6)) = 1.2
        _Metallic ("Metallic", Range(0, 1)) = 0.1
        _Glossiness ("Smoothness", Range(0, 1)) = 0.9
        _CoreAlpha ("Core Transparency (center, facing camera)", Range(0, 1)) = 0.35
        _EdgeAlpha ("Edge Opacity (rim, grazing angle)", Range(0, 1)) = 0.85
    }
    SubShader
    {
        // Alpha-blended like glass: mostly see-through face-on, more solid at the grazing edges.
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 200
        // Render both faces so the far inside walls show through the near ones.
        Cull Off

        CGPROGRAM
        // Plain Surface Shader - Unity's own well-tested codegen handles VR/instancing here,
        // unlike hand-patched Shader Graph output, so no multi_compile pitfalls to worry about.
        #pragma surface surf Standard alpha:fade fullforwardshadows
        #pragma target 3.0

        struct Input
        {
            float3 viewDir;
        };

        fixed4 _Color;
        fixed4 _EmissionColor;
        fixed4 _FresnelColor;
        float _FresnelPower;
        float _FresnelIntensity;
        half _Metallic;
        half _Glossiness;
        half _CoreAlpha;
        half _EdgeAlpha;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = _Color.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;

            half ndotv = saturate(dot(normalize(IN.viewDir), o.Normal));
            half fresnel = pow(1.0 - ndotv, _FresnelPower);

            o.Emission = _EmissionColor.rgb + _FresnelColor.rgb * fresnel * _FresnelIntensity;
            o.Alpha = lerp(_CoreAlpha, _EdgeAlpha, fresnel);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
