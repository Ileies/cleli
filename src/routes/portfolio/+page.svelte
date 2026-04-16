<script lang="ts">
	import { onMount } from 'svelte';
	import { fly, fade } from 'svelte/transition';

	// ── Types ──────────────────────────────────────────────────────────────────
	type MediaItem = {
		type: 'image' | 'video';
		src: string;
		thumbnail?: string;
	};

	type Project = {
		id: number;
		title: string;
		projectType: string;
		thumbnail?: string;
		thumbnailVideo?: boolean;
		description: string;
		softwareUsed?: string;
		media: MediaItem[];
	};

	// ── Projects ───────────────────────────────────────────────────────────────
	const projects: Project[] = [
		{
			id: 1,
			title: "Dragon's Library",
			projectType: 'Motion Design',
			thumbnail: '/portfolio/Drachen_Bib_Final Title Sequence by Miray Diri and Kevin Spahman.mp4',
			thumbnailVideo: true,
			description:
				'Motion Design created in cooperation with Kevin Spahmann aka Ryu Fafnir. Our goal was to create an opening trailer for a fake TV series/video game called „Die Drachen Bibliothek". His portfolio: ryufafnir.artstation.com',
			softwareUsed: 'After Effects, Illustrator, DaVinci Resolve, Procreate, Krita',
			media: [
				{ type: 'video', src: '/portfolio/Drachen_Bib_Final Title Sequence by Miray Diri and Kevin Spahman.mp4' },
				{ type: 'video', src: '/portfolio/Drachen_Bib_Animatic_Miray.mp4' },
				{ type: 'image', src: '/portfolio/Drachen_Bib_miray-diri-ryu-fafnir-pic1.jpg' },
				{ type: 'image', src: '/portfolio/Drachen_Bib_Concept by Miray Diri (2).jpg' },
			]
		},
		{
			id: 2,
			title: 'Scarlet',
			projectType: '2D Character Animation',
			thumbnail: '/portfolio/Scarlet_Walkcycle_Backrgound_Miray_Diri.mp4',
			thumbnailVideo: true,
			description:
				'My assignment was to create a steampunk-based character and animate an attack-animation and a walkcycle in 2D. The artworks and the attack-animation was done frame by frame in Procreate, the walkcycle in Adobe After Effects.',
			softwareUsed: 'After Effects, Procreate',
			media: [
				{ type: 'image', src: '/portfolio/Scarlet_Ref.jpg' },
				{ type: 'video', src: '/portfolio/scarlet_animated-birb.mp4' },
				{ type: 'image', src: '/portfolio/Scarlet_framebyframe-diri-miray.gif' },
				{ type: 'video', src: '/portfolio/Scarlet_Stages.mp4' },
				{ type: 'video', src: '/portfolio/Scarlet_Walkcycle_Backrgound_Miray_Diri.mp4' },
				{ type: 'video', src: '/portfolio/Scarlet_Walkcycle_NoBG.mp4' },
			]
		},
		{
			id: 3,
			title: 'Loop',
			projectType: '2D Animation',
			thumbnail: '/portfolio/Loop_Finished.mp4',
			thumbnailVideo: true,
			description:
				"A little loading animation made based on the Dragon's Library project. This animation would have played in an imaginary video game based off the series.",
			softwareUsed: 'Procreate',
			media: [
				{ type: 'video', src: '/portfolio/Loop_Finished.mp4' },
				{ type: 'video', src: '/portfolio/Loop_Ladebalken.mp4' },
				{ type: 'image', src: '/portfolio/hoch_und_runter.gif' },
				{ type: 'image', src: '/portfolio/Loop_Sketch.png' },
				{ type: 'image', src: '/portfolio/Loop_MakingOf.png' },
			]
		},
		{
			id: 4,
			title: 'Böser Drache',
			projectType: 'Short Film',
			thumbnail: '/portfolio/Boeser_Drache_Kurzfilm.MP4',
			thumbnailVideo: true,
			description:
				'Frame by frame animation telling a story about a little dragon who wants to be the hero for once!',
			softwareUsed: 'Procreate, Procreate Dreams',
			media: [
				{ type: 'video', src: '/portfolio/Boeser_Drache_Kurzfilm.MP4' },
			]
		},
		{
			id: 5,
			title: 'The Score',
			projectType: '2D Animation',
			thumbnail: '/portfolio/Phoenix_Loop.mp4',
			thumbnailVideo: true,
			description:
				'A handcrafted frame-by-frame animation created as a fanmade Spotify loop for a song by The Score. Based on an in-depth analysis of their music and visual identity, I developed a full corporate design concept, at the heart of it: a phoenix, rising step by step, frame by frame. This piece showcases the illustration process from first sketch to final loop.',
			softwareUsed: 'Procreate',
			media: [
				{ type: 'video', src: '/portfolio/Phoenix_Loop.mp4' },
				{ type: 'video', src: '/portfolio/Phoenix_fly_test.mp4' },
				{ type: 'video', src: '/portfolio/Phoenix_Loop_Sketch_2.mp4' },
				{ type: 'video', src: '/portfolio/Phoenix_Loop_Sketch.mp4' },
				{ type: 'video', src: '/portfolio/Phoenix_loop_Sketch_3.mp4' },
			]
		},
		{
			id: 6,
			title: 'Dragon Domain',
			projectType: 'Logo Animation',
			thumbnail: '/portfolio/Dragon_Domain_Animated.mp4',
			thumbnailVideo: true,
			description:
				'A frame-by-frame animated logo designed for the Dragon Domain Discord server. Every line drawn by hand, every frame crafted with intention.',
			softwareUsed: 'Procreate',
			media: [
				{ type: 'video', src: '/portfolio/Dragon_Domain_Animated.mp4' },
				{ type: 'image', src: '/portfolio/Dragon_Domain_Logo.png' },
				{ type: 'image', src: '/portfolio/Dragon_Domain_Sketch.png' },
			]
		},
		{
			id: 7,
			title: 'Terratrove Games',
			projectType: '2D Animation',
			thumbnail: '/portfolio/Leaf_Animation.mp4',
			thumbnailVideo: true,
			description:
				'A loading-screen animation created for Terratrove Games.',
			softwareUsed: 'Procreate',
			media: [
				{ type: 'video', src: '/portfolio/Leaf_Animation.mp4' },
			]
		}
	];

	// ── State ──────────────────────────────────────────────────────────────────
	let scrollY = $state(0);
	let windowHeight = $state(0);
	let selectedProject = $state<Project | null>(null);
	let lightboxOpen = $state(false);
	let lightboxIndex = $state(0);

	// ── Derived ────────────────────────────────────────────────────────────────
	// At scrollY = 0 → opacity 1; at scrollY = windowHeight/2 → opacity 0.2
	const titleOpacity = $derived(
		Math.max(0.2, 1 - (scrollY / Math.max(1, windowHeight * 0.5)) * 0.8)
	);

	// ── Helpers ────────────────────────────────────────────────────────────────
	function openProject(p: Project) {
		selectedProject = p;
		document.body.style.overflow = 'hidden';
	}

	function closeProject() {
		selectedProject = null;
		document.body.style.overflow = '';
	}

	function openLightbox(index: number) {
		lightboxIndex = index;
		lightboxOpen = true;
	}

	function navigateLightbox(dir: 1 | -1) {
		if (!selectedProject?.media.length) return;
		const len = selectedProject.media.length;
		lightboxIndex = (lightboxIndex + dir + len) % len;
	}

	// ── Nav helpers ────────────────────────────────────────────────────────────
	function scrollToGallery() {
		const galleryEl = document.getElementById('gallery');
		if (!galleryEl) return;
		const onHeroSection = scrollY < windowHeight;
		galleryEl.scrollIntoView({ behavior: onHeroSection ? 'smooth' : 'auto' });
	}

	// ── Lifecycle ──────────────────────────────────────────────────────────────
	onMount(() => {
		const onKeydown = (e: KeyboardEvent) => {
			if (lightboxOpen) {
				if (e.key === 'ArrowLeft') navigateLightbox(-1);
				if (e.key === 'ArrowRight') navigateLightbox(1);
				if (e.key === 'Escape') lightboxOpen = false;
			} else if (selectedProject && e.key === 'Escape') {
				closeProject();
			}
		};

		windowHeight = window.innerHeight;
		const onScroll = () => { scrollY = window.scrollY; };
		const onResize = () => { windowHeight = window.innerHeight; };
		window.addEventListener('scroll', onScroll, { passive: true });
		window.addEventListener('resize', onResize, { passive: true });
		window.addEventListener('keydown', onKeydown);

		return () => {
			window.removeEventListener('scroll', onScroll);
			window.removeEventListener('resize', onResize);
			window.removeEventListener('keydown', onKeydown);
			document.body.style.overflow = '';
		};
	});
