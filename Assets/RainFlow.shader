Shader "RainEffect/Flow"
{
    
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset]_NormalTex("Normal Map",2D )="bump"{
    }
        _RainColor("Water Color", Color) = (1,1,1,1)
        _FlowMap("FlowMap",2D)="white"{
    }
        [NoScaleOffset]_FlowNormal("Flow Normal Map",2D )="bump"{
    }
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _FlowRange("Flow Water Range",Range(0,1))=0.5
    }
    SubShader
    {
    
        Tags {"RenderType"="Opaque" }
        LOD 200
        Cull Back

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalTex;
        sampler2D _FlowMap;
        sampler2D _FlowNormal;

        struct Input
        {
    
            float2 uv_MainTex;
            half2 uv_FlowMap;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed _FlowRange;
        fixed4 _RainColor;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
    
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            half2 flowUV=IN.uv_FlowMap;
            fixed flowG=tex2D(_FlowMap,flowUV).g;
            flowUV=flowUV+half2(0,_Time.y*0.4);
            fixed flowB=tex2D(_FlowMap,flowUV).b;
            fixed flowMask=saturate(_FlowRange-flowB);

            half3 flowNormal=UnpackNormal(tex2D(_FlowNormal,IN.uv_FlowMap));
            //flowNormal.xy=-flowNormal.xy;
            half3 normal=UnpackNormal(tex2D(_NormalTex,IN.uv_MainTex));
            //flowNormal=normalize(normal+lerp(half3(0,0,1),flowNormal,flowMask));
            flowNormal=normalize(lerp(normal,flowNormal,flowMask));

            o.Albedo = c.rgb+_RainColor.rgb*flowG*flowMask;
            o.Normal=flowNormal;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}