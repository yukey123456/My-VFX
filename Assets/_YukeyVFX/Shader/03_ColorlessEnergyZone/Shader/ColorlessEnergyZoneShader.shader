Shader "YukeyVFX/Skills/ColorlessEnergyZoneShader"
{
    Properties
    {
        _ColorlessPattern ("Colorless Pattern", 2D) = "white" {}
        _PatternScrolling ("Pattern Scrolling", Vector) = (0.2, 0.2, 0, 0)
        _PatternFade ("Pattern Fade", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
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

            sampler2D _ColorlessPattern;
            float4 _ColorlessPattern_ST;
            float2 _PatternScrolling;
            float _PatternFade;

            //Get Camera Depth and Opaque Screen Texture
            sampler2D _CameraOpaqueTexture;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _ColorlessPattern);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Sampler Opaque Texture On Model
                fixed4 opaqueColor = tex2Dproj(_CameraOpaqueTexture, UNITY_PROJ_COORD(i.screenPos));
                fixed luminance = mul(0.2126, opaqueColor.r) + mul(0.7152, opaqueColor.g) + mul(0.0722, opaqueColor.b);
                opaqueColor.rgb = luminance;

                // Create Colorless Pattern
                fixed2 scrollingUV = fixed2(i.uv.x + _Time.y * _PatternScrolling.x, i.uv.y + _Time.y * _PatternScrolling.y);
                fixed4 patternCol = tex2D(_ColorlessPattern, scrollingUV);

                fixed4 finalColor = opaqueColor + mul(patternCol , _PatternFade);
                return finalColor;
            }
            ENDHLSL
        }
    }
}
