using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SplitManager : MonoBehaviour
{
    [SerializeField] private PositionSign[] positionSigns;
    [SerializeField] private Material m_Material;

    private int _splitCenterID = Shader.PropertyToID("_Center");
    private int _splitAngleID = Shader.PropertyToID("_Angle");
    public static SplitManager Instance { get; private set; }

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }
    private void Start()
    {
        positionSigns = FindObjectsOfType<PositionSign>();
        foreach (var positionSign in positionSigns)
        {
            positionSign.GetCurrentGameObjectScreenPosition();
            Debug.Log("Screen Position: " + positionSign.GetCurrentGameObjectScreenPosition());
        }
    }
    private void Update()
    {
        UpdateSplitPosition();
    }

    private void UpdateSplitPosition()
    {
        if (positionSigns.Length != 2)
        {
            return; 
        }
        Vector2 leftScreenPos = positionSigns[0].GetCurrentGameObjectScreenPosition();
        Vector2 rightScreenPos = positionSigns[1].GetCurrentGameObjectScreenPosition();
        Vector2 middlePosition = (leftScreenPos + rightScreenPos) / 2;
        //normalize到[0,1]之间
        middlePosition = new Vector2(middlePosition.x / Screen.width, middlePosition.y / Screen.height);
        m_Material.SetVector(_splitCenterID, new Vector4(middlePosition.x,middlePosition.y, 0, 0));
        Vector2 dir = (rightScreenPos - leftScreenPos).normalized;
        //计算角度
        float angle = Mathf.Atan2(dir.y, dir.x) * Mathf.Rad2Deg;
        //变成从0到180度
        angle -= 180;
        if (angle < 0)
        {
            angle += 360;
        }
        //设置材质属性
        m_Material.SetFloat(_splitAngleID, angle);

    }
}
