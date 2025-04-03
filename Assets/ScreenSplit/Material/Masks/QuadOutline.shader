Shader "QuadOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BorderWidth ("Border Width", Range(0, 0.1)) = 0.05
        _BorderColor ("Border Color", Color) = (0,0,0,1)
    }

    SubShader
    {
        Tags 
        {
            "RenderType"="Opaque" 
            "Queue"="Geometry"
            "RenderPipeline"="UniversalPipeline"
        }

        // Pass 2: 带边框的颜色渲染
        Pass
        {
            Name "ColorPass"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float _BorderWidth;
                float4 _BorderColor;
                float _Index;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //float2 uv = IN.uv;
                //float border = 
                //    (1 - step(_BorderWidth, uv.x)) +      // 左边界
                //    (step(1 - _BorderWidth, uv.x)) +     // 右边界
                //    (1 - step(_BorderWidth, uv.y)) +      // 下边界
                //    (step(1 - _BorderWidth, uv.y));       // 上边界
                //border = saturate(border); // 钳制到0-1范围

                //// 设置颜色和透明度
                //half4 color = _BorderColor;
                //color.a *= border; // 非边框区域alpha为0
                //return color;
                 // 边框检测
                float2 uv = IN.uv;
                float border = step(_BorderWidth, uv.x) * step(_BorderWidth, uv.y) *
                               step(uv.x, 1 - _BorderWidth) * step(uv.y, 1 - _BorderWidth);

                // 纹理采样
                half4 texColor = half4(0, 0, 0, 0);

                // 混合颜色
                return lerp(_BorderColor, texColor, border);
            }
            ENDHLSL
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
        }
    }
}