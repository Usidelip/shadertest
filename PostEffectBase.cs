using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostEffectBase : MonoBehaviour {

   

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    public bool IsSupported()
    {
        if(SystemInfo.supportsRenderTextures == false || SystemInfo.supportsImageEffects == false)
        {
            return false;
        }
        return true;
    }

    public Material CheckShaderAndMat(Shader shader, Material mat)
    {
        if (shader == null)
        {
            return null;
        }

        if (shader.isSupported && mat != null && mat.shader == shader)
        {
            return mat;
        }

        if (!shader.isSupported)
        {
            return null;
        }
        mat = new Material(shader);
        mat.hideFlags = HideFlags.DontSave;
        return mat;



    }


  
    
}
