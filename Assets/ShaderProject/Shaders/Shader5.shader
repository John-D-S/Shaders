Shader "Custom/Shader5"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NoiseTex ("Noise", 2D) = "white" {}

        _DissolveSpeed ("Dissolve Speed", Float) = 1
        _EdgeWidth ("Edge Width", Range(0, 1)) = 0.05
        [HDR] _EdgeColor ("Edge Color", Color) = (1,1,1,1)
        
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Geometry" "Queue"="Transparent" }
        LOD 200
        Cull [_Cull]

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard addshadow fullforwardshadows

       
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NoiseTex;

        float _DissolveSpeed;
        half _EdgeWidth;

        fixed4 _Color;
        fixed4 _EdgeColor;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NoiseTex;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        fixed4 noisePixel, pixel;
        float cutoff;
        float4 texOffset;
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            texOffset = _Time * float4 (_DissolveSpeed,0,0,0);
            
            pixel = tex2D (_MainTex, IN.uv_MainTex + texOffset) * _Color;

            o.Albedo = pixel.rgb;

            noisePixel = tex2D (_NoiseTex, IN.uv_NoiseTex + texOffset);

            cutoff = saturate(1 * sin(_Time * _DissolveSpeed));
            clip(noisePixel.r >= cutoff ? 1 : -1);
            o.Emission = noisePixel.r >= (cutoff * (_EdgeWidth + 1.0)) ? 0 : _EdgeColor;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
