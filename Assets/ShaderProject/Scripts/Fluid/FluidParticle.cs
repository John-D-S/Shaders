using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody), typeof(MeshRenderer))]
public class FluidParticle : MonoBehaviour
{
    public Vector3 Position
    {
        get => gameObject.transform.position;
        set => gameObject.transform.position = value;
    }
    public Vector3 Velocity => rigidbody.velocity;
    private MeshRenderer renderer;
    
    public void AddForce(Vector3 force)
    {
        rigidbody.AddForce(force);
    }
    
    public List<FluidParticle> nearbyParticles;
    private Rigidbody rigidbody;
    private void Awake()
    {
        rigidbody = GetComponent<Rigidbody>();
        renderer = GetComponent<MeshRenderer>();
    }

    public void SetMaterial(Material material)
    {
        renderer.material = material;
    }
}
