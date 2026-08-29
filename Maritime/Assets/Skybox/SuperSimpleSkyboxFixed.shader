Shader "OccaSoftware/SuperSimpleSkyboxFixed"
{
Properties
{
[ToggleUI]_Constant_Color_Mode("Constant Color Mode", Float) = 0
[ToggleUI]_GroundEnabled("Use Ground", Float) = 1
_GroundFadeAmount("Ground Fade", Range(0, 1)) = 0
_Ground_Height("Ground Height", Range(-1, 1)) = 0
[HDR]_GroundColor("Ground Color", Color) = (0, 0, 0, 0)
[HDR]_HorizonColorDay("Day Horizon Color", Color) = (1, 1, 1, 1)
_HorizonSaturationAmount("Horizon Saturation Amount", Range(0, 1)) = 0.3
[HDR]_SkyColorDay("Sky Color Day", Color) = (1, 1, 1, 0)
_HorizonSaturationFalloff("Horizon Desaturation Falloff", Range(1, 10)) = 3
[HDR]_HorizonColorNight("Night Horizon Color", Color) = (0.08736077, 0.07843138, 0.1333333, 0)
[HDR]_SkyColorNight("Night Sky Color", Color) = (0.1037736, 0.01507654, 0.1037736, 0)
_SkyColorBlend("Horizon / Zenith Color Blend", Range(0.1, 2)) = 0.5
[ToggleUI]_SunSkyLightingEnabled("Sun Sky Lighting Enabled", Float) = 1
[HDR]_SunColorZenith("Sun Zenith Color", Color) = (136.575, 113.7095, 61.18064, 0)
_SunsetRadialFalloff("Sunset Radial Falloff", Range(0.01, 1)) = 0.2
[HDR]_SunColorHorizon("Sun Horizon Color", Color) = (98.45184, 43.57705, 18.2916, 0)
_SunAngularDiameter("Sun Angular Diameter", Float) = 10
_SunsetHorizontalFalloff("Sunset Horizontal Falloff", Range(0.01, 1)) = 0.5
_SunFalloffIntensity("Sun Falloff Intensity", Float) = 0.04
_SunFalloff("Sun Falloff", Float) = 2
_SunsetIntensity("Sunset Intensity", Range(0, 1)) = 0.1
_SunsetVerticalFalloff("Sunset Vertical Falloff", Range(0.01, 1)) = 0.4
[ToggleUI]_Sun_Enabled("Sun Enabled", Float) = 1
[ToggleUI]_Moon_Enabled("Moon Enabled", Float) = 1
_MoonAngularDiameter("Moon Angular Diameter", Float) = 5
[HDR]_MoonColor("Moon Color", Color) = (1.615686, 1.74902, 1.811765, 0)
_MoonFalloff("Moon Falloff", Float) = 15
[ToggleUI]_Stars_Enabled("Stars Enabled", Float) = 1
[ToggleUI]_Use_Texture_Stars("Use Texture Stars", Float) = 1
[ToggleUI]_ProceduralStarsEnabled("Use Procedural Stars", Float) = 1
_StarScale("Star Scale", Float) = 0.5
_StarSpeed("Star Speed", Float) = 0.25
_StarSaturation("Star Saturation", Float) = 1
[HDR]_Star_Texture_Tint("Star Texture Tint", Color) = (1, 1, 1, 0)
_StarFrequency("Star Frequency", Float) = 1
_StarSharpness("Star Sharpness", Float) = 1
[NoScaleOffset]_StarTexture("Star Texture", 2D) = "black" {}
_StarHorizonFalloff("Star Horizon Falloff", Range(0, 2)) = 0.2
_StarDaytimeBrightness("Star Daytime Brightness", Range(0, 1)) = 0.1
_StarIntensity("Star Intensity", Range(0, 3)) = 1
[HDR]_CloudColorNight("Night Cloud Color", Color) = (0.07247217, 0.06087575, 0.09433961, 0)
[HDR]_CloudColorDay("Day Cloud Color", Color) = (0.9024564, 0.9250059, 0.9433962, 0)
_Cloudiness("Cloudiness", Range(0, 1)) = 0.5
_Shading_Intensity("Shading Intensity", Range(0, 1)) = 0.5
[NoScaleOffset]_CloudTexture("Cloud Texture", 2D) = "white" {}
_CloudScale("Cloud Scale", Vector) = (2, 1, 0, 0)
_CloudWindSpeed("Wind", Vector) = (-0.5, 1, 0, 0)
_CloudFalloff("Cloud Height Falloff", Range(0, 1)) = 0.3
_CloudOpacity("Cloud Opacity", Range(0, 1)) = 1
_CloudSharpness("Cloud Sharpness", Range(0, 1)) = 0.8
_Cloud_Iterations("Cloud Iterations", Float) = 3
_Cloud_Gain("Cloud Gain", Range(0, 1)) = 0.5
_Cloud_Lacunarity("Cloud Lacunarity", Float) = 1
[ToggleUI]_Clouds_Enabled("Clouds Enabled", Float) = 1
[HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
[HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
}
SubShader
{
Tags
{
// RenderPipeline: <None>
"RenderType"="Opaque"
"BuiltInMaterialType" = "Unlit"
"Queue"="Geometry"
// DisableBatching: <None>
"ShaderGraphShader"="true"
"ShaderGraphTargetId"="BuiltInUnlitSubTarget"
}
Pass
{
    Name "Pass"
    Tags
    {
        "LightMode" = "ForwardBase"
    }

// Render State
Cull Off
Blend One Zero
ZTest LEqual
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 3.0
// patched: multi_compile_instancing removed. A skybox is always drawn as a single full-screen
// dome (never GPU-instanced), so this variant serves no purpose here, and compiling the
// UNITY_ANY_INSTANCING_ENABLED + UNITY_STEREO_INSTANCING_ENABLED combination is exactly where
// the Unity 2022.3 Built-in RP/Shader Graph GLOBAL_CBUFFER_START compiler bug under VR lives.
#pragma multi_compile_fog
#pragma multi_compile LIGHTMAP_ON __ // patched: multi_compile_fwdbase's LIGHTPROBE_SH+SHADOWS_SCREEN+stereo combo hits the same compiler bug; those keywords are never referenced in this shader's code so only LIGHTMAP_ON is kept
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define VARYINGS_NEED_POSITION_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_UNLIT
#define BUILTIN_TARGET_API 1
#ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
#define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
#endif
#ifdef _BUILTIN_ALPHATEST_ON
#define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
#endif
#ifdef _BUILTIN_AlphaClip
#define _AlphaClip _BUILTIN_AlphaClip
#endif
#ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
#define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
#endif


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
// patched: Shims.hlsl (below) itself includes Common.hlsl (which redefines GLOBAL_CBUFFER_START
// to a 2-argument SRP ray-tracing form) and then UnityShaderVariables.cginc (which still calls
// the classic single-argument form) BACK TO BACK internally - so patching *after* Shims.hlsl is
// too late, the damage and the crash happen inside it. Pre-include Common.hlsl ourselves so its
// include guard is already set, restore the single-argument macro, then let Shims.hlsl's own
// "#include Common.hlsl" become a no-op (guarded) while its UnityShaderVariables.cginc include
// sees our correct definition.
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#undef GLOBAL_CBUFFER_START
#undef GLOBAL_CBUFFER_END
#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) || ((defined(UNITY_SINGLE_PASS_STEREO) || defined(UNITY_STEREO_INSTANCING_ENABLED)) && (defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL)))
    #define GLOBAL_CBUFFER_START(name)    cbuffer name {
    #define GLOBAL_CBUFFER_END            }
#else
    #define GLOBAL_CBUFFER_START(name)    CBUFFER_START(name)
    #define GLOBAL_CBUFFER_END            CBUFFER_END
#endif
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
// patched: Core.hlsl (below) pulls in ShaderVariablesFunctions.hlsl, which - when
// UNITY_SINGLE_PASS_STEREO is defined (true for any XR-capable build target) - redeclares
// TransformStereoScreenSpaceTex() as a real function. Shims.hlsl already pulled in Unity's own
// UnityCG.cginc above, which declares a byte-identical function of the same name under the same
// condition, so this is a flat redefinition error. This skybox never calls either function (it's
// boilerplate from the Shader Graph target template, not skybox-specific code), so it's safe to
// briefly hide UNITY_SINGLE_PASS_STEREO from just this one include: ShaderVariablesFunctions.hlsl
// then takes its non-stereo branch and skips its copy, while everything else it defines is still
// included normally.
#if defined(UNITY_SINGLE_PASS_STEREO)
    #undef UNITY_SINGLE_PASS_STEREO
    #define RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL
#endif
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
#if defined(RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL)
    #undef RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL
    #define UNITY_SINGLE_PASS_STEREO
#endif
// patched: com.unity.render-pipelines.core's Common.hlsl (pulled in by the Core.hlsl include
// above) redefines GLOBAL_CBUFFER_START to take a (name, register) pair for SRP ray tracing.
// Unity's own Built-in UnityShaderVariables.cginc - included transitively below via
// Lighting.hlsl - still calls the classic single-argument GLOBAL_CBUFFER_START(UnityStereoGlobals),
// which is exactly the "too few arguments to a macro call" compile error. Restore the original
// single-argument Built-in RP definition before anything else needs it.
#undef GLOBAL_CBUFFER_START
#undef GLOBAL_CBUFFER_END
#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) || ((defined(UNITY_SINGLE_PASS_STEREO) || defined(UNITY_STEREO_INSTANCING_ENABLED)) && (defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL)))
    #define GLOBAL_CBUFFER_START(name)    cbuffer name {
    #define GLOBAL_CBUFFER_END            }
#else
    #define GLOBAL_CBUFFER_START(name)    CBUFFER_START(name)
    #define GLOBAL_CBUFFER_END            CBUFFER_END
#endif
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceViewDirection;
 float3 ObjectSpacePosition;
 float3 TimeParameters;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.positionWS.xyz = input.positionWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.positionWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Use_Texture_Stars;
float _Ground_Height;
float4 _GroundColor;
float _GroundEnabled;
float _Shading_Intensity;
float _SkyColorBlend;
float4 _HorizonColorDay;
float4 _HorizonColorNight;
float _CloudSharpness;
float _Cloud_Iterations;
float _Cloud_Gain;
float _Cloud_Lacunarity;
float4 _SkyColorNight;
float _HorizonSaturationFalloff;
float _HorizonSaturationAmount;
float4 _SunColorZenith;
float4 _SunColorHorizon;
float _SunFalloffIntensity;
float _SunFalloff;
float _SunsetHorizontalFalloff;
float _SunsetVerticalFalloff;
float _SunsetRadialFalloff;
float _SunsetIntensity;
float4 _CloudTexture_TexelSize;
float2 _CloudWindSpeed;
float _Cloudiness;
float _CloudOpacity;
float _CloudFalloff;
float2 _CloudScale;
float4 _CloudColorDay;
float4 _CloudColorNight;
float4 _StarTexture_TexelSize;
float _StarHorizonFalloff;
float _StarScale;
float _StarSpeed;
float _StarIntensity;
float _StarDaytimeBrightness;
float _MoonAngularDiameter;
float _MoonFalloff;
float4 _MoonColor;
float _SunAngularDiameter;
float _GroundFadeAmount;
float _ProceduralStarsEnabled;
float _StarSaturation;
float _SunSkyLightingEnabled;
float4 _SkyColorDay;
float _Moon_Enabled;
float _Clouds_Enabled;
float _Stars_Enabled;
float _Sun_Enabled;
float _Constant_Color_Mode;
float _StarSharpness;
float _StarFrequency;
float4 _Star_Texture_Tint;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_CloudTexture);
SAMPLER(sampler_CloudTexture);
TEXTURE2D(_StarTexture);
SAMPLER(sampler_StarTexture);

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Includes
#include "Packages/com.occasoftware.super-simple-skybox/Shaders/HLSL/SuperSimpleSkyboxHLSL.hlsl"

// Graph Functions

struct Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float
{
};

void SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float IN, out float3 SunDirection_0, out float3 MoonDirection_1)
{
float3 _GetSkyboxLightsCustomFunction_b15f275c6eb441fdb43ee1dc42c6d0a4_SunDirection_0_Vector3;
float3 _GetSkyboxLightsCustomFunction_b15f275c6eb441fdb43ee1dc42c6d0a4_MoonDirection_1_Vector3;
GetSkyboxLights_float(_GetSkyboxLightsCustomFunction_b15f275c6eb441fdb43ee1dc42c6d0a4_SunDirection_0_Vector3, _GetSkyboxLightsCustomFunction_b15f275c6eb441fdb43ee1dc42c6d0a4_MoonDirection_1_Vector3);
SunDirection_0 = _GetSkyboxLightsCustomFunction_b15f275c6eb441fdb43ee1dc42c6d0a4_SunDirection_0_Vector3;
MoonDirection_1 = _GetSkyboxLightsCustomFunction_b15f275c6eb441fdb43ee1dc42c6d0a4_MoonDirection_1_Vector3;
}

void Unity_Negate_float3(float3 In, out float3 Out)
{
    Out = -1 * In;
}

void Unity_Normalize_float3(float3 In, out float3 Out)
{
    Out = normalize(In);
}

void Unity_Distance_float3(float3 A, float3 B, out float Out)
{
    Out = distance(A, B);
}

void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Arccosine_float(float In, out float Out)
{
    Out = acos(In);
}

void Unity_RadiansToDegrees_float(float In, out float Out)
{
    Out = degrees(In);
}

struct Bindings_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float
{
float3 WorldSpaceViewDirection;
};

void SG_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float(float3 _LightDirection, Bindings_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float IN, out float Out_1, out float Theta_2)
{
float3 _Negate_01ad90d79c09401ba6bf32d8e65c5996_Out_1_Vector3;
Unity_Negate_float3(IN.WorldSpaceViewDirection, _Negate_01ad90d79c09401ba6bf32d8e65c5996_Out_1_Vector3);
float3 _Normalize_2380ff12f1f84520820a632f6271c02e_Out_1_Vector3;
Unity_Normalize_float3(_Negate_01ad90d79c09401ba6bf32d8e65c5996_Out_1_Vector3, _Normalize_2380ff12f1f84520820a632f6271c02e_Out_1_Vector3);
float3 _Property_c51291aa84bd4d8f9d9bcaf1fd06defe_Out_0_Vector3 = _LightDirection;
float3 _Normalize_c4327a50f4b5458b92bc1bc213b9391c_Out_1_Vector3;
Unity_Normalize_float3(_Property_c51291aa84bd4d8f9d9bcaf1fd06defe_Out_0_Vector3, _Normalize_c4327a50f4b5458b92bc1bc213b9391c_Out_1_Vector3);
float _Distance_9756b9e474e146ab81e9ba71938e7d2b_Out_2_Float;
Unity_Distance_float3(_Normalize_2380ff12f1f84520820a632f6271c02e_Out_1_Vector3, _Normalize_c4327a50f4b5458b92bc1bc213b9391c_Out_1_Vector3, _Distance_9756b9e474e146ab81e9ba71938e7d2b_Out_2_Float);
float _Remap_83d857c433a9446abcb60930bea82966_Out_3_Float;
Unity_Remap_float(_Distance_9756b9e474e146ab81e9ba71938e7d2b_Out_2_Float, float2 (0, 2), float2 (0, 1), _Remap_83d857c433a9446abcb60930bea82966_Out_3_Float);
float _Saturate_ef228b34c998419284e98e73d9e1f936_Out_1_Float;
Unity_Saturate_float(_Remap_83d857c433a9446abcb60930bea82966_Out_3_Float, _Saturate_ef228b34c998419284e98e73d9e1f936_Out_1_Float);
float _DotProduct_a2cdc38c0c1c4c1a96227c4f8792db48_Out_2_Float;
Unity_DotProduct_float3(_Normalize_2380ff12f1f84520820a632f6271c02e_Out_1_Vector3, _Normalize_c4327a50f4b5458b92bc1bc213b9391c_Out_1_Vector3, _DotProduct_a2cdc38c0c1c4c1a96227c4f8792db48_Out_2_Float);
float _Arccosine_e880deb01a1f48a78d03c2d4adb3b685_Out_1_Float;
Unity_Arccosine_float(_DotProduct_a2cdc38c0c1c4c1a96227c4f8792db48_Out_2_Float, _Arccosine_e880deb01a1f48a78d03c2d4adb3b685_Out_1_Float);
float _RadiansToDegrees_b754e23e2ee24caeae845d381111dedf_Out_1_Float;
Unity_RadiansToDegrees_float(_Arccosine_e880deb01a1f48a78d03c2d4adb3b685_Out_1_Float, _RadiansToDegrees_b754e23e2ee24caeae845d381111dedf_Out_1_Float);
Out_1 = _Saturate_ef228b34c998419284e98e73d9e1f936_Out_1_Float;
Theta_2 = _RadiansToDegrees_b754e23e2ee24caeae845d381111dedf_Out_1_Float;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_SquareRoot_float(float In, out float Out)
{
    Out = sqrt(In);
}

void Unity_Power_float3(float3 A, float3 B, out float3 Out)
{
    Out = pow(A, B);
}

struct Bindings_LimbDarkening_92a0c29eaa0a30a41b6117a972eab2eb_float
{
};

void SG_LimbDarkening_92a0c29eaa0a30a41b6117a972eab2eb_float(float Vector1_b816fcc5a1374da190cf819d66b1fe51, Bindings_LimbDarkening_92a0c29eaa0a30a41b6117a972eab2eb_float IN, out float3 LimbDarkeningFactor_1)
{
float _Property_4007f0032af94bbfb48449358f577830_Out_0_Float = Vector1_b816fcc5a1374da190cf819d66b1fe51;
float _Multiply_d5f5e92d0ff24b91a9c039d58d90fc8a_Out_2_Float;
Unity_Multiply_float_float(_Property_4007f0032af94bbfb48449358f577830_Out_0_Float, _Property_4007f0032af94bbfb48449358f577830_Out_0_Float, _Multiply_d5f5e92d0ff24b91a9c039d58d90fc8a_Out_2_Float);
float _OneMinus_77598b036b5c497399f5b10a224a880e_Out_1_Float;
Unity_OneMinus_float(_Multiply_d5f5e92d0ff24b91a9c039d58d90fc8a_Out_2_Float, _OneMinus_77598b036b5c497399f5b10a224a880e_Out_1_Float);
float _SquareRoot_c62b5df89a9b40cb96212d62398ce339_Out_1_Float;
Unity_SquareRoot_float(_OneMinus_77598b036b5c497399f5b10a224a880e_Out_1_Float, _SquareRoot_c62b5df89a9b40cb96212d62398ce339_Out_1_Float);
float3 _Vector3_fca47881679f45a480000f1fb04d9369_Out_0_Vector3 = float3(0.397, 0.503, 0.652);
float3 _Power_c59760235ab543dab33993e21a5c9ea6_Out_2_Vector3;
Unity_Power_float3((_SquareRoot_c62b5df89a9b40cb96212d62398ce339_Out_1_Float.xxx), _Vector3_fca47881679f45a480000f1fb04d9369_Out_0_Vector3, _Power_c59760235ab543dab33993e21a5c9ea6_Out_2_Vector3);
LimbDarkeningFactor_1 = _Power_c59760235ab543dab33993e21a5c9ea6_Out_2_Vector3;
}

void Unity_Subtract_float(float A, float B, out float Out)
{
    Out = A - B;
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
Out = A * B;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
{
    Out = Predicate ? True : False;
}

void Unity_Branch_float(float Predicate, float True, float False, out float Out)
{
    Out = Predicate ? True : False;
}

void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

void Unity_Maximum_float(float A, float B, out float Out)
{
    Out = max(A, B);
}

void Unity_Power_float(float A, float B, out float Out)
{
    Out = pow(A, B);
}

void Unity_Arctangent2_float(float A, float B, out float Out)
{
    Out = atan2(A, B);
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Arcsine_float(float In, out float Out)
{
    Out = asin(In);
}

void Unity_Negate_float(float In, out float Out)
{
    Out = -1 * In;
}

struct Bindings_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float
{
float3 ObjectSpacePosition;
};

void SG_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float(Bindings_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float IN, out float2 UV_0)
{
float3 _Normalize_114e286bfc8e43149823821933350066_Out_1_Vector3;
Unity_Normalize_float3(IN.ObjectSpacePosition, _Normalize_114e286bfc8e43149823821933350066_Out_1_Vector3);
float _Split_e6aa136affe2465b9fa8e10e8f4ca136_R_1_Float = _Normalize_114e286bfc8e43149823821933350066_Out_1_Vector3[0];
float _Split_e6aa136affe2465b9fa8e10e8f4ca136_G_2_Float = _Normalize_114e286bfc8e43149823821933350066_Out_1_Vector3[1];
float _Split_e6aa136affe2465b9fa8e10e8f4ca136_B_3_Float = _Normalize_114e286bfc8e43149823821933350066_Out_1_Vector3[2];
float _Split_e6aa136affe2465b9fa8e10e8f4ca136_A_4_Float = 0;
float _Arctangent2_f64ade67015b499a929dfa4ec07cafcd_Out_2_Float;
Unity_Arctangent2_float(_Split_e6aa136affe2465b9fa8e10e8f4ca136_R_1_Float, _Split_e6aa136affe2465b9fa8e10e8f4ca136_B_3_Float, _Arctangent2_f64ade67015b499a929dfa4ec07cafcd_Out_2_Float);
float Constant_d14ed0c11ce8416b940adc8c9cb34cab = 6.283185;
float _Divide_295e87a0235547c2b915f0c2dfac0ed2_Out_2_Float;
Unity_Divide_float(_Arctangent2_f64ade67015b499a929dfa4ec07cafcd_Out_2_Float, Constant_d14ed0c11ce8416b940adc8c9cb34cab, _Divide_295e87a0235547c2b915f0c2dfac0ed2_Out_2_Float);
float3 _Normalize_79762ba3850d4e7ba5ec5d2d657d9a1b_Out_1_Vector3;
Unity_Normalize_float3(IN.ObjectSpacePosition, _Normalize_79762ba3850d4e7ba5ec5d2d657d9a1b_Out_1_Vector3);
float _Split_1f9a59d49698440097b3dbdf71bf8d40_R_1_Float = _Normalize_79762ba3850d4e7ba5ec5d2d657d9a1b_Out_1_Vector3[0];
float _Split_1f9a59d49698440097b3dbdf71bf8d40_G_2_Float = _Normalize_79762ba3850d4e7ba5ec5d2d657d9a1b_Out_1_Vector3[1];
float _Split_1f9a59d49698440097b3dbdf71bf8d40_B_3_Float = _Normalize_79762ba3850d4e7ba5ec5d2d657d9a1b_Out_1_Vector3[2];
float _Split_1f9a59d49698440097b3dbdf71bf8d40_A_4_Float = 0;
float _Arcsine_11832fe2b2b642229077454e8717d31f_Out_1_Float;
Unity_Arcsine_float(_Split_1f9a59d49698440097b3dbdf71bf8d40_G_2_Float, _Arcsine_11832fe2b2b642229077454e8717d31f_Out_1_Float);
float Constant_91f7ce0eb5134c629ec545040800424f = 3.141593;
float _Divide_749f8d715faf4c208eead3476414cb9d_Out_2_Float;
Unity_Divide_float(Constant_91f7ce0eb5134c629ec545040800424f, 2, _Divide_749f8d715faf4c208eead3476414cb9d_Out_2_Float);
float _Divide_907b15799dab4c78b671aa029448616b_Out_2_Float;
Unity_Divide_float(_Arcsine_11832fe2b2b642229077454e8717d31f_Out_1_Float, _Divide_749f8d715faf4c208eead3476414cb9d_Out_2_Float, _Divide_907b15799dab4c78b671aa029448616b_Out_2_Float);
float _Negate_0c531da746b94daba88b3dc15752b668_Out_1_Float;
Unity_Negate_float(_Divide_907b15799dab4c78b671aa029448616b_Out_2_Float, _Negate_0c531da746b94daba88b3dc15752b668_Out_1_Float);
float2 _Vector2_c6ef7fc715c34d4aa975b14d11eaaf36_Out_0_Vector2 = float2(_Divide_295e87a0235547c2b915f0c2dfac0ed2_Out_2_Float, _Negate_0c531da746b94daba88b3dc15752b668_Out_1_Float);
UV_0 = _Vector2_c6ef7fc715c34d4aa975b14d11eaaf36_Out_0_Vector2;
}

void Unity_Absolute_float(float In, out float Out)
{
    Out = abs(In);
}

void Unity_Preview_float(float In, out float Out)
{
    Out = In;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
{
    Out = Predicate ? True : False;
}

struct Bindings_SuperSimpleSun_a3132549029d16442b5fad27df2d1dfb_float
{
float3 WorldSpaceViewDirection;
float3 ObjectSpacePosition;
};

void SG_SuperSimpleSun_a3132549029d16442b5fad27df2d1dfb_float(float Vector1_5353185de25243e7bde600853d6cf0cb, float _Sun_Falloff_Intensity, float4 Vector4_2ec07c7af7514a75af07abef41e662b9, float4 Vector4_1f5f5779392d443aa605dd38004aeddd, float Vector1_f508ceae5b42447687ccd034e820f082, float Vector1_fcce2917e51043ca953b954c6200d44b, float Vector1_c50888b9a20c4b1f9fc459e8870c4c50, float Vector1_32666bfe6b374f95b3c76269aced7f96, float _Sun_Sky_Lighting, float _Sun_Angular_Diameter, float _Enabled, Bindings_SuperSimpleSun_a3132549029d16442b5fad27df2d1dfb_float IN, out float3 SunDiscColor_1, out float SunDiscAlpha_2, out float3 Falloff_3)
{
float _Property_190e0096579c48828b2fb768a9f394bc_Out_0_Boolean = _Enabled;
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_3e4a9f96b6e64530b4e9f7840d0e75d2;
float3 _GetLights_3e4a9f96b6e64530b4e9f7840d0e75d2_SunDirection_0_Vector3;
float3 _GetLights_3e4a9f96b6e64530b4e9f7840d0e75d2_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_3e4a9f96b6e64530b4e9f7840d0e75d2, _GetLights_3e4a9f96b6e64530b4e9f7840d0e75d2_SunDirection_0_Vector3, _GetLights_3e4a9f96b6e64530b4e9f7840d0e75d2_MoonDirection_1_Vector3);
Bindings_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float _GetSkyboxLightDistance_ff87eacd36c142c5afbfb6f0e9866204;
_GetSkyboxLightDistance_ff87eacd36c142c5afbfb6f0e9866204.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
float _GetSkyboxLightDistance_ff87eacd36c142c5afbfb6f0e9866204_Out_1_Float;
float _GetSkyboxLightDistance_ff87eacd36c142c5afbfb6f0e9866204_Theta_2_Float;
SG_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float(_GetLights_3e4a9f96b6e64530b4e9f7840d0e75d2_SunDirection_0_Vector3, _GetSkyboxLightDistance_ff87eacd36c142c5afbfb6f0e9866204, _GetSkyboxLightDistance_ff87eacd36c142c5afbfb6f0e9866204_Out_1_Float, _GetSkyboxLightDistance_ff87eacd36c142c5afbfb6f0e9866204_Theta_2_Float);
float _Property_57d4ebab9b1141a4a7fca5fb5b995414_Out_0_Float = _Sun_Angular_Diameter;
float _Multiply_c12b61ddedd54dd591c535db00d1ddc6_Out_2_Float;
Unity_Multiply_float_float(_Property_57d4ebab9b1141a4a7fca5fb5b995414_Out_0_Float, 0.5, _Multiply_c12b61ddedd54dd591c535db00d1ddc6_Out_2_Float);
float2 _Vector2_9a745157deea4ec2b587216d0aef7e55_Out_0_Vector2 = float2(0, _Multiply_c12b61ddedd54dd591c535db00d1ddc6_Out_2_Float);
float _Remap_e22ba0f0da494dbe84d13b642e2282e9_Out_3_Float;
Unity_Remap_float(_GetSkyboxLightDistance_ff87eacd36c142c5afbfb6f0e9866204_Theta_2_Float, _Vector2_9a745157deea4ec2b587216d0aef7e55_Out_0_Vector2, float2 (0, 1), _Remap_e22ba0f0da494dbe84d13b642e2282e9_Out_3_Float);
float _Saturate_a4d2c6d3544c47cd969049885d49a4b2_Out_1_Float;
Unity_Saturate_float(_Remap_e22ba0f0da494dbe84d13b642e2282e9_Out_3_Float, _Saturate_a4d2c6d3544c47cd969049885d49a4b2_Out_1_Float);
Bindings_LimbDarkening_92a0c29eaa0a30a41b6117a972eab2eb_float _LimbDarkening_a44207797bff4a8bb36e4a9ec84f8638;
float3 _LimbDarkening_a44207797bff4a8bb36e4a9ec84f8638_LimbDarkeningFactor_1_Vector3;
SG_LimbDarkening_92a0c29eaa0a30a41b6117a972eab2eb_float(_Saturate_a4d2c6d3544c47cd969049885d49a4b2_Out_1_Float, _LimbDarkening_a44207797bff4a8bb36e4a9ec84f8638, _LimbDarkening_a44207797bff4a8bb36e4a9ec84f8638_LimbDarkeningFactor_1_Vector3);
float _Subtract_606db144ed6a4c918086c4013912a7d0_Out_2_Float;
Unity_Subtract_float(_Multiply_c12b61ddedd54dd591c535db00d1ddc6_Out_2_Float, 0.1, _Subtract_606db144ed6a4c918086c4013912a7d0_Out_2_Float);
float _Smoothstep_300429cb31be4464a13fcf2125e8b4c2_Out_3_Float;
Unity_Smoothstep_float(_Subtract_606db144ed6a4c918086c4013912a7d0_Out_2_Float, _Multiply_c12b61ddedd54dd591c535db00d1ddc6_Out_2_Float, _GetSkyboxLightDistance_ff87eacd36c142c5afbfb6f0e9866204_Theta_2_Float, _Smoothstep_300429cb31be4464a13fcf2125e8b4c2_Out_3_Float);
float _OneMinus_b9581ea44fae47ff9980c2e3881c790a_Out_1_Float;
Unity_OneMinus_float(_Smoothstep_300429cb31be4464a13fcf2125e8b4c2_Out_3_Float, _OneMinus_b9581ea44fae47ff9980c2e3881c790a_Out_1_Float);
float3 _Multiply_73b91560faee4793bcb9e668f4c5a43e_Out_2_Vector3;
Unity_Multiply_float3_float3(_LimbDarkening_a44207797bff4a8bb36e4a9ec84f8638_LimbDarkeningFactor_1_Vector3, (_OneMinus_b9581ea44fae47ff9980c2e3881c790a_Out_1_Float.xxx), _Multiply_73b91560faee4793bcb9e668f4c5a43e_Out_2_Vector3);
float4 _Property_55b1bced183947f9b70fb9d00df24061_Out_0_Vector4 = Vector4_2ec07c7af7514a75af07abef41e662b9;
float4 _Property_ba58288c4f3a484b9a609fb7a7884f43_Out_0_Vector4 = Vector4_1f5f5779392d443aa605dd38004aeddd;
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_6a9fba68c6954b89892f6f9897508181;
float3 _GetLights_6a9fba68c6954b89892f6f9897508181_SunDirection_0_Vector3;
float3 _GetLights_6a9fba68c6954b89892f6f9897508181_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_6a9fba68c6954b89892f6f9897508181, _GetLights_6a9fba68c6954b89892f6f9897508181_SunDirection_0_Vector3, _GetLights_6a9fba68c6954b89892f6f9897508181_MoonDirection_1_Vector3);
float _Split_bc3c5ca8d6694a3db3c589dab090f8d8_R_1_Float = _GetLights_6a9fba68c6954b89892f6f9897508181_SunDirection_0_Vector3[0];
float _Split_bc3c5ca8d6694a3db3c589dab090f8d8_G_2_Float = _GetLights_6a9fba68c6954b89892f6f9897508181_SunDirection_0_Vector3[1];
float _Split_bc3c5ca8d6694a3db3c589dab090f8d8_B_3_Float = _GetLights_6a9fba68c6954b89892f6f9897508181_SunDirection_0_Vector3[2];
float _Split_bc3c5ca8d6694a3db3c589dab090f8d8_A_4_Float = 0;
float _Smoothstep_befe8d63cdf34643874c943b8604953e_Out_3_Float;
Unity_Smoothstep_float(0.1, 0.3, _Split_bc3c5ca8d6694a3db3c589dab090f8d8_G_2_Float, _Smoothstep_befe8d63cdf34643874c943b8604953e_Out_3_Float);
float4 _Lerp_d87a2b1b69e8448f9d188a168d29394d_Out_3_Vector4;
Unity_Lerp_float4(_Property_55b1bced183947f9b70fb9d00df24061_Out_0_Vector4, _Property_ba58288c4f3a484b9a609fb7a7884f43_Out_0_Vector4, (_Smoothstep_befe8d63cdf34643874c943b8604953e_Out_3_Float.xxxx), _Lerp_d87a2b1b69e8448f9d188a168d29394d_Out_3_Vector4);
float3 _Multiply_dc1f8989f7c1446c9db088a38224a06c_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_73b91560faee4793bcb9e668f4c5a43e_Out_2_Vector3, (_Lerp_d87a2b1b69e8448f9d188a168d29394d_Out_3_Vector4.xyz), _Multiply_dc1f8989f7c1446c9db088a38224a06c_Out_2_Vector3);
float3 _Branch_e409eeead86e42f28d3ed4d560e14025_Out_3_Vector3;
Unity_Branch_float3(_Property_190e0096579c48828b2fb768a9f394bc_Out_0_Boolean, _Multiply_dc1f8989f7c1446c9db088a38224a06c_Out_2_Vector3, float3(0, 0, 0), _Branch_e409eeead86e42f28d3ed4d560e14025_Out_3_Vector3);
float _Property_8b45dc44de2d4ff4a053bb868b427e85_Out_0_Boolean = _Enabled;
float _Branch_8b4249e71060427ba41961dd66f46e0e_Out_3_Float;
Unity_Branch_float(_Property_8b45dc44de2d4ff4a053bb868b427e85_Out_0_Boolean, _OneMinus_b9581ea44fae47ff9980c2e3881c790a_Out_1_Float, 0, _Branch_8b4249e71060427ba41961dd66f46e0e_Out_3_Float);
float _Property_db6fcd7c223741cda92fcf8e03958281_Out_0_Boolean = _Enabled;
float _Property_c8e4c44c0435453ab979ed32cce1841e_Out_0_Boolean = _Sun_Sky_Lighting;
float _Float_d5aa0b796eb24c08a0a62cfa78a10ce5_Out_0_Float = 0.05;
float4 _Multiply_d1c9f9cadf5745eaa185a87463cd0b62_Out_2_Vector4;
Unity_Multiply_float4_float4(_Lerp_d87a2b1b69e8448f9d188a168d29394d_Out_3_Vector4, (_Float_d5aa0b796eb24c08a0a62cfa78a10ce5_Out_0_Float.xxxx), _Multiply_d1c9f9cadf5745eaa185a87463cd0b62_Out_2_Vector4);
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_ab2281a5e39446639c9695d9f7686ae9;
float3 _GetLights_ab2281a5e39446639c9695d9f7686ae9_SunDirection_0_Vector3;
float3 _GetLights_ab2281a5e39446639c9695d9f7686ae9_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_ab2281a5e39446639c9695d9f7686ae9, _GetLights_ab2281a5e39446639c9695d9f7686ae9_SunDirection_0_Vector3, _GetLights_ab2281a5e39446639c9695d9f7686ae9_MoonDirection_1_Vector3);
Bindings_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float _GetSkyboxLightDistance_f7be5cf3c3df495cb7073286e2d28e7b;
_GetSkyboxLightDistance_f7be5cf3c3df495cb7073286e2d28e7b.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
float _GetSkyboxLightDistance_f7be5cf3c3df495cb7073286e2d28e7b_Out_1_Float;
float _GetSkyboxLightDistance_f7be5cf3c3df495cb7073286e2d28e7b_Theta_2_Float;
SG_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float(_GetLights_ab2281a5e39446639c9695d9f7686ae9_SunDirection_0_Vector3, _GetSkyboxLightDistance_f7be5cf3c3df495cb7073286e2d28e7b, _GetSkyboxLightDistance_f7be5cf3c3df495cb7073286e2d28e7b_Out_1_Float, _GetSkyboxLightDistance_f7be5cf3c3df495cb7073286e2d28e7b_Theta_2_Float);
float _OneMinus_29574bd7020243b0a62202debc78185a_Out_1_Float;
Unity_OneMinus_float(_GetSkyboxLightDistance_f7be5cf3c3df495cb7073286e2d28e7b_Out_1_Float, _OneMinus_29574bd7020243b0a62202debc78185a_Out_1_Float);
float _Property_8c00ebc3d5a848458bd732497fc0d516_Out_0_Float = Vector1_5353185de25243e7bde600853d6cf0cb;
float _Maximum_35aeefa5a91b48dea0f6953ca2a6b505_Out_2_Float;
Unity_Maximum_float(_Property_8c00ebc3d5a848458bd732497fc0d516_Out_0_Float, 0.001, _Maximum_35aeefa5a91b48dea0f6953ca2a6b505_Out_2_Float);
float _Power_8e524a9e63d34ddebe5bc28013651c0a_Out_2_Float;
Unity_Power_float(_OneMinus_29574bd7020243b0a62202debc78185a_Out_1_Float, _Maximum_35aeefa5a91b48dea0f6953ca2a6b505_Out_2_Float, _Power_8e524a9e63d34ddebe5bc28013651c0a_Out_2_Float);
float4 _Multiply_86aaa2b86f224c32b8f7063126f5b365_Out_2_Vector4;
Unity_Multiply_float4_float4(_Multiply_d1c9f9cadf5745eaa185a87463cd0b62_Out_2_Vector4, (_Power_8e524a9e63d34ddebe5bc28013651c0a_Out_2_Float.xxxx), _Multiply_86aaa2b86f224c32b8f7063126f5b365_Out_2_Vector4);
float4 _Property_a0ed6fe7c33c40869a96220cb09a3ed4_Out_0_Vector4 = Vector4_2ec07c7af7514a75af07abef41e662b9;
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_0b184f9252c2424fa00f0ea328b19167;
float3 _GetLights_0b184f9252c2424fa00f0ea328b19167_SunDirection_0_Vector3;
float3 _GetLights_0b184f9252c2424fa00f0ea328b19167_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_0b184f9252c2424fa00f0ea328b19167, _GetLights_0b184f9252c2424fa00f0ea328b19167_SunDirection_0_Vector3, _GetLights_0b184f9252c2424fa00f0ea328b19167_MoonDirection_1_Vector3);
Bindings_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float _GetSkyboxLightDistance_1aa1e79212a94a4cb3622248c56a6119;
_GetSkyboxLightDistance_1aa1e79212a94a4cb3622248c56a6119.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
float _GetSkyboxLightDistance_1aa1e79212a94a4cb3622248c56a6119_Out_1_Float;
float _GetSkyboxLightDistance_1aa1e79212a94a4cb3622248c56a6119_Theta_2_Float;
SG_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float(_GetLights_0b184f9252c2424fa00f0ea328b19167_SunDirection_0_Vector3, _GetSkyboxLightDistance_1aa1e79212a94a4cb3622248c56a6119, _GetSkyboxLightDistance_1aa1e79212a94a4cb3622248c56a6119_Out_1_Float, _GetSkyboxLightDistance_1aa1e79212a94a4cb3622248c56a6119_Theta_2_Float);
float _Property_8700fc19a4194f49a7a885e755be7829_Out_0_Float = Vector1_32666bfe6b374f95b3c76269aced7f96;
float _Power_ce5f6aca69ad40b3bb0237fe7f130868_Out_2_Float;
Unity_Power_float(_GetSkyboxLightDistance_1aa1e79212a94a4cb3622248c56a6119_Out_1_Float, _Property_8700fc19a4194f49a7a885e755be7829_Out_0_Float, _Power_ce5f6aca69ad40b3bb0237fe7f130868_Out_2_Float);
float _OneMinus_bc0074d604bd4e02b887ff84e72603ca_Out_1_Float;
Unity_OneMinus_float(_Power_ce5f6aca69ad40b3bb0237fe7f130868_Out_2_Float, _OneMinus_bc0074d604bd4e02b887ff84e72603ca_Out_1_Float);
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_ad1686ade9cb4fe18e754cddc89e2b23;
float3 _GetLights_ad1686ade9cb4fe18e754cddc89e2b23_SunDirection_0_Vector3;
float3 _GetLights_ad1686ade9cb4fe18e754cddc89e2b23_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_ad1686ade9cb4fe18e754cddc89e2b23, _GetLights_ad1686ade9cb4fe18e754cddc89e2b23_SunDirection_0_Vector3, _GetLights_ad1686ade9cb4fe18e754cddc89e2b23_MoonDirection_1_Vector3);
float _Split_b45a7190228e43829180135aff64c2ae_R_1_Float = _GetLights_ad1686ade9cb4fe18e754cddc89e2b23_SunDirection_0_Vector3[0];
float _Split_b45a7190228e43829180135aff64c2ae_G_2_Float = _GetLights_ad1686ade9cb4fe18e754cddc89e2b23_SunDirection_0_Vector3[1];
float _Split_b45a7190228e43829180135aff64c2ae_B_3_Float = _GetLights_ad1686ade9cb4fe18e754cddc89e2b23_SunDirection_0_Vector3[2];
float _Split_b45a7190228e43829180135aff64c2ae_A_4_Float = 0;
float _Smoothstep_70a04ea9593c4106bd1ea3ccffea282c_Out_3_Float;
Unity_Smoothstep_float(0.5, 0, _Split_b45a7190228e43829180135aff64c2ae_G_2_Float, _Smoothstep_70a04ea9593c4106bd1ea3ccffea282c_Out_3_Float);
float _Smoothstep_13a729ce3b2d42ba92ff4fe7267f228c_Out_3_Float;
Unity_Smoothstep_float(-0.2, 0, _Split_b45a7190228e43829180135aff64c2ae_G_2_Float, _Smoothstep_13a729ce3b2d42ba92ff4fe7267f228c_Out_3_Float);
float _Multiply_11f82775b75d4c45a4c9ed0c0ee4697f_Out_2_Float;
Unity_Multiply_float_float(_Smoothstep_70a04ea9593c4106bd1ea3ccffea282c_Out_3_Float, _Smoothstep_13a729ce3b2d42ba92ff4fe7267f228c_Out_3_Float, _Multiply_11f82775b75d4c45a4c9ed0c0ee4697f_Out_2_Float);
float _Multiply_d963dd873e7d47d59059bc97ef005e4e_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_bc0074d604bd4e02b887ff84e72603ca_Out_1_Float, _Multiply_11f82775b75d4c45a4c9ed0c0ee4697f_Out_2_Float, _Multiply_d963dd873e7d47d59059bc97ef005e4e_Out_2_Float);
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_699f2c1dda1d41e6a2d8f235901529d4;
float3 _GetLights_699f2c1dda1d41e6a2d8f235901529d4_SunDirection_0_Vector3;
float3 _GetLights_699f2c1dda1d41e6a2d8f235901529d4_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_699f2c1dda1d41e6a2d8f235901529d4, _GetLights_699f2c1dda1d41e6a2d8f235901529d4_SunDirection_0_Vector3, _GetLights_699f2c1dda1d41e6a2d8f235901529d4_MoonDirection_1_Vector3);
Bindings_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float _GetSkyboxLightDistance_7e539ebcd48b49f9882bd1f86a8f6023;
_GetSkyboxLightDistance_7e539ebcd48b49f9882bd1f86a8f6023.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
float _GetSkyboxLightDistance_7e539ebcd48b49f9882bd1f86a8f6023_Out_1_Float;
float _GetSkyboxLightDistance_7e539ebcd48b49f9882bd1f86a8f6023_Theta_2_Float;
SG_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float(_GetLights_699f2c1dda1d41e6a2d8f235901529d4_SunDirection_0_Vector3, _GetSkyboxLightDistance_7e539ebcd48b49f9882bd1f86a8f6023, _GetSkyboxLightDistance_7e539ebcd48b49f9882bd1f86a8f6023_Out_1_Float, _GetSkyboxLightDistance_7e539ebcd48b49f9882bd1f86a8f6023_Theta_2_Float);
float _Property_adf121659efd4c8f8d23dd428cfba402_Out_0_Float = Vector1_f508ceae5b42447687ccd034e820f082;
float _Power_63513e5f0d4d46a787caab19da1a917d_Out_2_Float;
Unity_Power_float(_GetSkyboxLightDistance_7e539ebcd48b49f9882bd1f86a8f6023_Out_1_Float, _Property_adf121659efd4c8f8d23dd428cfba402_Out_0_Float, _Power_63513e5f0d4d46a787caab19da1a917d_Out_2_Float);
float _OneMinus_4344fff26ac244e481c18176a1e7de51_Out_1_Float;
Unity_OneMinus_float(_Power_63513e5f0d4d46a787caab19da1a917d_Out_2_Float, _OneMinus_4344fff26ac244e481c18176a1e7de51_Out_1_Float);
Bindings_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float _SkyboxUVMap_bb38c51837214e5e855bc3827f3e4372;
_SkyboxUVMap_bb38c51837214e5e855bc3827f3e4372.ObjectSpacePosition = IN.ObjectSpacePosition;
float2 _SkyboxUVMap_bb38c51837214e5e855bc3827f3e4372_UV_0_Vector2;
SG_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float(_SkyboxUVMap_bb38c51837214e5e855bc3827f3e4372, _SkyboxUVMap_bb38c51837214e5e855bc3827f3e4372_UV_0_Vector2);
float _Split_81df2897c43a4a078dff91d9d18805e2_R_1_Float = _SkyboxUVMap_bb38c51837214e5e855bc3827f3e4372_UV_0_Vector2[0];
float _Split_81df2897c43a4a078dff91d9d18805e2_G_2_Float = _SkyboxUVMap_bb38c51837214e5e855bc3827f3e4372_UV_0_Vector2[1];
float _Split_81df2897c43a4a078dff91d9d18805e2_B_3_Float = 0;
float _Split_81df2897c43a4a078dff91d9d18805e2_A_4_Float = 0;
float _Absolute_c5d1d1514578412e92808ae7e390aa60_Out_1_Float;
Unity_Absolute_float(_Split_81df2897c43a4a078dff91d9d18805e2_G_2_Float, _Absolute_c5d1d1514578412e92808ae7e390aa60_Out_1_Float);
float _Preview_1ef07ca75bb940b6a034df22b87017b2_Out_1_Float;
Unity_Preview_float(_Absolute_c5d1d1514578412e92808ae7e390aa60_Out_1_Float, _Preview_1ef07ca75bb940b6a034df22b87017b2_Out_1_Float);
float _Property_69c6269613784d1d85a866de426676d4_Out_0_Float = Vector1_fcce2917e51043ca953b954c6200d44b;
float _Power_ec095d6c26a84875b9a7148e8e183f31_Out_2_Float;
Unity_Power_float(_Preview_1ef07ca75bb940b6a034df22b87017b2_Out_1_Float, _Property_69c6269613784d1d85a866de426676d4_Out_0_Float, _Power_ec095d6c26a84875b9a7148e8e183f31_Out_2_Float);
float _OneMinus_814de93980964bd792af8e75d27c03e0_Out_1_Float;
Unity_OneMinus_float(_Power_ec095d6c26a84875b9a7148e8e183f31_Out_2_Float, _OneMinus_814de93980964bd792af8e75d27c03e0_Out_1_Float);
float _Smoothstep_84613f03027148d69ccfb73a42bdce4a_Out_3_Float;
Unity_Smoothstep_float(_Power_63513e5f0d4d46a787caab19da1a917d_Out_2_Float, 1, _OneMinus_814de93980964bd792af8e75d27c03e0_Out_1_Float, _Smoothstep_84613f03027148d69ccfb73a42bdce4a_Out_3_Float);
float _Multiply_d044e766db9f4d60a38e5638b1bf5d8f_Out_2_Float;
Unity_Multiply_float_float(_OneMinus_4344fff26ac244e481c18176a1e7de51_Out_1_Float, _Smoothstep_84613f03027148d69ccfb73a42bdce4a_Out_3_Float, _Multiply_d044e766db9f4d60a38e5638b1bf5d8f_Out_2_Float);
float _Saturate_dc4ab0f88f0d447d8f3193dbeb25811b_Out_1_Float;
Unity_Saturate_float(_Multiply_d044e766db9f4d60a38e5638b1bf5d8f_Out_2_Float, _Saturate_dc4ab0f88f0d447d8f3193dbeb25811b_Out_1_Float);
float _Multiply_e6b7c65469d746d19aed18514e1a5cb2_Out_2_Float;
Unity_Multiply_float_float(_Multiply_11f82775b75d4c45a4c9ed0c0ee4697f_Out_2_Float, _Saturate_dc4ab0f88f0d447d8f3193dbeb25811b_Out_1_Float, _Multiply_e6b7c65469d746d19aed18514e1a5cb2_Out_2_Float);
float _Add_b807fc8ac3204db696f652085dd9a03f_Out_2_Float;
Unity_Add_float(_Multiply_d963dd873e7d47d59059bc97ef005e4e_Out_2_Float, _Multiply_e6b7c65469d746d19aed18514e1a5cb2_Out_2_Float, _Add_b807fc8ac3204db696f652085dd9a03f_Out_2_Float);
float _Property_a4c1dd88e99741e9bbf0efcdd07f7349_Out_0_Float = Vector1_c50888b9a20c4b1f9fc459e8870c4c50;
float _Multiply_15ce2ca2bcbc4eaa94204e4accf50fc6_Out_2_Float;
Unity_Multiply_float_float(_Add_b807fc8ac3204db696f652085dd9a03f_Out_2_Float, _Property_a4c1dd88e99741e9bbf0efcdd07f7349_Out_0_Float, _Multiply_15ce2ca2bcbc4eaa94204e4accf50fc6_Out_2_Float);
float4 _Multiply_b81c76a4d2bc44f5aff4d3436c1c9af6_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_a0ed6fe7c33c40869a96220cb09a3ed4_Out_0_Vector4, (_Multiply_15ce2ca2bcbc4eaa94204e4accf50fc6_Out_2_Float.xxxx), _Multiply_b81c76a4d2bc44f5aff4d3436c1c9af6_Out_2_Vector4);
float4 _Add_4012fc6dca974479983d4205e9a59352_Out_2_Vector4;
Unity_Add_float4(_Multiply_86aaa2b86f224c32b8f7063126f5b365_Out_2_Vector4, _Multiply_b81c76a4d2bc44f5aff4d3436c1c9af6_Out_2_Vector4, _Add_4012fc6dca974479983d4205e9a59352_Out_2_Vector4);
float _Float_0a687515087c4f8f87b4f65ea2cb2f1b_Out_0_Float = 0.1;
float4 _Multiply_d365d0a9829941de99dd2f6c97e8dbb2_Out_2_Vector4;
Unity_Multiply_float4_float4(_Add_4012fc6dca974479983d4205e9a59352_Out_2_Vector4, (_Float_0a687515087c4f8f87b4f65ea2cb2f1b_Out_0_Float.xxxx), _Multiply_d365d0a9829941de99dd2f6c97e8dbb2_Out_2_Vector4);
float _Property_655492b992744728ada9f2087e1791d5_Out_0_Float = _Sun_Falloff_Intensity;
float4 _Multiply_a715ce27407b433eaeb09f9a11cf40dc_Out_2_Vector4;
Unity_Multiply_float4_float4(_Multiply_d365d0a9829941de99dd2f6c97e8dbb2_Out_2_Vector4, (_Property_655492b992744728ada9f2087e1791d5_Out_0_Float.xxxx), _Multiply_a715ce27407b433eaeb09f9a11cf40dc_Out_2_Vector4);
float4 _Branch_1611dc71330b4982ae2f573a6e1ce77a_Out_3_Vector4;
Unity_Branch_float4(_Property_c8e4c44c0435453ab979ed32cce1841e_Out_0_Boolean, _Multiply_a715ce27407b433eaeb09f9a11cf40dc_Out_2_Vector4, float4(0, 0, 0, 0), _Branch_1611dc71330b4982ae2f573a6e1ce77a_Out_3_Vector4);
float4 _Branch_1eb9afe6a1cf4e419123eec2cf376685_Out_3_Vector4;
Unity_Branch_float4(_Property_db6fcd7c223741cda92fcf8e03958281_Out_0_Boolean, _Branch_1611dc71330b4982ae2f573a6e1ce77a_Out_3_Vector4, float4(0, 0, 0, 0), _Branch_1eb9afe6a1cf4e419123eec2cf376685_Out_3_Vector4);
SunDiscColor_1 = _Branch_e409eeead86e42f28d3ed4d560e14025_Out_3_Vector3;
SunDiscAlpha_2 = _Branch_8b4249e71060427ba41961dd66f46e0e_Out_3_Float;
Falloff_3 = (_Branch_1eb9afe6a1cf4e419123eec2cf376685_Out_3_Vector4.xyz);
}

