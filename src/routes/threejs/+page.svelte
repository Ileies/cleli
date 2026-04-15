<script lang="ts">
	import { onMount } from 'svelte';
	import * as THREE from 'three';
	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

	let canvasElement: HTMLCanvasElement;
	let theme = $state('light');
	let isAnimating = $state(true);
	let particleCount = $state(1000);
	let rotationSpeed = $state(0.5);
	let showWireframe = $state(false);
	let geometryType = $state<'sphere' | 'torus' | 'cube' | 'dodecahedron'>('sphere');
	let colorScheme = $state<'rainbow' | 'blue' | 'red' | 'purple'>('rainbow');
	let showTips = $state(true);

	// Three.js variables
	let scene: THREE.Scene;
	let camera: THREE.PerspectiveCamera;
	let renderer: THREE.WebGLRenderer;
	let mainMesh: THREE.Mesh;
	let particleSystem: THREE.Points;
	let starFieldGroup: THREE.Group | undefined;
	let warpLines: THREE.LineSegments | undefined;
	let starDirs: Float32Array;
	let starRadii: Float32Array;
	let animationFrameId: number;
	let controls: OrbitControls | undefined;
	let zapActive = false;
	let zapStartTime = 0;
	const ZAP_MS = 2800;
	let savedCamPos = new THREE.Vector3();
	let savedTarget = new THREE.Vector3();
	let zapSavedFov = 75;
	let hyperspaceBoost = 1;

	function onKeyDown(e: KeyboardEvent) {
		const t = e.target as HTMLElement | null;
		if (t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.tagName === 'SELECT')) return;
		if (e.key === 'z' || e.key === 'Z') {
			e.preventDefault();
			triggerZap();
		}
	}

	function triggerZap() {
		if (!camera || !controls || zapActive) return;
		zapActive = true;
		zapStartTime = performance.now();
		savedCamPos.copy(camera.position);
		savedTarget.copy(controls.target);
		zapSavedFov = camera.fov;
		controls.enabled = false;
	}

	function updateWarpStreakGeometry(w: number, time: number) {
		if (!warpLines || !starDirs || !starRadii) return;
		const geom = warpLines.geometry;
		const pos = geom.attributes.position.array as Float32Array;
		const streak = Math.pow(Math.max(0, w), 1.12) * 0.96;
		const flicker = 0.38 + 0.62 * (0.5 + 0.5 * Math.sin(time * 37.1));
		const spread = 0.08 * streak;
		const n = Math.min(particleCount, starRadii.length);
		for (let i = 0; i < n; i++) {
			const i3 = i * 3;
			const r = starRadii[i];
			const dx = starDirs[i3];
			const dy = starDirs[i3 + 1];
			const dz = starDirs[i3 + 2];
			const rOut = r * (1 + spread);
			const rIn = Math.max(0.12, r * (1 - streak * 0.93));
			const seg = i * 6;
			pos[seg] = dx * rOut;
			pos[seg + 1] = dy * rOut;
			pos[seg + 2] = dz * rOut;
			pos[seg + 3] = dx * rIn;
			pos[seg + 4] = dy * rIn;
			pos[seg + 5] = dz * rIn;
		}
		geom.attributes.position.needsUpdate = true;
		const mat = warpLines.material as THREE.LineBasicMaterial;
		mat.opacity = Math.min(0.98, 0.28 + 0.7 * flicker * (0.4 + 0.6 * w));
	}

	function easeInOutCubic(t: number): number {
		return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
	}

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
				window.addEventListener('keydown', onKeyDown);
				startAnimation();
			} else {
				console.error('❌ Canvas element not found!');
			}
		}, 100);

		// Cleanup
		return () => {
			console.log('🧹 Cleaning up Three.js...');
			window.removeEventListener('keydown', onKeyDown);
			window.removeEventListener('resize', handleResize);
			if (controls) {
				controls.dispose();
				controls = undefined;
			}
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
			if (warpLines) {
				warpLines.geometry.dispose();
				if (Array.isArray(warpLines.material)) {
					warpLines.material.forEach(m => m.dispose());
				} else {
					warpLines.material.dispose();
				}
			}
			scene.fog = null;
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

		controls = new OrbitControls(camera, canvasElement);
		controls.enableDamping = true;
		controls.dampingFactor = 0.06;
		controls.minDistance = 2;
		controls.maxDistance = 40;
		controls.enablePan = true;
		controls.target.set(0, 0, 0);

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

		starFieldGroup = new THREE.Group();
		scene.add(starFieldGroup);

		// Create main geometry
		createGeometry();

		// Create particles + warp lines (Hyperraum)
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
		if (!starFieldGroup) return;

		if (particleSystem) {
			starFieldGroup.remove(particleSystem);
			particleSystem.geometry.dispose();
			if (Array.isArray(particleSystem.material)) {
				particleSystem.material.forEach(m => m.dispose());
			} else {
				particleSystem.material.dispose();
			}
		}
		if (warpLines) {
			starFieldGroup.remove(warpLines);
			warpLines.geometry.dispose();
			if (Array.isArray(warpLines.material)) {
				warpLines.material.forEach(m => m.dispose());
			} else {
				warpLines.material.dispose();
			}
			warpLines = undefined;
		}

		starDirs = new Float32Array(particleCount * 3);
		starRadii = new Float32Array(particleCount);

		const geometry = new THREE.BufferGeometry();
		const positions = new Float32Array(particleCount * 3);
		const colors = new Float32Array(particleCount * 3);
		const linePos = new Float32Array(particleCount * 6);
		const lineColors = new Float32Array(particleCount * 6);

		for (let i = 0; i < particleCount; i++) {
			const i3 = i * 3;
			const radius = 8 + Math.random() * 10;
			const theta = Math.random() * Math.PI * 2;
			const phi = Math.acos(Math.random() * 2 - 1);
			const dx = Math.sin(phi) * Math.cos(theta);
			const dy = Math.sin(phi) * Math.sin(theta);
			const dz = Math.cos(phi);

			starDirs[i3] = dx;
			starDirs[i3 + 1] = dy;
			starDirs[i3 + 2] = dz;
			starRadii[i] = radius;

			positions[i3] = dx * radius;
			positions[i3 + 1] = dy * radius;
			positions[i3 + 2] = dz * radius;

			colors[i3] = Math.random();
			colors[i3 + 1] = Math.random();
			colors[i3 + 2] = Math.random();

			const seg = i * 6;
			linePos[seg] = positions[i3];
			linePos[seg + 1] = positions[i3 + 1];
			linePos[seg + 2] = positions[i3 + 2];
			linePos[seg + 3] = dx * radius * 0.985;
			linePos[seg + 4] = dy * radius * 0.985;
			linePos[seg + 5] = dz * radius * 0.985;
			lineColors[seg] = colors[i3];
			lineColors[seg + 1] = colors[i3 + 1];
			lineColors[seg + 2] = colors[i3 + 2];
			lineColors[seg + 3] = colors[i3];
			lineColors[seg + 4] = colors[i3 + 1];
			lineColors[seg + 5] = colors[i3 + 2];
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
		starFieldGroup.add(particleSystem);

		const lineGeom = new THREE.BufferGeometry();
		lineGeom.setAttribute('position', new THREE.BufferAttribute(linePos, 3));
		lineGeom.setAttribute('color', new THREE.BufferAttribute(lineColors, 3));
		const lineMat = new THREE.LineBasicMaterial({
			vertexColors: true,
			transparent: true,
			opacity: 0.85,
			blending: THREE.AdditiveBlending,
			depthWrite: false
		});
		warpLines = new THREE.LineSegments(lineGeom, lineMat);
		warpLines.visible = false;
		starFieldGroup.add(warpLines);

		console.log('✅ Particles + warp streaks created:', particleCount);
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

		// ZAP / Hyperraum: Kamera zurück, Zentrum „zoomt raus“, Sterne → radiale Linien, Flackern
		if (zapActive && controls) {
			const elapsed = performance.now() - zapStartTime;
			const u = Math.min(1, elapsed / ZAP_MS);
			if (u >= 1) {
				zapActive = false;
				hyperspaceBoost = 1;
				camera.position.copy(savedCamPos);
				camera.fov = zapSavedFov;
				camera.updateProjectionMatrix();
				controls.target.copy(savedTarget);
				controls.enabled = true;
				if (scene.background instanceof THREE.Color) {
					(scene.background as THREE.Color).setHex(0x0f0f23);
				}
				scene.fog = null;
				if (particleSystem) particleSystem.visible = true;
				if (warpLines) warpLines.visible = false;
				controls.update();
			} else {
				const w = Math.sin(Math.PI * u);
				const wEase = easeInOutCubic(w);
				hyperspaceBoost = 1 + 4.5 * w;

				if (particleSystem) particleSystem.visible = false;
				if (warpLines) {
					warpLines.visible = true;
					updateWarpStreakGeometry(w, time);
				}

				// Kamera von der Mitte wegziehen = Objekt wirkt kleiner
				camera.position.copy(savedCamPos).multiplyScalar(1.0 + 0.95 * wEase);
				camera.lookAt(controls.target);
				camera.fov = THREE.MathUtils.lerp(zapSavedFov, Math.min(zapSavedFov + 34, 115), wEase);
				camera.updateProjectionMatrix();

				if (scene.background instanceof THREE.Color) {
					const base = new THREE.Color(0x0f0f23);
					const deep = new THREE.Color(0x030208);
					const violet = new THREE.Color(0x180038);
					const bg = scene.background as THREE.Color;
					bg.copy(base).lerp(deep, w * 0.85).lerp(violet, w * 0.45);
				}

				if (!scene.fog) {
					scene.fog = new THREE.FogExp2(0x0c0020, 0.014);
				}
				if (scene.fog instanceof THREE.FogExp2) {
					scene.fog.color.setHex(0x0a0018);
					scene.fog.density = 0.01 + 0.028 * w;
				}
			}
		} else if (controls) {
			controls.update();
		}

		// Animate main mesh
		if (mainMesh && isAnimating) {
			mainMesh.rotation.x += 0.01 * rotationSpeed * hyperspaceBoost;
			mainMesh.rotation.y += 0.02 * rotationSpeed * hyperspaceBoost;

			const pulse = 1 + Math.sin(time * 2) * 0.1;
			const zapU = zapActive
				? Math.sin(Math.PI * Math.min(1, (performance.now() - zapStartTime) / ZAP_MS))
				: 0;
			const zapScale = THREE.MathUtils.lerp(1, 0.18, zapU);
			const s = pulse * zapScale;
			mainMesh.scale.set(s, s, s);

			if (colorScheme === 'rainbow') {
				const hue = (time * 0.1) % 1;
				(mainMesh.material as THREE.MeshPhongMaterial).color.setHSL(hue, 1, 0.5);
			}
		}

		if (starFieldGroup && isAnimating) {
			const ps = hyperspaceBoost;
			starFieldGroup.rotation.y = time * 0.05 * ps;
			starFieldGroup.rotation.x = Math.sin(time * 0.1) * 0.3 * ps;
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
		if (camera && controls) {
			camera.position.set(0, 0, 5);
			camera.fov = 75;
			camera.updateProjectionMatrix();
			controls.target.set(0, 0, 0);
			controls.update();
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
		if (scene && starFieldGroup) {
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

		<!-- Controls: volle Höhe, scrollbar rechts (breiter Griff) -->
		<div
			class="fixed inset-y-0 right-0 z-10 flex w-[min(22rem,calc(100vw-0.25rem))] pointer-events-none sm:w-[min(22rem,calc(100vw-0.5rem))]"
			aria-label="Einstellungen"
		>
			<div
				class="pointer-events-auto flex h-full min-h-0 w-full flex-col border-l border-base-300/50 bg-base-200/40 shadow-lg backdrop-blur-md"
			>
				<div
					class="controls-scroll-rail flex-1 min-h-0 overflow-y-auto overscroll-y-contain px-4 pb-8 pt-24 space-y-4"
				>
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
			</div>
		</div>

		<!-- Info Panel (schließbar) -->
		{#if showTips}
			<div class="fixed left-6 bottom-6 z-10 max-w-md pointer-events-auto">
				<div class="card relative bg-base-200/90 shadow-xl backdrop-blur-sm">
					<button
						type="button"
						class="btn btn-ghost btn-sm btn-circle absolute right-2 top-2 z-[1] min-h-8 min-w-8"
						aria-label="Tips schließen"
						onclick={() => (showTips = false)}
					>
						<span class="text-lg leading-none" aria-hidden="true">×</span>
					</button>
					<div class="card-body py-4 pl-5 pr-12">
						<h3 class="card-title text-lg pr-2">💡 Tips</h3>
						<ul class="text-sm space-y-1 list-disc list-inside text-base-content/80">
							<li>Maus: drehen · Rad: zoomen · Rechtsklick: schwenken</li>
							<li>
								<kbd class="kbd kbd-sm">Z</kbd> Hyperraum: Sterne werden zu Linien zur Mitte, Zentrum „fällt
								zurück“
							</li>
							<li>Geometrie, Farben und Partikel wie gewohnt testen</li>
							<li>Rechte Leiste: nach unten scrollen, um alle Karten zu erreichen</li>
						</ul>
						<div class="mt-4">
							<a href="/tests" class="btn btn-primary btn-sm w-full">
								← Back to Tests
							</a>
						</div>
					</div>
				</div>
			</div>
		{:else}
			<div class="fixed bottom-6 left-6 z-10 pointer-events-auto">
				<button
					type="button"
					class="btn btn-sm btn-primary shadow-lg"
					aria-label="Tips anzeigen"
					onclick={() => (showTips = true)}
				>
					💡 Tips
				</button>
			</div>
		{/if}
	</div>
</div>

<style>
	canvas {
		display: block;
	}

	.controls-scroll-rail {
		scrollbar-gutter: stable;
		scrollbar-width: auto;
		scrollbar-color: rgba(120, 120, 160, 0.75) rgba(0, 0, 0, 0.15);
	}

	.controls-scroll-rail::-webkit-scrollbar {
		width: 14px;
	}

	.controls-scroll-rail::-webkit-scrollbar-track {
		margin: 0.5rem 0;
		border-radius: 9999px;
		background: rgba(0, 0, 0, 0.12);
	}

	.controls-scroll-rail::-webkit-scrollbar-thumb {
		border-radius: 9999px;
		border: 3px solid transparent;
		background-clip: content-box;
		background-color: rgba(100, 120, 200, 0.65);
	}

	.controls-scroll-rail::-webkit-scrollbar-thumb:hover {
		background-color: rgba(120, 140, 220, 0.85);
	}
</style>