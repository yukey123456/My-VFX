using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayVFXs : MonoBehaviour
{
    public List<ParticleSystem> lstVfxs;

    public void PlayVFX(int index)
    {
        lstVfxs[index].Play();
    }
}
