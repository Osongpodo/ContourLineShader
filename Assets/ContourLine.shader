Shader "Custom/ContourLine"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Main Color", Color) = (1,1,1,1)
        _LineColor("Line Color", Color) = (1,1,1,1)
        _LineSharpness("Line Sharpness", float) = 6
        _LineBrightness("Line Brightness", Range(1,100)) = 1
        _LineSpacing("Line Spacing", Float) = 2
        _OffsetY("Offset Y", Float) = 0.0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                // make fog work
                #pragma multi_compile_fog

                #include "UnityCG.cginc"

                fixed4 _Color;
                fixed4 _LineColor;
                fixed _LineSharpness;
                fixed _LineSpacing;
                fixed _LineBrightness;
                fixed _OffsetY;
                sampler2D _MainTex;
                float4 _MainTex_ST;

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
                    float3 worldPos : TEXCOORD1;
                };

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                    UNITY_TRANSFER_FOG(o,o.vertex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 texcol = tex2D(_MainTex, i.uv);
                    float rl = 0.0;
                    float gl = 0.0;
                    float bl = 0.0;
                    float _y = i.worldPos.y + _OffsetY;

                    float temp = 1;
                    for (int i = 0; i < _LineSharpness; i++)
                    {
                        temp = temp * ((_y % _LineSpacing) / _LineSpacing);
                    }
                    //기존의 pow를 이용한 제곱 계산은 밑이 음수일경우 내부 계산 로직에서 overflow로 인한 NaN오류값이 반환됨
                    //따라서 반복문으로 제곱

                    rl = 1.0 + abs(_LineBrightness * temp * _LineColor.r);
                    gl = 1.0 + abs(_LineBrightness * temp * _LineColor.g);
                    bl = 1.0 + abs(_LineBrightness * temp * _LineColor.b);

                    fixed4 hl = fixed4((fixed3(rl,gl,bl)), 1);

                    return texcol * hl;

                }
                ENDCG

            }
        }
}