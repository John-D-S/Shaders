using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Random = UnityEngine.Random;

public class Ball : MonoBehaviour
{
    [SerializeField] private float ballSpeed = 5f;
    private float timeAlive;
    private float timer;

    private void OnEnable()
    {
        timeAlive = Random.Range(5f, 25f);
        timer = 0;
    }

    private void FixedUpdate()
    {
        timer += Time.fixedDeltaTime * ballSpeed;
        transform.position += transform.forward * Time.fixedDeltaTime;
        if(timer > timeAlive)
        {
            gameObject.SetActive(false);
        }
    }
}
