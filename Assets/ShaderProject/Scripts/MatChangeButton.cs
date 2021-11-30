using System;
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
            Debug.Log(e.Message);
            throw;
        }
        material = GetComponent<MeshRenderer>().material;
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Player"))
        {
            fluidManager.SetAllMaterials(material);
        }
    }
}
