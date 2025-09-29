<script lang="ts">
	import { onMount } from 'svelte';
	import * as THREE from 'three';

	let canvasElement: HTMLCanvasElement;
	let theme = $state('light');
	let isAnimating = $state(true);
	let particleCount = $state(1000);
	let rotationSpeed = $state(0.5);
	let showWireframe = $state(false);
	let geometryType = $state<'sphere' | 'torus' | 'cube' | 'dodecahedron'>('sphere');
	let colorScheme = $state<'rainbow' | 'blue' | 'red' | 'purple'>('rainbow');

	// Three.js variables
	let scene: THREE.Scene;
	let camera: THREE.PerspectiveCamera;
	let renderer: THREE.WebGLRenderer;
	let mainMesh: THREE.Mesh;
	let particleSystem: THREE.Points;
	let animationFrameId: number;

	onMount(() => {
		console.log('🚀 Component mounted, initializing Three.js...');
		
		// Get saved theme
		const savedTheme = localStorage.getItem('theme') || 'light';
		theme = savedTheme;
		document.documentElement.setAttribute('data-theme', theme);

		// Wait a tick to ensure canvas is in DOM
		setTimeout(() => {
			if (canvasElement) {
				console.log('Canvas element found:', canvasElement);
				console.log('Canvas dimensions:', canvasElement.clientWidth, 'x', canvasElement.clientHeight);
				setupThreeJS();
				startAnimation();
			} else {
				console.error('❌ Canvas element not found!');
			}
		}, 100);

		// Cleanup
		return () => {
			console.log('🧹 Cleaning up Three.js...');
			if (animationFrameId) {
				cancelAnimationFrame(animationFrameId);
			}
			if (renderer) {
				renderer.dispose();
			}
			if (mainMesh) {
				mainMesh.geometry.dispose();
				if (Array.isArray(mainMesh.material)) {
					mainMesh.material.forEach(m => m.dispose());
				} else {
					mainMesh.material.dispose();
				}
			}
			if (particleSystem) {
				particleSystem.geometry.dispose();
				if (Array.isArray(particleSystem.material)) {
					particleSystem.material.forEach(m => m.dispose());
				} else {
					particleSystem.material.dispose();
				}
			}
		};
	});

	function setupThreeJS() {
		console.log('🎬 Setting up Three.js scene...');

		// Create scene
		scene = new THREE.Scene();
		scene.background = new THREE.Color(0x0f0f23);
		console.log('✅ Scene created');

		// Create camera
		const width = canvasElement.clientWidth;
		const height = canvasElement.clientHeight;
		camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000);
		camera.position.z = 5;
		console.log('✅ Camera created at position:', camera.position);

		// Create renderer
		renderer = new THREE.WebGLRenderer({ 
			canvas: canvasElement,
			antialias: true
		});
		renderer.setSize(width, height);
		renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
		console.log('✅ Renderer created with size:', width, 'x', height);

		// Add lights
		const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
		scene.add(ambientLight);

		const pointLight1 = new THREE.PointLight(0xff0040, 2, 100);
		pointLight1.position.set(5, 5, 5);
		scene.add(pointLight1);

		const pointLight2 = new THREE.PointLight(0x0040ff, 2, 100);
		pointLight2.position.set(-5, -5, 5);
		scene.add(pointLight2);

		const pointLight3 = new THREE.PointLight(0x40ff00, 2, 100);
		pointLight3.position.set(0, 5, -5);
		scene.add(pointLight3);
		console.log('✅ Lights added');

		// Create main geometry
		createGeometry();

		// Create particles
		createParticles();

		// Handle resize
		window.addEventListener('resize', handleResize);

		console.log('✅ Three.js setup complete!');
		console.log('Scene children count:', scene.children.length);
	}

	function createGeometry() {
		// Remove old geometry if exists
		if (mainMesh) {
			scene.remove(mainMesh);
			mainMesh.geometry.dispose();
			if (Array.isArray(mainMesh.material)) {
				mainMesh.material.forEach(m => m.dispose());
			} else {
				mainMesh.material.dispose();
			}
		}

		let geometry: THREE.BufferGeometry;

		switch (geometryType) {
			case 'sphere':
				geometry = new THREE.SphereGeometry(1.5, 32, 32);
				break;
			case 'torus':
				geometry = new THREE.TorusGeometry(1.2, 0.5, 16, 100);
				break;
			case 'cube':
				geometry = new THREE.BoxGeometry(2, 2, 2);
				break;
			case 'dodecahedron':
				geometry = new THREE.DodecahedronGeometry(1.5);
				break;
		}

		const material = new THREE.MeshPhongMaterial({
			color: getColor(),
			wireframe: showWireframe,
			shininess: 100,
			specular: 0xffffff
		});

		mainMesh = new THREE.Mesh(geometry, material);
		scene.add(mainMesh);
		console.log('✅ Geometry created and added to scene:', geometryType);
	}

	function createParticles() {
		// Remove old particles if exists
		if (particleSystem) {
			scene.remove(particleSystem);
			particleSystem.geometry.dispose();
			if (Array.isArray(particleSystem.material)) {
				particleSystem.material.forEach(m => m.dispose());
			} else {
				particleSystem.material.dispose();
			}
		}

		const geometry = new THREE.BufferGeometry();
		const positions = new Float32Array(particleCount * 3);
		const colors = new Float32Array(particleCount * 3);

		for (let i = 0; i < particleCount; i++) {
			const i3 = i * 3;
			
			// Random spherical distribution
			const radius = 8 + Math.random() * 10;
			const theta = Math.random() * Math.PI * 2;
			const phi = Math.acos(Math.random() * 2 - 1);

			positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
			positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
			positions[i3 + 2] = radius * Math.cos(phi);

			// Random colors
			colors[i3] = Math.random();
			colors[i3 + 1] = Math.random();
			colors[i3 + 2] = Math.random();
		}

		geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
		geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));

		const material = new THREE.PointsMaterial({
			size: 0.1,
			vertexColors: true,
			transparent: true,
			opacity: 0.8,
			blending: THREE.AdditiveBlending
		});

		particleSystem = new THREE.Points(geometry, material);
		scene.add(particleSystem);
		console.log('✅ Particles created:', particleCount);
	}

	function getColor(): number {
		switch (colorScheme) {
			case 'blue': return 0x3b82f6;
			case 'red': return 0xef4444;
			case 'purple': return 0xa855f7;
			case 'rainbow':
			default: return 0x00ff00;
		}
	}

	function startAnimation() {
		console.log('🎥 Starting animation loop...');
		animate();
	}

	function animate() {
		animationFrameId = requestAnimationFrame(animate);

		if (!renderer || !scene || !camera) return;

		const time = Date.now() * 0.001;

		// Animate main mesh
		if (mainMesh && isAnimating) {
			mainMesh.rotation.x += 0.01 * rotationSpeed;
			mainMesh.rotation.y += 0.02 * rotationSpeed;

			// Pulsing effect
			const scale = 1 + Math.sin(time * 2) * 0.1;
			mainMesh.scale.set(scale, scale, scale);

			// Rainbow color
			if (colorScheme === 'rainbow') {
				const hue = (time * 0.1) % 1;
				(mainMesh.material as THREE.MeshPhongMaterial).color.setHSL(hue, 1, 0.5);
			}
		}

		// Animate particles
		if (particleSystem && isAnimating) {
			particleSystem.rotation.y = time * 0.05;
			particleSystem.rotation.x = Math.sin(time * 0.1) * 0.3;
		}

		renderer.render(scene, camera);
	}

	function handleResize() {
		if (!camera || !renderer || !canvasElement) return;
		
		const width = canvasElement.clientWidth;
		const height = canvasElement.clientHeight;
		
		camera.aspect = width / height;
		camera.updateProjectionMatrix();
		renderer.setSize(width, height);
	}

	function toggleTheme() {
		theme = theme === 'light' ? 'dark' : 'light';
		localStorage.setItem('theme', theme);
		document.documentElement.setAttribute('data-theme', theme);
	}

	function toggleAnimation() {
		isAnimating = !isAnimating;
	}

	function resetCamera() {
		if (camera) {
			camera.position.set(0, 0, 5);
			camera.lookAt(0, 0, 0);
		}
	}

	// Watch for changes
	$effect(() => {
		const geo = geometryType;
		if (scene && mainMesh) {
			createGeometry();
		}
	});

	$effect(() => {
		const color = colorScheme;
		if (mainMesh && color !== 'rainbow') {
			(mainMesh.material as THREE.MeshPhongMaterial).color.set(getColor());
		}
	});

	$effect(() => {
		const wire = showWireframe;
		if (mainMesh) {
			(mainMesh.material as THREE.MeshPhongMaterial).wireframe = wire;
		}
	});

	$effect(() => {
		const count = particleCount;
		if (scene && particleSystem) {
			createParticles();
		}
	});
