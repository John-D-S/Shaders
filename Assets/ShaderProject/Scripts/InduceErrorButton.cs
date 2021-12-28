using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

using UnityEngine;

using Random = UnityEngine.Random;

public class InduceErrorButton : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Player"))
        {
            if(Random.Range(0f, 1f) > 0.5f)
            {
                GameObject _go = null;
                try
                {
                    _go.transform.position = Vector3.up;
                }
                catch(Exception e)
                {
                    Debug.Log("shouldHaveLogged");
                    LogErrorToFile(e);
                    throw;
                }
            }
            else
            {
                int i = 0;
                try
                {
                    i = 5 / i;
                }
                catch(Exception e)
                {
                    Debug.Log("shouldHaveLogged");
                    LogErrorToFile(e);
                    throw;
                }
            }
        }
    }

    /// <summary>
    /// logs the exception message to a text file, along with the date and time
    /// </summary>
    public void LogErrorToFile(Exception _exception)
    {
        string filepath = "errorLogs/";  //Text File Path
        if (!Directory.Exists(filepath))  
        {  
            Directory.CreateDirectory(filepath);
        }  
        filepath = filepath + DateTime.Today.ToString("dd-MM-yy") + ".txt";
        if (!File.Exists(filepath))  
        {  
            File.Create(filepath).Dispose();
        }  
        using (StreamWriter sw = File.AppendText(filepath))  
        {  
            string error = $"{DateTime.Now.ToString()} - {_exception.Message}"; 
            sw.WriteLine(error);
            sw.Flush();  
            sw.Close();
        }
    }
}
