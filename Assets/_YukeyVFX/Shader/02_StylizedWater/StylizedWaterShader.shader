Shader "Unlit/StylizedWaterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShallowColor("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
        _DeepColor("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ShallowColor;
            float4 _DeepColor;
            float _DepthMaxDistance;
            sampler2D _CameraDepthTexture; //Need screen position to sample

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.vertex); //Convert Clip Postion to Screen Position
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float sampleDepth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)).r; //R is for depth, tex2Dproj (orthographic => perspective) 
                float linearDepthValue = LinearEyeDepth(sampleDepth); //Make depth value linear
                float waterDepth = saturate((linearDepthValue  - i.screenPos.w) / _DepthMaxDistance); //Calculate the depth from water surface and clamp between 0 -> 1
                float4 waterColor = lerp( _ShallowColor, _DeepColor, waterDepth);
                return waterColor;
            }
            ENDCG
        }
    }
}
