Shader "YukeyVFX/Toon/StylizedWater"
{
    Properties
    {       
        [Header(COLOR)]
        [Space(10)]
        _ShallowColor("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
        _DeepColor("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1

        [Header(SURFACE)]
        [Space(10)]
        _SurfaceNoise ("Surface Noise", 2D) = "white" {}
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Float) = 0.0
        _SurfaceDistortion ("Surface Distortion", 2D) = "white" {}
        _SurfaceDistortionAmount("Surface Distortion Amount", Range(0, 1)) = 0.5
        _FoamDistance("Foam Distance", Float) = 0.4
        _SurfaceScrolling("Surface Scrolling", Vector) = (0.3, 0.3, 0.0, 0.0)

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
                float2 distortionUV : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD2;
            };

            //Color
            float4 _ShallowColor;
            float4 _DeepColor;
            float _DepthMaxDistance;
            sampler2D _CameraDepthTexture; //Need screen position to sample
            //Surface
            sampler2D _SurfaceNoise;
            float4 _SurfaceNoise_ST;
            float _SurfaceNoiseCutoff;
            float _FoamDistance;
            sampler2D _SurfaceDistortion;
            float4 _SurfaceDistortion_ST;
            float _SurfaceDistortionAmount;
            float2 _SurfaceScrolling;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _SurfaceNoise);
                o.distortionUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);
                o.screenPos = ComputeScreenPos(o.vertex); //Convert Clip Postion to Screen Position
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Calculate Water Color
                fixed sampleDepth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)).x; //R is for depth, tex2Dproj (orthographic => perspective) 
                fixed linearDepthValue = LinearEyeDepth(sampleDepth); //Make depth value linear
                fixed waterDepth = saturate((linearDepthValue  - i.screenPos.w) / _DepthMaxDistance); //Calculate the depth from water surface and clamp between 0 -> 1
                fixed4 waterColor = lerp( _ShallowColor, _DeepColor, waterDepth);

                //Calculate Water Surface Distortion
                fixed2 distortionSampler =  mul(tex2D(_SurfaceDistortion, i.distortionUV).xy, 2) - 1; //Convert distortion.rg from range [0,1] to [-1,1]
                fixed2 waterDistortion = mul(distortionSampler, _SurfaceDistortionAmount); // To control the distortion amount
                //Calculate Water Noise Surface
                float2 scrollingUV =  float2(i.uv.x + mul(_Time.y, _SurfaceScrolling.x), i.uv.y + mul(_Time.y, _SurfaceScrolling.y)); // Add scrolling
                scrollingUV = float2(scrollingUV.x + waterDistortion.x, scrollingUV.y + waterDistortion.y); //Add distortion
                fixed noiseSampler = tex2D(_SurfaceNoise, scrollingUV).x;
                fixed foamBaseOnDepth = saturate(waterDepth / _FoamDistance);
                fixed surfaceNoiseCutoff = mul(_SurfaceNoiseCutoff, foamBaseOnDepth);
                fixed waterFoam = step(surfaceNoiseCutoff, noiseSampler);

                waterColor += waterFoam;

                return waterColor;
            }
            ENDCG
        }
    }
}