</script>

<svelte:head>
	<title>Portfolio</title>
</svelte:head>

<!-- ══════════════════════════ NAVBAR ══════════════════════════ -->
<nav
	class="nav-bar fixed top-0 left-0 right-0 z-[60] flex items-center justify-between px-5 py-3 md:px-8"
	class:nav-light={scrollY > windowHeight * 1.3}
	class:hidden={selectedProject !== null}
>
	<!-- Favicon / Home link -->
	<a href="/portfolio" aria-label="Home" class="flex shrink-0 items-center">
		<img src="/favicon.png" alt="Logo" class="h-8 w-8 rounded-md object-contain" />
	</a>

	<!-- Nav links -->
	<div class="flex items-center gap-1">
		<button onclick={scrollToGallery} class="nav-link rounded-md px-4 py-1.5 text-xs font-medium uppercase tracking-widest transition-colors">
			Works
		</button>
		<a href="/about" class="nav-link rounded-md px-4 py-1.5 text-xs font-medium uppercase tracking-widest transition-colors">
			About
		</a>
	</div>
</nav>

<!-- ══════════════════════════ MAIN PAGE ══════════════════════════ -->
<div class="relative">
	<!-- ─────────────── LANDING SECTION ─────────────── -->
	<section class="sticky top-0 z-0 flex h-screen items-center justify-center overflow-hidden">

		<!-- Solid black background -->
		<div class="absolute inset-0 z-0 bg-black"></div>

		<!-- Hero text -->
		<div
			class="pointer-events-none relative z-[1] select-none px-6 text-center"
			style="opacity: {titleOpacity}; transition: opacity 0.05s linear;"
		>
			<h1 class="text-5xl font-bold leading-none tracking-tight text-white sm:text-7xl md:text-8xl lg:text-9xl">
				Miray Diri
			</h1>
			<p class="mt-5 text-xs uppercase tracking-[0.35em] text-white/50 sm:text-sm md:text-base">
				2D Animation &amp; Character Design
			</p>
		</div>

		<!-- Scroll indicator -->
		<div class="pointer-events-none absolute bottom-8 left-1/2 z-[1] flex -translate-x-1/2 flex-col items-center gap-2">
			<span class="text-[10px] uppercase tracking-[0.3em] text-white/30">Scroll</span>
			<div class="h-8 w-px bg-gradient-to-b from-white/25 to-transparent"></div>
		</div>
	</section>

	<!-- Extra scroll space — Gallery startet erst nach diesem Puffer -->
	<div class="h-[5vh] md:h-[20vh]"></div>

	<!-- ─────────────── GALLERY SECTION ─────────────── -->
	<section id="gallery" class="relative z-10 min-h-screen bg-white px-1 pb-1 pt-16 md:px-2 md:pt-20">
		<div class="mx-auto max-w-6xl">
			<div class="grid grid-cols-2 gap-0.5 md:grid-cols-3 md:gap-1">
				{#each projects as p (p.id)}
					<div class="flex flex-col">
						<button
							class="group relative aspect-square cursor-pointer overflow-hidden bg-[#e0e0e0] focus:outline-none"
							onclick={() => openProject(p)}
						>
							{#if p.thumbnail && p.thumbnailVideo}
								<video
									src={p.thumbnail}
									class="h-full w-full object-cover transition-transform duration-700 group-hover:scale-110"
									autoplay muted loop playsinline
								><track kind="captions" /></video>
							{:else if p.thumbnail}
								<img
									src={p.thumbnail}
									alt={p.title}
									class="h-full w-full object-cover transition-transform duration-700 group-hover:scale-110"
								/>
							{:else}
								<!-- Placeholder tile — shown until you add a thumbnail -->
								<div class="flex h-full w-full items-center justify-center bg-[#e0e0e0]">
									<svg
										class="h-auto w-14"
										viewBox="0 0 160 90"
										fill="black"
										style="opacity: 0.08"
										xmlns="http://www.w3.org/2000/svg"
									>
										<path d="M40,55 Q75,42 110,50 Q118,52 116,62 Q112,70 95,68 Q60,72 38,64 Q32,60 40,55 Z" />
										<path d="M108,50 Q122,42 132,38 Q140,36 144,42 Q146,48 140,54 Q132,58 122,54 Q114,52 108,52 Z" />
										<path d="M65,52 Q48,28 22,14 Q36,32 60,55 Z" />
										<path d="M85,48 Q95,28 112,16 Q100,32 87,50 Z" />
									</svg>
								</div>
							{/if}

							<!-- Hover overlay — nur auf Desktop sichtbar -->
							<div class="absolute inset-0 bg-white/0 transition-all duration-300 md:group-hover:bg-white/80">
								<div class="absolute inset-0 flex flex-col items-center justify-center px-4 opacity-0 transition-opacity duration-300 md:group-hover:opacity-100">
									<h3 class="text-center text-sm font-semibold leading-tight text-black md:text-lg">
										{p.title}
									</h3>
									<p class="mt-2 text-[10px] uppercase tracking-widest text-black/50 md:text-xs">
										{p.projectType}
									</p>
								</div>
							</div>
						</button>

						<!-- Titel unter der Kachel — nur auf Mobile -->
						<div class="px-1 pb-2 pt-1.5 md:hidden">
							<h3 class="text-xs font-semibold leading-tight text-black">
								{p.title}
							</h3>
							<p class="mt-0.5 text-[9px] uppercase tracking-widest text-black/40">
								{p.projectType}
							</p>
						</div>
					</div>
				{/each}

				<!-- Coming Soon – sichtbar auf Mobile & Desktop -->
				<div class="relative aspect-square overflow-hidden bg-[#ede8e8]">
					<div class="flex h-full w-full flex-col items-center justify-center gap-3">
						<span class="text-[10px] uppercase tracking-[0.3em] text-black/25 md:text-xs">Coming Soon</span>
					</div>
				</div>

				<!-- Coming Soon – nur auf Desktop sichtbar -->
				<div class="relative hidden aspect-square overflow-hidden bg-[#e8eaef] md:block">
					<div class="flex h-full w-full flex-col items-center justify-center gap-3">
						<span class="text-[10px] uppercase tracking-[0.3em] text-black/20 md:text-xs">Coming Soon</span>
					</div>
				</div>
			</div>
		</div>
	</section>

	<!--
		Kreis-Platzhalter mit Parallax — bewegt sich 1.5x schneller als die Gallery.
		Später durch einen Drachen-SVG ersetzen.
		- top: calc(100vh + 200px) → startet 200px hinter der Gallery versteckt
		- transform: translateY mit Faktor -0.5 → extra 50% Geschwindigkeit on top
	-->
	<img
		src="/portfolio/Dragon_Flying.png"
		alt="Dragon Flying"
		class="pointer-events-none absolute z-[5] hidden h-[160px] w-auto md:block md:h-[220px]"
		style="top: calc(100vh - 0px); right: 12%; transform: translateY({-scrollY * 0.7}px)"
	/>
	<img
		src="/portfolio/Dragon_Gliding.png"
		alt="Dragon Gliding"
		class="pointer-events-none absolute z-[5] h-[120px] w-auto md:h-[220px]"
		style="top: calc(100vh - 0px); left: 12%; transform: translateY({-scrollY * 1}px)"
	/>
</div>

<!-- ══════════════════════════ PROJECT DETAIL ══════════════════════════ -->
{#if selectedProject}
	<div
		class="fixed inset-0 z-50 overflow-y-auto bg-[#080808]"
		in:fly={{ y: 50, duration: 400 }}
		out:fade={{ duration: 200 }}
	>
		<!-- Back button (sticky at top) -->
		<div class="sticky top-0 z-10 border-b border-white/5 bg-[#080808]/90 backdrop-blur-sm">
			<button
				class="flex items-center gap-2 px-5 py-4 text-xs uppercase tracking-widest text-white/50 transition-colors hover:text-white"
				onclick={closeProject}
			>
				<svg class="h-4 w-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
				</svg>
				Back to Gallery
			</button>
		</div>

		<!-- Content: media left, info right (on mobile: info first, then media) -->
		<div class="mx-auto flex max-w-7xl flex-col gap-8 p-5 md:flex-row md:gap-14 md:p-12">

			<!-- Left: stacked media (scrollable as you go down) — on mobile shown BELOW info -->
			<div class="order-2 flex w-full flex-col gap-3 md:order-1 md:w-[62%]">
				{#each selectedProject.media as item, i (i)}
					<button
						class="group block w-full cursor-zoom-in overflow-hidden rounded-sm"
						onclick={() => openLightbox(i)}
					>
						{#if item.type === 'video'}
							<video
								src={item.src}
								class="w-full object-cover transition-transform duration-500 group-hover:scale-[1.015]"
								autoplay
								muted
								loop
								playsinline
							>
								<track kind="captions" />
							</video>
						{:else}
							<img
								src={item.src}
								alt=""
								class="w-full object-cover transition-transform duration-500 group-hover:scale-[1.015]"
							/>
						{/if}
					</button>
				{:else}
					<!-- Shown when no media added yet -->
					<div class="flex aspect-video flex-col items-center justify-center gap-4 rounded-sm bg-[#131313]">
						<svg
							class="h-auto w-16"
							viewBox="0 0 160 90"
							fill="white"
							style="opacity: 0.15"
							xmlns="http://www.w3.org/2000/svg"
						>
							<path d="M40,55 Q75,42 110,50 Q118,52 116,62 Q112,70 95,68 Q60,72 38,64 Q32,60 40,55 Z" />
							<path d="M108,50 Q122,42 132,38 Q140,36 144,42 Q146,48 140,54 Q132,58 122,54 Q114,52 108,52 Z" />
							<path d="M65,52 Q48,28 22,14 Q36,32 60,55 Z" />
							<path d="M85,48 Q95,28 112,16 Q100,32 87,50 Z" />
						</svg>
						<p class="text-sm text-white/25">Media coming soon</p>
					</div>
				{/each}
			</div>

			<!-- Right: project info — on mobile shown ABOVE media -->
			<div class="order-1 w-full md:order-2 md:w-[38%]">
				<div class="pt-2 md:sticky md:top-[62px] md:pt-6">
					<p class="mb-3 text-[11px] uppercase tracking-[0.25em] text-white/35">
						{selectedProject.projectType}
					</p>
					<h2 class="mb-6 text-3xl font-bold leading-tight text-white md:text-4xl lg:text-5xl">
						{selectedProject.title}
					</h2>
					<p class="text-sm leading-relaxed text-white/55 md:text-base">
						{selectedProject.description}
					</p>
					{#if selectedProject.softwareUsed}
						<p class="mt-4 text-sm leading-relaxed text-white/55 md:text-base">
							<span class="text-white/35">Software used:</span> {selectedProject.softwareUsed}
						</p>
					{/if}
				</div>
			</div>
		</div>
	</div>
{/if}

<!-- ══════════════════════════ LIGHTBOX ══════════════════════════ -->
{#if lightboxOpen && selectedProject && selectedProject.media.length > 0}
	{@const media = selectedProject.media}
	{@const current = media[lightboxIndex]}
	<div class="fixed inset-0 z-[100] bg-black/96" transition:fade={{ duration: 200 }}>

		<!-- Close button (top right) -->
		<button
			class="absolute right-4 top-4 z-20 p-2 text-white/50 transition-colors hover:text-white"
			onclick={() => (lightboxOpen = false)}
			aria-label="Close"
		>
			<svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
			</svg>
		</button>

		<!-- Image counter -->
		<div class="absolute left-1/2 top-5 z-20 -translate-x-1/2 select-none tabular-nums text-white/30">
			{lightboxIndex + 1} / {media.length}
		</div>

		<!-- Left navigation zone -->
		<button
			class="absolute left-0 top-0 z-10 flex h-full w-1/3 cursor-w-resize items-center justify-start pl-4 text-white/0 transition-colors hover:text-white/40"
			onclick={() => navigateLightbox(-1)}
			aria-label="Previous"
		>
			<svg class="h-7 w-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 19l-7-7 7-7" />
			</svg>
		</button>

		<!-- Right navigation zone -->
		<button
			class="absolute right-0 top-0 z-10 flex h-full w-1/3 cursor-e-resize items-center justify-end pr-4 text-white/0 transition-colors hover:text-white/40"
			onclick={() => navigateLightbox(1)}
			aria-label="Next"
		>
			<svg class="h-7 w-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5l7 7-7 7" />
			</svg>
		</button>

		<!-- Media display -->
		<div class="pointer-events-none absolute inset-0 z-[15] flex items-center justify-center px-16 py-14">
			<div class="pointer-events-auto flex max-h-full max-w-full items-center justify-center">
				{#if current?.type === 'video'}
					<video src={current.src} controls autoplay class="max-h-[80vh] max-w-[80vw] outline-none">
						<track kind="captions" />
					</video>
				{:else if current}
				<img src={current.src} alt="" class="max-h-[80vh] max-w-[80vw] object-contain" />
			{/if}
		</div>
	</div>
	</div>
{/if}

<style>
	.nav-link {
		color: rgba(255, 255, 255, 0.65);
	}
	.nav-link:hover {
		color: rgba(255, 255, 255, 1);
	}
	.nav-light .nav-link {
		color: rgba(0, 0, 0, 0.55);
		background-color: rgba(255, 255, 255, 0.72);
		backdrop-filter: blur(6px);
		-webkit-backdrop-filter: blur(6px);
	}
	.nav-light .nav-link:hover {
		color: rgba(0, 0, 0, 1);
		background-color: rgba(255, 255, 255, 0.9);
	}
</style>
