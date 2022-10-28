Shader "RainEffect/RainFlow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset]_NormalTex("Normal Map",2D )="bump"{}
        _RainColor("Water Color", Color) = (1,1,1,1)
        _FlowMap("FlowMap",2D)="white"{}
        [NoScaleOffset]_FlowNormal("Flow Normal Map",2D )="bump"{}
        _FlowRange("Flow Water Range",Range(0,1))=0.5
        _RainColor("Water Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            
        }
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
                half2 uv_FlowMap:TEXCOORD1;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _FlowMap;
            float4 _FlowMap_ST;

            sampler2D _FlowNormal;
            sampler2D _FlowNormal_ST;
            

            half _FlowRange;
            half4 _RainColor;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_FlowMap = TRANSFORM_TEX(v.uv, _FlowMap);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv);

                half2 flowUV=i.uv_FlowMap;
                half flowG=tex2D(_FlowMap,flowUV).g;
                flowUV=flowUV+half2(0,_Time.y*0.4);
                half flowB=tex2D(_FlowMap,flowUV).b;
                half flowMask=saturate(_FlowRange-flowB);

               /* half3 flowNormal=UnpackNormal(tex2D(_FlowNormal,IN.uv_FlowMap));
                half3 normal=UnpackNormal(tex2D(_NormalTex,IN.uv_MainTex));
                flowNormal=normalize(lerp(normal,flowNormal,flowMask));*/
                
                return col + _RainColor *flowG*flowMask ;
            }
            ENDCG
        }
    }
}
