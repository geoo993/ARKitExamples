using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireControl : MonoBehaviour {

    private ParticleSystem ps {
        get {
            return GetComponent<ParticleSystem>();
        }
    }
    
	public void StartFire () {
		ps.Play();
	}
    
    public void StopFire () {
        ps.Stop();
    }
}
