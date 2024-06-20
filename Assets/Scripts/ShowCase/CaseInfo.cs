using System;
using UnityEngine;
using UnityEngine.SceneManagement;

[Serializable]
public class CaseInfo 
{
    public string txtName;
    public Sprite sprScreenshot;
    public SceneType demoScene;
}

public enum SceneType
{
    MobileCelShader = 1,
}