void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_Comparison_Less_float(float A, float B, out float Out)
{
    Out = A < B ? 1 : 0;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Add_float3(float3 A, float3 B, out float3 Out)
{
    Out = A + B;
}

void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
{
    float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
    Out =  luma.xxx + Saturation.xxx * (In - luma.xxx);
}

struct Bindings_SuperSimpleStars_e6cb6a8c68f031b4ba1c3ab79a9be02d_float
{
float3 WorldSpaceViewDirection;
float3 TimeParameters;
};

void SG_SuperSimpleStars_e6cb6a8c68f031b4ba1c3ab79a9be02d_float(UnityTexture2D Texture2D_a89d6acea61940e590e36cd904a5cfc5, float Vector1_973705f5b18e4849aa89229cd62b3912, float Vector1_66a434b963c74dd5acf35e074f2e8a7e, float Vector1_deaefb4ccd6549e38f440f74839a7ddc, float4 Vector4_eccc882f54904d67914cbddf1713b4a0, float Vector1_be2813b77a1e4c309e8ce912ad0f4429, float Vector1_bcfb5981762e47ebbc4bb417e00d184f, float _UseProceduralStars, float _Saturation, float _Enabled, float _Constant_Color_Mode, float _Sharpness, float _Frequency, float _Use_Texture_Stars, float4 _Star_Texture_Tint, Bindings_SuperSimpleStars_e6cb6a8c68f031b4ba1c3ab79a9be02d_float IN, out float3 Out_1)
{
float _Property_4c1b4179d12b487c915b6215c7912fbb_Out_0_Boolean = _Enabled;
float _Property_7c61895e257e40b085eacec34c12990b_Out_0_Boolean = _Constant_Color_Mode;
float4 _Property_f60e097682cc4be586fb70a1db161b4d_Out_0_Vector4 = Vector4_eccc882f54904d67914cbddf1713b4a0;
float _Split_0d5bcf60306e49a79f1100107097b5a7_R_1_Float = _Property_f60e097682cc4be586fb70a1db161b4d_Out_0_Vector4[0];
float _Split_0d5bcf60306e49a79f1100107097b5a7_G_2_Float = _Property_f60e097682cc4be586fb70a1db161b4d_Out_0_Vector4[1];
float _Split_0d5bcf60306e49a79f1100107097b5a7_B_3_Float = _Property_f60e097682cc4be586fb70a1db161b4d_Out_0_Vector4[2];
float _Split_0d5bcf60306e49a79f1100107097b5a7_A_4_Float = _Property_f60e097682cc4be586fb70a1db161b4d_Out_0_Vector4[3];
float _Smoothstep_65a7d57e5ec9442b957d8d30a702efd2_Out_3_Float;
Unity_Smoothstep_float(0.1, -0.4, _Split_0d5bcf60306e49a79f1100107097b5a7_G_2_Float, _Smoothstep_65a7d57e5ec9442b957d8d30a702efd2_Out_3_Float);
float _Property_811780c9d3214f98b7eb237fb3fb7e11_Out_0_Float = Vector1_be2813b77a1e4c309e8ce912ad0f4429;
float2 _Vector2_c80c850976ac4934a0fbd5ff103e1a8a_Out_0_Vector2 = float2(_Property_811780c9d3214f98b7eb237fb3fb7e11_Out_0_Float, 1);
float _Remap_81763b23a231410687e944654b4bfaf7_Out_3_Float;
Unity_Remap_float(_Smoothstep_65a7d57e5ec9442b957d8d30a702efd2_Out_3_Float, float2 (0, 1), _Vector2_c80c850976ac4934a0fbd5ff103e1a8a_Out_0_Vector2, _Remap_81763b23a231410687e944654b4bfaf7_Out_3_Float);
float _Saturate_1c83b9872ad4467ea93a0e6921206bed_Out_1_Float;
Unity_Saturate_float(_Remap_81763b23a231410687e944654b4bfaf7_Out_3_Float, _Saturate_1c83b9872ad4467ea93a0e6921206bed_Out_1_Float);
float _Branch_ed98706a77b64f2480cdc49bd35e7b43_Out_3_Float;
Unity_Branch_float(_Property_7c61895e257e40b085eacec34c12990b_Out_0_Boolean, 1, _Saturate_1c83b9872ad4467ea93a0e6921206bed_Out_1_Float, _Branch_ed98706a77b64f2480cdc49bd35e7b43_Out_3_Float);
float _Property_dd2e3783142b426c8aaeabdd9df47eaf_Out_0_Boolean = _UseProceduralStars;
float _Property_998d732db1b84dfa83c866844786238c_Out_0_Float = _Sharpness;
float _Property_a219b0d0f50846eaad0f8aa6738dbb3b_Out_0_Float = _Frequency;
float3 _GetStarsCustomFunction_b41ac7a284b7415f8f483b53eac3816d_Out_1_Vector3;
GetStars_float(IN.WorldSpaceViewDirection, _Property_998d732db1b84dfa83c866844786238c_Out_0_Float, _Property_a219b0d0f50846eaad0f8aa6738dbb3b_Out_0_Float, _GetStarsCustomFunction_b41ac7a284b7415f8f483b53eac3816d_Out_1_Vector3);
float3 _Branch_2fd09031d7164b31896e3ba633325c4d_Out_3_Vector3;
Unity_Branch_float3(_Property_dd2e3783142b426c8aaeabdd9df47eaf_Out_0_Boolean, _GetStarsCustomFunction_b41ac7a284b7415f8f483b53eac3816d_Out_1_Vector3, float3(0, 0, 0), _Branch_2fd09031d7164b31896e3ba633325c4d_Out_3_Vector3);
float _Property_46809dec2e3e4b668143f76502f595d0_Out_0_Boolean = _Use_Texture_Stars;
UnityTexture2D _Property_077b39c2691a4798a82562c9c7784109_Out_0_Texture2D = Texture2D_a89d6acea61940e590e36cd904a5cfc5;
float _Split_c2ed7c8325ff4e8b94d238865f7abef3_R_1_Float = IN.WorldSpaceViewDirection[0];
float _Split_c2ed7c8325ff4e8b94d238865f7abef3_G_2_Float = IN.WorldSpaceViewDirection[1];
float _Split_c2ed7c8325ff4e8b94d238865f7abef3_B_3_Float = IN.WorldSpaceViewDirection[2];
float _Split_c2ed7c8325ff4e8b94d238865f7abef3_A_4_Float = 0;
float2 _Vector2_c04021d057094705b94dcd34ceb0e9c0_Out_0_Vector2 = float2(_Split_c2ed7c8325ff4e8b94d238865f7abef3_R_1_Float, _Split_c2ed7c8325ff4e8b94d238865f7abef3_B_3_Float);
float _Absolute_7133ee48f9654b1aaf689d8863c86cca_Out_1_Float;
Unity_Absolute_float(_Split_c2ed7c8325ff4e8b94d238865f7abef3_G_2_Float, _Absolute_7133ee48f9654b1aaf689d8863c86cca_Out_1_Float);
float _Saturate_d8b25d65947a4b4d94cefc9b2c6040e7_Out_1_Float;
Unity_Saturate_float(_Absolute_7133ee48f9654b1aaf689d8863c86cca_Out_1_Float, _Saturate_d8b25d65947a4b4d94cefc9b2c6040e7_Out_1_Float);
float _OneMinus_7a331010413545d3a7a52a39c34fc6a0_Out_1_Float;
Unity_OneMinus_float(_Saturate_d8b25d65947a4b4d94cefc9b2c6040e7_Out_1_Float, _OneMinus_7a331010413545d3a7a52a39c34fc6a0_Out_1_Float);
float2 _Multiply_ec4284c998454797a864612748e18e10_Out_2_Vector2;
Unity_Multiply_float2_float2(_Vector2_c04021d057094705b94dcd34ceb0e9c0_Out_0_Vector2, (_OneMinus_7a331010413545d3a7a52a39c34fc6a0_Out_1_Float.xx), _Multiply_ec4284c998454797a864612748e18e10_Out_2_Vector2);
float2 _Add_c9a06e15cb754d5fa248c821cc030696_Out_2_Vector2;
Unity_Add_float2(_Vector2_c04021d057094705b94dcd34ceb0e9c0_Out_0_Vector2, _Multiply_ec4284c998454797a864612748e18e10_Out_2_Vector2, _Add_c9a06e15cb754d5fa248c821cc030696_Out_2_Vector2);
float _Property_90c9aedfffa044bfac5a8ad2de88e864_Out_0_Float = Vector1_66a434b963c74dd5acf35e074f2e8a7e;
float _Split_e87e5598081b4d37b0ef090e944b2a09_R_1_Float = IN.WorldSpaceViewDirection[0];
float _Split_e87e5598081b4d37b0ef090e944b2a09_G_2_Float = IN.WorldSpaceViewDirection[1];
float _Split_e87e5598081b4d37b0ef090e944b2a09_B_3_Float = IN.WorldSpaceViewDirection[2];
float _Split_e87e5598081b4d37b0ef090e944b2a09_A_4_Float = 0;
float _Comparison_38e98f08963b436390c8ab1821169b50_Out_2_Boolean;
Unity_Comparison_Less_float(_Split_e87e5598081b4d37b0ef090e944b2a09_G_2_Float, 0, _Comparison_38e98f08963b436390c8ab1821169b50_Out_2_Boolean);
float _Branch_4cb739da9370400abedc668b38eeccc6_Out_3_Float;
Unity_Branch_float(_Comparison_38e98f08963b436390c8ab1821169b50_Out_2_Boolean, 1, -1, _Branch_4cb739da9370400abedc668b38eeccc6_Out_3_Float);
float _Property_6b81208616ac4d688622a04f18227e4f_Out_0_Float = Vector1_deaefb4ccd6549e38f440f74839a7ddc;
float _Multiply_ba9ebb6542ff469f8a71d997fd081804_Out_2_Float;
Unity_Multiply_float_float(_Property_6b81208616ac4d688622a04f18227e4f_Out_0_Float, 0.01, _Multiply_ba9ebb6542ff469f8a71d997fd081804_Out_2_Float);
float _Multiply_d20955766e0a4cb182fdecf07ee72aa2_Out_2_Float;
Unity_Multiply_float_float(_Branch_4cb739da9370400abedc668b38eeccc6_Out_3_Float, _Multiply_ba9ebb6542ff469f8a71d997fd081804_Out_2_Float, _Multiply_d20955766e0a4cb182fdecf07ee72aa2_Out_2_Float);
float _Multiply_780187c25d4f4e4aa379018609cd1736_Out_2_Float;
Unity_Multiply_float_float(IN.TimeParameters.x, _Multiply_d20955766e0a4cb182fdecf07ee72aa2_Out_2_Float, _Multiply_780187c25d4f4e4aa379018609cd1736_Out_2_Float);
float2 _TilingAndOffset_4ab9692d83504b2a8df70468820e4515_Out_3_Vector2;
Unity_TilingAndOffset_float(_Add_c9a06e15cb754d5fa248c821cc030696_Out_2_Vector2, (_Property_90c9aedfffa044bfac5a8ad2de88e864_Out_0_Float.xx), (_Multiply_780187c25d4f4e4aa379018609cd1736_Out_2_Float.xx), _TilingAndOffset_4ab9692d83504b2a8df70468820e4515_Out_3_Vector2);
float4 _SampleTexture2D_482c5d04eb9141a9b8d45d1dad4fc486_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_077b39c2691a4798a82562c9c7784109_Out_0_Texture2D.tex, _Property_077b39c2691a4798a82562c9c7784109_Out_0_Texture2D.samplerstate, _Property_077b39c2691a4798a82562c9c7784109_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_4ab9692d83504b2a8df70468820e4515_Out_3_Vector2) );
float _SampleTexture2D_482c5d04eb9141a9b8d45d1dad4fc486_R_4_Float = _SampleTexture2D_482c5d04eb9141a9b8d45d1dad4fc486_RGBA_0_Vector4.r;
float _SampleTexture2D_482c5d04eb9141a9b8d45d1dad4fc486_G_5_Float = _SampleTexture2D_482c5d04eb9141a9b8d45d1dad4fc486_RGBA_0_Vector4.g;
float _SampleTexture2D_482c5d04eb9141a9b8d45d1dad4fc486_B_6_Float = _SampleTexture2D_482c5d04eb9141a9b8d45d1dad4fc486_RGBA_0_Vector4.b;
float _SampleTexture2D_482c5d04eb9141a9b8d45d1dad4fc486_A_7_Float = _SampleTexture2D_482c5d04eb9141a9b8d45d1dad4fc486_RGBA_0_Vector4.a;
float4 _Property_360ca722d70f45b597d5484d174d05f0_Out_0_Vector4 = _Star_Texture_Tint;
float4 _Multiply_3406b95f77784569bef0fc871ed2e862_Out_2_Vector4;
Unity_Multiply_float4_float4(_SampleTexture2D_482c5d04eb9141a9b8d45d1dad4fc486_RGBA_0_Vector4, _Property_360ca722d70f45b597d5484d174d05f0_Out_0_Vector4, _Multiply_3406b95f77784569bef0fc871ed2e862_Out_2_Vector4);
float4 _Branch_b530c0b739694d6a848dfa58073a2cea_Out_3_Vector4;
Unity_Branch_float4(_Property_46809dec2e3e4b668143f76502f595d0_Out_0_Boolean, _Multiply_3406b95f77784569bef0fc871ed2e862_Out_2_Vector4, float4(0, 0, 0, 0), _Branch_b530c0b739694d6a848dfa58073a2cea_Out_3_Vector4);
float3 _Add_49d6aedb87674007bf8ec570ac123afd_Out_2_Vector3;
Unity_Add_float3(_Branch_2fd09031d7164b31896e3ba633325c4d_Out_3_Vector3, (_Branch_b530c0b739694d6a848dfa58073a2cea_Out_3_Vector4.xyz), _Add_49d6aedb87674007bf8ec570ac123afd_Out_2_Vector3);
float _Property_552daebeafe24b7a9f839e662917cb89_Out_0_Float = _Saturation;
float3 _Saturation_4f5792195ae148f3b82b1dadab21f9f3_Out_2_Vector3;
Unity_Saturation_float(_Add_49d6aedb87674007bf8ec570ac123afd_Out_2_Vector3, _Property_552daebeafe24b7a9f839e662917cb89_Out_0_Float, _Saturation_4f5792195ae148f3b82b1dadab21f9f3_Out_2_Vector3);
float _Split_5ddd097341824aa0b55f11f07c1dec5e_R_1_Float = IN.WorldSpaceViewDirection[0];
float _Split_5ddd097341824aa0b55f11f07c1dec5e_G_2_Float = IN.WorldSpaceViewDirection[1];
float _Split_5ddd097341824aa0b55f11f07c1dec5e_B_3_Float = IN.WorldSpaceViewDirection[2];
float _Split_5ddd097341824aa0b55f11f07c1dec5e_A_4_Float = 0;
float _Absolute_cea83ea9fcc843b5a6678b4195cf6659_Out_1_Float;
Unity_Absolute_float(_Split_5ddd097341824aa0b55f11f07c1dec5e_G_2_Float, _Absolute_cea83ea9fcc843b5a6678b4195cf6659_Out_1_Float);
float _Saturate_b32418cca4934171b5de1f53ee470de2_Out_1_Float;
Unity_Saturate_float(_Absolute_cea83ea9fcc843b5a6678b4195cf6659_Out_1_Float, _Saturate_b32418cca4934171b5de1f53ee470de2_Out_1_Float);
float _Property_669837f583b04146b193d8d1097ac3a6_Out_0_Float = Vector1_973705f5b18e4849aa89229cd62b3912;
float _Power_5e9f421cd4ad4f24b2c0edbcd2b5c7b3_Out_2_Float;
Unity_Power_float(_Saturate_b32418cca4934171b5de1f53ee470de2_Out_1_Float, _Property_669837f583b04146b193d8d1097ac3a6_Out_0_Float, _Power_5e9f421cd4ad4f24b2c0edbcd2b5c7b3_Out_2_Float);
float3 _Multiply_eae1f719400d407988957e0099dbfc96_Out_2_Vector3;
Unity_Multiply_float3_float3(_Saturation_4f5792195ae148f3b82b1dadab21f9f3_Out_2_Vector3, (_Power_5e9f421cd4ad4f24b2c0edbcd2b5c7b3_Out_2_Float.xxx), _Multiply_eae1f719400d407988957e0099dbfc96_Out_2_Vector3);
float3 _Multiply_3989a58b99f94d2da531d7a1812062eb_Out_2_Vector3;
Unity_Multiply_float3_float3((_Branch_ed98706a77b64f2480cdc49bd35e7b43_Out_3_Float.xxx), _Multiply_eae1f719400d407988957e0099dbfc96_Out_2_Vector3, _Multiply_3989a58b99f94d2da531d7a1812062eb_Out_2_Vector3);
float _Property_3eca1267c6a34489bb555dc97e68cf49_Out_0_Float = Vector1_bcfb5981762e47ebbc4bb417e00d184f;
float _Multiply_683381ea47b649848876581d441f3b04_Out_2_Float;
Unity_Multiply_float_float(_Property_3eca1267c6a34489bb555dc97e68cf49_Out_0_Float, _Property_3eca1267c6a34489bb555dc97e68cf49_Out_0_Float, _Multiply_683381ea47b649848876581d441f3b04_Out_2_Float);
float3 _Multiply_907c7fd3ce364ebbad892ea273b692ac_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_3989a58b99f94d2da531d7a1812062eb_Out_2_Vector3, (_Multiply_683381ea47b649848876581d441f3b04_Out_2_Float.xxx), _Multiply_907c7fd3ce364ebbad892ea273b692ac_Out_2_Vector3);
float3 _Branch_4b2d4f60e5444763b722eb6ffea49500_Out_3_Vector3;
Unity_Branch_float3(_Property_4c1b4179d12b487c915b6215c7912fbb_Out_0_Boolean, _Multiply_907c7fd3ce364ebbad892ea273b692ac_Out_2_Vector3, float3(0, 0, 0), _Branch_4b2d4f60e5444763b722eb6ffea49500_Out_3_Vector3);
Out_1 = _Branch_4b2d4f60e5444763b722eb6ffea49500_Out_3_Vector3;
}

