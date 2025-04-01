using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using static UnityEngine.XR.XRDisplaySubsystem;

public class ScreenSplitRenderFeature : ScriptableRendererFeature
{



    [SerializeField] private Material m_Material;
    [SerializeField] private string targetCameraTag = "MainCamera";


    private ScreenSplitRenderPass m_RenderPass;

    public override void Create()
    {
        Debug.Log("Create");
        var rtLeft = CameraManager.Instance != null ? CameraManager.Instance.GetLeftTexture() : null;
        var rtRight = CameraManager.Instance != null ? CameraManager.Instance.GetRightTexture() : null;
        m_RenderPass = new ScreenSplitRenderPass(m_Material, rtLeft, rtRight);
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

