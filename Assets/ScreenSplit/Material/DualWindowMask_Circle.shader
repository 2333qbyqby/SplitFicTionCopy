Shader "Custom/DualWindowMask_Circle"
{
    Properties
    {
        _Camera1Tex ("Camera 1 Texture", 2D) = "white" {}
        _Camera2Tex ("Camera 2 Texture", 2D) = "white" {}
        _Radius("Radius", Range(0, 1)) = 0.3
        _Center("Window Center", Vector) = (0.5, 0.5, 0, 0)
        _BorderWidth("Border Width", Range(0, 0.5)) = 0.1
        [Toggle]_Pulse("Pulse Effect", int) = 0
        _PulseSpeed("Pulse Speed", Float) = 1.0
        _PulseAmplitude("Pulse Amplitude", Float) = 0.1
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
             float _Radius;
            float4 _Center;
            float _BorderWidth;
            int _Pulse;
            float _PulseSpeed;
            float _PulseAmplitude;
            CBUFFER_END

            half4 frag (Varyings i) : SV_Target
            {
                // 转换为以中心为原点的坐标系
                float2 centeredUV = i.texcoord - _Center.xy;
                float aspect = _ScreenParams.x / _ScreenParams.y;
                centeredUV.x *= aspect; 
                // 脉冲效果
                float pulse = _Pulse ? sin(_Time.y * _PulseSpeed) * _PulseAmplitude : 0;
                float currentRadius = _Radius + pulse;

               // 计算距离
                float distance = length(centeredUV);
                float fade = fwidth(distance) * 2.0;

                // 边界计算（保持视觉一致性）
                float borderScale = 1.0 / aspect;
                float inner = currentRadius - _BorderWidth * 0.5 * borderScale;
                float outer = currentRadius + _BorderWidth * 0.5 * borderScale;

                // 区域判断
                if (distance < inner - fade) {
                    return SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord);
                } else if (distance > outer + fade) {
                    return SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord);
                } else {
                    // 边缘混合
                    if (distance < inner + fade) {
                        float t = smoothstep(inner - fade, inner + fade, distance);
                        return lerp(
                            SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord),
                            half4(0,0,0,1),
                            t
                        );
                    } else if (distance > outer - fade) {
                        float t = smoothstep(outer - fade, outer + fade, distance);
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