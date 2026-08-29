
Shader "Custom/FishSwimBend"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.4
        _SpecColor ("Specular", Color) = (0.2,0.2,0.2,1)
        _RimColor ("Rim Color", Color) = (0.6,0.85,1,1)
        _RimPower ("Rim Power", Range(0.5,8)) = 3.0
        _BendAxis ("Bend Axis (body length dir, local space)", Vector) = (0,1,0,0)
        _BodyLength ("Body Length Along Axis (local units)", Float) = 1.0
        _BendAmplitude ("Bend Amplitude (fraction of body length)", Range(0,0.4)) = 0.12
        _BendFrequency ("Bend Frequency (cycles per body length)", Range(0.1,4)) = 1.2
        _SwimSpeed ("Swim Speed", Range(0,10)) = 3.0
        _PhaseOffset ("Phase Offset", Range(0,6.283)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        CGPROGRAM
        #pragma surface surf StandardSpecular vertex:vert addshadow
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        half _Glossiness;
        fixed4 _RimColor;
        float _RimPower;
        float4 _BendAxis;
        float _BodyLength;
        float _BendAmplitude;
        float _BendFrequency;
        float _SwimSpeed;
        float _PhaseOffset;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 viewDir;
        };

        void vert(inout appdata_full v)
        {
            float3 axis = normalize(_BendAxis.xyz + float3(0.0001,0,0));
            float along = dot(v.vertex.xyz, axis);
            float len = max(_BodyLength, 0.0001);
            float t = along / len;
            float phase = t * _BendFrequency * 6.28318 - _Time.y * _SwimSpeed + _PhaseOffset;
            float offset = sin(phase) * _BendAmplitude * len * t;
            float3 sideDir = normalize(cross(axis, float3(0,0,1)) + float3(0,0.0001,0));
            v.vertex.xyz += sideDir * offset;
        }

        void surf(Input IN, inout SurfaceOutputStandardSpecular o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Specular = _SpecColor.rgb;
            o.Smoothness = _Glossiness;
            half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
            o.Emission = _RimColor.rgb * pow(rim, _RimPower) * 0.25;
        }
        ENDCG
    }
    FallBack "Standard (Specular setup)"
}
