using UnityEngine;
using System.Collections;

namespace DigitalRuby.PyroParticles
{
    /// <summary>
    /// Simple script to fade in and out a light for an effect, as well as randomize movement for constant effects
    /// </summary>
    public class FireLightScript : MonoBehaviour
    {
        [Tooltip("Random seed for movement, 0 for no movement.")]
        public float Seed = 100.0f;

        [Tooltip("Multiplier for light intensity.")]
        public float IntensityModifier = 2.0f;

        [SingleLine("Min and max intensity range.")]
        public RangeOfFloats IntensityMaxRange = new RangeOfFloats { Minimum = 0.0f, Maximum = 8.0f };

        private Light firePointLight;
        private float lightIntensity;
        private float seed;
        private FireBaseScript fireBaseScript;
        private float baseY;

        private void Awake()
        {
            // find a point light
            firePointLight = gameObject.GetComponentInChildren<Light>();
            if (firePointLight != null)
            {
                // we have a point light, set the intensity to 0 so it can fade in nicely
                lightIntensity = firePointLight.intensity;
                firePointLight.intensity = 0.0f;
                baseY = firePointLight.gameObject.transform.position.y;
            }
            seed = UnityEngine.Random.value * Seed;
            fireBaseScript = gameObject.GetComponent<FireBaseScript>();
        }

        private void Update()
        {
            if (firePointLight == null)
            {
                return;
            }

            if (seed != 0)
            {
                // we have a random movement seed, set up with random movement
                bool setIntensity = true;
                float intensityModifier2 = 1.0f;
                if (fireBaseScript != null)
                {
                    if (fireBaseScript.Stopping)
                    {
                        // don't randomize intensity during a stop, it looks bad
                        setIntensity = false;
                        firePointLight.intensity = Mathf.Lerp(firePointLight.intensity, 0.0f, fireBaseScript.StopPercent);
                    }
                    else if (fireBaseScript.Starting)
                    {
                        intensityModifier2 = fireBaseScript.StartPercent;
                    }
                }

                if (setIntensity)
                {
                    float intensity = Mathf.Clamp(IntensityModifier * intensityModifier2 * Mathf.PerlinNoise(seed + Time.time, seed + 1 + Time.time),
                        IntensityMaxRange.Minimum, IntensityMaxRange.Maximum);
                    firePointLight.intensity = intensity;
                }

                // random movement with perlin noise
                float x = Mathf.PerlinNoise(seed + 0 + Time.time * 2, seed + 1 + Time.time * 2) - 0.5f;
                float y = baseY + Mathf.PerlinNoise(seed + 2 + Time.time * 2, seed + 3 + Time.time * 2) - 0.5f;
                float z = Mathf.PerlinNoise(seed + 4 + Time.time * 2, seed + 5 + Time.time * 2) - 0.5f;
                firePointLight.gameObject.transform.localPosition = Vector3.up + new Vector3(x, y, z);
            }
            else if (fireBaseScript.Stopping)
            {
                // fade out
                firePointLight.intensity = Mathf.Lerp(firePointLight.intensity, 0.0f, fireBaseScript.StopPercent);
            }
            else if (fireBaseScript.Starting)
            {
                // fade in
                firePointLight.intensity = Mathf.Lerp(0.0f, lightIntensity, fireBaseScript.StartPercent);
            }
        }
    }
}