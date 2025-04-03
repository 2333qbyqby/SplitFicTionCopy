Shader "Custom/FourCameraSplit"
{
    Properties
    {
        _Camera1Tex ("Camera 1 Texture", 2D) = "white" {}
        _Camera2Tex ("Camera 2 Texture", 2D) = "white" {}
        _Angle("Split Angle", Range(0, 360)) = 90
        _Center("Split Center", Vector) = (0, 0, 0, 0)
        _splitInterval("Split Interval", Range(0, 1)) = 0.1
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
            CBUFFER_END

            half4 frag (Varyings i) : SV_Target
            {
                // 转换为以中心为原点的坐标系
                float2 centeredUV = i.texcoord - _Center.xy;
                // 计算角度方向向量
                float angleRad = radians(_Angle);
                float2 direction1 = float2(cos(angleRad), sin(angleRad));

                float2 direction2 = float2(-sin(angleRad), cos(angleRad));

                
                 // 计算点与分割线的相对位置（带偏移量）
                float side1 = dot(centeredUV, direction1);
                float side2 = dot(centeredUV, direction2);

                 // 计算抗锯齿参数
                float fadeDist = fwidth(side1) * 1.5; // 控制抗锯齿范围
                float upperBound = _splitInterval/2;
                float lowerBound = -upperBound;

                // 边缘混合计算(Deep Seek给的，来抗锯齿)
                if(side1 > upperBound + fadeDist) {
                    if(side2 > upperBound + fadeDist) {
                        return SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord);
                        
                    }
                    else if(side2 < lowerBound + fadeDist) {
                        return SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord);
                    }
                    else
                    {
                        if(side2 > upperBound - fadeDist) {
                        float t = smoothstep(upperBound - fadeDist, upperBound + fadeDist, side2);
                        return lerp(half4(0,0,0,1), SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord), t);
                        }
                    // 下边缘混合
                    else if(side2 < lowerBound + fadeDist) {
                        float t = smoothstep(lowerBound - fadeDist, lowerBound + fadeDist, side2);
                        return lerp(SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord), half4(0,0,0,1), t);
                        }
                    // 中间纯黑
                    else {
                        return half4(0,0,0,1);
                        }
                    }
                    //return SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord);
                }
                else if(side1 < lowerBound - fadeDist) {
                    if(side2 > upperBound + fadeDist) {
                        return SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord);
                    }
                    else if(side2 < lowerBound + fadeDist) {
                        return SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord);
                    }
                    else
                    {
                        if(side2 > upperBound - fadeDist) {
                        float t = smoothstep(upperBound - fadeDist, upperBound + fadeDist, side2);
                        return lerp(SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord), half4(0,0,0,1), t);
                        }
                    // 下边缘混合
                    else if(side2 < lowerBound + fadeDist) {
                        float t = smoothstep(lowerBound - fadeDist, lowerBound + fadeDist, side2);
                        return lerp(half4(0,0,0,1), SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord), t);

                        }
                    // 中间纯黑
                    else {
                        return half4(0,0,0,1);
                        }
                    }

                }
                else {
                    // 上边缘混合
                    if(side1 > upperBound - fadeDist) {
                        float t = smoothstep(upperBound - fadeDist, upperBound + fadeDist, side1);
                        return lerp(half4(0,0,0,1), SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord), t);
                    }
                    // 下边缘混合
                    else if(side1 < lowerBound + fadeDist) {
                        float t = smoothstep(lowerBound - fadeDist, lowerBound + fadeDist, side1);
                        return lerp(SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord), half4(0,0,0,1), t);
                    }
                    // 中间纯黑
                    else {
                        return half4(0,0,0,1);
                    }
                }
            }
            ENDHLSL
        }
    }
}