void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
{
    Out = lerp(A, B, T);
}

struct Bindings_SuperSimpleMoon_70141643167b638499823de61c9e3f1d_float
{
float3 WorldSpaceViewDirection;
};

void SG_SuperSimpleMoon_70141643167b638499823de61c9e3f1d_float(float Vector1_6b5b6d25364046c78942a109900b1db5, float4 Vector4_8f4d25fa58e9402985403cb2a7bf0b6f, float Vector1_1e6b085b1b6b4dfd8300cac8180eb612, float _Enabled, Bindings_SuperSimpleMoon_70141643167b638499823de61c9e3f1d_float IN, out float3 Falloff_1, out float3 MoonDiscColor_2, out float MoonDiscAlpha_3)
{
float _Property_bc5ef1fe686a4567a04a880d1373c04d_Out_0_Boolean = _Enabled;
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_91f669cd27614ddaa4160296f74b7d51;
float3 _GetLights_91f669cd27614ddaa4160296f74b7d51_SunDirection_0_Vector3;
float3 _GetLights_91f669cd27614ddaa4160296f74b7d51_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_91f669cd27614ddaa4160296f74b7d51, _GetLights_91f669cd27614ddaa4160296f74b7d51_SunDirection_0_Vector3, _GetLights_91f669cd27614ddaa4160296f74b7d51_MoonDirection_1_Vector3);
Bindings_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float _GetSkyboxLightDistance_12beff520bf0474cb66e56355b5d19f8;
_GetSkyboxLightDistance_12beff520bf0474cb66e56355b5d19f8.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
float _GetSkyboxLightDistance_12beff520bf0474cb66e56355b5d19f8_Out_1_Float;
float _GetSkyboxLightDistance_12beff520bf0474cb66e56355b5d19f8_Theta_2_Float;
SG_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float(_GetLights_91f669cd27614ddaa4160296f74b7d51_MoonDirection_1_Vector3, _GetSkyboxLightDistance_12beff520bf0474cb66e56355b5d19f8, _GetSkyboxLightDistance_12beff520bf0474cb66e56355b5d19f8_Out_1_Float, _GetSkyboxLightDistance_12beff520bf0474cb66e56355b5d19f8_Theta_2_Float);
float _OneMinus_56aeabf67a7f400a831bcb13bd90689c_Out_1_Float;
Unity_OneMinus_float(_GetSkyboxLightDistance_12beff520bf0474cb66e56355b5d19f8_Out_1_Float, _OneMinus_56aeabf67a7f400a831bcb13bd90689c_Out_1_Float);
float _Property_fa60416a59b14202ad80661c3efb7a28_Out_0_Float = Vector1_6b5b6d25364046c78942a109900b1db5;
float _Absolute_b8da800f7a804291bef9179f7e245931_Out_1_Float;
Unity_Absolute_float(_Property_fa60416a59b14202ad80661c3efb7a28_Out_0_Float, _Absolute_b8da800f7a804291bef9179f7e245931_Out_1_Float);
float _Power_0ba28ab3019149c4856831aa3b08aa58_Out_2_Float;
Unity_Power_float(_OneMinus_56aeabf67a7f400a831bcb13bd90689c_Out_1_Float, _Absolute_b8da800f7a804291bef9179f7e245931_Out_1_Float, _Power_0ba28ab3019149c4856831aa3b08aa58_Out_2_Float);
float4 _Property_4f212feadcd64b8bac138338860a8386_Out_0_Vector4 = Vector4_8f4d25fa58e9402985403cb2a7bf0b6f;
float4 _Multiply_bdb584448c82453383c0dc9be2fe7f0e_Out_2_Vector4;
Unity_Multiply_float4_float4((_Power_0ba28ab3019149c4856831aa3b08aa58_Out_2_Float.xxxx), _Property_4f212feadcd64b8bac138338860a8386_Out_0_Vector4, _Multiply_bdb584448c82453383c0dc9be2fe7f0e_Out_2_Vector4);
float4 _Branch_1ddc578028a24f06a4d58017fa12572c_Out_3_Vector4;
Unity_Branch_float4(_Property_bc5ef1fe686a4567a04a880d1373c04d_Out_0_Boolean, _Multiply_bdb584448c82453383c0dc9be2fe7f0e_Out_2_Vector4, float4(0, 0, 0, 0), _Branch_1ddc578028a24f06a4d58017fa12572c_Out_3_Vector4);
float _Property_4473b7e136ec4136994fc47622eec5ec_Out_0_Boolean = _Enabled;
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_ba83ec02df4049918f8ffed6a59eb628;
float3 _GetLights_ba83ec02df4049918f8ffed6a59eb628_SunDirection_0_Vector3;
float3 _GetLights_ba83ec02df4049918f8ffed6a59eb628_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_ba83ec02df4049918f8ffed6a59eb628, _GetLights_ba83ec02df4049918f8ffed6a59eb628_SunDirection_0_Vector3, _GetLights_ba83ec02df4049918f8ffed6a59eb628_MoonDirection_1_Vector3);
Bindings_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float _GetSkyboxLightDistance_fbbb46b4cded4b038c4ea919c660626c;
_GetSkyboxLightDistance_fbbb46b4cded4b038c4ea919c660626c.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
float _GetSkyboxLightDistance_fbbb46b4cded4b038c4ea919c660626c_Out_1_Float;
float _GetSkyboxLightDistance_fbbb46b4cded4b038c4ea919c660626c_Theta_2_Float;
SG_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float(_GetLights_ba83ec02df4049918f8ffed6a59eb628_MoonDirection_1_Vector3, _GetSkyboxLightDistance_fbbb46b4cded4b038c4ea919c660626c, _GetSkyboxLightDistance_fbbb46b4cded4b038c4ea919c660626c_Out_1_Float, _GetSkyboxLightDistance_fbbb46b4cded4b038c4ea919c660626c_Theta_2_Float);
float _Property_2cbd7e1b1886442cb3dad1aceefdef9d_Out_0_Float = Vector1_1e6b085b1b6b4dfd8300cac8180eb612;
float _Multiply_25cdb3aece8441aea2eb44bc70dd6bee_Out_2_Float;
Unity_Multiply_float_float(_Property_2cbd7e1b1886442cb3dad1aceefdef9d_Out_0_Float, 0.5, _Multiply_25cdb3aece8441aea2eb44bc70dd6bee_Out_2_Float);
float2 _Vector2_a6dfdc850aaa417f98e2edd2469f1019_Out_0_Vector2 = float2(0, _Multiply_25cdb3aece8441aea2eb44bc70dd6bee_Out_2_Float);
float _Remap_3341578a1ed8448ab80963eacbf27e2a_Out_3_Float;
Unity_Remap_float(_GetSkyboxLightDistance_fbbb46b4cded4b038c4ea919c660626c_Theta_2_Float, _Vector2_a6dfdc850aaa417f98e2edd2469f1019_Out_0_Vector2, float2 (0, 1), _Remap_3341578a1ed8448ab80963eacbf27e2a_Out_3_Float);
float _Saturate_c8986b1cd8e04e298ff2c7b0a1f9ce98_Out_1_Float;
Unity_Saturate_float(_Remap_3341578a1ed8448ab80963eacbf27e2a_Out_3_Float, _Saturate_c8986b1cd8e04e298ff2c7b0a1f9ce98_Out_1_Float);
Bindings_LimbDarkening_92a0c29eaa0a30a41b6117a972eab2eb_float _LimbDarkening_293cc21c2b4d415aa38db140ac1aa225;
float3 _LimbDarkening_293cc21c2b4d415aa38db140ac1aa225_LimbDarkeningFactor_1_Vector3;
SG_LimbDarkening_92a0c29eaa0a30a41b6117a972eab2eb_float(_Saturate_c8986b1cd8e04e298ff2c7b0a1f9ce98_Out_1_Float, _LimbDarkening_293cc21c2b4d415aa38db140ac1aa225, _LimbDarkening_293cc21c2b4d415aa38db140ac1aa225_LimbDarkeningFactor_1_Vector3);
float _Subtract_f3c5014e21914d3e890e8e2cbcb081ef_Out_2_Float;
Unity_Subtract_float(_Multiply_25cdb3aece8441aea2eb44bc70dd6bee_Out_2_Float, 0.1, _Subtract_f3c5014e21914d3e890e8e2cbcb081ef_Out_2_Float);
float _Smoothstep_f6b02f8b81b24a6893e53a461db3b44e_Out_3_Float;
Unity_Smoothstep_float(_Subtract_f3c5014e21914d3e890e8e2cbcb081ef_Out_2_Float, _Multiply_25cdb3aece8441aea2eb44bc70dd6bee_Out_2_Float, _GetSkyboxLightDistance_fbbb46b4cded4b038c4ea919c660626c_Theta_2_Float, _Smoothstep_f6b02f8b81b24a6893e53a461db3b44e_Out_3_Float);
float _OneMinus_a2d6fa07fe4b4240b2d3ba255be58541_Out_1_Float;
Unity_OneMinus_float(_Smoothstep_f6b02f8b81b24a6893e53a461db3b44e_Out_3_Float, _OneMinus_a2d6fa07fe4b4240b2d3ba255be58541_Out_1_Float);
float3 _Multiply_74204af44356466a99485d6cd89a41ca_Out_2_Vector3;
Unity_Multiply_float3_float3(_LimbDarkening_293cc21c2b4d415aa38db140ac1aa225_LimbDarkeningFactor_1_Vector3, (_OneMinus_a2d6fa07fe4b4240b2d3ba255be58541_Out_1_Float.xxx), _Multiply_74204af44356466a99485d6cd89a41ca_Out_2_Vector3);
float4 _Property_fbbc24728a5344c2a35f52ae5e305ba2_Out_0_Vector4 = Vector4_8f4d25fa58e9402985403cb2a7bf0b6f;
float3 _Multiply_f7c188ea27c34e53a89a48fd5c933377_Out_2_Vector3;
Unity_Multiply_float3_float3(_Multiply_74204af44356466a99485d6cd89a41ca_Out_2_Vector3, (_Property_fbbc24728a5344c2a35f52ae5e305ba2_Out_0_Vector4.xyz), _Multiply_f7c188ea27c34e53a89a48fd5c933377_Out_2_Vector3);
float3 _Branch_cbf30c9c3bef4cd98c9c4485d457e6cb_Out_3_Vector3;
Unity_Branch_float3(_Property_4473b7e136ec4136994fc47622eec5ec_Out_0_Boolean, _Multiply_f7c188ea27c34e53a89a48fd5c933377_Out_2_Vector3, float3(0, 0, 0), _Branch_cbf30c9c3bef4cd98c9c4485d457e6cb_Out_3_Vector3);
float _Property_c0699b2e740e4b719491c420121a9969_Out_0_Boolean = _Enabled;
float _Branch_3e2c79dbca7e4540b902db7ff2a3b84d_Out_3_Float;
Unity_Branch_float(_Property_c0699b2e740e4b719491c420121a9969_Out_0_Boolean, _OneMinus_a2d6fa07fe4b4240b2d3ba255be58541_Out_1_Float, 0, _Branch_3e2c79dbca7e4540b902db7ff2a3b84d_Out_3_Float);
Falloff_1 = (_Branch_1ddc578028a24f06a4d58017fa12572c_Out_3_Vector4.xyz);
MoonDiscColor_2 = _Branch_cbf30c9c3bef4cd98c9c4485d457e6cb_Out_3_Vector3;
MoonDiscAlpha_3 = _Branch_3e2c79dbca7e4540b902db7ff2a3b84d_Out_3_Float;
}

