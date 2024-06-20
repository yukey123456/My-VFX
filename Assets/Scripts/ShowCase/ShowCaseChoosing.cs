using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class ShowCaseChoosing : MonoBehaviour
{
    [SerializeField] private Camera _camera;
    [SerializeField] private GameObject gobjContent;
    [SerializeField] private CaseButton btnCasePrefab;
    [SerializeField] private Transform tfmButtonHolder;
    [SerializeField] private Button btnExit;
    [SerializeField] private List<CaseInfo> lstCase;

    private List<CaseButton> lstBtnCase = new List<CaseButton>();
    private int _currDemoScene = -1;

    private void Start()
    {
        btnExit.gameObject.SetActive(false);

        foreach (var info in lstCase)
        {
            var btn = Instantiate(btnCasePrefab, tfmButtonHolder);
            btn.Init(info);
            btn.Button.onClick.AddListener(() => OnCaseButtonClick(btn));
            lstBtnCase.Add(btn);
        }
    }

    public void OnCaseButtonClick(CaseButton button)
    {
        int _index = lstBtnCase.IndexOf(button);
        int demoScene = (int)lstCase[_index].demoScene;
        SceneManager.LoadScene(demoScene, LoadSceneMode.Additive);
        _currDemoScene = demoScene;
        gobjContent.SetActive(false);
        btnExit.gameObject.SetActive(true);
    }

    public void OnExitClick()
    {
        SceneManager.UnloadSceneAsync(_currDemoScene);
        gobjContent.SetActive(true);
        btnExit.gameObject.SetActive(false);
    }
}
