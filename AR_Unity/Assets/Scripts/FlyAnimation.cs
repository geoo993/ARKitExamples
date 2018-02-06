using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlyAnimation : MonoBehaviour {
    private Animation anim {
        get {
            return GetComponent<Animation>();
        }
    }

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
    
    public void fly () {
        anim.Play();
    }
}