struct Bindings_SuperSimpleClouds_cf3facbd665dd47478e6d26e508dc671_float
{
float3 WorldSpaceViewDirection;
float3 ObjectSpacePosition;
};

void SG_SuperSimpleClouds_cf3facbd665dd47478e6d26e508dc671_float(UnityTexture2D Texture2D_f8d3a18694174160aed0db7ab2d71323, float Vector1_57fc82054d2c4fa2992cdacd511a2c0b, float2 Vector2_5f2634825991491b8751da489bd3a81f, float2 Vector2_b7efbcf0dd30434dafe10a160ac0f5e7, float Vector1_e307e5fcb934457d904dc21027e7d943, float Vector1_76f188f8a1a240a49a8071b17c757983, float4 Color_732135cce0c94099a11977664c75750a, float4 Color_1, float _Enabled, float _Constant_Color_Enabled, float _Shading_Intensity, float4 _Ambient_Color, float _Cloud_Opacity, float _Iterations, float _Gain, float _Lacunarity, Bindings_SuperSimpleClouds_cf3facbd665dd47478e6d26e508dc671_float IN, out float3 Color_2, out float Alpha_1)
{
float _Property_60e119ffa1484d368b8bc763e3d4a971_Out_0_Boolean = _Enabled;
float4 _Property_d35a35b7c08b41e29742f8663de9e951_Out_0_Vector4 = _Ambient_Color;
float4 _Property_c2216925245342f5b25411d21a87b78f_Out_0_Vector4 = Color_732135cce0c94099a11977664c75750a;
float4 _Property_abfef5044e9f4dc183ff95949e4bd00d_Out_0_Vector4 = Color_1;
float _Property_9f1a0087272745ccb12180c8726f8ab1_Out_0_Boolean = _Constant_Color_Enabled;
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_75c558ac707443f7acbf642f3731ebf9;
float3 _GetLights_75c558ac707443f7acbf642f3731ebf9_SunDirection_0_Vector3;
float3 _GetLights_75c558ac707443f7acbf642f3731ebf9_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_75c558ac707443f7acbf642f3731ebf9, _GetLights_75c558ac707443f7acbf642f3731ebf9_SunDirection_0_Vector3, _GetLights_75c558ac707443f7acbf642f3731ebf9_MoonDirection_1_Vector3);
float _Split_a7bfea87cc954027b56bfafd08146bca_R_1_Float = _GetLights_75c558ac707443f7acbf642f3731ebf9_SunDirection_0_Vector3[0];
float _Split_a7bfea87cc954027b56bfafd08146bca_G_2_Float = _GetLights_75c558ac707443f7acbf642f3731ebf9_SunDirection_0_Vector3[1];
float _Split_a7bfea87cc954027b56bfafd08146bca_B_3_Float = _GetLights_75c558ac707443f7acbf642f3731ebf9_SunDirection_0_Vector3[2];
float _Split_a7bfea87cc954027b56bfafd08146bca_A_4_Float = 0;
float _Smoothstep_d21bb40414724d5aa682d0f2116aafa8_Out_3_Float;
Unity_Smoothstep_float(0, -0.3, _Split_a7bfea87cc954027b56bfafd08146bca_G_2_Float, _Smoothstep_d21bb40414724d5aa682d0f2116aafa8_Out_3_Float);
float _Branch_c9d91877e0c748b782bc4ec2d3d269c2_Out_3_Float;
Unity_Branch_float(_Property_9f1a0087272745ccb12180c8726f8ab1_Out_0_Boolean, 0, _Smoothstep_d21bb40414724d5aa682d0f2116aafa8_Out_3_Float, _Branch_c9d91877e0c748b782bc4ec2d3d269c2_Out_3_Float);
float4 _Lerp_b6f3edf1d7c442c783233b7bcbeebc12_Out_3_Vector4;
Unity_Lerp_float4(_Property_c2216925245342f5b25411d21a87b78f_Out_0_Vector4, _Property_abfef5044e9f4dc183ff95949e4bd00d_Out_0_Vector4, (_Branch_c9d91877e0c748b782bc4ec2d3d269c2_Out_3_Float.xxxx), _Lerp_b6f3edf1d7c442c783233b7bcbeebc12_Out_3_Vector4);
float4 _Multiply_ff2662508bd9472e95f7f7b7b97618b9_Out_2_Vector4;
Unity_Multiply_float4_float4(_Property_d35a35b7c08b41e29742f8663de9e951_Out_0_Vector4, _Lerp_b6f3edf1d7c442c783233b7bcbeebc12_Out_3_Vector4, _Multiply_ff2662508bd9472e95f7f7b7b97618b9_Out_2_Vector4);
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_674b0635002e4aa18d52cefb7d9ec8e0;
float3 _GetLights_674b0635002e4aa18d52cefb7d9ec8e0_SunDirection_0_Vector3;
float3 _GetLights_674b0635002e4aa18d52cefb7d9ec8e0_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_674b0635002e4aa18d52cefb7d9ec8e0, _GetLights_674b0635002e4aa18d52cefb7d9ec8e0_SunDirection_0_Vector3, _GetLights_674b0635002e4aa18d52cefb7d9ec8e0_MoonDirection_1_Vector3);
Bindings_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float _GetSkyboxLightDistance_a25dd1e519c94cd8ac917428533ed69e;
_GetSkyboxLightDistance_a25dd1e519c94cd8ac917428533ed69e.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
float _GetSkyboxLightDistance_a25dd1e519c94cd8ac917428533ed69e_Out_1_Float;
float _GetSkyboxLightDistance_a25dd1e519c94cd8ac917428533ed69e_Theta_2_Float;
SG_GetSkyboxLightDistance_645715d76a04d7a40b033edbe2a2db51_float(_GetLights_674b0635002e4aa18d52cefb7d9ec8e0_SunDirection_0_Vector3, _GetSkyboxLightDistance_a25dd1e519c94cd8ac917428533ed69e, _GetSkyboxLightDistance_a25dd1e519c94cd8ac917428533ed69e_Out_1_Float, _GetSkyboxLightDistance_a25dd1e519c94cd8ac917428533ed69e_Theta_2_Float);
float _Remap_828d3c2e199542a592a397fba1a61021_Out_3_Float;
Unity_Remap_float(_GetSkyboxLightDistance_a25dd1e519c94cd8ac917428533ed69e_Out_1_Float, float2 (0, 0.4), float2 (1, 0), _Remap_828d3c2e199542a592a397fba1a61021_Out_3_Float);
float _Saturate_76cf6f46a3434d579ad2c053f50865f3_Out_1_Float;
Unity_Saturate_float(_Remap_828d3c2e199542a592a397fba1a61021_Out_3_Float, _Saturate_76cf6f46a3434d579ad2c053f50865f3_Out_1_Float);
float _OneMinus_df4fa502314440f59113f15957850582_Out_1_Float;
Unity_OneMinus_float(_GetSkyboxLightDistance_a25dd1e519c94cd8ac917428533ed69e_Out_1_Float, _OneMinus_df4fa502314440f59113f15957850582_Out_1_Float);
float _Remap_c667ae97be1045189abfbd463bb3b8a6_Out_3_Float;
Unity_Remap_float(_GetSkyboxLightDistance_a25dd1e519c94cd8ac917428533ed69e_Out_1_Float, float2 (0, 1), float2 (0, 0.2), _Remap_c667ae97be1045189abfbd463bb3b8a6_Out_3_Float);
float _Maximum_aa75d48a74cd4222b1e1d06fdbf90887_Out_2_Float;
Unity_Maximum_float(_OneMinus_df4fa502314440f59113f15957850582_Out_1_Float, _Remap_c667ae97be1045189abfbd463bb3b8a6_Out_3_Float, _Maximum_aa75d48a74cd4222b1e1d06fdbf90887_Out_2_Float);
float _Remap_f9917caf68704cb0a5ca7337047eae76_Out_3_Float;
Unity_Remap_float(_Maximum_aa75d48a74cd4222b1e1d06fdbf90887_Out_2_Float, float2 (0, 1), float2 (0.5, 1), _Remap_f9917caf68704cb0a5ca7337047eae76_Out_3_Float);
float _Saturate_0bedc809245442afb8513d4733dab543_Out_1_Float;
Unity_Saturate_float(_Remap_f9917caf68704cb0a5ca7337047eae76_Out_3_Float, _Saturate_0bedc809245442afb8513d4733dab543_Out_1_Float);
float _Add_99a9bc7a24324e1f9e165bab57de40ca_Out_2_Float;
Unity_Add_float(_Saturate_76cf6f46a3434d579ad2c053f50865f3_Out_1_Float, _Saturate_0bedc809245442afb8513d4733dab543_Out_1_Float, _Add_99a9bc7a24324e1f9e165bab57de40ca_Out_2_Float);
float4 _Multiply_f7b914d1c1364230b108419f51af3ca1_Out_2_Vector4;
Unity_Multiply_float4_float4((_Add_99a9bc7a24324e1f9e165bab57de40ca_Out_2_Float.xxxx), _Lerp_b6f3edf1d7c442c783233b7bcbeebc12_Out_3_Vector4, _Multiply_f7b914d1c1364230b108419f51af3ca1_Out_2_Vector4);
Bindings_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float _SkyboxUVMap_f99c2cf3139046fbb4cc466089468f4b;
_SkyboxUVMap_f99c2cf3139046fbb4cc466089468f4b.ObjectSpacePosition = IN.ObjectSpacePosition;
float2 _SkyboxUVMap_f99c2cf3139046fbb4cc466089468f4b_UV_0_Vector2;
SG_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float(_SkyboxUVMap_f99c2cf3139046fbb4cc466089468f4b, _SkyboxUVMap_f99c2cf3139046fbb4cc466089468f4b_UV_0_Vector2);
UnityTexture2D _Property_10e43cd1981f41f585e2748d946d140b_Out_0_Texture2D = Texture2D_f8d3a18694174160aed0db7ab2d71323;
float2 _Property_785924a7fec8456d9098b79a69ad1d9d_Out_0_Vector2 = Vector2_b7efbcf0dd30434dafe10a160ac0f5e7;
float2 _Property_535beb87ef3344b29209d24c6442b716_Out_0_Vector2 = Vector2_5f2634825991491b8751da489bd3a81f;
float _Property_1e0a05309e024a90bea8163d9c6f896c_Out_0_Float = _Iterations;
float _Property_00cc3c00a1f24d0ab0f23d0109320839_Out_0_Float = _Gain;
float _Property_023190b2083c41d5afefdc109657821b_Out_0_Float = _Lacunarity;
float _GetCloudsCustomFunction_48fa157e27564308a616b1cde2a8775b_value_0_Float;
GetClouds_float(_SkyboxUVMap_f99c2cf3139046fbb4cc466089468f4b_UV_0_Vector2, _Property_10e43cd1981f41f585e2748d946d140b_Out_0_Texture2D.tex, _Property_785924a7fec8456d9098b79a69ad1d9d_Out_0_Vector2, _Property_535beb87ef3344b29209d24c6442b716_Out_0_Vector2, _Property_1e0a05309e024a90bea8163d9c6f896c_Out_0_Float, _Property_00cc3c00a1f24d0ab0f23d0109320839_Out_0_Float, _Property_023190b2083c41d5afefdc109657821b_Out_0_Float, _GetCloudsCustomFunction_48fa157e27564308a616b1cde2a8775b_value_0_Float);
float _Property_ec539208733e4faa9ba71b70e8361e24_Out_0_Float = Vector1_e307e5fcb934457d904dc21027e7d943;
float _OneMinus_aacab7d64e2e43fe8a1269f54b8f4900_Out_1_Float;
Unity_OneMinus_float(_Property_ec539208733e4faa9ba71b70e8361e24_Out_0_Float, _OneMinus_aacab7d64e2e43fe8a1269f54b8f4900_Out_1_Float);
float2 _Vector2_3906a45145844c8ca63bf26f7d828662_Out_0_Vector2 = float2(_OneMinus_aacab7d64e2e43fe8a1269f54b8f4900_Out_1_Float, 1);
float _Remap_5f8e2443ea7e42a8924e9fce46542e5b_Out_3_Float;
Unity_Remap_float(_GetCloudsCustomFunction_48fa157e27564308a616b1cde2a8775b_value_0_Float, _Vector2_3906a45145844c8ca63bf26f7d828662_Out_0_Vector2, float2 (0, 1), _Remap_5f8e2443ea7e42a8924e9fce46542e5b_Out_3_Float);
Bindings_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float _SkyboxUVMap_13bfea43f71f40ad88a4532bb2fae472;
_SkyboxUVMap_13bfea43f71f40ad88a4532bb2fae472.ObjectSpacePosition = IN.ObjectSpacePosition;
float2 _SkyboxUVMap_13bfea43f71f40ad88a4532bb2fae472_UV_0_Vector2;
SG_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float(_SkyboxUVMap_13bfea43f71f40ad88a4532bb2fae472, _SkyboxUVMap_13bfea43f71f40ad88a4532bb2fae472_UV_0_Vector2);
float _Split_59560823cbbb48ec91fc78cc73fa90e5_R_1_Float = _SkyboxUVMap_13bfea43f71f40ad88a4532bb2fae472_UV_0_Vector2[0];
float _Split_59560823cbbb48ec91fc78cc73fa90e5_G_2_Float = _SkyboxUVMap_13bfea43f71f40ad88a4532bb2fae472_UV_0_Vector2[1];
float _Split_59560823cbbb48ec91fc78cc73fa90e5_B_3_Float = 0;
float _Split_59560823cbbb48ec91fc78cc73fa90e5_A_4_Float = 0;
float _Absolute_a4476f8bba794d9b850381d5f9105445_Out_1_Float;
Unity_Absolute_float(_Split_59560823cbbb48ec91fc78cc73fa90e5_G_2_Float, _Absolute_a4476f8bba794d9b850381d5f9105445_Out_1_Float);
float _OneMinus_e944248454554725baaa777618bf5d88_Out_1_Float;
Unity_OneMinus_float(_Absolute_a4476f8bba794d9b850381d5f9105445_Out_1_Float, _OneMinus_e944248454554725baaa777618bf5d88_Out_1_Float);
float _Property_2b3064541f8f49b79b3c9a4cca6a9aff_Out_0_Float = Vector1_57fc82054d2c4fa2992cdacd511a2c0b;
float _Power_f5d15e5cbce941ad94ba8e3b6674d925_Out_2_Float;
Unity_Power_float(_OneMinus_e944248454554725baaa777618bf5d88_Out_1_Float, _Property_2b3064541f8f49b79b3c9a4cca6a9aff_Out_0_Float, _Power_f5d15e5cbce941ad94ba8e3b6674d925_Out_2_Float);
float _OneMinus_4e85fd25b58743edb9d72d28704b00cd_Out_1_Float;
Unity_OneMinus_float(_Power_f5d15e5cbce941ad94ba8e3b6674d925_Out_2_Float, _OneMinus_4e85fd25b58743edb9d72d28704b00cd_Out_1_Float);
float2 _Vector2_fadc8f76a1704b60a2d3ebffe173cc06_Out_0_Vector2 = float2(_OneMinus_4e85fd25b58743edb9d72d28704b00cd_Out_1_Float, 1);
float _Remap_c112ac1ff86b4ab09ad2933a446a0657_Out_3_Float;
Unity_Remap_float(_Remap_5f8e2443ea7e42a8924e9fce46542e5b_Out_3_Float, _Vector2_fadc8f76a1704b60a2d3ebffe173cc06_Out_0_Vector2, float2 (0, 1), _Remap_c112ac1ff86b4ab09ad2933a446a0657_Out_3_Float);
float _Saturate_dc5b819176ba46488b45ca99106767a9_Out_1_Float;
Unity_Saturate_float(_Remap_c112ac1ff86b4ab09ad2933a446a0657_Out_3_Float, _Saturate_dc5b819176ba46488b45ca99106767a9_Out_1_Float);
float _OneMinus_089c64fa5834499a891ecd02afd531b1_Out_1_Float;
Unity_OneMinus_float(_Saturate_dc5b819176ba46488b45ca99106767a9_Out_1_Float, _OneMinus_089c64fa5834499a891ecd02afd531b1_Out_1_Float);
float _Property_3c31dd047c3549a8908f7ab400c2d133_Out_0_Float = _Shading_Intensity;
float _OneMinus_1194c9269ed84a5fb1d55c5697186da6_Out_1_Float;
Unity_OneMinus_float(_Property_3c31dd047c3549a8908f7ab400c2d133_Out_0_Float, _OneMinus_1194c9269ed84a5fb1d55c5697186da6_Out_1_Float);
float2 _Vector2_63d20c939e164107bff6cc1dd8ad38e4_Out_0_Vector2 = float2(_OneMinus_1194c9269ed84a5fb1d55c5697186da6_Out_1_Float, 1);
float _Remap_de37e21140df4472b39dd5d671947e0d_Out_3_Float;
Unity_Remap_float(_OneMinus_089c64fa5834499a891ecd02afd531b1_Out_1_Float, float2 (0, 1), _Vector2_63d20c939e164107bff6cc1dd8ad38e4_Out_0_Vector2, _Remap_de37e21140df4472b39dd5d671947e0d_Out_3_Float);
float4 _Multiply_e58f243bf3bf42e497454d3fecd0f0ea_Out_2_Vector4;
Unity_Multiply_float4_float4(_Multiply_f7b914d1c1364230b108419f51af3ca1_Out_2_Vector4, (_Remap_de37e21140df4472b39dd5d671947e0d_Out_3_Float.xxxx), _Multiply_e58f243bf3bf42e497454d3fecd0f0ea_Out_2_Vector4);
float4 _Add_e3ee827f4f604a66bd293b74f96921b6_Out_2_Vector4;
Unity_Add_float4(_Multiply_ff2662508bd9472e95f7f7b7b97618b9_Out_2_Vector4, _Multiply_e58f243bf3bf42e497454d3fecd0f0ea_Out_2_Vector4, _Add_e3ee827f4f604a66bd293b74f96921b6_Out_2_Vector4);
float4 _Branch_ed22fb43a3794283b707e4f740ba80cf_Out_3_Vector4;
Unity_Branch_float4(_Property_60e119ffa1484d368b8bc763e3d4a971_Out_0_Boolean, _Add_e3ee827f4f604a66bd293b74f96921b6_Out_2_Vector4, float4(0, 0, 0, 0), _Branch_ed22fb43a3794283b707e4f740ba80cf_Out_3_Vector4);
float _Property_733d0a070e53437a9cc58fbbe3b18c5c_Out_0_Boolean = _Enabled;
float _Property_079bc17e9c8f4ca5823d4bb74274d229_Out_0_Float = _Cloud_Opacity;
float _Property_cf90da333b974e1887dade7f0bbde2a9_Out_0_Float = Vector1_76f188f8a1a240a49a8071b17c757983;
float _OneMinus_e4b4149d6bc3429493c85e69271685f8_Out_1_Float;
Unity_OneMinus_float(_Property_cf90da333b974e1887dade7f0bbde2a9_Out_0_Float, _OneMinus_e4b4149d6bc3429493c85e69271685f8_Out_1_Float);
float2 _Vector2_b535219479a04cddb2333d064524e4d6_Out_0_Vector2 = float2(0, _OneMinus_e4b4149d6bc3429493c85e69271685f8_Out_1_Float);
float _Remap_4c43d7fa8ba14a49a9df51ac3b06afaf_Out_3_Float;
Unity_Remap_float(_Saturate_dc5b819176ba46488b45ca99106767a9_Out_1_Float, _Vector2_b535219479a04cddb2333d064524e4d6_Out_0_Vector2, float2 (0, 1), _Remap_4c43d7fa8ba14a49a9df51ac3b06afaf_Out_3_Float);
float _Saturate_f2bec94517d147709f8f34e26b908b40_Out_1_Float;
Unity_Saturate_float(_Remap_4c43d7fa8ba14a49a9df51ac3b06afaf_Out_3_Float, _Saturate_f2bec94517d147709f8f34e26b908b40_Out_1_Float);
float _Multiply_b81ff9a188a3471e84e4fc654829b13b_Out_2_Float;
Unity_Multiply_float_float(_Property_079bc17e9c8f4ca5823d4bb74274d229_Out_0_Float, _Saturate_f2bec94517d147709f8f34e26b908b40_Out_1_Float, _Multiply_b81ff9a188a3471e84e4fc654829b13b_Out_2_Float);
float _Branch_3c0323dff709451bb92f23f02eb03a4a_Out_3_Float;
Unity_Branch_float(_Property_733d0a070e53437a9cc58fbbe3b18c5c_Out_0_Boolean, _Multiply_b81ff9a188a3471e84e4fc654829b13b_Out_2_Float, 0, _Branch_3c0323dff709451bb92f23f02eb03a4a_Out_3_Float);
Color_2 = (_Branch_ed22fb43a3794283b707e4f740ba80cf_Out_3_Vector4.xyz);
Alpha_1 = _Branch_3c0323dff709451bb92f23f02eb03a4a_Out_3_Float;
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_bb2a1119a3a94855934ae0c7d47269b8_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_GroundColor) : _GroundColor;
float _Property_4e191a8624864725ae3250c4cd5ef251_Out_0_Float = _SunFalloff;
float _Property_59991196789c4066bc355a8251e0c88a_Out_0_Float = _SunFalloffIntensity;
float4 _Property_02ec90f7dfd14d538867d451307e61fa_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SunColorHorizon) : _SunColorHorizon;
float4 _Property_38ab47f27ebf48d8b4ce97b9745861db_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SunColorZenith) : _SunColorZenith;
float _Property_9ffe745a8d0e4b2fb7b10be387831aa9_Out_0_Float = _SunsetHorizontalFalloff;
float _Property_0e1f4c62c84b4b308daa717e315c9366_Out_0_Float = _SunsetVerticalFalloff;
float _Property_11678814fae3491597351ffe548908a1_Out_0_Float = _SunsetIntensity;
float _Property_b3adf223ffec470bac65ce8ed2cdd782_Out_0_Float = _SunsetRadialFalloff;
float _Property_cea7d8ea7f75475e8749021e87130a9b_Out_0_Boolean = _SunSkyLightingEnabled;
float _Property_137e29c7e80546bb9666cc4eea3b3483_Out_0_Float = _SunAngularDiameter;
float _Property_ae0462e8fcbe4f8a8d302df3b8af9209_Out_0_Boolean = _Sun_Enabled;
Bindings_SuperSimpleSun_a3132549029d16442b5fad27df2d1dfb_float _SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336;
_SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
_SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336_SunDiscColor_1_Vector3;
float _SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336_SunDiscAlpha_2_Float;
float3 _SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336_Falloff_3_Vector3;
SG_SuperSimpleSun_a3132549029d16442b5fad27df2d1dfb_float(_Property_4e191a8624864725ae3250c4cd5ef251_Out_0_Float, _Property_59991196789c4066bc355a8251e0c88a_Out_0_Float, _Property_02ec90f7dfd14d538867d451307e61fa_Out_0_Vector4, _Property_38ab47f27ebf48d8b4ce97b9745861db_Out_0_Vector4, _Property_9ffe745a8d0e4b2fb7b10be387831aa9_Out_0_Float, _Property_0e1f4c62c84b4b308daa717e315c9366_Out_0_Float, _Property_11678814fae3491597351ffe548908a1_Out_0_Float, _Property_b3adf223ffec470bac65ce8ed2cdd782_Out_0_Float, _Property_cea7d8ea7f75475e8749021e87130a9b_Out_0_Boolean, _Property_137e29c7e80546bb9666cc4eea3b3483_Out_0_Float, _Property_ae0462e8fcbe4f8a8d302df3b8af9209_Out_0_Boolean, _SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336, _SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336_SunDiscColor_1_Vector3, _SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336_SunDiscAlpha_2_Float, _SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336_Falloff_3_Vector3);
UnityTexture2D _Property_35e2af45556d4c61aac98518723e239a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_StarTexture);
float _Property_4d14d929f9db486d8c8a22df18de9c0d_Out_0_Float = _StarHorizonFalloff;
float _Property_16eb41575cde4841baef1e12b2c23b29_Out_0_Float = _StarScale;
float _Property_89c1965db4e44cd787257d3b4ae7a35c_Out_0_Float = _StarSpeed;
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_787f84c80ce04fb5bd418908b3b38782;
float3 _GetLights_787f84c80ce04fb5bd418908b3b38782_SunDirection_0_Vector3;
float3 _GetLights_787f84c80ce04fb5bd418908b3b38782_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_787f84c80ce04fb5bd418908b3b38782, _GetLights_787f84c80ce04fb5bd418908b3b38782_SunDirection_0_Vector3, _GetLights_787f84c80ce04fb5bd418908b3b38782_MoonDirection_1_Vector3);
float _Property_ae913b673bb24789b7340ab1f32f8657_Out_0_Float = _StarDaytimeBrightness;
float _Property_7f9a6b61f28a4875a3fa358aecd2a268_Out_0_Float = _StarIntensity;
float _Property_c17b558ec2e54850bf933566744484fa_Out_0_Boolean = _ProceduralStarsEnabled;
float _Property_02d1f447f6e34c14a1d890e2c9be8f10_Out_0_Float = _StarSaturation;
float _Property_8c250503ccb348cebcd343af94d61f40_Out_0_Boolean = _Stars_Enabled;
float _Property_e82817321ae346de83b7c32153a93d8e_Out_0_Boolean = _Constant_Color_Mode;
float _Property_3569a15a025844c293cb66cd200d71da_Out_0_Float = _StarSharpness;
float _Property_62a11d53b4e34710ac321b269a7c707c_Out_0_Float = _StarFrequency;
float _Property_017f8bc2c1de4e94a135b99c31069560_Out_0_Boolean = _Use_Texture_Stars;
float4 _Property_d6065fa34144444cad72b9e0ad6bbbce_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Star_Texture_Tint) : _Star_Texture_Tint;
Bindings_SuperSimpleStars_e6cb6a8c68f031b4ba1c3ab79a9be02d_float _SuperSimpleStars_99a54db92f7c4fcfbb664d3690c89c9d;
_SuperSimpleStars_99a54db92f7c4fcfbb664d3690c89c9d.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
_SuperSimpleStars_99a54db92f7c4fcfbb664d3690c89c9d.TimeParameters = IN.TimeParameters;
float3 _SuperSimpleStars_99a54db92f7c4fcfbb664d3690c89c9d_Out_1_Vector3;
SG_SuperSimpleStars_e6cb6a8c68f031b4ba1c3ab79a9be02d_float(_Property_35e2af45556d4c61aac98518723e239a_Out_0_Texture2D, _Property_4d14d929f9db486d8c8a22df18de9c0d_Out_0_Float, _Property_16eb41575cde4841baef1e12b2c23b29_Out_0_Float, _Property_89c1965db4e44cd787257d3b4ae7a35c_Out_0_Float, (float4(_GetLights_787f84c80ce04fb5bd418908b3b38782_SunDirection_0_Vector3, 1.0)), _Property_ae913b673bb24789b7340ab1f32f8657_Out_0_Float, _Property_7f9a6b61f28a4875a3fa358aecd2a268_Out_0_Float, _Property_c17b558ec2e54850bf933566744484fa_Out_0_Boolean, _Property_02d1f447f6e34c14a1d890e2c9be8f10_Out_0_Float, _Property_8c250503ccb348cebcd343af94d61f40_Out_0_Boolean, _Property_e82817321ae346de83b7c32153a93d8e_Out_0_Boolean, _Property_3569a15a025844c293cb66cd200d71da_Out_0_Float, _Property_62a11d53b4e34710ac321b269a7c707c_Out_0_Float, _Property_017f8bc2c1de4e94a135b99c31069560_Out_0_Boolean, _Property_d6065fa34144444cad72b9e0ad6bbbce_Out_0_Vector4, _SuperSimpleStars_99a54db92f7c4fcfbb664d3690c89c9d, _SuperSimpleStars_99a54db92f7c4fcfbb664d3690c89c9d_Out_1_Vector3);
float4 _Property_fefb1e2741e64544a9e7ea63eec8fe91_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_HorizonColorNight) : _HorizonColorNight;
float4 _Property_f287268ed9cd40a4aa03cb0eca75886d_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SkyColorNight) : _SkyColorNight;
Bindings_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float _SkyboxUVMap_b48175f092aa40a6a758818dfd9ea45b;
_SkyboxUVMap_b48175f092aa40a6a758818dfd9ea45b.ObjectSpacePosition = IN.ObjectSpacePosition;
float2 _SkyboxUVMap_b48175f092aa40a6a758818dfd9ea45b_UV_0_Vector2;
SG_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float(_SkyboxUVMap_b48175f092aa40a6a758818dfd9ea45b, _SkyboxUVMap_b48175f092aa40a6a758818dfd9ea45b_UV_0_Vector2);
float _Split_45670360e6084d0393b8eea3f3b6ad53_R_1_Float = _SkyboxUVMap_b48175f092aa40a6a758818dfd9ea45b_UV_0_Vector2[0];
float _Split_45670360e6084d0393b8eea3f3b6ad53_G_2_Float = _SkyboxUVMap_b48175f092aa40a6a758818dfd9ea45b_UV_0_Vector2[1];
float _Split_45670360e6084d0393b8eea3f3b6ad53_B_3_Float = 0;
float _Split_45670360e6084d0393b8eea3f3b6ad53_A_4_Float = 0;
float _Absolute_2d987b174d9d480dbf2653de1e22d977_Out_1_Float;
Unity_Absolute_float(_Split_45670360e6084d0393b8eea3f3b6ad53_G_2_Float, _Absolute_2d987b174d9d480dbf2653de1e22d977_Out_1_Float);
float _Saturate_f3bd295b456047d78e8262a48bf6199f_Out_1_Float;
Unity_Saturate_float(_Absolute_2d987b174d9d480dbf2653de1e22d977_Out_1_Float, _Saturate_f3bd295b456047d78e8262a48bf6199f_Out_1_Float);
float _Property_79ba791b59e34ef39643ad687d057a5d_Out_0_Float = _SkyColorBlend;
float _Power_3b07bbc0261f41ab84c2ad1077ff27ed_Out_2_Float;
Unity_Power_float(_Saturate_f3bd295b456047d78e8262a48bf6199f_Out_1_Float, _Property_79ba791b59e34ef39643ad687d057a5d_Out_0_Float, _Power_3b07bbc0261f41ab84c2ad1077ff27ed_Out_2_Float);
float4 _Lerp_a271a554e932422d9c357cfb38aeb0c6_Out_3_Vector4;
Unity_Lerp_float4(_Property_fefb1e2741e64544a9e7ea63eec8fe91_Out_0_Vector4, _Property_f287268ed9cd40a4aa03cb0eca75886d_Out_0_Vector4, (_Power_3b07bbc0261f41ab84c2ad1077ff27ed_Out_2_Float.xxxx), _Lerp_a271a554e932422d9c357cfb38aeb0c6_Out_3_Vector4);
float4 _Property_543ab66d0dcd4ae197380cd25847fc88_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_HorizonColorDay) : _HorizonColorDay;
float4 _Property_b13244b377214e5b8ce0a9f439ed991d_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SkyColorDay) : _SkyColorDay;
float4 _Lerp_6e984e00c6fa4a85aaa428cbbb34341b_Out_3_Vector4;
Unity_Lerp_float4(_Property_543ab66d0dcd4ae197380cd25847fc88_Out_0_Vector4, _Property_b13244b377214e5b8ce0a9f439ed991d_Out_0_Vector4, (_Power_3b07bbc0261f41ab84c2ad1077ff27ed_Out_2_Float.xxxx), _Lerp_6e984e00c6fa4a85aaa428cbbb34341b_Out_3_Vector4);
float _Property_1e1417f540c74f0ea417f87919066421_Out_0_Boolean = _Constant_Color_Mode;
Bindings_GetLights_ff805950c4775b041a84e7e55c7e3975_float _GetLights_304ddaba97b54640b328dbe57e23345d;
float3 _GetLights_304ddaba97b54640b328dbe57e23345d_SunDirection_0_Vector3;
float3 _GetLights_304ddaba97b54640b328dbe57e23345d_MoonDirection_1_Vector3;
SG_GetLights_ff805950c4775b041a84e7e55c7e3975_float(_GetLights_304ddaba97b54640b328dbe57e23345d, _GetLights_304ddaba97b54640b328dbe57e23345d_SunDirection_0_Vector3, _GetLights_304ddaba97b54640b328dbe57e23345d_MoonDirection_1_Vector3);
float _Split_2c56d446d80646f7834987fd375599c0_R_1_Float = _GetLights_304ddaba97b54640b328dbe57e23345d_SunDirection_0_Vector3[0];
float _Split_2c56d446d80646f7834987fd375599c0_G_2_Float = _GetLights_304ddaba97b54640b328dbe57e23345d_SunDirection_0_Vector3[1];
float _Split_2c56d446d80646f7834987fd375599c0_B_3_Float = _GetLights_304ddaba97b54640b328dbe57e23345d_SunDirection_0_Vector3[2];
float _Split_2c56d446d80646f7834987fd375599c0_A_4_Float = 0;
float _Smoothstep_4105cb2ecbaa4f4b8bc57ad6f861470e_Out_3_Float;
Unity_Smoothstep_float(-0.3, 0, _Split_2c56d446d80646f7834987fd375599c0_G_2_Float, _Smoothstep_4105cb2ecbaa4f4b8bc57ad6f861470e_Out_3_Float);
float _Branch_8374936d85f24a4da0fb409c093864ff_Out_3_Float;
Unity_Branch_float(_Property_1e1417f540c74f0ea417f87919066421_Out_0_Boolean, 1, _Smoothstep_4105cb2ecbaa4f4b8bc57ad6f861470e_Out_3_Float, _Branch_8374936d85f24a4da0fb409c093864ff_Out_3_Float);
float4 _Lerp_49385f25dd4e412995ef46ade121a983_Out_3_Vector4;
Unity_Lerp_float4(_Lerp_a271a554e932422d9c357cfb38aeb0c6_Out_3_Vector4, _Lerp_6e984e00c6fa4a85aaa428cbbb34341b_Out_3_Vector4, (_Branch_8374936d85f24a4da0fb409c093864ff_Out_3_Float.xxxx), _Lerp_49385f25dd4e412995ef46ade121a983_Out_3_Vector4);
float _Property_74673acfd3fb4491892da841db340ec9_Out_0_Float = _HorizonSaturationAmount;
float3 _Saturation_826bd3bea97341809983430a6c027e72_Out_2_Vector3;
Unity_Saturation_float((_Lerp_49385f25dd4e412995ef46ade121a983_Out_3_Vector4.xyz), _Property_74673acfd3fb4491892da841db340ec9_Out_0_Float, _Saturation_826bd3bea97341809983430a6c027e72_Out_2_Vector3);
Bindings_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float _SkyboxUVMap_b4cf5268e1f44dad9a9b2e77ce66a9b1;
_SkyboxUVMap_b4cf5268e1f44dad9a9b2e77ce66a9b1.ObjectSpacePosition = IN.ObjectSpacePosition;
float2 _SkyboxUVMap_b4cf5268e1f44dad9a9b2e77ce66a9b1_UV_0_Vector2;
SG_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float(_SkyboxUVMap_b4cf5268e1f44dad9a9b2e77ce66a9b1, _SkyboxUVMap_b4cf5268e1f44dad9a9b2e77ce66a9b1_UV_0_Vector2);
float _Split_e0c435f5ee9b4cb38d90f5494195cef5_R_1_Float = _SkyboxUVMap_b4cf5268e1f44dad9a9b2e77ce66a9b1_UV_0_Vector2[0];
float _Split_e0c435f5ee9b4cb38d90f5494195cef5_G_2_Float = _SkyboxUVMap_b4cf5268e1f44dad9a9b2e77ce66a9b1_UV_0_Vector2[1];
float _Split_e0c435f5ee9b4cb38d90f5494195cef5_B_3_Float = 0;
float _Split_e0c435f5ee9b4cb38d90f5494195cef5_A_4_Float = 0;
float _Absolute_6a3b416d74ac43b5a7dd4418e4437e62_Out_1_Float;
Unity_Absolute_float(_Split_e0c435f5ee9b4cb38d90f5494195cef5_G_2_Float, _Absolute_6a3b416d74ac43b5a7dd4418e4437e62_Out_1_Float);
float _Saturate_2781dbb2fbb847759f07c45baea6967a_Out_1_Float;
Unity_Saturate_float(_Absolute_6a3b416d74ac43b5a7dd4418e4437e62_Out_1_Float, _Saturate_2781dbb2fbb847759f07c45baea6967a_Out_1_Float);
float _OneMinus_08c73dd5b0bc4fcebf2554a3fe7877ce_Out_1_Float;
Unity_OneMinus_float(_Saturate_2781dbb2fbb847759f07c45baea6967a_Out_1_Float, _OneMinus_08c73dd5b0bc4fcebf2554a3fe7877ce_Out_1_Float);
float _Absolute_aabc5ea2ed5a468c839488ad4b2e6fbc_Out_1_Float;
Unity_Absolute_float(_OneMinus_08c73dd5b0bc4fcebf2554a3fe7877ce_Out_1_Float, _Absolute_aabc5ea2ed5a468c839488ad4b2e6fbc_Out_1_Float);
float _Property_df1dec7f374c41019a5a6c63598f92f4_Out_0_Float = _HorizonSaturationFalloff;
float _Multiply_bffa094afc9b42c3bccfed24a51eb32f_Out_2_Float;
Unity_Multiply_float_float(_Property_df1dec7f374c41019a5a6c63598f92f4_Out_0_Float, _Property_df1dec7f374c41019a5a6c63598f92f4_Out_0_Float, _Multiply_bffa094afc9b42c3bccfed24a51eb32f_Out_2_Float);
float _Power_6d540ce942444a9fa07400c47db79551_Out_2_Float;
Unity_Power_float(_Absolute_aabc5ea2ed5a468c839488ad4b2e6fbc_Out_1_Float, _Multiply_bffa094afc9b42c3bccfed24a51eb32f_Out_2_Float, _Power_6d540ce942444a9fa07400c47db79551_Out_2_Float);
float3 _Lerp_6e7832b1648c4916a87daec0217cc40a_Out_3_Vector3;
Unity_Lerp_float3((_Lerp_49385f25dd4e412995ef46ade121a983_Out_3_Vector4.xyz), _Saturation_826bd3bea97341809983430a6c027e72_Out_2_Vector3, (_Power_6d540ce942444a9fa07400c47db79551_Out_2_Float.xxx), _Lerp_6e7832b1648c4916a87daec0217cc40a_Out_3_Vector3);
float3 _Add_05ef036db725499bbbc55b174e159c44_Out_2_Vector3;
Unity_Add_float3(_SuperSimpleStars_99a54db92f7c4fcfbb664d3690c89c9d_Out_1_Vector3, _Lerp_6e7832b1648c4916a87daec0217cc40a_Out_3_Vector3, _Add_05ef036db725499bbbc55b174e159c44_Out_2_Vector3);
float3 _Lerp_79c213c1fc0b483cafa951dfd4a0339c_Out_3_Vector3;
Unity_Lerp_float3(_Add_05ef036db725499bbbc55b174e159c44_Out_2_Vector3, _SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336_SunDiscColor_1_Vector3, (_SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336_SunDiscAlpha_2_Float.xxx), _Lerp_79c213c1fc0b483cafa951dfd4a0339c_Out_3_Vector3);
float _Property_0d278ee6007442f485bf3e311eac6a3a_Out_0_Float = _MoonFalloff;
float4 _Property_c206fd16dbd546f39fc17eb3d23d8a85_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_MoonColor) : _MoonColor;
float _Property_997f017d153c431998ad74523e179f24_Out_0_Float = _MoonAngularDiameter;
float _Property_dd392c4503a848859d7481ce407fae05_Out_0_Boolean = _Moon_Enabled;
Bindings_SuperSimpleMoon_70141643167b638499823de61c9e3f1d_float _SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff;
_SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
float3 _SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff_Falloff_1_Vector3;
float3 _SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff_MoonDiscColor_2_Vector3;
float _SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff_MoonDiscAlpha_3_Float;
SG_SuperSimpleMoon_70141643167b638499823de61c9e3f1d_float(_Property_0d278ee6007442f485bf3e311eac6a3a_Out_0_Float, _Property_c206fd16dbd546f39fc17eb3d23d8a85_Out_0_Vector4, _Property_997f017d153c431998ad74523e179f24_Out_0_Float, _Property_dd392c4503a848859d7481ce407fae05_Out_0_Boolean, _SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff, _SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff_Falloff_1_Vector3, _SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff_MoonDiscColor_2_Vector3, _SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff_MoonDiscAlpha_3_Float);
float3 _Lerp_92179b9b5461478ebde926cd1e793253_Out_3_Vector3;
Unity_Lerp_float3(_Lerp_79c213c1fc0b483cafa951dfd4a0339c_Out_3_Vector3, _SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff_MoonDiscColor_2_Vector3, (_SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff_MoonDiscAlpha_3_Float.xxx), _Lerp_92179b9b5461478ebde926cd1e793253_Out_3_Vector3);
float3 _Add_b2877f45d1e44ded911215d792b80787_Out_2_Vector3;
Unity_Add_float3(_Lerp_92179b9b5461478ebde926cd1e793253_Out_3_Vector3, _SuperSimpleMoon_c3ba4eb94dd34c3ab442bfb0dd765aff_Falloff_1_Vector3, _Add_b2877f45d1e44ded911215d792b80787_Out_2_Vector3);
float3 _Add_7be27328a6794f788a1be925054aa224_Out_2_Vector3;
Unity_Add_float3(_SuperSimpleSun_f5c80f05606d4d0892585d23b84d8336_Falloff_3_Vector3, _Add_b2877f45d1e44ded911215d792b80787_Out_2_Vector3, _Add_7be27328a6794f788a1be925054aa224_Out_2_Vector3);
UnityTexture2D _Property_2b2d3b76006d49d9887e16dcd0b84905_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CloudTexture);
float _Property_a68b76b0ccc640aebb7733b3ad8a1ea6_Out_0_Float = _CloudFalloff;
float2 _Property_a05cf4003fa541e8aa529a8e0eb0434c_Out_0_Vector2 = _CloudScale;
float2 _Property_caf042d9afaf4b279940ee6bdc37696c_Out_0_Vector2 = _CloudWindSpeed;
float _Property_e87dea65b3b54eaf85054050e54b5bf4_Out_0_Float = _Cloudiness;
float _Property_c8280e6a4c6649f5ab613b1099603326_Out_0_Float = _CloudSharpness;
float4 _Property_4418d3d18fed4884a9682d9e4f16b71b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CloudColorDay) : _CloudColorDay;
float4 _Property_671126c06bc24c7181346180b078fa35_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CloudColorNight) : _CloudColorNight;
float _Property_a9702817247a49f19f2e902ef542d155_Out_0_Boolean = _Clouds_Enabled;
float _Property_222d4aa7202b450b9e2cf4f6340ada3b_Out_0_Boolean = _Constant_Color_Mode;
float _Property_fb26c7e9e71740ef835a7bccd76ec4c9_Out_0_Float = _Shading_Intensity;
float _Property_ce1815833dd44624b449b060135aa9af_Out_0_Float = _CloudOpacity;
float _Property_bc7a430ab4d249dab6d1d473ffb5fc43_Out_0_Float = _Cloud_Iterations;
float _Property_31dd255036594529961695a5ae65abb1_Out_0_Float = _Cloud_Gain;
float _Property_3fb0633fca544429b2234a267066e0e0_Out_0_Float = _Cloud_Lacunarity;
Bindings_SuperSimpleClouds_cf3facbd665dd47478e6d26e508dc671_float _SuperSimpleClouds_e1e0491b480a4e95a73ea82f74259df1;
_SuperSimpleClouds_e1e0491b480a4e95a73ea82f74259df1.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
_SuperSimpleClouds_e1e0491b480a4e95a73ea82f74259df1.ObjectSpacePosition = IN.ObjectSpacePosition;
float3 _SuperSimpleClouds_e1e0491b480a4e95a73ea82f74259df1_Color_2_Vector3;
float _SuperSimpleClouds_e1e0491b480a4e95a73ea82f74259df1_Alpha_1_Float;
SG_SuperSimpleClouds_cf3facbd665dd47478e6d26e508dc671_float(_Property_2b2d3b76006d49d9887e16dcd0b84905_Out_0_Texture2D, _Property_a68b76b0ccc640aebb7733b3ad8a1ea6_Out_0_Float, _Property_a05cf4003fa541e8aa529a8e0eb0434c_Out_0_Vector2, _Property_caf042d9afaf4b279940ee6bdc37696c_Out_0_Vector2, _Property_e87dea65b3b54eaf85054050e54b5bf4_Out_0_Float, _Property_c8280e6a4c6649f5ab613b1099603326_Out_0_Float, _Property_4418d3d18fed4884a9682d9e4f16b71b_Out_0_Vector4, _Property_671126c06bc24c7181346180b078fa35_Out_0_Vector4, _Property_a9702817247a49f19f2e902ef542d155_Out_0_Boolean, _Property_222d4aa7202b450b9e2cf4f6340ada3b_Out_0_Boolean, _Property_fb26c7e9e71740ef835a7bccd76ec4c9_Out_0_Float, (float4(_Lerp_6e7832b1648c4916a87daec0217cc40a_Out_3_Vector3, 1.0)), _Property_ce1815833dd44624b449b060135aa9af_Out_0_Float, _Property_bc7a430ab4d249dab6d1d473ffb5fc43_Out_0_Float, _Property_31dd255036594529961695a5ae65abb1_Out_0_Float, _Property_3fb0633fca544429b2234a267066e0e0_Out_0_Float, _SuperSimpleClouds_e1e0491b480a4e95a73ea82f74259df1, _SuperSimpleClouds_e1e0491b480a4e95a73ea82f74259df1_Color_2_Vector3, _SuperSimpleClouds_e1e0491b480a4e95a73ea82f74259df1_Alpha_1_Float);
float3 _Lerp_b6948952958d4284b416d7db0c9ef85e_Out_3_Vector3;
Unity_Lerp_float3(_Add_7be27328a6794f788a1be925054aa224_Out_2_Vector3, _SuperSimpleClouds_e1e0491b480a4e95a73ea82f74259df1_Color_2_Vector3, (_SuperSimpleClouds_e1e0491b480a4e95a73ea82f74259df1_Alpha_1_Float.xxx), _Lerp_b6948952958d4284b416d7db0c9ef85e_Out_3_Vector3);
float _Property_f0aaffe54631477da6d87bb465fdc074_Out_0_Boolean = _GroundEnabled;
float _Property_ba628c27c35f4b349c11a50ae37480b8_Out_0_Float = _Ground_Height;
float _Property_4ac5daecc5504de6a6843ecd600055d6_Out_0_Float = _GroundFadeAmount;
float _Add_f248b03263d545fea892aafeb3044f2c_Out_2_Float;
Unity_Add_float(_Property_ba628c27c35f4b349c11a50ae37480b8_Out_0_Float, _Property_4ac5daecc5504de6a6843ecd600055d6_Out_0_Float, _Add_f248b03263d545fea892aafeb3044f2c_Out_2_Float);
Bindings_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float _SkyboxUVMap_12c658208fbb4d558078e5461b9c38d3;
_SkyboxUVMap_12c658208fbb4d558078e5461b9c38d3.ObjectSpacePosition = IN.ObjectSpacePosition;
float2 _SkyboxUVMap_12c658208fbb4d558078e5461b9c38d3_UV_0_Vector2;
SG_SkyboxUVMap_03ed8d52d303ab446b07faff69e10ebe_float(_SkyboxUVMap_12c658208fbb4d558078e5461b9c38d3, _SkyboxUVMap_12c658208fbb4d558078e5461b9c38d3_UV_0_Vector2);
float _Split_8413904edfd24b9081db50aede18fd85_R_1_Float = _SkyboxUVMap_12c658208fbb4d558078e5461b9c38d3_UV_0_Vector2[0];
float _Split_8413904edfd24b9081db50aede18fd85_G_2_Float = _SkyboxUVMap_12c658208fbb4d558078e5461b9c38d3_UV_0_Vector2[1];
float _Split_8413904edfd24b9081db50aede18fd85_B_3_Float = 0;
float _Split_8413904edfd24b9081db50aede18fd85_A_4_Float = 0;
float _Negate_15afbbaa75bb45c39ef2e07479de4294_Out_1_Float;
Unity_Negate_float(_Split_8413904edfd24b9081db50aede18fd85_G_2_Float, _Negate_15afbbaa75bb45c39ef2e07479de4294_Out_1_Float);
float _Smoothstep_2be9f89ad7484212a2cb66a65c33601e_Out_3_Float;
Unity_Smoothstep_float(_Property_ba628c27c35f4b349c11a50ae37480b8_Out_0_Float, _Add_f248b03263d545fea892aafeb3044f2c_Out_2_Float, _Negate_15afbbaa75bb45c39ef2e07479de4294_Out_1_Float, _Smoothstep_2be9f89ad7484212a2cb66a65c33601e_Out_3_Float);
float _Branch_d287593791284b7eb2fffe9cd4549830_Out_3_Float;
Unity_Branch_float(_Property_f0aaffe54631477da6d87bb465fdc074_Out_0_Boolean, _Smoothstep_2be9f89ad7484212a2cb66a65c33601e_Out_3_Float, 1, _Branch_d287593791284b7eb2fffe9cd4549830_Out_3_Float);
float3 _Lerp_049a91f07cf94e11ad676bbe94e29a2d_Out_3_Vector3;
Unity_Lerp_float3((_Property_bb2a1119a3a94855934ae0c7d47269b8_Out_0_Vector4.xyz), _Lerp_b6948952958d4284b416d7db0c9ef85e_Out_3_Vector3, (_Branch_d287593791284b7eb2fffe9cd4549830_Out_3_Float.xxx), _Lerp_049a91f07cf94e11ad676bbe94e29a2d_Out_3_Vector3);
// patched: with Sun/Moon/Clouds/Ground all disabled in this material, some of the generated
// graph math (division in the sun falloff terms) evaluates to NaN even though its branch is
// "off" - IEEE float multiply-by-zero on a NaN is still NaN, so it can silently poison the
// final lerp and the whole sky renders solid white in the Player even though the Editor
// preview doesn't show it. Sanitize before output.
float3 _FinalSkyColor_Safe = _Lerp_049a91f07cf94e11ad676bbe94e29a2d_Out_3_Vector3;
if (any(isnan(_FinalSkyColor_Safe)) || any(isinf(_FinalSkyColor_Safe)))
{
    _FinalSkyColor_Safe = float3(0.01, 0.01, 0.02);
}
surface.BaseColor = _FinalSkyColor_Safe;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    





    output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
    output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
{
    result.vertex     = float4(attributes.positionOS, 1);
    result.tangent    = attributes.tangentOS;
    result.normal     = attributes.normalOS;
    result.vertex     = float4(vertexDescription.Position, 1);
    result.normal     = vertexDescription.Normal;
    result.tangent    = float4(vertexDescription.Tangent, 0);
    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
}

