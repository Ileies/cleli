<script lang="ts">
	import { T } from '@threlte/core';
	import { TrackballControls, interactivity } from '@threlte/extras';
	import { onMount } from 'svelte';
	import * as THREE from 'three';

	// Enable interactivity
	interactivity();

	// Props using $props()
	let {
		isAnimating = true,
		particleCount = 1000,
		rotationSpeed = 0.5,
		showWireframe = false,
		geometryType = 'sphere' as 'sphere' | 'torus' | 'cube' | 'dodecahedron',
		colorScheme = 'rainbow' as 'rainbow' | 'blue' | 'red' | 'purple',
		isHyperspace = false,
		hyperspaceStartTime = 0
	} = $props();
	
	// Local copy of start time to prevent reactive issues
	let localHyperspaceStartTime = $state(0);
	
	// Update local start time when hyperspace begins
	$effect(() => {
		if (isHyperspace && hyperspaceStartTime > 0) {
			localHyperspaceStartTime = hyperspaceStartTime;
			console.log('🚀 Hyperspace started at:', localHyperspaceStartTime);
		} else if (!isHyperspace && localHyperspaceStartTime > 0) {
			// Hyperspace ended - update velocities to current positions to prevent reset
			console.log('🌟 Hyperspace ended - saving final positions');
			if (particleSystemRef) {
				const particles = particleSystemRef;
				const positions = particles.geometry.attributes.position.array as Float32Array;
				const velocities = particles.geometry.attributes.velocity.array as Float32Array;
				
				for (let i = 0; i < positions.length; i += 3) {
					velocities[i] = positions[i];
					velocities[i + 1] = positions[i + 1];
					velocities[i + 2] = positions[i + 2];
				}
				particles.geometry.attributes.velocity.needsUpdate = true;
			}
			localHyperspaceStartTime = 0;
		}
	});

	// Reactive variables
	let mainMeshRef = $state<THREE.Mesh>();
	let particleSystemRef = $state<THREE.Points>();
	let trailSystemRef = $state<THREE.LineSegments>();
	let cameraRef = $state<THREE.PerspectiveCamera>();
	let controlsRef = $state<any>();
	let time = $state(0);
	
	// Store geometries as state to prevent recreation
	let particlesGeometry = $state<THREE.BufferGeometry>();
	let trailGeometry = $state<THREE.BufferGeometry>();
	
	// Force geometry recreation when type changes
	let geometryKey = $derived(geometryType + showWireframe + colorScheme);

	// Export camera reset function
	export function resetCamera() {
		if (cameraRef && controlsRef) {
			cameraRef.position.set(0, 0, 5);
			cameraRef.lookAt(0, 0, 0);
			controlsRef.reset();
		}
	}

	// Animation loop
	let animationFrameId: number;

	function animate() {
		animationFrameId = requestAnimationFrame(animate);
		time = Date.now() * 0.001;
		
		// Update rotation and particles every frame
		updateRotation();
		updateParticles();
	}

	onMount(() => {
		// Create geometries once on mount
		if (!particlesGeometry) {
			particlesGeometry = createParticlesGeometry();
		}
		if (!trailGeometry) {
			trailGeometry = createTrailGeometry();
		}
		
		animate();
		return () => {
			if (animationFrameId) {
				cancelAnimationFrame(animationFrameId);
			}
		};
	});
	
	// Recreate particles geometry when particle count changes (but avoid infinite loop)
	let lastParticleCount = particleCount;
	$effect(() => {
		if (particleCount !== lastParticleCount && particleCount > 0) {
			console.log('🔄 Recreating geometry for new particle count:', particleCount);
			particlesGeometry = createParticlesGeometry();
			trailGeometry = createTrailGeometry();
			lastParticleCount = particleCount;
			
			// Update the existing Points object with new geometry if it exists
			if (particleSystemRef) {
				particleSystemRef.geometry = particlesGeometry;
			}
		}
	});

	// Get color based on scheme - realistic but visible colors
	function getColor(): string {
		switch (colorScheme) {
			case 'blue': return '#5a6b7d'; // Realistic blue-gray
			case 'red': return '#b8653a'; // Realistic terracotta
			case 'purple': return '#7c5cd6'; // Realistic purple
			case 'rainbow':
			default: return '#4a6b2a'; // Realistic forest green
		}
	}

	// Get geometry component based on type
	function getGeometry() {
		switch (geometryType) {
			case 'sphere':
				return { component: 'SphereGeometry', args: [1.5, 32, 32] };
			case 'torus':
				return { component: 'TorusGeometry', args: [1.2, 0.5, 16, 100] };
			case 'cube':
				return { component: 'BoxGeometry', args: [2, 2, 2] };
			case 'dodecahedron':
				return { component: 'DodecahedronGeometry', args: [1.5] };
		}
	}

	// Reactive color for rainbow mode - realistic rainbow
	let rainbowColor = $derived(colorScheme === 'rainbow' ? 
		`hsl(${(time * 36) % 360}, 65%, 45%)` : getColor());

	// Reactive scale for pulsing effect
	let scale = $derived(isAnimating ? 1 + Math.sin(time * 2) * 0.1 : 1);

	// Rotation state
	let currentRotationX = $state(0);
	let currentRotationY = $state(0);
	
	// Update rotation in animation loop
	function updateRotation() {
		if (isAnimating) {
			currentRotationX += 0.01 * rotationSpeed;
			currentRotationY += 0.02 * rotationSpeed;
		}
	}

	// Create a circular star texture
	function createStarTexture() {
		const canvas = document.createElement('canvas');
		canvas.width = 64;
		canvas.height = 64;
		const context = canvas.getContext('2d')!;
		
		// Create radial gradient for star
		const gradient = context.createRadialGradient(32, 32, 0, 32, 32, 32);
		gradient.addColorStop(0, 'rgba(255,255,255,1)');
		gradient.addColorStop(0.2, 'rgba(255,255,255,0.8)');
		gradient.addColorStop(0.5, 'rgba(255,255,255,0.3)');
		gradient.addColorStop(1, 'rgba(255,255,255,0)');
		
		context.fillStyle = gradient;
		context.fillRect(0, 0, 64, 64);
		
		return new THREE.CanvasTexture(canvas);
	}

	// Create particles geometry
	function createParticlesGeometry() {
		const geometry = new THREE.BufferGeometry();
		const positions = new Float32Array(particleCount * 3);
		const colors = new Float32Array(particleCount * 3);
		const velocities = new Float32Array(particleCount * 3);

		for (let i = 0; i < particleCount; i++) {
			const i3 = i * 3;
			
			// Create stars uniformly distributed from near to far
			const radius = 5 + Math.random() * 35; // Uniform distribution 5-40
			const theta = Math.random() * Math.PI * 2;
			const phi = Math.acos(Math.random() * 2 - 1);

			positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
			positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
			positions[i3 + 2] = radius * Math.cos(phi);

			// Store original positions for reset
			velocities[i3] = positions[i3];
			velocities[i3 + 1] = positions[i3 + 1];
			velocities[i3 + 2] = positions[i3 + 2];

			// Ultra bright star colors for maximum contrast in light mode
			const colorType = Math.random();
			if (colorType < 0.3) {
				colors[i3] = 5; colors[i3 + 1] = 5; colors[i3 + 2] = 5; // Ultra bright white
			} else if (colorType < 0.5) {
				colors[i3] = 3; colors[i3 + 1] = 4; colors[i3 + 2] = 6; // Ultra bright blue
			} else if (colorType < 0.7) {
				colors[i3] = 6; colors[i3 + 1] = 5; colors[i3 + 2] = 1; // Ultra bright yellow
			} else if (colorType < 0.85) {
				colors[i3] = 6; colors[i3 + 1] = 2; colors[i3 + 2] = 2; // Ultra bright red
			} else {
				colors[i3] = 4; colors[i3 + 1] = 2; colors[i3 + 2] = 6; // Ultra bright purple
			}
		}

		geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
		geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
		geometry.setAttribute('velocity', new THREE.BufferAttribute(velocities, 3));

		return geometry;
	}

	// Create trail geometry for hyperspace effect
	function createTrailGeometry() {
		const geometry = new THREE.BufferGeometry();
		const positions = new Float32Array(particleCount * 6); // 2 points per trail (start and end)
		const colors = new Float32Array(particleCount * 6); // 2 colors per trail

		// Initialize with empty trails
		for (let i = 0; i < particleCount * 6; i++) {
			positions[i] = 0;
			colors[i] = 1; // White trails
		}

		geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
		geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));

		return geometry;
	}

	// Update particles for hyperspace effect - runs every frame
	function updateParticles() {
		if (!particleSystemRef || !isAnimating || !particleSystemRef.geometry) return;

		const particles = particleSystemRef;
		if (!particles.geometry.attributes || !particles.geometry.attributes.position) return;
		
		const positions = particles.geometry.attributes.position.array as Float32Array;
		const velocities = particles.geometry.attributes.velocity.array as Float32Array;
		
		// Get trail system if available
		const trails = trailSystemRef;
		let trailPositions: Float32Array | null = null;
		let trailColors: Float32Array | null = null;
		
		if (trails && isHyperspace) {
			trailPositions = trails.geometry.attributes.position.array as Float32Array;
			trailColors = trails.geometry.attributes.color.array as Float32Array;
		}

		if (isHyperspace && localHyperspaceStartTime > 0) {
			const elapsed = (Date.now() - localHyperspaceStartTime) / 1000;
			const totalDuration = 4.0; // Total hyperspace duration
			const progress = Math.min(elapsed / totalDuration, 1.0);
			
			
			// Smooth speed curve with proper ending
			let speed;
			if (progress < 0.8) {
				// Most of the time: constant speed
				speed = 1.5;
			} else {
				// Last 20%: slow down smoothly
				const endProgress = (progress - 0.8) / 0.2; // 0 to 1
				speed = 1.5 * (1 - endProgress * endProgress); // Quadratic slowdown
			}
			
			for (let i = 0; i < positions.length; i += 3) {
				// Store previous position for trail
				const prevX = positions[i];
				const prevY = positions[i + 1];
				const prevZ = positions[i + 2];
				
				// Move particles towards camera (0,0,0)
				const x = positions[i];
				const y = positions[i + 1];
				const z = positions[i + 2];
				
				// Calculate distance from center
				const distance = Math.sqrt(x * x + y * y + z * z);
				if (distance === 0) continue;
				
				// Direction vector FROM camera (0,0,0) TO particle (away from center)
				const dirX = x / distance;
				const dirY = y / distance;
				const dirZ = z / distance;

				// Move particles away from camera with speed
				positions[i] += dirX * speed;
				positions[i + 1] += dirY * speed;
				positions[i + 2] += dirZ * speed;

				// Create trail if moving fast enough and trails are available
				if (trailPositions && speed > 0.3) {
					const particleIndex = i / 3;
					const trailIndex = particleIndex * 6; // 2 points per trail, 3 coords each
					
					// Calculate trail length based on speed (longer trails at higher speeds)
					const trailLength = Math.min(speed * 2, 8);
					const trailDirX = dirX * trailLength;
					const trailDirY = dirY * trailLength;
					const trailDirZ = dirZ * trailLength;
					
					// Trail start (behind the particle)
					trailPositions[trailIndex] = positions[i] - trailDirX;
					trailPositions[trailIndex + 1] = positions[i + 1] - trailDirY;
					trailPositions[trailIndex + 2] = positions[i + 2] - trailDirZ;
					
					// Trail end (current position)
					trailPositions[trailIndex + 3] = positions[i];
					trailPositions[trailIndex + 4] = positions[i + 1];
					trailPositions[trailIndex + 5] = positions[i + 2];
					
					// Simplified trail colors
					if (trailColors) {
						const alpha = Math.min(speed / 2.0, 1.0);
						// Start transparent
						trailColors[trailIndex] = alpha * 0.2;
						trailColors[trailIndex + 1] = alpha * 0.2;
						trailColors[trailIndex + 2] = alpha * 0.2;
						// End bright
						trailColors[trailIndex + 3] = alpha;
						trailColors[trailIndex + 4] = alpha;
						trailColors[trailIndex + 5] = alpha;
					}
				}

				// Reset particles that have moved too far away
				const newDistance = Math.sqrt(
					positions[i] * positions[i] + 
					positions[i + 1] * positions[i + 1] + 
					positions[i + 2] * positions[i + 2]
				);

				if (newDistance > 50) {
					// Create new particle with same uniform distribution
					const radius = 5 + Math.random() * 35; // Uniform distribution 5-40
					const theta = Math.random() * Math.PI * 2;
					const phi = Math.acos(Math.random() * 2 - 1);

					positions[i] = radius * Math.sin(phi) * Math.cos(theta);
					positions[i + 1] = radius * Math.sin(phi) * Math.sin(theta);
					positions[i + 2] = radius * Math.cos(phi);
					
					// Update original position too
					velocities[i] = positions[i];
					velocities[i + 1] = positions[i + 1];
					velocities[i + 2] = positions[i + 2];
				}
			}

			// Optimized geometry updates - only update what's necessary
			const positionAttribute = particles.geometry.attributes.position;
			const velocityAttribute = particles.geometry.attributes.velocity;
			
			positionAttribute.needsUpdate = true;
			velocityAttribute.needsUpdate = true;
			
			// Update trails only if they exist and have changed
			if (trails && trailPositions && speed > 0.3) {
				trails.geometry.attributes.position.needsUpdate = true;
				if (trailColors) {
					trails.geometry.attributes.color.needsUpdate = true;
				}
			}
		} else {
			// Normal rotation animation - but preserve post-hyperspace positions
			// Only rotate if we haven't had hyperspace yet, or reset rotation after hyperspace
			if (localHyperspaceStartTime === 0) {
				// Normal rotation only if no hyperspace has happened
				particles.rotation.y = time * 0.05;
				particles.rotation.x = Math.sin(time * 0.1) * 0.3;
				
				// Update velocities to match current positions for future hyperspace
				for (let i = 0; i < positions.length; i += 3) {
					velocities[i] = positions[i];
					velocities[i + 1] = positions[i + 1];
					velocities[i + 2] = positions[i + 2];
				}
				particles.geometry.attributes.velocity.needsUpdate = true;
			} else {
				// After hyperspace: keep particles where they are, no rotation
				// Velocities are already updated when hyperspace ended
			}
		}
	}

