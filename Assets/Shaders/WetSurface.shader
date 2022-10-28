Shader "RainEffect/WetSurface"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", color) = (1,1,1,1)
        _RainTex("Rain Texture", 2D) = "white"{}
        _Speed("Speed", float) = 1
        _RainColorDensity("Rain Color Density", Range(0.01, 1)) = 0.11
        
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
                half4 vertex : POSITION;
                half2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half4 vertex : SV_POSITION;
            };
            
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _RainTex;
            float4 _RainTex_ST;
    
            half4 _Color;
            half _Speed;
            float _RainColorDensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv,_RainTex);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half lerp_t = frac(_Time.y * _Speed); 
                half t = 1 - lerp_t; 
                half t2 = 1 - frac((_Time.y) * _Speed + 0.5); 
                half3 rainColor = tex2D(_RainTex,i.uv);
                half3 rainColor2 = tex2D(_RainTex, i.uv + half2(0.5,0.5)) ;
                half dis = saturate(1-distance(rainColor.r - t,0.05)/0.05)* _RainColorDensity;
                half dis2 = saturate(1-distance(rainColor2.r - t2,0.05)/0.05)*_RainColorDensity;
                half3 col = half3(dis,dis,dis);
                half3 col2 = half3(dis2,dis2,dis2);
                half3 texColor = tex2D(_MainTex,i.uv);
                half lerp_t2 = sin(lerp_t * 3.14159); 
                half3 finalCol = lerp(col2,col,lerp_t2) + texColor;// + _Color.rgb;
                
                return half4(finalCol,1);
            }
            ENDCG
        }
    }
}
