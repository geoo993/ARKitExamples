Pyro Particles, created by Jeff Johnson
http://www.digitalruby.com/unity-plugins/

Pyro Particles is a set of 10 spell / fire effects for your game. I've put a lot of work into this asset, and I hope that you enjoy it. If you have any questions or feedback, please don't hesitate to email me at jjxtra@gmail.com.

*****************
*** IMPORTANT ***
*****************

Make sure you have a layer created named 'FireLayer' (without quotes)

*****************
*****************
*****************

Pyro Particles comes with 10 effects as prefabs:
- Fire bolt
	This small projectile moves in a straight line until it hits something or expires, causing a small explosion
- Fire ball
	This large projectile moves in a straight line until it hits something or expires, causing a large explosion
- Meteor swarm
	Spawns lots of meteors that fall from the sky causing explosions and carnage to the impact area
- Flamethrower
	Shoots a realistic flamethrower effect from a source position
- Flame strike
	Creates a cloud of flame that shoots fire straight down (or at any angle if you rotate the prefab)
- Wall of fire
	Creates a line of fire that lasts until stopped
- Small fires
	Creates small fires that last until stopped
- Camp fire
	A small, simple yet cozy camp fire
- Ring of fire
	Similar to wall of fire, except it's a circle
- Explosion
	A bright and loud explosion that pushes away objects with explosive force, useful for all manner of situations

Prefab layout:
Each prefab has it's individual components (particle systems, lights, colliders, etc.) as child objects. If you need to customize these prefabs, you can drag them into your scene, break the prefab connection, rename the parent object, make your changes, and then save back as a new prefab.

Code:
Pyro Particles uses FireBaseScript.cs as the base class for all effects. This script handles things such as stopping and starting effects, creating an initial explosion and starting and stopping particle systems.
FireConstantBaseScript is a sub-class that handles effects such as wall of fire that last until stopped. This class fades the looping audio in and out when the effect is started and stopped.
FireLightScript.cs is a simple script that fades in/out any point light for the effects, and optionally allows for random movement.
FireProjectileScript.cs works with effects such as fire bolt and fireball and forwards on collision events.
FireCollisionForwardScript.cs allows forwarding collision events to a common collision handler.
SingleLineAttribute.cs allows rendering range of ints and range of floats classes on one line.
MeteorSwarmScript.cs is the crown jewel of Pyro Particles and controls the meteor swarm effect.
DemoScript.cs is a great reference on how to get started using the prefabs in your game.

I've tried to make sure the code is documented with comments or tooltip attributes, but if anything is unclear, please send me an email at jjxtra@gmail.com.

Thank you for purchasing Pyro Particles, I hope this makes your game even better!

- Jeff

Credits:
Some audio files used with permission from http://www.freesfx.co.uk/