using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WindowComtroller : MonoBehaviour
{
    [SerializeField] private GameObject window;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //实现简单的左右走

        if (Input.GetKey(KeyCode.A))
        {
            window.transform.Translate(Vector3.left * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.D))
        {
            window.transform.Translate(Vector3.right * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.W))
        {
            window.transform.Translate(Vector3.up * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.S))
        {
            window.transform.Translate(Vector3.down * Time.deltaTime);
        }
    }
}