void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
{
    result.pos = varyings.positionCS;
    result.worldPos = varyings.positionWS;
    // World Tangent isn't an available input on v2f_surf


    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogCoord = varyings.fogFactorAndVertexLight.x;
        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
}

void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
{
    result.positionCS = surfVertex.pos;
    result.positionWS = surfVertex.worldPos;
    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
    // World Tangent isn't an available input on v2f_surf

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

// Render State
Cull Off
Blend One Zero
ZTest LEqual
ZWrite On
ColorMask 0

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 3.0
#pragma multi_compile_shadowcaster
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
// GraphKeywords: <None>

// Defines
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_SHADOWCASTER
#define BUILTIN_TARGET_API 1
#ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
#define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
#endif
#ifdef _BUILTIN_ALPHATEST_ON
#define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
#endif
#ifdef _BUILTIN_AlphaClip
#define _AlphaClip _BUILTIN_AlphaClip
#endif
#ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
#define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
#endif


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
// patched: Shims.hlsl (below) itself includes Common.hlsl (which redefines GLOBAL_CBUFFER_START
// to a 2-argument SRP ray-tracing form) and then UnityShaderVariables.cginc (which still calls
// the classic single-argument form) BACK TO BACK internally - so patching *after* Shims.hlsl is
// too late, the damage and the crash happen inside it. Pre-include Common.hlsl ourselves so its
// include guard is already set, restore the single-argument macro, then let Shims.hlsl's own
// "#include Common.hlsl" become a no-op (guarded) while its UnityShaderVariables.cginc include
// sees our correct definition.
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#undef GLOBAL_CBUFFER_START
#undef GLOBAL_CBUFFER_END
#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) || ((defined(UNITY_SINGLE_PASS_STEREO) || defined(UNITY_STEREO_INSTANCING_ENABLED)) && (defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL)))
    #define GLOBAL_CBUFFER_START(name)    cbuffer name {
    #define GLOBAL_CBUFFER_END            }
#else
    #define GLOBAL_CBUFFER_START(name)    CBUFFER_START(name)
    #define GLOBAL_CBUFFER_END            CBUFFER_END
#endif
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
// patched: Core.hlsl (below) pulls in ShaderVariablesFunctions.hlsl, which - when
// UNITY_SINGLE_PASS_STEREO is defined (true for any XR-capable build target) - redeclares
// TransformStereoScreenSpaceTex() as a real function. Shims.hlsl already pulled in Unity's own
// UnityCG.cginc above, which declares a byte-identical function of the same name under the same
// condition, so this is a flat redefinition error. This skybox never calls either function (it's
// boilerplate from the Shader Graph target template, not skybox-specific code), so it's safe to
// briefly hide UNITY_SINGLE_PASS_STEREO from just this one include: ShaderVariablesFunctions.hlsl
// then takes its non-stereo branch and skips its copy, while everything else it defines is still
// included normally.
#if defined(UNITY_SINGLE_PASS_STEREO)
    #undef UNITY_SINGLE_PASS_STEREO
    #define RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL
#endif
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
#if defined(RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL)
    #undef RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL
    #define UNITY_SINGLE_PASS_STEREO
#endif
// patched: com.unity.render-pipelines.core's Common.hlsl (pulled in by the Core.hlsl include
// above) redefines GLOBAL_CBUFFER_START to take a (name, register) pair for SRP ray tracing.
// Unity's own Built-in UnityShaderVariables.cginc - included transitively below via
// Lighting.hlsl - still calls the classic single-argument GLOBAL_CBUFFER_START(UnityStereoGlobals),
// which is exactly the "too few arguments to a macro call" compile error. Restore the original
// single-argument Built-in RP definition before anything else needs it.
#undef GLOBAL_CBUFFER_START
#undef GLOBAL_CBUFFER_END
#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) || ((defined(UNITY_SINGLE_PASS_STEREO) || defined(UNITY_STEREO_INSTANCING_ENABLED)) && (defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL)))
    #define GLOBAL_CBUFFER_START(name)    cbuffer name {
    #define GLOBAL_CBUFFER_END            }
#else
    #define GLOBAL_CBUFFER_START(name)    CBUFFER_START(name)
    #define GLOBAL_CBUFFER_END            CBUFFER_END
#endif
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Use_Texture_Stars;
float _Ground_Height;
float4 _GroundColor;
float _GroundEnabled;
float _Shading_Intensity;
float _SkyColorBlend;
float4 _HorizonColorDay;
float4 _HorizonColorNight;
float _CloudSharpness;
float _Cloud_Iterations;
float _Cloud_Gain;
float _Cloud_Lacunarity;
float4 _SkyColorNight;
float _HorizonSaturationFalloff;
float _HorizonSaturationAmount;
float4 _SunColorZenith;
float4 _SunColorHorizon;
float _SunFalloffIntensity;
float _SunFalloff;
float _SunsetHorizontalFalloff;
float _SunsetVerticalFalloff;
float _SunsetRadialFalloff;
float _SunsetIntensity;
float4 _CloudTexture_TexelSize;
float2 _CloudWindSpeed;
float _Cloudiness;
float _CloudOpacity;
float _CloudFalloff;
float2 _CloudScale;
float4 _CloudColorDay;
float4 _CloudColorNight;
float4 _StarTexture_TexelSize;
float _StarHorizonFalloff;
float _StarScale;
float _StarSpeed;
float _StarIntensity;
float _StarDaytimeBrightness;
float _MoonAngularDiameter;
float _MoonFalloff;
float4 _MoonColor;
float _SunAngularDiameter;
float _GroundFadeAmount;
float _ProceduralStarsEnabled;
float _StarSaturation;
float _SunSkyLightingEnabled;
float4 _SkyColorDay;
float _Moon_Enabled;
float _Clouds_Enabled;
float _Stars_Enabled;
float _Sun_Enabled;
float _Constant_Color_Mode;
float _StarSharpness;
float _StarFrequency;
float4 _Star_Texture_Tint;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_CloudTexture);
SAMPLER(sampler_CloudTexture);
TEXTURE2D(_StarTexture);
SAMPLER(sampler_StarTexture);

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Includes
// GraphIncludes: <None>

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    






    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
{
    result.vertex     = float4(attributes.positionOS, 1);
    result.tangent    = attributes.tangentOS;
    result.normal     = attributes.normalOS;
    result.vertex     = float4(vertexDescription.Position, 1);
    result.normal     = vertexDescription.Normal;
    result.tangent    = float4(vertexDescription.Tangent, 0);
    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
}

