using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Collider))]
public class ToggleObjectEnabled : MonoBehaviour
{
	[SerializeField] private GameObject gameObjectToToggleEnableOn;

	private void OnTriggerEnter(Collider other)
	{
		if(other.CompareTag("Player"))
		{
			gameObjectToToggleEnableOn.SetActive(!gameObjectToToggleEnableOn.activeSelf);
		}
	}
}
