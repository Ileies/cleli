<script lang="ts">
	import { onMount } from 'svelte';
	import { Canvas } from '@threlte/core';
	import { Moon, Sun, Menu, X } from 'lucide-svelte';
	import Scene from './Scene.svelte';

	let theme = $state('light');
	let isAnimating = $state(true);
	let particleCount = $state(1000);
	let rotationSpeed = $state(0.5);
	let showWireframe = $state(false);
	let geometryType = $state<'sphere' | 'torus' | 'cube' | 'dodecahedron'>('sphere');
	let colorScheme = $state<'rainbow' | 'blue' | 'red' | 'purple'>('rainbow');

	// Easteregg variables
	let keySequence = '';
	let isHyperspace = $state(false);
	let hyperspaceStartTime = $state(0);

	// Mobile menu
	let showMobileMenu = $state(false);
	let showTips = $state(true);
	let sceneRef: any;

	onMount(() => {
		console.log('🚀 Component mounted, initializing Threlte...');
		
		// Get saved theme
		const savedTheme = localStorage.getItem('theme') || 'light';
		theme = savedTheme;
		document.documentElement.setAttribute('data-theme', theme);

		// Handle keyboard input for easteregg
		const handleKeyPress = (event: KeyboardEvent) => {
			keySequence += event.key.toLowerCase();
			
			// Keep only last 10 characters
			if (keySequence.length > 10) {
				keySequence = keySequence.slice(-10);
			}
			
			// Check for "zap" sequence
			if (keySequence.includes('zap')) {
				triggerHyperspace();
				keySequence = ''; // Reset sequence
			}
		};
		window.addEventListener('keypress', handleKeyPress);

		// Cleanup
		return () => {
			window.removeEventListener('keypress', handleKeyPress);
		};
	});


	function toggleTheme() {
		theme = theme === 'light' ? 'dark' : 'light';
		localStorage.setItem('theme', theme);
		document.documentElement.setAttribute('data-theme', theme);
	}

	function toggleAnimation() {
		isAnimating = !isAnimating;
	}

	function resetCamera() {
		if (sceneRef && sceneRef.resetCamera) {
			sceneRef.resetCamera();
			console.log('🎯 Camera reset');
		}
	}

	function triggerHyperspace() {
		// Prevent multiple triggers while already in hyperspace
		if (isHyperspace) {
			console.log('⚠️ Hyperspace already active, ignoring trigger');
			return;
		}
		
		console.log('⚡ ZAP! Entering hyperspace...');
		isHyperspace = true;
		hyperspaceStartTime = Date.now();
		
		// Auto-exit hyperspace after 4 seconds (longer for deceleration)
		setTimeout(() => {
			isHyperspace = false;
			console.log('🌟 Exiting hyperspace...');
		}, 4000);
	}

</script>

<svelte:head>
	<title>Three.js Demo - Cleli</title>
	<meta name="description" content="Interactive Three.js 3D graphics demonstration" />
</svelte:head>

