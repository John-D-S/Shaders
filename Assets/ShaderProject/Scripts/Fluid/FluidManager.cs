using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Random = UnityEngine.Random;

public class FluidManager : MonoBehaviour
{
    [SerializeField] private FluidParticle fluidParticlePrefab;
    [SerializeField] private float nearbyDistance = 1;
    [SerializeField] private int particlesToSimulateAtATime = 50;
    [SerializeField] private float particleSize = 0.5f;
    [SerializeField] private int maxNearbyParticles = 5;
    [SerializeField] private float particleRepulsionStrength = 1;
    [SerializeField] private float particleAttractionStrength = 0.75f;
    [SerializeField] private float particleRandomForce = 0.1f;
    [SerializeField] private float targetNumberOfParticles = 250;
    private float squaredParticleSize;
    private float squaredNearbyDistance;
    
    private List<FluidParticle> spawnedParticles = new List<FluidParticle>();
    
    private float SquareDistance(Vector3 a, Vector3 b) => Mathf.Pow(a.x - b.x, 2) + Mathf.Pow(a.y - b.y, 2) + Mathf.Pow(a.z - b.z, 2);

    private void Start()
    {
        squaredParticleSize = Mathf.Pow(particleSize, 2);
        squaredNearbyDistance = Mathf.Pow(particleSize, 2);
        StartCoroutine(UpdateAllNearbyParticles());
    }

    public void SetAllMaterials(Material material)
    {
        foreach(FluidParticle spawnedParticle in spawnedParticles)
        {
            spawnedParticle.SetMaterial(material);
        }
    }
    
    private List<FluidParticle> UpdateNearByParticles(FluidParticle fluidParticle)
    {
        List<FluidParticle> returnVal = new List<FluidParticle>();
        int i = 0;
        foreach(FluidParticle particle in spawnedParticles)
        {
            if(i > maxNearbyParticles)
            {
                break;
            }
            if(Vector3.Distance(fluidParticle.Position, particle.Position) < nearbyDistance && particle != fluidParticle)
            {
                returnVal.Add(particle);
                i++;
            }
        }
        return returnVal;
    }

    private IEnumerator UpdateAllNearbyParticles()
    {
        while(true)
        {
            while(spawnedParticles.Count < 2)
                    yield return new WaitForFixedUpdate();
            for(int i = 0; i < spawnedParticles.Count; i++)
            {
                if(i % particlesToSimulateAtATime == 0 || i >= spawnedParticles.Count - 1)
                {
                    yield return new WaitForFixedUpdate();
                }
                spawnedParticles[i].nearbyParticles = UpdateNearByParticles(spawnedParticles[i]);                
            }
        }
    }

    /// <summary>
    /// calculate the repulsion force at a given position
    /// </summary>
    private Vector3 RepulsionForce(FluidParticle particle, FluidParticle repulsiveParticle)
    {
        Vector3 positionRelativeToFieldCenter = repulsiveParticle.Position - particle.Position;
        Vector3 directionToApplyForceIn = -positionRelativeToFieldCenter.normalized;
        float distanceToCenter = positionRelativeToFieldCenter.magnitude;
        return directionToApplyForceIn * (particleSize * particleRepulsionStrength / distanceToCenter);
    }
    
    /// <summary>
    /// calculate the attraction force at a given position.
    /// </summary>
    private Vector3 AttractionForce(FluidParticle particle, FluidParticle attractiveParticle)
    {
        Vector3 positionRelativeToFieldCenter = attractiveParticle.Position - particle.Position;
        Vector3 directionToApplyForceIn = positionRelativeToFieldCenter.normalized;
        float distanceToCenter = positionRelativeToFieldCenter.magnitude;
        return directionToApplyForceIn * (nearbyDistance * particleAttractionStrength / distanceToCenter);
    }
    
    
    private Vector3 ParticleForceToApply(FluidParticle particle)
    {
        Vector3 returnVal = Vector3.zero;
        foreach(FluidParticle nearbyParticle in particle.nearbyParticles)
        {
            if(SquareDistance(particle.Position, nearbyParticle.Position) < squaredParticleSize)
            {
                returnVal += RepulsionForce(particle, nearbyParticle);
            }
            else
            {
                returnVal += AttractionForce(particle, nearbyParticle);
            }
            returnVal += Random.onUnitSphere * particleRandomForce;
        }
        return returnVal.normalized;
    }
    
    private void FixedUpdate()
    {
        if(spawnedParticles.Count < targetNumberOfParticles)
        {
            spawnedParticles.Add(Instantiate(fluidParticlePrefab, transform.position + Random.onUnitSphere * 4, Quaternion.identity, transform));
        }
        for(int i = 0; i < spawnedParticles.Count; i++)
        {
            spawnedParticles[i].AddForce(ParticleForceToApply(spawnedParticles[i]));
        }
    }
}
