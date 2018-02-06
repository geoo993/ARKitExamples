using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace DigitalRuby.PyroParticles
{
    /// <summary>
    /// Meteor collision delegate
    /// </summary>
    /// <param name="script">Meteor swarm script</param>
    /// <param name="meteor">Meteor</param>
    public delegate void MeteorSwarmCollisionDelegate(MeteorSwarmScript script, GameObject meteor);

    /// <summary>
    /// Handles the meteor swarm effect
    /// </summary>
    public class MeteorSwarmScript : FireBaseScript, ICollisionHandler
    {
        [Tooltip("The game object prefab that represents the meteor.")]
        public GameObject MeteorPrefab;

        [Tooltip("Explosion particle system that should be emitted for each initial collision.")]
        public ParticleSystem MeteorExplosionParticleSystem;

        [Tooltip("Shrapnel particle system that should be emitted for each initial collision.")]
        public ParticleSystem MeteorShrapnelParticleSystem;

        [Tooltip("A list of materials to use for the meteors. One will be chosen at random for each meteor.")]
        public Material[] MeteorMaterials;

        [Tooltip("A list of meshes to use for the meteors. One will be chosen at random for each meteor.")]
        public Mesh[] MeteorMeshes;

        [Tooltip("The destination radius")]
        public float DestinationRadius;

        [Tooltip("The source of the meteor swarm (in the sky somewhere usually)")]
        public Vector3 Source;

        [Tooltip("The source radius")]
        public float SourceRadius;

        [Tooltip("The time it should take the meteors to impact assuming a clear path to destination.")]
        public float TimeToImpact = 1.0f;

        [SingleLine("How many meteors should be emitted per second (min and max)")]
        public RangeOfIntegers MeteorsPerSecondRange = new RangeOfIntegers { Minimum = 5, Maximum = 10 };

        [SingleLine("Scale multiplier for meteors (min and max)")]
        public RangeOfFloats ScaleRange = new RangeOfFloats { Minimum = 0.25f, Maximum = 1.5f };

        [SingleLine("Maximum life time of meteors in seconds (min and max).")]
        public RangeOfFloats MeteorLifeTimeRange = new RangeOfFloats { Minimum = 4.0f, Maximum = 8.0f };

        [Tooltip("Array of emission sounds. One will be chosen at random upon meteor creation.")]
        public AudioClip[] EmissionSounds;

        [Tooltip("Array of explosion sounds. One will be chosen at random upon impact.")]
        public AudioClip[] ExplosionSounds;

        /// <summary>
        /// A delegate that can be assigned to listen for collision. Use this to apply damage for meteor impacts or other effects.
        /// </summary>
        [HideInInspector]
        public event MeteorSwarmCollisionDelegate CollisionDelegate;

        private float elapsedSecond = 1.0f;

        private IEnumerator SpawnMeteor()
        {
            {
                float delay = UnityEngine.Random.Range(0.0f, 1.0f);
                yield return new WaitForSeconds(delay);
            }

            // find a random source and destination point within the specified radius
            Vector3 src = Source + (UnityEngine.Random.insideUnitSphere * SourceRadius);
            GameObject meteor = GameObject.Instantiate(MeteorPrefab);
            float scale = UnityEngine.Random.Range(ScaleRange.Minimum, ScaleRange.Maximum);
            meteor.transform.localScale = new Vector3(scale, scale, scale);
            meteor.transform.position = src;
            Vector3 dest = gameObject.transform.position + (UnityEngine.Random.insideUnitSphere * DestinationRadius);
            dest.y = 0.0f;

            // get the direction and set speed based on how fast the meteor should arrive at the destination
            Vector3 dir = (dest - src);
            Vector3 vel = dir / TimeToImpact;
            Rigidbody r = meteor.GetComponent<Rigidbody>();
            r.velocity = vel;
            float xRot = UnityEngine.Random.Range(-90.0f, 90.0f);
            float yRot = UnityEngine.Random.Range(-90.0f, 90.0f);
            float zRot = UnityEngine.Random.Range(-90.0f, 90.0f);
            r.angularVelocity = new Vector3(xRot, yRot, zRot);
            r.mass *= (scale * scale);

            // setup material
            Renderer renderer = meteor.GetComponent<Renderer>();
            renderer.sharedMaterial = MeteorMaterials[UnityEngine.Random.Range(0, MeteorMaterials.Length)];
            meteor.transform.parent = gameObject.transform;
            meteor.GetComponent<FireCollisionForwardScript>().CollisionHandler = this;

            // setup mesh
            Mesh mesh = MeteorMeshes[UnityEngine.Random.Range(0, MeteorMeshes.Length - 1)];
            meteor.GetComponent<MeshFilter>().mesh = mesh;

            // setup trail
            TrailRenderer t = meteor.GetComponent<TrailRenderer>();
            t.startWidth = UnityEngine.Random.Range(2.0f, 3.0f) * scale;
            t.endWidth = UnityEngine.Random.Range(0.25f, 0.5f) * scale;
            t.time = UnityEngine.Random.Range(0.25f, 0.5f);

            // play sound
            if (EmissionSounds != null && EmissionSounds.Length != 0)
            {
                AudioSource audio = meteor.GetComponent<AudioSource>();
                if (audio != null)
                {
                    int index = UnityEngine.Random.Range(0, EmissionSounds.Length);
                    AudioClip clip = EmissionSounds[index];
                    audio.PlayOneShot(clip, scale);
                }
            }
        }

        private void SpawnMeteors()
        {
            int count = (int)UnityEngine.Random.Range(MeteorsPerSecondRange.Minimum, MeteorsPerSecondRange.Maximum);
            for (int i = 0; i < count; i++)
            {
                StartCoroutine(SpawnMeteor());
            }
        }

        protected override void Update()
        {
 	        base.Update();

            if (Duration > 0.0f && (elapsedSecond += Time.deltaTime) >= 1.0f)
            {
                elapsedSecond = elapsedSecond - 1.0f;
                SpawnMeteors();
            }
        }

        private void PlayCollisionSound(GameObject obj)
        {
            if (ExplosionSounds == null || ExplosionSounds.Length == 0)
            {
                return;
            }

            AudioSource s = obj.GetComponent<AudioSource>();
            if (s == null)
            {
                return;
            }

            int index = UnityEngine.Random.Range(0, ExplosionSounds.Length);
            AudioClip clip = ExplosionSounds[index];
            s.PlayOneShot(clip, obj.transform.localScale.x);
        }

        private IEnumerator CleanupMeteor(float delay, GameObject obj)
        {
            yield return new WaitForSeconds(delay);

            GameObject.Destroy(obj.GetComponent<Collider>());
            GameObject.Destroy(obj.GetComponent<Rigidbody>());
            GameObject.Destroy(obj.GetComponent<TrailRenderer>());
        }

        public void HandleCollision(GameObject obj, Collision col)
        {
            Renderer r = obj.GetComponent<Renderer>();
            if (r == null)
            {
                return;
            }
            else if (CollisionDelegate != null)
            {
                CollisionDelegate(this, obj);
            }

            Vector3 pos, normal;
            if (col.contacts.Length == 0)
            {
                pos = obj.transform.position;
                normal = -pos;
            }
            else
            {
                pos = col.contacts[0].point;
                normal = col.contacts[0].normal;
            }

            MeteorExplosionParticleSystem.transform.position = pos;
            MeteorExplosionParticleSystem.transform.rotation = Quaternion.LookRotation(normal);
            MeteorExplosionParticleSystem.Emit(UnityEngine.Random.Range(10, 20));
            MeteorShrapnelParticleSystem.transform.position = col.contacts[0].point;
            MeteorShrapnelParticleSystem.Emit(UnityEngine.Random.Range(10, 20));

            PlayCollisionSound(obj);

            GameObject.Destroy(r);

            StartCoroutine(CleanupMeteor(0.1f, obj));
            GameObject.Destroy(obj, 4.0f);
        }
    }
}
