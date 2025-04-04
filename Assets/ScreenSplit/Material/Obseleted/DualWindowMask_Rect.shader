Shader "Custom/DualWindowMask_Rect"
{
    Properties
    {
        _Camera1Tex ("Camera 1 Texture", 2D) = "white" {}
        _Camera2Tex ("Camera 2 Texture", 2D) = "white" {}
        _Size("Size", Range(0, 1)) = 0.4
        _Center("Window Center", Vector) = (0.5, 0.5, 0, 0)
        _BorderWidth("Border Width", Range(0, 0.5)) = 0.1
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
            Name "SceneMask"
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
            float _Size;
            float4 _Center;
            float _BorderWidth;
            CBUFFER_END

            half4 frag (Varyings i) : SV_Target
            {
                // 转换为以中心为原点的坐标系
                float2 centeredUV = i.texcoord - _Center.xy;
                float2 absUV = abs(centeredUV);
                float maxEdge = max(absUV.x, absUV.y);
                
                // 计算抗锯齿
                float fade = fwidth(maxEdge) * 2.0;

                 // 边界计算
                float inner = _Size - _BorderWidth/2;
                float outer = _Size + _BorderWidth/2;

                // 区域判断
                if (maxEdge < inner - fade) {
                    return SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord);
                } else if (maxEdge > outer + fade) {
                    return SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord);
                } else {
                    // 边缘混合
                    if (maxEdge < inner + fade) {
                        float t = smoothstep(inner - fade, inner + fade, maxEdge);
                        return lerp(
                            SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord),
                            half4(0,0,0,1),
                            t
                        );
                    } else if (maxEdge > outer - fade) {
                        float t = smoothstep(outer - fade, outer + fade, maxEdge);
                        return lerp(
                            half4(0,0,0,1),
                            SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord),
                            t
                        );
                    }
                    return half4(0,0,0,1); // 纯边框
                }
            }
            ENDHLSL
        }
    }
}