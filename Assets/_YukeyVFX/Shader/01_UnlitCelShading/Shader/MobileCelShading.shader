Shader "YukeyVFX/Toon/MobileCelShading"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _Color ("Color", Color) = (0.73, 0.73, 0.73, 1.0)
        _Glossiness ("Glossiness", float) = 0.0
        _SmoothCel ("SmoothCel", Range(0.0, 1.0)) = 0.03
        _RimAmount ("RimAmount", float) = 0.0
        _ShadowReduce ("ShadowReduce", Range(0.0, 1.0)) = 0.36
    }

    SubShader
    {   
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }

        Pass
        {   
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {                
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1; 
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD2; 
            };

            //====VARIABLES======
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Glossiness;
            float _SmoothCel;
            float _RimAmount;
            float _ShadowReduce;
            
            //====FUNCTIONS======

            half CalculateFresnelEffect(half3 normal, half3 viewDir, half power) 
            {
                half satNDotV = saturate(dot(normal, viewDir));
                half clampedPower = max(1.0, power); 
                return pow((1.0 - satNDotV), clampedPower);
            }

            //====VERTEX AND FRAGMENT=====

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = TransformObjectToWorldNormal(v.normal);
                o.worldPos = TransformObjectToWorld(v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);

                Light _mainLight = GetMainLight(TransformWorldToShadowCoord(i.worldPos));
                half _lightAtten = max(_mainLight.shadowAttenuation, _ShadowReduce) * _mainLight.distanceAttenuation;

                // Vector
                half3 _normal = normalize(i.normal);
                half3 _viewDir = normalize(TransformWorldToView(i.worldPos));
                half3 _halfDir = normalize(_mainLight.direction + _viewDir);

                // Dot
                half nDotL = dot(_normal, _mainLight.direction);
                half nDotH = dot(_halfDir, _normal);

                // Ambient
                half3 AmbientLight = _mainLight.color;

                // Diffuse
                half _diffuseValue = smoothstep(0.0, _SmoothCel, nDotL); 
                half3 DiffuseLight  = _diffuseValue;
                
                // Specular
                half _specularValue = pow(nDotH * _diffuseValue, _Glossiness);
                half3 SpecularLight = smoothstep(0.0, _SmoothCel, _specularValue);

                // Rim Light (Freshnel)
                half _rimValue = CalculateFresnelEffect(_normal, _viewDir, _RimAmount); 
                half3 RimLight = smoothstep(0.0, _SmoothCel, _rimValue) * _diffuseValue; 

                col.xyz *= AmbientLight + DiffuseLight + SpecularLight + RimLight;
                col *=  _lightAtten * _Color;
                return col;
            }

            ENDHLSL
        }

        // Make Object Cast Shadow
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }

    FallBack "Universal Render Pipeline/Diffuse"
}