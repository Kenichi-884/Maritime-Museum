// Replacement for the original ASE-generated AQUAS_Bubble shader.
// The original mixed a surface-shader pragma (which auto-generates ShadowCaster) with an
// explicit ShadowCaster Pass - a duplicate that fails to compile in some Unity versions.
// This rewrite uses a plain vertex/fragment pass: unambiguous structure, no duplicates,
// and full ParticleSystem vertex-color support.
Shader "AQUAS/Misc/Bubble"
{
    Properties
    {
        _Color ("Tint", Color) = (1, 1, 1, 0.5)
        _BubbleSpecColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Smoothness ("Smoothness", Range(0, 1)) = 0.7
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color  : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos     : SV_POSITION;
                float3 wNormal : TEXCOORD0;
                float3 wPos    : TEXCOORD1;
                float4 color   : COLOR;
                UNITY_FOG_COORDS(2)
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _Color;
            fixed4 _BubbleSpecColor;
            float  _Smoothness;

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.pos     = UnityObjectToClipPos(v.vertex);
                o.wNormal = UnityObjectToWorldNormal(v.normal);
                o.wPos    = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.color   = v.color * _Color;
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 N = normalize(i.wNormal);
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 H = normalize(L + V);

                float specPow = exp2(_Smoothness * 10.0 + 1.0);
                float spec    = pow(max(0.0, dot(N, H)), specPow);

                fixed4 col = i.color;
                col.rgb += _BubbleSpecColor.rgb * spec * _LightColor0.rgb;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    Fallback "Transparent/Diffuse"
}
