using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectPooler : MonoBehaviour
{
    public static ObjectPooler sharedInstance;

    private List<GameObject> pooledObjects;
    [SerializeField]
    private GameObject objectToPool;
    [SerializeField]
    private int amountToPool;
    [SerializeField]
    private bool shouldExpand = true;

    private void Awake()
    {
        sharedInstance = this;
    }

    private void Start()
    {
        pooledObjects = new List<GameObject>();
        for (int i = 0; i < amountToPool; i++) 
        {
            GameObject obj = (GameObject)Instantiate(objectToPool, transform, true);
            obj.SetActive(false); 
            pooledObjects.Add(obj);
        }   
    }
    
    /// <summary>
    /// gets an inactive pooled object or creates a new one if should expand is true and there are none. Otherwise returns null.
    /// </summary>
    public GameObject GetPooledObject() {
        for (int i = 0; i < pooledObjects.Count; i++) 
        {
            if (!pooledObjects[i].activeInHierarchy) 
            {
                return pooledObjects[i];
            }
        } 
        if (shouldExpand) 
        {
            GameObject obj = Instantiate(objectToPool, transform, true);
            obj.SetActive(false);
            pooledObjects.Add(obj);
            return obj;
        }
        return null;
    }
}
