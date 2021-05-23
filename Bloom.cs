using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase{

    public Shader m_shader;
    private Material m_mat;
    public int downSample = 2;

    public int iteration = 4;

    public float luminThreshold = 0.6f;

    public float blurSpread = 0f;
    // Use this for initialization
    void Start () {
		Debug.Log("sdfsdf");
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
        mat.SetFloat("_LuminThreshold", luminThreshold);
        int rtW = source.width / downSample;
        int rtH = source.height / downSample;
        RenderTexture buff0 = RenderTexture.GetTemporary(rtW, rtH,0);
        buff0.filterMode = FilterMode.Bilinear;
        Graphics.Blit(source, buff0, mat, 0);
        
        for(int i = 0; i < iteration; i++)
        {
            m_mat.SetFloat("_BlurSize", 1.0f + i * blurSpread);
            RenderTexture buff1 = RenderTexture.GetTemporary(rtW, rtH,0);
            Graphics.Blit(buff0, buff1,mat, 1);

            RenderTexture.ReleaseTemporary(buff0);

            buff0 = buff1;
            buff1 = RenderTexture.GetTemporary(rtW, rtH,0);
            Graphics.Blit(buff0, buff1, m_mat, 2);
            RenderTexture.ReleaseTemporary(buff0);
            buff0 = buff1;


        }

        m_mat.SetTexture("_Bloom", buff0);
        Graphics.Blit(source, destination, m_mat, 3);
        RenderTexture.ReleaseTemporary(buff0);


    }



}
