using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraDepthSample : PostEffectBase {

    public Camera camera;

    public Shader m_shader;

    private Material m_mat;
	// Use this for initialization
	void Start () {
		if (camera != null)
        {
            camera.depthTextureMode |= DepthTextureMode.Depth;
        }
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
        Debug.Log("did");
    }

    private void OnDisable()
    {
        camera.depthTextureMode &= ~DepthTextureMode.Depth;
    }


    public Material mat
    {
        get
        {
            m_mat = CheckShaderAndMat(m_shader, m_mat);
            return m_mat;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, mat,0);
    }
}
