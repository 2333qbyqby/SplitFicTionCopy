Shader "Custom/DualCameraSplit"
{
    Properties
    {
        _Camera1Tex ("Camera 1 Texture", 2D) = "white" {}
        _Camera2Tex ("Camera 2 Texture", 2D) = "white" {}
        _Angle("Split Angle", Range(0, 360)) = 90
        _Offset("Split Offset", Range(-1, 1)) = 0
        _splitInterval("Split Interval", Range(0, 1)) = 0.1
        [Toggle]_ifWave("ifWave",int) = 0
        //波浪效果参数
        _WaveFrequency("Wave Frequency", Float) = 10.0
        _WaveSpeed("Wave Speed", Float) = 2.0
        _WaveAmplitude("Wave Amplitude", Float) = 0.05
    }
    
    SubShader
    {
        Tags 
        {
            "RenderPipeline" = "UniversalPipeline"
            //"RenderType"="Opaque"
            //"queue"="Overlay"
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
            float _Offset;
            float _splitInterval;
            float _WaveFrequency;
            float _WaveSpeed;
            float _WaveAmplitude;
            int _ifWave;
            CBUFFER_END

            half4 frag (Varyings i) : SV_Target
            {
                // 转换为以中心为原点的坐标系
                float2 centeredUV = i.texcoord - float2(0.5, 0.5);
                // 计算角度方向向量
                float angleRad = radians(_Angle);
                float2 direction = float2(cos(angleRad), sin(angleRad));

                // 计算垂直方向（波浪传播方向）
                float2 perpendicularDirection = float2(-direction.y, direction.x);
                // 波浪计算
                float perpendicularPos = dot(centeredUV, perpendicularDirection);
                float wave = sin(perpendicularPos * _WaveFrequency + _Time.y * _WaveSpeed) * _WaveAmplitude/2;
                wave += sin(perpendicularPos * _WaveFrequency * 2 + _Time.y * _WaveSpeed) * _WaveAmplitude/2;

                wave = _ifWave == 1 ? wave : 0;
                 // 计算点与分割线的相对位置（带偏移量）
                float side = dot(centeredUV, direction) - _Offset + wave;
                 // 计算抗锯齿参数
                float fadeDist = fwidth(side) * 1.5; // 控制抗锯齿范围
                float upperBound = _splitInterval/2;
                float lowerBound = -upperBound;

                // 边缘混合计算(Deep Seek给的，来抗锯齿)
                if(side > upperBound + fadeDist) {
                    return SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord);
                }
                else if(side < lowerBound - fadeDist) {
                    return SAMPLE_TEXTURE2D(_Camera1Tex, sampler_Camera1Tex, i.texcoord);
                }
                else {
                    // 上边缘混合
                    if(side > upperBound - fadeDist) {
                        float t = smoothstep(upperBound - fadeDist, upperBound + fadeDist, side);
                        return lerp(half4(0,0,0,1), SAMPLE_TEXTURE2D(_Camera2Tex, sampler_Camera2Tex, i.texcoord), t);
                    }
                    // 下边缘混合
                    else if(side < lowerBound + fadeDist) {
                        float t = smoothstep(lowerBound - fadeDist, lowerBound + fadeDist, side);
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