Shader "Custom/FourCameraSplit"
{
    Properties
    {
        _Camera1Tex ("Camera 1 Texture", 2D) = "white" {}
        _Camera2Tex ("Camera 2 Texture", 2D) = "white" {}
        _Angle("Split Angle", Range(0, 360)) = 90
        _Center("Split Center", Vector) = (0, 0, 0, 0)
        _splitInterval("Split Interval", Range(0, 1)) = 0.1
        _FadeWidth("Fade Width", Range(0, 0.5)) = 0.02
    }
    
    SubShader
    {
        Tags 
        {
            "RenderPipeline" = "UniversalPipeline"
        }
        ZWrite Off Cull Off 
        Pass
        {
            Name "ColorBlend"
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            
            TEXTURE2D_X(_CameraOpaqueTexture);
            SAMPLER(sampler_CameraOpaqueTexture);

            TEXTURE2D(_Camera1Tex);
            SAMPLER(sampler_Camera1Tex);
            TEXTURE2D(_Camera2Tex);
            SAMPLER(sampler_Camera2Tex);
            CBUFFER_START(UnityPerMaterial)
            float _Angle;
            float _splitInterval;
            float4 _Center;
            float _FadeWidth;
            CBUFFER_END

            half4 frag (Varyings i) : SV_Target
            {
                float aspect = _ScreenParams.x / _ScreenParams.y;
                // 转换为以中心为原点的坐标系
                float2 centeredUV = i.texcoord - _Center.xy;
                centeredUV.x *= aspect;  // 关键修改：补偿宽高比
                // 计算角度方向向量
                float angleRad = radians(_Angle);
                float2 direction1 = float2(cos(angleRad), sin(angleRad));

                float2 direction2 = float2(-sin(angleRad), cos(angleRad));

                
                 // 计算点与分割线的相对位置（带偏移量
                float side1 = dot(centeredUV, direction1);
                float side2 = dot(centeredUV, direction2);

                float adjustedInterval = _splitInterval * 0.5 * aspect;
                float upperBound = adjustedInterval;
                float lowerBound = -adjustedInterval;
                float fade = _FadeWidth * adjustedInterval;
                if(side1 > upperBound && side2 > upperBound) {
                        return SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord);
                    }
                else if(side2 < lowerBound && side1 > upperBound) {
                        return SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord);
                    }
                else if(side1 < lowerBound && side2 > upperBound) {
                        return SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord);
                    }
                else if(side2 < lowerBound && side1 < lowerBound) {
                        return SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord);
                    }
                else 
                {
                    return half4(0,0,0,1);
                }
            }
            ENDHLSL
        }
    }
}