using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PositionSign : MonoBehaviour
{
    [SerializeField] private Camera m_CurrentSceneCamera;
    
    public Vector2 GetCurrentGameObjectScreenPosition()
    {
        // Get the position of the GameObject in world space
        Vector3 worldPosition = transform.position;
        // Convert the world position to screen space
        Vector3 screenPosition = m_CurrentSceneCamera.WorldToScreenPoint(worldPosition);
        // Return the screen position as a Vector2
        return new Vector2(screenPosition.x, screenPosition.y);
    }
}
