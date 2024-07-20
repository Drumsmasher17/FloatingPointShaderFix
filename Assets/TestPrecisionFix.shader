Shader "Unlit/TestPrecisionFix"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile _ USE_CUSTOM_VIEW

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4x4 _customMatrix;

            v2f vert (appdata v)
            {
                v2f o;
        
#ifdef USE_CUSTOM_VIEW
                /// This will fix jittery vertices, but will not fix jittery object transforms
                //o.vertex = mul(mul(UNITY_MATRIX_VP, unity_ObjectToWorld), float4(v.vertex.xyz, 1.0));
    
                /// This bypasses world and view transforms - fixing both jittery vertices and jittery object transforms
                o.vertex = mul(UNITY_MATRIX_P, mul(_customMatrix, float4(v.vertex.xyz, 1.0)));
#else
                /// Original Code:
                o.vertex = UnityObjectToClipPos(v.vertex);
#endif
    
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