<div class="min-h-screen bg-base-100">
	<!-- Threlte Canvas -->
	<div class="fixed inset-0 w-full h-full bg-gray-900">
		<Canvas>
			<Scene
				bind:this={sceneRef}
				{isAnimating}
				{particleCount}
				{rotationSpeed}
				{showWireframe}
				{geometryType}
				{colorScheme}
				{isHyperspace}
				{hyperspaceStartTime}
			/>
		</Canvas>
	</div>

	<!-- Overlay UI -->
	<div class="relative z-10 pointer-events-none">
		<!-- Mobile Header -->
		<div class="p-3 pointer-events-auto md:hidden">
			<div class="flex justify-between items-center">
				<div class="bg-base-200/90 backdrop-blur-sm px-4 py-2 rounded-lg shadow-lg">
					<h1 class="text-lg font-bold text-base-content">Three.js Demo</h1>
				</div>
				<div class="flex gap-2">
					<button
						aria-label="Toggle theme"
						class="btn btn-ghost btn-circle bg-base-200/90 backdrop-blur-sm"
						onclick={toggleTheme}
					>
						{#if theme === 'light'}
							<Moon class="w-5 h-5" />
						{:else}
							<Sun class="w-5 h-5" />
						{/if}
					</button>
					<button
						aria-label="Toggle menu"
						class="btn btn-ghost btn-circle bg-base-200/90 backdrop-blur-sm"
						onclick={() => showMobileMenu = !showMobileMenu}
					>
						{#if showMobileMenu}
							<X class="w-5 h-5" />
						{:else}
							<Menu class="w-5 h-5" />
						{/if}
					</button>
				</div>
			</div>
		</div>

		<!-- Desktop Header -->
		<div class="p-6 pointer-events-auto hidden md:block">
			<div class="flex justify-between items-center gap-4 mb-4">
				<div class="bg-base-200/90 backdrop-blur-sm px-6 py-3 rounded-lg shadow-lg">
					<h1 class="text-3xl font-bold text-base-content">Three.js Demo</h1>
					<p class="text-base text-base-content/70">Interactive 3D Graphics</p>
				</div>
				<button
					aria-label="Toggle theme"
					class="btn btn-ghost btn-circle bg-base-200/90 backdrop-blur-sm"
					onclick={toggleTheme}
				>
					{#if theme === 'light'}
						<Moon class="w-6 h-6" />
					{:else}
						<Sun class="w-6 h-6" />
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

		<!-- Mobile Menu Overlay -->
		{#if showMobileMenu}
			<div 
				class="fixed inset-0 bg-black/50 backdrop-blur-sm z-20 md:hidden pointer-events-auto" 
				role="button"
				tabindex="0"
				onclick={() => showMobileMenu = false}
				onkeydown={(e) => e.key === 'Enter' && (showMobileMenu = false)}
			></div>
			<div class="fixed right-0 top-0 h-full w-80 bg-base-200/95 backdrop-blur-sm shadow-2xl z-30 md:hidden pointer-events-auto transform transition-transform duration-300 overflow-y-auto">
				<div class="p-4 space-y-4">
					<div class="flex justify-between items-center mb-6">
						<h2 class="text-xl font-bold">Controls</h2>
						<button class="btn btn-ghost btn-circle" onclick={() => showMobileMenu = false}>
							<X class="w-5 h-5" />
						</button>
					</div>
					
					<!-- Mobile Controls Content -->
					<div class="space-y-4">
						<!-- Animation Controls -->
						<div class="card bg-base-300/50 shadow-lg">
							<div class="card-body py-3 px-4">
								<h3 class="card-title text-base">Animation</h3>
								<div class="space-y-2">
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
						<div class="card bg-base-300/50 shadow-lg">
							<div class="card-body py-3 px-4">
								<h3 class="card-title text-base">Geometry</h3>
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
											<span class="label-text text-sm">Wireframe</span>
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
						<div class="card bg-base-300/50 shadow-lg">
							<div class="card-body py-3 px-4">
								<h3 class="card-title text-base">Colors</h3>
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
						<div class="card bg-base-300/50 shadow-lg">
							<div class="card-body py-3 px-4">
								<h3 class="card-title text-base">Rotation</h3>
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
						<div class="card bg-base-300/50 shadow-lg">
							<div class="card-body py-3 px-4">
								<h3 class="card-title text-base">Particles</h3>
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

						<!-- Tips -->
						<div class="card bg-base-300/50 shadow-lg">
							<div class="card-body py-3 px-4">
								<h3 class="card-title text-base">💡 Tips</h3>
								<ul class="text-xs space-y-1 list-disc list-inside text-base-content/80">
									<li>Drag to rotate camera</li>
									<li>Pinch to zoom</li>
									<li>Type "zap" for hyperspace! ⚡</li>
								</ul>
							</div>
						</div>

						<!-- Back Button -->
						<div class="pt-4">
							<a href="/tests" class="btn btn-primary btn-sm w-full">
								← Back to Tests
							</a>
						</div>
					</div>
				</div>
			</div>
		{/if}

		<!-- Desktop Controls Panel -->
		<div class="fixed right-6 top-32 space-y-4 max-w-xs pointer-events-auto max-h-[calc(100vh-8rem)] overflow-y-auto hidden md:block">
			<!-- Animation Controls -->
			<div class="card bg-base-200/90 backdrop-blur-sm shadow-xl">
				<div class="card-body py-4 px-5">
					<h3 class="card-title text-lg">Animation</h3>
					<div class="space-y-3">
						<button 
							class="btn btn-sm w-full {isAnimating ? 'btn-error' : 'btn-success'}"
							onclick={() => isAnimating = !isAnimating}
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

		<!-- Desktop Info Panel -->
		{#if showTips}
			<div class="fixed left-6 bottom-6 max-w-md pointer-events-auto hidden md:block">
				<div class="card bg-base-200/90 backdrop-blur-sm shadow-xl">
					<div class="card-body py-4 px-5">
						<div class="flex justify-between items-center mb-2">
							<h3 class="card-title text-lg">💡 Tips</h3>
							<button 
								class="btn btn-ghost btn-xs btn-circle"
								onclick={() => showTips = false}
								aria-label="Close tips"
							>
								<X class="w-4 h-4" />
							</button>
						</div>
						<ul class="text-sm space-y-1 list-disc list-inside text-base-content/80">
							<li>Watch the geometry rotate and pulse</li>
							<li>Try different shapes and colors</li>
							<li>Adjust particle count and rotation speed</li>
							<li>Enable wireframe for a different look</li>
							<li>Use mouse to control camera (drag to rotate)</li>
							<li>Type "zap" for a Star Wars surprise! ⚡</li>
						</ul>
						<div class="mt-4">
							<a href="/tests" class="btn btn-primary btn-sm w-full">
								← Back to Tests
							</a>
						</div>
					</div>
				</div>
			</div>
		{/if}

		<!-- Mobile Bottom Info -->
		{#if showTips}
			<div class="fixed bottom-3 left-3 right-3 pointer-events-auto md:hidden">
				<div class="bg-base-200/90 backdrop-blur-sm rounded-lg shadow-lg px-3 py-2">
					<div class="flex justify-between items-center">
						<p class="text-xs text-base-content/80 flex-1">
							Tap <Menu class="inline w-3 h-3" /> for controls • Type "zap" for hyperspace ⚡
						</p>
						<button 
							class="btn btn-ghost btn-xs ml-2"
							onclick={() => showTips = false}
							aria-label="Close tips"
						>
							<X class="w-3 h-3" />
						</button>
					</div>
				</div>
			</div>
		{/if}
	</div>
</div>
