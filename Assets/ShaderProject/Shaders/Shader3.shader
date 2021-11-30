Shader "Custom/Shader3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Color ("Color", Color) = (1,1,1,1)

        _FadeAmount("Fade Amount", Range(0, 10)) = 3
        _EdgeFade("Edge Fade", Range(0, 1)) = .1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        Cull Back
        Lighting Off
        ZWrite On

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #pragma target 3.0

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float light : TEXCOORD1;
                float4 position : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            half _FadeAmount;
            float _EdgeFade;

            
            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // #pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)

            fixed3 viewDir;
            v2f vert (appdata vert)
            {
                v2f output;

                output.position = UnityObjectToClipPos(vert.vertex);
                output.uv = TRANSFORM_TEX(vert.uv, _MainTex);

                viewDir = normalize(ObjSpaceViewDir(vert.vertex));
                output.light = dot(viewDir, vert.normal);

                output.uv += float4 (0.1, 0, 0, 0) * _Time.y;

                return output;
            }

            fixed4 pixel;
            fixed4 frag (v2f input) : SV_Target
            {
                pixel = tex2D(_MainTex, input.uv) * _Color * pow(_FadeAmount, input.light * _EdgeFade);
                pixel = lerp(0, pixel, input.light);
                
                return clamp(pixel, 0, _Color);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
