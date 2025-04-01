using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine;

public class ScreenSplitRenderPass : ScriptableRenderPass
{
    ProfilingSampler m_ProfilingSampler = new ProfilingSampler("ColorBlit");
    private Material blendMaterial;
    private RenderTexture rtLeft;
    private RenderTexture rtRight;
    private RTHandle m_FinalOutPutRT;
    public ScreenSplitRenderPass(Material material,RenderTexture RT1,RenderTexture RT2)
    {
        blendMaterial = material;
        rtLeft = RT1;
        rtRight = RT2;
        renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
    }
    public void SetTarget(RTHandle target)
    {
        m_FinalOutPutRT = target;
    }
    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        ConfigureTarget(m_FinalOutPutRT);
    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (blendMaterial == null) return;
        var cameraData = renderingData.cameraData;
        if (cameraData.camera.cameraType != CameraType.Game)
        {
            return;
        }
        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, m_ProfilingSampler))
        {
            if (rtLeft != null && rtRight != null)
            {
                blendMaterial.SetTexture("_Camera1Tex", rtLeft);
                blendMaterial.SetTexture("_Camera2Tex", rtRight);
                Blitter.BlitCameraTexture(cmd, m_FinalOutPutRT, m_FinalOutPutRT, blendMaterial, 0);
            }
        }
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
        CommandBufferPool.Release(cmd);
    }
}