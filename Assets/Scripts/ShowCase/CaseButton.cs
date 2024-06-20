using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class CaseButton : MonoBehaviour
{
    [SerializeField] private Text txtName;
    [SerializeField] private Image imgCase;
    [SerializeField] private Button btn;

    public Button Button => btn;

    public void Init(CaseInfo info)
    {
        gameObject.SetActive(true);
        txtName.text = info.txtName;
        imgCase.sprite = info.sprScreenshot;
        btn.onClick.RemoveAllListeners();
    }

}
