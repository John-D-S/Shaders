Shader "Custom/Shader1"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _TextureMoveSpeed ("Texture Move Speed", Range(0, 5)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float _TextureMoveSpeed;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float4 alteredTime = _Time * _TextureMoveSpeed;
            float2 pos = 0.1 * (sin(alteredTime * 5), cos(alteredTime * 5));
            fixed4 c1 = tex2D (_MainTex, IN.uv_MainTex + pos + sin(sin(alteredTime * 0.7)));
            fixed4 c2 = tex2D (_MainTex, IN.uv_MainTex - pos + sin(sin(alteredTime * 0.71)));
            fixed4 c = saturate(c1 + c2);
            o.Albedo = c.rgb * _Color;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness * c;
            o.Alpha = c.a;
            o.Emission = 1 - c;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
