using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenSplitGameManager : MonoBehaviour
{
    [SerializeField] private GameObject playerPrefabScene1;
    [SerializeField] private GameObject playerPrefabScene2;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //实现简单的左右走

        if (Input.GetKey(KeyCode.A))
        {
            playerPrefabScene1.transform.Translate(Vector3.left * Time.deltaTime);
            playerPrefabScene2.transform.Translate(Vector3.left * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.D))
        {
            playerPrefabScene1.transform.Translate(Vector3.right * Time.deltaTime);
            playerPrefabScene2.transform.Translate(Vector3.right * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.W))
        {
            playerPrefabScene1.transform.Translate(Vector3.up * Time.deltaTime);
            playerPrefabScene2.transform.Translate(Vector3.up * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.S))
        {
            playerPrefabScene1.transform.Translate(Vector3.down * Time.deltaTime);
            playerPrefabScene2.transform.Translate(Vector3.down * Time.deltaTime);
        }
    }
}
