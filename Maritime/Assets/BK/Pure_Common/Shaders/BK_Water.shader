// Made with Amplify Shader Editor v1.9.9.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BK/Water"
{
	Properties
	{
		[Toggle( _USEDISTANCEFADE_ON )] _UseDistanceFade( "Use Distance Fade", Float ) = 0
		_DistanceFade( "Distance Fade", Float ) = 1000
		_DistanceFadeOffset( "Distance Fade Offset", Float ) = 500
		[Space(10)][Header(Main Parameters)][Space(10)] _NormalMap( "Normal", 2D ) = "bump" {}
		_NormalPower( "Normal Power", Range( 0, 1 ) ) = 1
		_RefractionPower( "Refraction Power", Range( 0, 5 ) ) = 1
		_NormalScale( "Normal Scale", Float ) = 1
		_NormalSpeed( "Normal Speed", Float ) = 0.1
		_NormalDirection( "Normal Direction", Vector ) = ( 1, 0, -1, 0.2 )
		[Space(10)][Header(Foam)][Space(10)] _FoamMask( "Foam Mask", 2D ) = "white" {}
		_FoamDistance( "Foam Distance", Range( 0, 100 ) ) = 1
		_FoamPower( "Foam Power", Range( 0, 1 ) ) = 1
		_FoamScale( "Foam Scale", Float ) = 1
		_FoamSpeed( "Foam Speed", Float ) = 0.1
		[Space(30)] _EdgesFade( "Edges Fade", Float ) = 0.1
		_ShallowColor( "Shallow Color (RGBA)", Color ) = ( 0, 0.6810271, 0.6886792, 1 )
		_DepthColor( "Depth Color (RGBA)", Color ) = ( 0.1282781, 0.265286, 0.4433962, 1 )
		_Depth( "Depth", Float ) = 1
		[Space(10)][Header(Caustics)][Space(10)] _CausticsColor( "Caustics Color", Color ) = ( 0.2666667, 0.4509804, 0.5647059, 1 )
		_CausticsScale( "Caustics Scale", Float ) = 0.5
		_CausticsSpeed( "Caustics Speed", Float ) = 2
		_CausticsOffset( "Caustics Offset", Float ) = 0
		[Space(10)][Header(Waves)][Space(10)] _WavesHeight( "Waves Height", Float ) = 25
		_WavesSpeed( "Waves Speed", Float ) = 5
		_WavesScale( "Waves Scale", Float ) = 10
		[Space(10)][Header(Tesselation)][Space(10)] _TesselationPower( "Tesselation Power", Range( 1, 128 ) ) = 1
		_DistanceMin( "Distance Min", Float ) = 10
		_DistanceMax( "Distance Max", Range( 0, 200 ) ) = 100
		[Space(10)][Header(Metallic Smoothness)][Space(10)] _MetallicPower( "Metallic Power", Range( 0, 1 ) ) = 1
		_SmoothnessPower( "Smoothness Power", Range( 0, 1 ) ) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		GrabPass{ "_BKWaterGrab" }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma shader_feature_local _USEDISTANCEFADE_ON
		#define ASE_VERSION 19908
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard alpha:fade keepalpha noforwardadd vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform float _WavesSpeed;
		uniform float _WavesScale;
		uniform float _WavesHeight;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalDirection;
		uniform float _NormalSpeed;
		uniform float _NormalScale;
		uniform float _NormalPower;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _EdgesFade;
		uniform float _FoamDistance;
		uniform sampler2D _FoamMask;
		uniform float _FoamSpeed;
		uniform float _FoamScale;
		uniform float _FoamPower;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _BKWaterGrab )
		uniform float _RefractionPower;
		uniform float _Depth;
		uniform float4 _ShallowColor;
		uniform float4 _CausticsColor;
		uniform float _CausticsScale;
		uniform float _CausticsSpeed;
		uniform float _CausticsOffset;
		uniform float4 _DepthColor;
		uniform float _MetallicPower;
		uniform float _SmoothnessPower;
		uniform float _DistanceFade;
		uniform float _DistanceFadeOffset;
		uniform float _DistanceMin;
		uniform float _DistanceMax;
		uniform float _TesselationPower;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float2 voronoihash110( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi110( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0; int i, j;
			for ( j = -1; j <= 1; j++ )
			{
				for ( i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash110( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return F1;
		}


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g1( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		float2 voronoihash129( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi129( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0; int i, j;
			for ( j = -1; j <= 1; j++ )
			{
				for ( i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash129( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return F1;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _DistanceMin,_DistanceMax,_TesselationPower);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_normalOS = v.normal.xyz;
			float2 appendResult195 = (float2(_WavesSpeed , _WavesSpeed));
			float3 ase_positionWS = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult194 = (float2(ase_positionWS.x , ase_positionWS.z));
			float2 panner196 = ( 1.0 * _Time.y * appendResult195 + appendResult194);
			float simplePerlin2D199 = snoise( panner196*( _WavesScale / 100.0 ) );
			simplePerlin2D199 = simplePerlin2D199*0.5 + 0.5;
			float3 worldToObjDir273 = mul( unity_WorldToObject, float4( ( ase_normalOS * ( simplePerlin2D199 * _WavesHeight ) ), 0.0 ) ).xyz;
			float3 WavesHeight49 = worldToObjDir273;
			v.vertex.xyz += WavesHeight49;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 appendResult337 = (float2(_NormalDirection.x , _NormalDirection.y));
			float temp_output_106_0 = ( _NormalSpeed / 100.0 );
			float3 ase_positionWS = i.worldPos;
			float2 appendResult31 = (float2(ase_positionWS.x , ase_positionWS.z));
			float2 WorldSpace32 = appendResult31;
			float2 temp_output_68_0 = ( ( WorldSpace32 / 100.0 ) * _NormalScale );
			float2 panner72 = ( 1.0 * _Time.y * ( appendResult337 * temp_output_106_0 ) + temp_output_68_0);
			float2 appendResult338 = (float2(_NormalDirection.z , _NormalDirection.w));
			float2 panner73 = ( 1.0 * _Time.y * ( appendResult338 * ( temp_output_106_0 * 2.0 ) ) + ( temp_output_68_0 * ( _NormalScale * 1.2 ) ));
			float3 Normals81 = BlendNormals( UnpackScaleNormal( tex2D( _NormalMap, panner72 ), _NormalPower ) , UnpackScaleNormal( tex2D( _NormalMap, panner73 ), _NormalPower ) );
			o.Normal = Normals81;
			float3 ase_viewVectorWS = ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz );
			float3 ase_viewDirWS = normalize( ase_viewVectorWS );
			float temp_output_368_0 = abs( ase_viewDirWS.y );
			float4 ase_positionSS = float4( i.screenPos.xyz , i.screenPos.w + 1e-7 );
			float4 ase_positionSSNorm = ase_positionSS / ase_positionSS.w;
			ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
			float screenDepth241 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth241 = abs( ( screenDepth241 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _EdgesFade ) );
			float temp_output_377_0 = ( temp_output_368_0 * distanceDepth241 );
			float screenDepth230 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth230 = abs( ( screenDepth230 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( ( _FoamDistance * 0.1 ) ) );
			float screenDepth4 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth4 = abs( ( screenDepth4 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _FoamDistance ) );
			float temp_output_6_0 = ( 1.0 - ( temp_output_368_0 * distanceDepth4 ) );
			float temp_output_215_0 = ( _FoamSpeed / 100.0 );
			float2 temp_cast_0 = (temp_output_215_0).xx;
			float2 temp_output_225_0 = ( WorldSpace32 * ( _FoamScale / 100.0 ) );
			float2 panner213 = ( 1.0 * _Time.y * temp_cast_0 + temp_output_225_0);
			float2 temp_cast_1 = (temp_output_215_0).xx;
			float2 panner254 = ( 1.0 * _Time.y * temp_cast_1 + ( 1.0 - temp_output_225_0 ));
			float clampResult9 = clamp( ( temp_output_377_0 * ( ( ( 1.0 - ( temp_output_368_0 * distanceDepth230 ) ) + ( temp_output_6_0 * pow( ( temp_output_6_0 * ( tex2D( _FoamMask, panner213 ).r * tex2D( _FoamMask, panner254 ).r ) ) , ( 1.0 - 0.5 ) ) ) ) * _FoamPower ) ) , 0.0 , 1.0 );
			float Edges62 = clampResult9;
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_positionSS );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float screenDepth95 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
			float distanceDepth95 = abs( ( screenDepth95 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _Depth ) );
			float3 temp_cast_2 = (( 1.0 - saturate( ( distanceDepth95 * abs( ase_viewDirWS.y ) ) ) )).xxx;
			float3 temp_cast_3 = (( 1.0 - saturate( ( distanceDepth95 * abs( ase_viewDirWS.y ) ) ) )).xxx;
			float3 gammaToLinear330 = GammaToLinearSpace( temp_cast_3 );
			float Depth98 = gammaToLinear330.x;
			float clampResult391 = clamp( Depth98 , 0.0 , 1.0 );
			float saferPower393 = abs( ( 1.0 - clampResult391 ) );
			float4 screenColor20 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BKWaterGrab,( ase_grabScreenPosNorm + float4( ( ( ( _RefractionPower * pow( saferPower393 , 2.0 ) ) / 10.0 ) * Normals81 ) , 0.0 ) ).xy);
			float3 Refraction60 = saturate( (screenColor20).rgb );
			float mulTime27 = _Time.y * _CausticsSpeed;
			float time110 = ( mulTime27 * 1.0 );
			float2 voronoiSmoothId110 = 0;
			float2 UV22_g3 = ase_positionSSNorm.xy;
			float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
			float2 break64_g1 = localUnStereo22_g3;
			float depth01_69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - depth01_69_g1 );
			#else
				float staticSwitch38_g1 = depth01_69_g1;
			#endif
			float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
			float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
			float3 temp_output_46_0_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
			float3 In72_g1 = temp_output_46_0_g1;
			float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
			float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
			float4 temp_output_348_0 = mul( unity_CameraToWorld, appendResult49_g1 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_lightDirWS = 0;
			#else //aseld
			float3 ase_lightDirWS = normalize( UnityWorldSpaceLightDir( ase_positionWS ) );
			#endif //aseld
			float2 appendResult353 = (float2(ase_lightDirWS.x , ase_lightDirWS.z));
			float3 worldToObj350 = mul( unity_WorldToObject, float4( temp_output_348_0.xyz, 1 ) ).xyz;
			float2 temp_output_355_0 = ( (temp_output_348_0).xz + ( appendResult353 * -worldToObj350.y * _CausticsOffset ) );
			float2 coords110 = temp_output_355_0 * ( _CausticsScale * 0.5 );
			float2 id110 = 0;
			float2 uv110 = 0;
			float voroi110 = voronoi110( coords110, time110, id110, uv110, 0, voronoiSmoothId110 );
			float time129 = mulTime27;
			float2 voronoiSmoothId129 = 0;
			float2 coords129 = temp_output_355_0 * _CausticsScale;
			float2 id129 = 0;
			float2 uv129 = 0;
			float voroi129 = voronoi129( coords129, time129, id129, uv129, 0, voronoiSmoothId129 );
			float Caustics47 = saturate( ( voroi110 + voroi129 ) );
			float clampResult56 = clamp( Caustics47 , 0.0 , 1.0 );
			float3 lerpResult52 = lerp( _ShallowColor.rgb , _CausticsColor.rgb , clampResult56);
			float3 lerpResult326 = lerp( lerpResult52 , _DepthColor.rgb , ( 1.0 - Depth98 ));
			float3 blendOpSrc173 = Refraction60;
			float3 blendOpDest173 = lerpResult326;
			float3 lerpBlendMode173 = lerp(blendOpDest173,(( blendOpDest173 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest173 ) * ( 1.0 - blendOpSrc173 ) ) : ( 2.0 * blendOpDest173 * blendOpSrc173 ) ),( 1.0 - _DepthColor.a ));
			float3 Albedo58 = ( saturate( lerpBlendMode173 ));
			float3 lerpResult100 = lerp( Albedo58 , Refraction60 , Depth98);
			float3 clampResult109 = clamp( ( Edges62 + lerpResult100 ) , float3( 0,0,0 ) , float3( 1,1,1 ) );
			o.Albedo = clampResult109;
			o.Metallic = _MetallicPower;
			o.Smoothness = _SmoothnessPower;
			float clampResult249 = clamp( temp_output_377_0 , 0.0 , 1.0 );
			float4 ase_positionOS4f = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_positionVS = UnityObjectToViewPos( ase_positionOS4f );
			float ase_screenDepth = -ase_positionVS.z;
			float cameraDepthFade293 = (( ase_screenDepth -_ProjectionParams.y - _DistanceFadeOffset ) / _DistanceFade);
			#ifdef _USEDISTANCEFADE_ON
				float staticSwitch395 = ( clampResult249 * saturate( ( 1.0 - ( temp_output_368_0 * cameraDepthFade293 ) ) ) );
			#else
				float staticSwitch395 = clampResult249;
			#endif
			float Opacity263 = staticSwitch395;
			o.Alpha = Opacity263;
		}

		ENDCG
	}
	Fallback Off
}
/*ASEBEGIN
Version=19908
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;168;-2176,-5504;Inherit;False;1621.547;337.7678;;10;371;372;374;98;333;330;102;370;95;96;Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;96;-2128,-5424;Inherit;False;Property;_Depth;Depth;17;0;Create;True;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;371;-2032,-5328;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;372;-1824,-5328;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;95;-1936,-5440;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;374;-1664,-5440;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;370;-1520,-5440;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;102;-1376,-5440;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;165;-2176,-2816;Inherit;False;2271.568;1055.857;;23;81;80;65;66;72;64;73;76;71;79;70;68;77;91;106;69;78;67;92;335;337;338;11;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.GammaToLinearNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;330;-1216,-5440;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;78;-2112,-2016;Inherit;False;Property;_NormalSpeed;Normal Speed;7;0;Create;True;0;0;0;False;0;False;0.1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;92;-2112,-2656;Inherit;False;Constant;_Float1;Float 1;18;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;335;-1904,-2272;Inherit;False;Property;_NormalDirection;Normal Direction;8;0;Create;True;0;0;0;False;0;False;1,0,-1,0.2;-1,2.3,1.7,-0.2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;333;-1008,-5440;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;67;-2144,-2752;Inherit;False;32;WorldSpace;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;163;-2176,-6912;Inherit;False;614;229;;3;30;31;32;World Space UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;106;-1904,-2016;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;91;-1952,-2720;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;69;-2064,-2464;Inherit;False;Property;_NormalScale;Normal Scale;6;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;70;-1840,-2400;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;337;-1632,-2272;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;169;-2176,-4992;Inherit;False;2306.721;512.0931;;15;60;20;19;16;18;105;228;392;393;17;394;391;390;396;397;Refraction;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;77;-1648,-1904;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;338;-1648,-2032;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;98;-768,-5440;Inherit;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;30;-2144,-6848;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;235;-2176,-3584;Inherit;False;2803.369;635.6409;;18;356;47;132;131;159;355;28;158;360;354;27;353;162;359;358;350;348;382;Caustics;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;68;-1840,-2528;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;79;-1328,-1936;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;76;-1456,-2272;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;71;-1456,-2144;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;390;-2144,-4608;Inherit;False;98;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;184;-2176,-1536;Inherit;False;3710.818;1532.722;;47;263;284;249;297;290;378;293;295;296;62;9;242;234;377;229;241;8;7;250;231;219;376;217;230;227;232;233;6;259;84;375;258;254;4;213;83;255;215;185;225;183;224;226;223;362;368;395;Foam / Edge Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;350;-1776,-3312;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;358;-1776,-3456;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;72;-1168,-2528;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;73;-1168,-2064;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;64;-1200,-2320;Inherit;True;Property;_NormalMap;Normal;3;0;Create;False;0;0;0;False;3;Space(10);Header(Main Parameters);Space(10);False;None;0754386dd9914019a899e516da7e41a3;True;bump;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ClampOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;391;-1952,-4608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;31;-1952,-6848;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;11;-1088,-1920;Inherit;False;Property;_NormalPower;Normal Power;4;0;Create;True;0;0;0;False;0;False;1;0.398;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;32;-1792,-6848;Inherit;False;WorldSpace;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;223;-2144,-384;Inherit;False;Property;_FoamScale;Foam Scale;12;0;Create;True;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;359;-1536,-3344;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;353;-1536,-3456;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;356;-1568,-3248;Inherit;False;Property;_CausticsOffset;Caustics Offset;21;0;Create;True;0;0;0;False;0;False;0;3.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;162;-1312,-3216;Inherit;False;Property;_CausticsSpeed;Caustics Speed;20;0;Create;True;0;0;0;False;0;False;2;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;394;-1792,-4608;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;348;-2128,-3536;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;65;-768,-2432;Inherit;True;Property;_TextureSample0;Texture Sample 0;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;66;-768,-2208;Inherit;True;Property;_TextureSample1;Texture Sample 1;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;224;-2048,-512;Inherit;False;32;WorldSpace;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;226;-1952,-384;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;183;-1792,-320;Inherit;False;Property;_FoamSpeed;Foam Speed;13;0;Create;True;0;0;0;False;0;False;0.1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;354;-1360,-3424;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;360;-1376,-3536;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;27;-1136,-3216;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;158;-1136,-3072;Inherit;False;Property;_CausticsScale;Caustics Scale;19;0;Create;True;0;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;17;-2144,-4736;Inherit;False;Property;_RefractionPower;Refraction Power;5;0;Create;True;0;0;0;False;0;False;1;1.54;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;393;-1632,-4608;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;80;-448,-2304;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;225;-1792,-448;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;255;-1408,-192;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;215;-1408,-320;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;382;-144,-3552;Inherit;False;218.6917;574.7078;Noises;2;110;129;;1,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;28;-896,-3424;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;355;-864,-3536;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;159;-896,-3312;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;392;-1408,-4736;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;81;-192,-2304;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;213;-1152,-448;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;254;-1152,-320;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;83;-1152,-688;Inherit;True;Property;_FoamMask;Foam Mask;9;0;Create;True;0;0;0;False;3;Space(10);Header(Foam);Space(10);False;None;043b9a1abeb64417b5d7f46b316b3025;False;white;Auto;Texture2D;False;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.VoronoiNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;129;-112,-3248;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.VoronoiNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;110;-112,-3504;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;228;-1248,-4736;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;105;-1280,-4608;Inherit;False;81;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;185;-1664,-1280;Inherit;False;Property;_FoamDistance;Foam Distance;10;0;Create;True;0;0;0;False;0;False;1;3.3;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;258;-768,-352;Inherit;True;Property;_TextureSample3;Texture Sample 3;18;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;84;-768,-576;Inherit;True;Property;_TextureSample2;Texture Sample 2;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;131;128,-3392;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;18;-1024,-4736;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GrabScreenPosition, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;16;-1408,-4928;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;4;-1152,-1280;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;259;-432,-448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;233;-384,-256;Inherit;False;Constant;_Float0;Float 0;21;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;232;-1344,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;132;240,-3392;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;19;-896,-4864;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;375;-768,-1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;230;-1152,-1152;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;227;-224,-256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;217;-256,-640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;166;-2176,-6528;Inherit;False;1282.369;831.7024;;13;58;173;175;292;52;117;56;326;55;325;53;329;327;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;47;384,-3392;Inherit;False;Caustics;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;20;-784,-4864;Inherit;False;Global;_BKWaterGrab;_BKWaterGrab;9;0;Create;True;0;0;0;False;0;False;Object;-1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;6;-448,-1280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;164;-2176,-4352;Inherit;False;2172.17;608.8064;;14;49;273;200;201;191;48;196;198;194;195;197;193;192;383;Waves;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;219;0,-576;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;376;-768,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;55;-2144,-5792;Inherit;False;47;Caustics;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;396;-576,-4864;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;362;-1152,-1472;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;7;160,-704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;192;-2112,-4288;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;193;-2112,-4096;Inherit;False;Property;_WavesSpeed;Waves Speed;23;0;Create;True;0;0;0;False;0;False;5;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;231;-448,-1152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;327;-2144,-5920;Inherit;False;98;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;56;-1920,-5840;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;117;-2016,-6288;Inherit;False;Property;_CausticsColor;Caustics Color;18;0;Create;True;0;0;0;False;3;Space(10);Header(Caustics);Space(10);False;0.2666667,0.4509804,0.5647059,1;0.5582057,0.694339,0.7924528,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;325;-2016,-6464;Inherit;False;Property;_ShallowColor;Shallow Color (RGBA);15;0;Create;False;0;0;0;False;0;False;0,0.6810271,0.6886792,1;0.1936632,0.3479838,0.4811321,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;295;-1536,-928;Inherit;False;Property;_DistanceFade;Distance Fade;1;0;Create;True;0;0;0;False;0;False;1000;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;296;-1536,-832;Inherit;False;Property;_DistanceFadeOffset;Distance Fade Offset;2;0;Create;True;0;0;0;False;0;False;500;1000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;250;-1536,-1024;Inherit;False;Property;_EdgesFade;Edges Fade;14;0;Create;True;0;0;0;False;1;Space(30);False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;397;-352,-4864;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;368;-928,-1424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;8;256,-576;Inherit;False;Property;_FoamPower;Foam Power;11;0;Create;True;0;0;0;False;0;False;1;0.081;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;229;320,-1088;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;194;-1920,-4256;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;195;-1888,-4112;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;197;-1728,-4032;Inherit;False;Property;_WavesScale;Waves Scale;24;0;Create;True;0;0;0;False;0;False;10;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;329;-1920,-5920;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;53;-2016,-6112;Inherit;False;Property;_DepthColor;Depth Color (RGBA);16;0;Create;False;0;0;0;False;0;False;0.1282781,0.265286,0.4433962,1;0.151418,0.2660419,0.2735848,0.7411765;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;52;-1728,-6400;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CameraDepthFade, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;293;-1152,-896;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;241;-1152,-1024;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;60;-192,-4864;Inherit;False;Refraction;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;383;-1310,-4256;Inherit;False;258.6666;286.6663;Noise;1;199;;1,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;234;512,-1088;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;196;-1728,-4192;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;198;-1472,-4032;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;326;-1536,-6144;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;292;-1536,-5952;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;378;-768,-896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;377;-768,-1024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;175;-1536,-6272;Inherit;False;60;Refraction;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;48;-2112,-3968;Inherit;False;Property;_WavesHeight;Waves Height;22;0;Create;True;0;0;0;False;3;Space(10);Header(Waves);Space(10);False;25;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;199;-1280,-4192;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;173;-1344,-6144;Inherit;False;Overlay;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;290;-608,-864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;242;768,-960;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;9;1024,-960;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;200;-992,-4240;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;58;-1120,-6144;Inherit;False;Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;191;-976,-4000;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;297;-448,-864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;249;-448,-1024;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;62;1280,-960;Inherit;False;Edges;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;201;-704,-4160;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;101;1623.622,-3466.495;Inherit;False;98;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;99;1623.622,-3546.495;Inherit;False;60;Refraction;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;59;1623.622,-3626.495;Inherit;False;58;Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;284;-256,-896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;100;1815.622,-3562.495;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;273;-512,-4224;Inherit;False;World;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;63;1807.822,-3678.795;Inherit;False;62;Edges;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;395;0,-1280;Inherit;False;Property;_UseDistanceFade;Use Distance Fade;0;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;49;-256,-4160;Inherit;False;WavesHeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;108;1995.922,-3586.695;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;280;1920,-2736;Inherit;False;Property;_DistanceMin;Distance Min;26;0;Create;True;0;0;0;True;0;False;10;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;46;1920,-2816;Inherit;False;Property;_TesselationPower;Tesselation Power;25;0;Create;True;0;0;0;True;3;Space(10);Header(Tesselation);Space(10);False;1;128;1;128;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;279;1920,-2656;Inherit;False;Property;_DistanceMax;Distance Max;27;0;Create;True;0;0;0;True;0;False;100;200;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;263;448,-1280;Inherit;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;109;2143.422,-3587.995;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;82;2048,-3328;Inherit;False;81;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;176;2048,-3232;Inherit;False;Property;_MetallicPower;Metallic Power;28;0;Create;True;0;0;0;False;3;Space(10);Header(Metallic Smoothness);Space(10);False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;13;2048,-3136;Inherit;False;Property;_SmoothnessPower;Smoothness Power;29;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;51;2048,-2944;Inherit;False;49;WavesHeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceBasedTessNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;380;2240,-2720;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;285;2048,-3040;Inherit;False;263;Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;379;2560,-3265;Float;False;True;-1;6;;0;0;Standard;BK/Water;False;False;False;False;False;False;False;False;False;False;False;True;False;False;True;False;False;False;False;False;False;Back;2;False;;3;False;;False;0;False;;0;False;;False;3;0;False;;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;372;0;371;2
WireConnection;95;0;96;0
WireConnection;374;0;95;0
WireConnection;374;1;372;0
WireConnection;370;0;374;0
WireConnection;102;0;370;0
WireConnection;330;0;102;0
WireConnection;333;0;330;0
WireConnection;106;0;78;0
WireConnection;91;0;67;0
WireConnection;91;1;92;0
WireConnection;70;0;69;0
WireConnection;337;0;335;1
WireConnection;337;1;335;2
WireConnection;77;0;106;0
WireConnection;338;0;335;3
WireConnection;338;1;335;4
WireConnection;98;0;333;0
WireConnection;68;0;91;0
WireConnection;68;1;69;0
WireConnection;79;0;338;0
WireConnection;79;1;77;0
WireConnection;76;0;337;0
WireConnection;76;1;106;0
WireConnection;71;0;68;0
WireConnection;71;1;70;0
WireConnection;350;0;348;0
WireConnection;72;0;68;0
WireConnection;72;2;76;0
WireConnection;73;0;71;0
WireConnection;73;2;79;0
WireConnection;391;0;390;0
WireConnection;31;0;30;1
WireConnection;31;1;30;3
WireConnection;32;0;31;0
WireConnection;359;0;350;2
WireConnection;353;0;358;1
WireConnection;353;1;358;3
WireConnection;394;0;391;0
WireConnection;65;0;64;0
WireConnection;65;1;72;0
WireConnection;65;5;11;0
WireConnection;66;0;64;0
WireConnection;66;1;73;0
WireConnection;66;5;11;0
WireConnection;226;0;223;0
WireConnection;354;0;353;0
WireConnection;354;1;359;0
WireConnection;354;2;356;0
WireConnection;360;0;348;0
WireConnection;27;0;162;0
WireConnection;393;0;394;0
WireConnection;80;0;65;0
WireConnection;80;1;66;0
WireConnection;225;0;224;0
WireConnection;225;1;226;0
WireConnection;255;0;225;0
WireConnection;215;0;183;0
WireConnection;28;0;27;0
WireConnection;355;0;360;0
WireConnection;355;1;354;0
WireConnection;159;0;158;0
WireConnection;392;0;17;0
WireConnection;392;1;393;0
WireConnection;81;0;80;0
WireConnection;213;0;225;0
WireConnection;213;2;215;0
WireConnection;254;0;255;0
WireConnection;254;2;215;0
WireConnection;129;0;355;0
WireConnection;129;1;27;0
WireConnection;129;2;158;0
WireConnection;110;0;355;0
WireConnection;110;1;28;0
WireConnection;110;2;159;0
WireConnection;228;0;392;0
WireConnection;258;0;83;0
WireConnection;258;1;254;0
WireConnection;84;0;83;0
WireConnection;84;1;213;0
WireConnection;131;0;110;0
WireConnection;131;1;129;0
WireConnection;18;0;228;0
WireConnection;18;1;105;0
WireConnection;4;0;185;0
WireConnection;259;0;84;1
WireConnection;259;1;258;1
WireConnection;232;0;185;0
WireConnection;132;0;131;0
WireConnection;19;0;16;0
WireConnection;19;1;18;0
WireConnection;375;0;368;0
WireConnection;375;1;4;0
WireConnection;230;0;232;0
WireConnection;227;0;233;0
WireConnection;217;0;6;0
WireConnection;217;1;259;0
WireConnection;47;0;132;0
WireConnection;20;0;19;0
WireConnection;6;0;375;0
WireConnection;219;0;217;0
WireConnection;219;1;227;0
WireConnection;376;0;368;0
WireConnection;376;1;230;0
WireConnection;396;0;20;0
WireConnection;7;0;6;0
WireConnection;7;1;219;0
WireConnection;231;0;376;0
WireConnection;56;0;55;0
WireConnection;397;0;396;0
WireConnection;368;0;362;2
WireConnection;229;0;231;0
WireConnection;229;1;7;0
WireConnection;194;0;192;1
WireConnection;194;1;192;3
WireConnection;195;0;193;0
WireConnection;195;1;193;0
WireConnection;329;0;327;0
WireConnection;52;0;325;5
WireConnection;52;1;117;5
WireConnection;52;2;56;0
WireConnection;293;0;295;0
WireConnection;293;1;296;0
WireConnection;241;0;250;0
WireConnection;60;0;397;0
WireConnection;234;0;229;0
WireConnection;234;1;8;0
WireConnection;196;0;194;0
WireConnection;196;2;195;0
WireConnection;198;0;197;0
WireConnection;326;0;52;0
WireConnection;326;1;53;5
WireConnection;326;2;329;0
WireConnection;292;0;53;4
WireConnection;378;0;368;0
WireConnection;378;1;293;0
WireConnection;377;0;368;0
WireConnection;377;1;241;0
WireConnection;199;0;196;0
WireConnection;199;1;198;0
WireConnection;173;0;175;0
WireConnection;173;1;326;0
WireConnection;173;2;292;0
WireConnection;290;0;378;0
WireConnection;242;0;377;0
WireConnection;242;1;234;0
WireConnection;9;0;242;0
WireConnection;58;0;173;0
WireConnection;191;0;199;0
WireConnection;191;1;48;0
WireConnection;297;0;290;0
WireConnection;249;0;377;0
WireConnection;62;0;9;0
WireConnection;201;0;200;0
WireConnection;201;1;191;0
WireConnection;284;0;249;0
WireConnection;284;1;297;0
WireConnection;100;0;59;0
WireConnection;100;1;99;0
WireConnection;100;2;101;0
WireConnection;273;0;201;0
WireConnection;395;1;249;0
WireConnection;395;0;284;0
WireConnection;49;0;273;0
WireConnection;108;0;63;0
WireConnection;108;1;100;0
WireConnection;263;0;395;0
WireConnection;109;0;108;0
WireConnection;380;0;46;0
WireConnection;380;1;280;0
WireConnection;380;2;279;0
WireConnection;379;0;109;0
WireConnection;379;1;82;0
WireConnection;379;3;176;0
WireConnection;379;4;13;0
WireConnection;379;9;285;0
WireConnection;379;11;51;0
WireConnection;379;14;380;0
ASEEND*/
//CHKSM=41A9A49315A24890A3A3939160592F4837378A12