void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
{
    result.pos = varyings.positionCS;
    // World Tangent isn't an available input on v2f_surf


    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogCoord = varyings.fogFactorAndVertexLight.x;
        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
}

void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
{
    result.positionCS = surfVertex.pos;
    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
    // World Tangent isn't an available input on v2f_surf

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

ENDHLSL
}
Pass
{
    Name "SceneSelectionPass"
    Tags
    {
        "LightMode" = "SceneSelectionPass"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 3.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SceneSelectionPass
#define BUILTIN_TARGET_API 1
#define SCENESELECTIONPASS 1
#ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
#define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
#endif
#ifdef _BUILTIN_ALPHATEST_ON
#define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
#endif
#ifdef _BUILTIN_AlphaClip
#define _AlphaClip _BUILTIN_AlphaClip
#endif
#ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
#define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
#endif


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
// patched: Shims.hlsl (below) itself includes Common.hlsl (which redefines GLOBAL_CBUFFER_START
// to a 2-argument SRP ray-tracing form) and then UnityShaderVariables.cginc (which still calls
// the classic single-argument form) BACK TO BACK internally - so patching *after* Shims.hlsl is
// too late, the damage and the crash happen inside it. Pre-include Common.hlsl ourselves so its
// include guard is already set, restore the single-argument macro, then let Shims.hlsl's own
// "#include Common.hlsl" become a no-op (guarded) while its UnityShaderVariables.cginc include
// sees our correct definition.
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#undef GLOBAL_CBUFFER_START
#undef GLOBAL_CBUFFER_END
#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) || ((defined(UNITY_SINGLE_PASS_STEREO) || defined(UNITY_STEREO_INSTANCING_ENABLED)) && (defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL)))
    #define GLOBAL_CBUFFER_START(name)    cbuffer name {
    #define GLOBAL_CBUFFER_END            }
#else
    #define GLOBAL_CBUFFER_START(name)    CBUFFER_START(name)
    #define GLOBAL_CBUFFER_END            CBUFFER_END
#endif
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
// patched: Core.hlsl (below) pulls in ShaderVariablesFunctions.hlsl, which - when
// UNITY_SINGLE_PASS_STEREO is defined (true for any XR-capable build target) - redeclares
// TransformStereoScreenSpaceTex() as a real function. Shims.hlsl already pulled in Unity's own
// UnityCG.cginc above, which declares a byte-identical function of the same name under the same
// condition, so this is a flat redefinition error. This skybox never calls either function (it's
// boilerplate from the Shader Graph target template, not skybox-specific code), so it's safe to
// briefly hide UNITY_SINGLE_PASS_STEREO from just this one include: ShaderVariablesFunctions.hlsl
// then takes its non-stereo branch and skips its copy, while everything else it defines is still
// included normally.
#if defined(UNITY_SINGLE_PASS_STEREO)
    #undef UNITY_SINGLE_PASS_STEREO
    #define RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL
#endif
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
#if defined(RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL)
    #undef RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL
    #define UNITY_SINGLE_PASS_STEREO
#endif
// patched: com.unity.render-pipelines.core's Common.hlsl (pulled in by the Core.hlsl include
// above) redefines GLOBAL_CBUFFER_START to take a (name, register) pair for SRP ray tracing.
// Unity's own Built-in UnityShaderVariables.cginc - included transitively below via
// Lighting.hlsl - still calls the classic single-argument GLOBAL_CBUFFER_START(UnityStereoGlobals),
// which is exactly the "too few arguments to a macro call" compile error. Restore the original
// single-argument Built-in RP definition before anything else needs it.
#undef GLOBAL_CBUFFER_START
#undef GLOBAL_CBUFFER_END
#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) || ((defined(UNITY_SINGLE_PASS_STEREO) || defined(UNITY_STEREO_INSTANCING_ENABLED)) && (defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL)))
    #define GLOBAL_CBUFFER_START(name)    cbuffer name {
    #define GLOBAL_CBUFFER_END            }
#else
    #define GLOBAL_CBUFFER_START(name)    CBUFFER_START(name)
    #define GLOBAL_CBUFFER_END            CBUFFER_END
#endif
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Use_Texture_Stars;
float _Ground_Height;
float4 _GroundColor;
float _GroundEnabled;
float _Shading_Intensity;
float _SkyColorBlend;
float4 _HorizonColorDay;
float4 _HorizonColorNight;
float _CloudSharpness;
float _Cloud_Iterations;
float _Cloud_Gain;
float _Cloud_Lacunarity;
float4 _SkyColorNight;
float _HorizonSaturationFalloff;
float _HorizonSaturationAmount;
float4 _SunColorZenith;
float4 _SunColorHorizon;
float _SunFalloffIntensity;
float _SunFalloff;
float _SunsetHorizontalFalloff;
float _SunsetVerticalFalloff;
float _SunsetRadialFalloff;
float _SunsetIntensity;
float4 _CloudTexture_TexelSize;
float2 _CloudWindSpeed;
float _Cloudiness;
float _CloudOpacity;
float _CloudFalloff;
float2 _CloudScale;
float4 _CloudColorDay;
float4 _CloudColorNight;
float4 _StarTexture_TexelSize;
float _StarHorizonFalloff;
float _StarScale;
float _StarSpeed;
float _StarIntensity;
float _StarDaytimeBrightness;
float _MoonAngularDiameter;
float _MoonFalloff;
float4 _MoonColor;
float _SunAngularDiameter;
float _GroundFadeAmount;
float _ProceduralStarsEnabled;
float _StarSaturation;
float _SunSkyLightingEnabled;
float4 _SkyColorDay;
float _Moon_Enabled;
float _Clouds_Enabled;
float _Stars_Enabled;
float _Sun_Enabled;
float _Constant_Color_Mode;
float _StarSharpness;
float _StarFrequency;
float4 _Star_Texture_Tint;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_CloudTexture);
SAMPLER(sampler_CloudTexture);
TEXTURE2D(_StarTexture);
SAMPLER(sampler_StarTexture);

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Includes
// GraphIncludes: <None>

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    






    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
{
    result.vertex     = float4(attributes.positionOS, 1);
    result.tangent    = attributes.tangentOS;
    result.normal     = attributes.normalOS;
    result.vertex     = float4(vertexDescription.Position, 1);
    result.normal     = vertexDescription.Normal;
    result.tangent    = float4(vertexDescription.Tangent, 0);
    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
}

void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
{
    result.pos = varyings.positionCS;
    // World Tangent isn't an available input on v2f_surf


    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogCoord = varyings.fogFactorAndVertexLight.x;
        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
}

void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
{
    result.positionCS = surfVertex.pos;
    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
    // World Tangent isn't an available input on v2f_surf

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

ENDHLSL
}
Pass
{
    Name "ScenePickingPass"
    Tags
    {
        "LightMode" = "Picking"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 3.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS ScenePickingPass
#define BUILTIN_TARGET_API 1
#define SCENEPICKINGPASS 1
#ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
#define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
#endif
#ifdef _BUILTIN_ALPHATEST_ON
#define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
#endif
#ifdef _BUILTIN_AlphaClip
#define _AlphaClip _BUILTIN_AlphaClip
#endif
#ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
#define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
#endif


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
// patched: Shims.hlsl (below) itself includes Common.hlsl (which redefines GLOBAL_CBUFFER_START
// to a 2-argument SRP ray-tracing form) and then UnityShaderVariables.cginc (which still calls
// the classic single-argument form) BACK TO BACK internally - so patching *after* Shims.hlsl is
// too late, the damage and the crash happen inside it. Pre-include Common.hlsl ourselves so its
// include guard is already set, restore the single-argument macro, then let Shims.hlsl's own
// "#include Common.hlsl" become a no-op (guarded) while its UnityShaderVariables.cginc include
// sees our correct definition.
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#undef GLOBAL_CBUFFER_START
#undef GLOBAL_CBUFFER_END
#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) || ((defined(UNITY_SINGLE_PASS_STEREO) || defined(UNITY_STEREO_INSTANCING_ENABLED)) && (defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL)))
    #define GLOBAL_CBUFFER_START(name)    cbuffer name {
    #define GLOBAL_CBUFFER_END            }
#else
    #define GLOBAL_CBUFFER_START(name)    CBUFFER_START(name)
    #define GLOBAL_CBUFFER_END            CBUFFER_END
#endif
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
// patched: Core.hlsl (below) pulls in ShaderVariablesFunctions.hlsl, which - when
// UNITY_SINGLE_PASS_STEREO is defined (true for any XR-capable build target) - redeclares
// TransformStereoScreenSpaceTex() as a real function. Shims.hlsl already pulled in Unity's own
// UnityCG.cginc above, which declares a byte-identical function of the same name under the same
// condition, so this is a flat redefinition error. This skybox never calls either function (it's
// boilerplate from the Shader Graph target template, not skybox-specific code), so it's safe to
// briefly hide UNITY_SINGLE_PASS_STEREO from just this one include: ShaderVariablesFunctions.hlsl
// then takes its non-stereo branch and skips its copy, while everything else it defines is still
// included normally.
#if defined(UNITY_SINGLE_PASS_STEREO)
    #undef UNITY_SINGLE_PASS_STEREO
    #define RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL
#endif
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
#if defined(RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL)
    #undef RESTORE_UNITY_SINGLE_PASS_STEREO_AFTER_CORE_HLSL
    #define UNITY_SINGLE_PASS_STEREO
#endif
// patched: com.unity.render-pipelines.core's Common.hlsl (pulled in by the Core.hlsl include
// above) redefines GLOBAL_CBUFFER_START to take a (name, register) pair for SRP ray tracing.
// Unity's own Built-in UnityShaderVariables.cginc - included transitively below via
// Lighting.hlsl - still calls the classic single-argument GLOBAL_CBUFFER_START(UnityStereoGlobals),
// which is exactly the "too few arguments to a macro call" compile error. Restore the original
// single-argument Built-in RP definition before anything else needs it.
#undef GLOBAL_CBUFFER_START
#undef GLOBAL_CBUFFER_END
#if defined(UNITY_STEREO_MULTIVIEW_ENABLED) || ((defined(UNITY_SINGLE_PASS_STEREO) || defined(UNITY_STEREO_INSTANCING_ENABLED)) && (defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL)))
    #define GLOBAL_CBUFFER_START(name)    cbuffer name {
    #define GLOBAL_CBUFFER_END            }
#else
    #define GLOBAL_CBUFFER_START(name)    CBUFFER_START(name)
    #define GLOBAL_CBUFFER_END            CBUFFER_END
#endif
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float _Use_Texture_Stars;
float _Ground_Height;
float4 _GroundColor;
float _GroundEnabled;
float _Shading_Intensity;
float _SkyColorBlend;
float4 _HorizonColorDay;
float4 _HorizonColorNight;
float _CloudSharpness;
float _Cloud_Iterations;
float _Cloud_Gain;
float _Cloud_Lacunarity;
float4 _SkyColorNight;
float _HorizonSaturationFalloff;
float _HorizonSaturationAmount;
float4 _SunColorZenith;
float4 _SunColorHorizon;
float _SunFalloffIntensity;
float _SunFalloff;
float _SunsetHorizontalFalloff;
float _SunsetVerticalFalloff;
float _SunsetRadialFalloff;
float _SunsetIntensity;
float4 _CloudTexture_TexelSize;
float2 _CloudWindSpeed;
float _Cloudiness;
float _CloudOpacity;
float _CloudFalloff;
float2 _CloudScale;
float4 _CloudColorDay;
float4 _CloudColorNight;
float4 _StarTexture_TexelSize;
float _StarHorizonFalloff;
float _StarScale;
float _StarSpeed;
float _StarIntensity;
float _StarDaytimeBrightness;
float _MoonAngularDiameter;
float _MoonFalloff;
float4 _MoonColor;
float _SunAngularDiameter;
float _GroundFadeAmount;
float _ProceduralStarsEnabled;
float _StarSaturation;
float _SunSkyLightingEnabled;
float4 _SkyColorDay;
float _Moon_Enabled;
float _Clouds_Enabled;
float _Stars_Enabled;
float _Sun_Enabled;
float _Constant_Color_Mode;
float _StarSharpness;
float _StarFrequency;
float4 _Star_Texture_Tint;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_CloudTexture);
SAMPLER(sampler_CloudTexture);
TEXTURE2D(_StarTexture);
SAMPLER(sampler_StarTexture);

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Includes
// GraphIncludes: <None>

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    






    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
{
    result.vertex     = float4(attributes.positionOS, 1);
    result.tangent    = attributes.tangentOS;
    result.normal     = attributes.normalOS;
    result.vertex     = float4(vertexDescription.Position, 1);
    result.normal     = vertexDescription.Normal;
    result.tangent    = float4(vertexDescription.Tangent, 0);
    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
}

void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
{
    result.pos = varyings.positionCS;
    // World Tangent isn't an available input on v2f_surf


    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogCoord = varyings.fogFactorAndVertexLight.x;
        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
}

void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
{
    result.positionCS = surfVertex.pos;
    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
    // World Tangent isn't an available input on v2f_surf

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

ENDHLSL
}
}
CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
CustomEditorForRenderPipeline "OccaSoftware.SuperSimpleSkybox.Editor.SkyboxEditorGUI" ""
FallBack "Hidden/Shader Graph/FallbackError"
}