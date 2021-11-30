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
        fluidManager = FindObjectOfType<FluidManager>(true);
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
