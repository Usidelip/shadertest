using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class res : MonoBehaviour {

	// Use this for initialization
	void Start () {
		flar[] objs = gameObject.transform.GetComponentsInChildren<flar>();
		for(int i = 0;i<objs.Length;i++){
			Debug.Log("did");
			GameObject.Destroy(objs[i].gameObject);

		}
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
