Shader "Unlit/StencilObject"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _index ("Index", Range(0, 255)) = 0
        _BorderWidth ("Border Width", Range(0, 0.1)) = 0.05
        _BorderColor ("Border Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags 
        {
        "RenderType"="Opaque" 
        "Queue"="Geometry"
        "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        Pass
        {
        Name "Stencil Write"
            ZWrite Off

            Cull Off
            Blend Zero One // 修改为Alpha混合
            Stencil
            {
                Ref [_index]
                Comp Always
                Pass Replace
                Fail Keep
            }
            
            
        }
        
        }
    }
