using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class MatChangeButton : MonoBehaviour
{
    private Material material;
    private FluidManager fluidManager;
    private void Start()
    {
        try
        {
            fluidManager = FindObjectOfType<FluidManager>(true);
        }
        catch(Exception e)
        {
            File.WriteAllText("errorLog.txt", e.Message);
            throw;
        }
        material = GetComponent<MeshRenderer>().material;
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Player"))
        {
            try
            {
                fluidManager.SetAllMaterials(material);
            }
            catch(Exception e)
            {
                File.WriteAllText("errorLog.txt", e.Message);
                throw;
            }
        }
    }
}
