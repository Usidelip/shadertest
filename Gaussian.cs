using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gaussian :PostEffectBase {

    public Shader m_shader;
    private Material m_mat;
    public int downSample = 1;
    public int iteration = 4;
    public float blurSize = 0.5f;
    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
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
        int rtW = source.width / downSample;
        int rtH = source.height / downSample;
        RenderTexture buff0 = RenderTexture.GetTemporary(rtW, rtH, 0);
        buff0.filterMode = FilterMode.Bilinear;

        Graphics.Blit(source, buff0);
        for (int i = 0; i < iteration; i++)
        {
            mat.SetFloat("_BlurSize", 1.0f + i * blurSize);
            RenderTexture buff1 = RenderTexture.GetTemporary(rtW, rtH, 0);
            Graphics.Blit(buff0, buff1, mat, 1);

            RenderTexture.ReleaseTemporary(buff0);

            buff0 = buff1;
            buff1 = RenderTexture.GetTemporary(rtW, rtH, 0);
            Graphics.Blit(buff0, buff1, m_mat, 2);
            RenderTexture.ReleaseTemporary(buff0);
            buff0 = buff1;


        }

        Graphics.Blit(buff0, destination);
        RenderTexture.ReleaseTemporary(buff0);


    }


}
