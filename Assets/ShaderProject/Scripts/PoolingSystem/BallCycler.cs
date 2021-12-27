using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Random = UnityEngine.Random;

public class BallCycler : MonoBehaviour
{
    private void FixedUpdate()
    {
        GameObject ball = ObjectPooler.sharedInstance.GetPooledObject();
        if(ball != null)
        {
            ball.transform.position = transform.position + new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), 0);
            ball.SetActive(true);
        }
    }
}
