Shader "Custom/WaterSurface"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _FlowMap ("Flow (RG), Noise (A)", 2D) = "black" {}
        [NoScaleOffset] _NormalMap ("Normal Map", 2d) = "bump" {}
        [NoScaleOffset] _DerivitiveMap ("Derivitive Map (AG) Height (B)", 2d) = "black" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Rate ("Flow Rate", float) = 1
        _UJump ("U jump per phase", range(-.25, 0.25)) = 0.25
        _VJump ("V jump per phase", range(-.25, 0.25)) = -0.25
        _Tiling("Tiling", float) = 1
        _FlowStrength ("Flow Strength", float) = 1
        _FlowOffset ("Flow Offset", float) = 1
        _HeightScale ("Height Scale", float) = 1
        _HeightScaleModulated ("Height Scale Modulated", float) = 0.75
                
        _WaterFogColor("Water Fog Color", color) = (1,1,1,1)
        _WaterFogDensity("Water Fog Density", Range(0,2)) = 0.1
        _RefractionStrength("Refraction Strength", Range(0,1)) = 0.25
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        LOD 200
        
        GrabPass{"_WaterBackground"}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha finalcolor:ResetAlpha

        #pragma target 3.0

        sampler2D _MainTex, _FlowMap, _NormalMap, _DerivitiveMap;
        sampler2D _CameraDepthTexture, _WaterBackground;
        float4 _CameraDepthTexture_TexelSize;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color, _WaterFogColor;
        float _Rate;
        float _UJump;
        float _VJump;
        float _Tiling;
        float _FlowStrength, _FlowOffset, _HeightScale, _HeightScaleModulated;
        float _WaterFogDensity;
        float _RefractionStrength;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float2 AlignWithGrabTexel(float2 uv)
        {
            #if  UNITY_UV_STARTS_AT_TOP
                if (_CameraDepthTexture_TexelSize.x < 0)
                {
                    uv.y = 1 - uv.y;
                }
            #endif

            return (floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) * abs(_CameraDepthTexture_TexelSize.xy);
        }
        
        void ResetAlpha(Input In, SurfaceOutputStandard o, inout fixed4 color)
        {
            color.a = 1;
        }

        float3 ColorBelowWater(float4 screenPos, float3 tangentSpaceNormal)
        {
        float2 uvOffset = tangentSpaceNormal.xy * _RefractionStrength;
		uvOffset.y *= _CameraDepthTexture_TexelSize.z * abs(_CameraDepthTexture_TexelSize.y);
		float2 uv = AlignWithGrabTexel((screenPos.xy + uvOffset) / screenPos.w);
	
		float backgroundDepth =
		LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
		float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
		float depthDifference = backgroundDepth - surfaceDepth;
	
		uvOffset *= saturate(depthDifference);
		uv = AlignWithGrabTexel((screenPos.xy + uvOffset) / screenPos.w);
		backgroundDepth =
		LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
		depthDifference = backgroundDepth - surfaceDepth;
	
		float3 backgroundColor = tex2D(_WaterBackground, uv).rgb;
		float fogFactor = exp2(-_WaterFogDensity * depthDifference);
		return lerp(_WaterFogColor, backgroundColor, fogFactor);
        }


        float3 UnpackDerivitiveHeight(float4 textureData)
        {
            float3 dh = textureData.agb;
            dh.xy = dh.xy * 2 -1;
            return dh;
        }

        float3 FlowUVW(float2 uv, float2 flowVector, float2 jump,float flowOffset, float tiling, float time, bool flowB)
        {
            float phaseOffset = flowB ? 0.5:0;
            float progress = frac(time + phaseOffset);
            float3 uvw; 
            uvw.xy = uv - flowVector * (progress + flowOffset);
            uvw.xy += (time - progress) * jump;
            uvw.xy *= tiling;
            
            // making a triangle wave
            uvw.z = 1 - abs(1 - 2 * progress);
            return uvw;
        }

        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float4 flowSample = tex2D(_FlowMap, IN.uv_MainTex);
            float2 flowVector = flowSample.rg *2 -1;
            flowVector *= _FlowStrength;
            float noise = flowSample.a;
            float time  = _Time.y * _Rate + noise;
            float2 jump = float2(_UJump, _VJump);
            
            float3 uvwA = FlowUVW(IN.uv_MainTex, flowVector,jump,_FlowOffset, _Tiling, time, false);
            float3 uvwB = FlowUVW(IN.uv_MainTex, flowVector, jump,_FlowOffset, _Tiling, time, true);

            float finalHeightScale = flowSample.b * _HeightScaleModulated + _HeightScale;
            float3 dhA = UnpackDerivitiveHeight(tex2D(_DerivitiveMap, uvwA.xy)) * (uvwA.z * finalHeightScale);
            float3 dhB = UnpackDerivitiveHeight(tex2D(_DerivitiveMap, uvwB.xy)) * (uvwB.z * finalHeightScale);
            o.Normal = normalize(float3(-(dhA.xy + dhB.xy),1));
            
            fixed4 texA = tex2D (_MainTex,uvwA.xy)* uvwA.z;
            fixed4 texB = tex2D (_MainTex,uvwB.xy)* uvwB.z;
            
            fixed4 c = (texA + texB) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            o.Emission = ColorBelowWater(IN.screenPos, o.Normal) * (1 - c.a);
        }
        ENDCG
    }
}
