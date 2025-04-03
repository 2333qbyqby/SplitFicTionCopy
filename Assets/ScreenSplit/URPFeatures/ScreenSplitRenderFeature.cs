using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using static UnityEngine.XR.XRDisplaySubsystem;

public class ScreenSplitRenderFeature : ScriptableRendererFeature
{
    public enum SplitType
    {
        twoCamera,
        fourCamera,
        CircleMask,
        RectMask,
    }


    [SerializeField] private Material m_Material;
    [SerializeField] private Material m_Mask_Material_Circle;
    [SerializeField] private Material m_Mask_Material_Rect;
    [SerializeField] private string targetCameraTag = "MainCamera";
    [SerializeField] private SplitType m_SplitType = SplitType.twoCamera;

    private ScreenSplitRenderPass m_RenderPass;

    public override void Create()
    {
        var rtLeft = CameraManager.Instance != null ? CameraManager.Instance.GetLeftTexture() : null;
        var rtRight = CameraManager.Instance != null ? CameraManager.Instance.GetRightTexture() : null;

        switch (m_SplitType)
        {
            case SplitType.twoCamera:
                m_RenderPass = new ScreenSplitRenderPass(m_Material, rtLeft, rtRight);
                break;
            case SplitType.fourCamera:
                break;
            case SplitType.CircleMask:
                m_RenderPass = new ScreenSplitRenderPass(m_Mask_Material_Circle, rtLeft, rtRight);
                break;
            case SplitType.RectMask:
                m_RenderPass = new ScreenSplitRenderPass(m_Mask_Material_Rect, rtLeft, rtRight);
                break;
            default:
                m_RenderPass = new ScreenSplitRenderPass(m_Material, rtLeft, rtRight);
                break;
        }
        m_RenderPass.renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
    }
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (m_Material == null) return;
        // 获取当前渲染的摄像机
        Camera currentCamera = renderingData.cameraData.camera;

        // 判断条件（根据标签或实例）
        if (currentCamera.CompareTag(targetCameraTag))
        {
            renderer.EnqueuePass(m_RenderPass);
        }
    }
    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {
        if (m_RenderPass == null) return;
        // 获取当前渲染的摄像机
        Camera currentCamera = renderingData.cameraData.camera;

        // 判断条件（根据标签或实例）
        if (currentCamera.CompareTag(targetCameraTag))
        {
            if (renderingData.cameraData.camera.cameraType == CameraType.Game)
            {
                m_RenderPass.SetTarget(renderer.cameraColorTargetHandle);
                m_RenderPass.ConfigureInput(ScriptableRenderPassInput.Color);

            }
        }


    }
    protected override void Dispose(bool isDisposing)
    {
    }
}

