using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class CameraManager : MonoBehaviour
{
    [SerializeField] private Camera camera1;
    [SerializeField] private Camera camera2;

    [SerializeField] private Material blendMaterial;

    private RenderTexture rtLeft;
    private RenderTexture rtRight;

    public static CameraManager Instance { get; private set; }
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
    }
    private void Start()
    {
        UpdateRenderTextures();
    }

    private void UpdateRenderTextures()
    {
        rtLeft = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);
        rtRight = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);

        camera1.targetTexture = rtLeft;

        camera2.targetTexture = rtRight;
    }

    private void ReleaseRenderTextures()
    {
        if (rtLeft != null)
        {
            rtLeft.Release();
        }
        if (rtRight != null)
        {
            rtRight.Release();
        }
    }

    private void OnDestroy()
    {
        ReleaseRenderTextures();
    }

    public RenderTexture GetLeftTexture()
    {
        return rtLeft;
    }
    public RenderTexture GetRightTexture()
    {
        return rtRight;
    }
}