</script>

<svelte:head>
	<title>Three.js Demo - Cleli</title>
	<meta name="description" content="Interactive Three.js 3D graphics demonstration" />
</svelte:head>

<div class="min-h-screen bg-base-100">
	<!-- Canvas -->
	<canvas 
		bind:this={canvasElement}
		class="fixed inset-0 w-full h-full"
	></canvas>

	<!-- Overlay UI -->
	<div class="relative z-10 pointer-events-none">
		<!-- Header -->
		<div class="p-6 pointer-events-auto">
			<div class="flex justify-between items-center mb-4">
				<div class="bg-base-200/90 backdrop-blur-sm px-6 py-3 rounded-lg shadow-lg">
					<h1 class="text-3xl font-bold text-base-content">Three.js Demo</h1>
					<p class="text-base-content/70">Interactive 3D Graphics</p>
				</div>
				<button
					aria-label="Toggle theme"
					class="btn btn-ghost btn-circle bg-base-200/90 backdrop-blur-sm"
					onclick={toggleTheme}
				>
					{#if theme === 'light'}
						<svg class="w-6 h-6 fill-current" viewBox="0 0 24 24">
							<path d="M21.64,13a1,1,0,0,0-1.05-.14,8.05,8.05,0,0,1-3.37.73A8.15,8.15,0,0,1,9.08,5.49a8.59,8.59,0,0,1,.25-2A1,1,0,0,0,8,2.36,10.14,10.14,0,1,0,22,14.05,1,1,0,0,0,21.64,13Zm-9.5,6.69A8.14,8.14,0,0,1,7.08,5.22v.27A10.15,10.15,0,0,0,17.22,15.63a9.79,9.79,0,0,0,2.1-.22A8.11,8.11,0,0,1,12.14,19.73Z" />
						</svg>
					{:else}
						<svg class="w-6 h-6 fill-current" viewBox="0 0 24 24">
							<path d="M5.64,17l-.71.71a1,1,0,0,0,0,1.41,1,1,0,0,0,1.41,0l.71-.71A1,1,0,0,0,5.64,17ZM5,12a1,1,0,0,0-1-1H3a1,1,0,0,0,0,2H4A1,1,0,0,0,5,12Zm7-7a1,1,0,0,0,1-1V3a1,1,0,0,0-2,0V4A1,1,0,0,0,12,5ZM5.64,7.05a1,1,0,0,0,.7.29,1,1,0,0,0,.71-.29,1,1,0,0,0,0-1.41l-.71-.71A1,1,0,0,0,4.93,6.34Zm12,.29a1,1,0,0,0,.7-.29l.71-.71a1,1,0,1,0-1.41-1.41L17,5.64a1,1,0,0,0,0,1.41A1,1,0,0,0,17.66,7.34ZM21,11H20a1,1,0,0,0,0,2h1a1,1,0,0,0,0-2Zm-9,8a1,1,0,0,0-1,1v1a1,1,0,0,0,2,0V20A1,1,0,0,0,12,19ZM18.36,17A1,1,0,0,0,17,18.36l.71.71a1,1,0,0,0,1.41,0,1,1,0,0,0,0-1.41ZM12,6.5A5.5,5.5,0,1,0,17.5,12,5.51,5.51,0,0,0,12,6.5Zm0,9A3.5,3.5,0,1,1,15.5,12,3.5,3.5,0,0,1,12,15.5Z" />
						</svg>
					{/if}
				</button>
			</div>

			<!-- Breadcrumbs -->
			<div class="breadcrumbs text-sm bg-base-200/90 backdrop-blur-sm px-4 py-2 rounded-lg inline-block">
				<ul>
					<li><a href="/" class="link link-primary">Home</a></li>
					<li><a href="/tests" class="link link-primary">Tests</a></li>
					<li>Three.js</li>
				</ul>
			</div>
		</div>

		<!-- Controls Panel -->
		<div class="fixed right-6 top-32 space-y-4 max-w-xs pointer-events-auto">
			<!-- Animation Controls -->
			<div class="card bg-base-200/90 backdrop-blur-sm shadow-xl">
				<div class="card-body py-4 px-5">
					<h3 class="card-title text-lg">Animation</h3>
					<div class="space-y-3">
						<button 
							class="btn btn-sm w-full {isAnimating ? 'btn-error' : 'btn-success'}"
							onclick={toggleAnimation}
						>
							{isAnimating ? '⏸️ Pause' : '▶️ Play'}
						</button>
						<button class="btn btn-sm btn-outline w-full" onclick={resetCamera}>
							🎯 Reset Camera
						</button>
					</div>
				</div>
			</div>

			<!-- Geometry Controls -->
			<div class="card bg-base-200/90 backdrop-blur-sm shadow-xl">
				<div class="card-body py-4 px-5">
					<h3 class="card-title text-lg">Geometry</h3>
					<div class="space-y-2">
						<select 
							class="select select-bordered select-sm w-full"
							bind:value={geometryType}
						>
							<option value="sphere">Sphere</option>
							<option value="torus">Torus</option>
							<option value="cube">Cube</option>
							<option value="dodecahedron">Dodecahedron</option>
						</select>
						<div class="form-control">
							<label class="label cursor-pointer py-1">
								<span class="label-text">Wireframe</span>
								<input 
									type="checkbox" 
									class="toggle toggle-sm toggle-primary"
									bind:checked={showWireframe}
								/>
							</label>
						</div>
					</div>
				</div>
			</div>

			<!-- Color Controls -->
			<div class="card bg-base-200/90 backdrop-blur-sm shadow-xl">
				<div class="card-body py-4 px-5">
					<h3 class="card-title text-lg">Colors</h3>
					<select 
						class="select select-bordered select-sm w-full"
						bind:value={colorScheme}
					>
						<option value="rainbow">🌈 Rainbow</option>
						<option value="blue">🔵 Blue</option>
						<option value="red">🔴 Red</option>
						<option value="purple">🟣 Purple</option>
					</select>
				</div>
			</div>

			<!-- Rotation Speed -->
			<div class="card bg-base-200/90 backdrop-blur-sm shadow-xl">
				<div class="card-body py-4 px-5">
					<h3 class="card-title text-lg">Rotation</h3>
					<div class="space-y-2">
						<input 
							type="range" 
							min="0" 
							max="2" 
							step="0.1"
							class="range range-primary range-sm"
							bind:value={rotationSpeed}
						/>
						<div class="text-center text-sm">{rotationSpeed.toFixed(1)}x</div>
					</div>
				</div>
			</div>

			<!-- Particle Count -->
			<div class="card bg-base-200/90 backdrop-blur-sm shadow-xl">
				<div class="card-body py-4 px-5">
					<h3 class="card-title text-lg">Particles</h3>
					<div class="space-y-2">
						<input 
							type="range" 
							min="100" 
							max="5000" 
							step="100"
							class="range range-secondary range-sm"
							bind:value={particleCount}
						/>
						<div class="text-center text-sm">{particleCount.toLocaleString()}</div>
					</div>
				</div>
			</div>
		</div>

		<!-- Info Panel -->
		<div class="fixed left-6 bottom-6 max-w-md pointer-events-auto">
			<div class="card bg-base-200/90 backdrop-blur-sm shadow-xl">
				<div class="card-body py-4 px-5">
					<h3 class="card-title text-lg">💡 Tips</h3>
					<ul class="text-sm space-y-1 list-disc list-inside text-base-content/80">
						<li>Watch the geometry rotate and pulse</li>
						<li>Try different shapes and colors</li>
						<li>Adjust particle count and rotation speed</li>
						<li>Enable wireframe for a different look</li>
					</ul>
					<div class="mt-4">
						<a href="/tests" class="btn btn-primary btn-sm w-full">
							← Back to Tests
						</a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<style>
	canvas {
		display: block;
	}
</style>