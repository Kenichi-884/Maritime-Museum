// Simple textured transparent/additive particle shader.
// Replaces third-party materials that referenced Unity built-in fileID 211
// (Particles/Standard Unlit) which fails to resolve in this project.
// Blend mode is driven by _SrcBlend / _DstBlend so one shader covers both
// alpha-blended bubbles and additive light shafts.
Shader "Maritime/FxParticle"
{
    Properties
    {
        _MainTex  ("Texture", 2D)          = "white" {}
        _Color    ("Tint Color", Color)    = (1, 1, 1, 1)
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend ("Src Blend", Float)     = 5   // SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("Dst Blend", Float)     = 10  // OneMinusSrcAlpha
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        Blend [_SrcBlend] [_DstBlend]
        ZWrite Off
        Cull Off
        Lighting Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4    _MainTex_ST;
            fixed4    _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
                float4 color  : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
                fixed4 color : COLOR;
                UNITY_FOG_COORDS(1)
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.pos   = UnityObjectToClipPos(v.vertex);
                o.uv    = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color * _Color;
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    Fallback "Transparent/Diffuse"
}