</script>

<!-- Camera with OrbitControls -->
<T.PerspectiveCamera
	bind:ref={cameraRef}
	makeDefault
	position={[0, 0, 5]}
	fov={75}
	near={0.1}
	far={1000}
>
	<TrackballControls
		bind:ref={controlsRef}
		enableDamping={true}
		dampingFactor={0.05}
		enableZoom={true}
		enablePan={true}
		enableRotate={true}
		rotateSpeed={3.0}
		zoomSpeed={2.0}
		panSpeed={1.5}
		minDistance={4}
		maxDistance={40}
		enabled={!isHyperspace}
	/>
</T.PerspectiveCamera>

<!-- Lights -->
<T.AmbientLight intensity={0.3} color="#ffffff" />
<T.DirectionalLight 
	position={[10, 10, 5]} 
	intensity={1.5} 
	color="#ffffff"
	castShadow={true}
/>
<T.PointLight position={[3, 3, 3]} intensity={0.8} color="#ffffff" />
<T.PointLight position={[-3, -3, 3]} intensity={0.6} color="#f0f0f0" />

<!-- Main Geometry -->
{#key geometryKey}
	<T.Mesh
		bind:ref={mainMeshRef}
		rotation.x={currentRotationX}
		rotation.y={currentRotationY}
		scale={[scale, scale, scale]}
	>
		{#if geometryType === 'sphere'}
			<T.SphereGeometry args={[1.5, 32, 32]} />
		{:else if geometryType === 'torus'}
			<T.TorusGeometry args={[1.2, 0.5, 16, 100]} />
		{:else if geometryType === 'cube'}
			<T.BoxGeometry args={[2, 2, 2]} />
		{:else if geometryType === 'dodecahedron'}
			<T.DodecahedronGeometry args={[1.5]} />
		{/if}
		
		<T.MeshStandardMaterial
			color={rainbowColor}
			wireframe={showWireframe}
			roughness={0.7}
			metalness={0.2}
			receiveShadow={true}
			castShadow={true}
		/>
	</T.Mesh>
{/key}

<!-- Particle System -->
{#if particlesGeometry}
	<T.Points
		bind:ref={particleSystemRef}
		geometry={particlesGeometry}
	>
	<T.PointsMaterial
		size={0.3}
		vertexColors={true}
		transparent={true}
		opacity={1.0}
		blending={THREE.AdditiveBlending}
		map={createStarTexture()}
		alphaTest={0.001}
		depthWrite={false}
	/>
	</T.Points>
{/if}

<!-- Trail System for Hyperspace -->
{#if isHyperspace && trailGeometry}
	<T.LineSegments
		bind:ref={trailSystemRef}
		geometry={trailGeometry}
	>
		<T.LineBasicMaterial
			vertexColors={true}
			transparent={true}
			blending={THREE.AdditiveBlending}
			depthWrite={false}
		/>
	</T.LineSegments>
{/if}
