<script lang="ts">
	import { fly, fade } from 'svelte/transition';
</script>

<svelte:head>
	<title>About – Miray Diri</title>
</svelte:head>

<!-- ══════════════════════════ NAVBAR ══════════════════════════ -->
<nav class="fixed top-0 left-0 right-0 z-[60] flex items-center justify-between px-5 py-3 md:px-8 nav-bar">
	<a href="/portfolio" aria-label="Home" class="flex shrink-0 items-center">
		<img src="/favicon.png" alt="Logo" class="h-8 w-8 rounded-md object-contain" />
	</a>
	<div class="flex items-center gap-1">
		<a href="/portfolio#gallery" class="nav-link rounded-md px-4 py-1.5 text-xs font-medium uppercase tracking-widest transition-colors">
			Works
		</a>
		<a href="/about" class="nav-link nav-link--active rounded-md px-4 py-1.5 text-xs font-medium uppercase tracking-widest transition-colors">
			About
		</a>
	</div>
</nav>

<!-- ══════════════════════════ ABOUT CONTENT ══════════════════════════ -->
<main
	class="bg-[#080808] px-6 md:px-12"
	style="padding-top: 7rem; padding-bottom: 6rem;"
	in:fly={{ y: 30, duration: 500 }}
>
	<div class="mx-auto max-w-2xl">

		<!-- ── Let me introduce myself ── -->
		<section style="margin-bottom: 1rem;">
			<h1 class="text-3xl font-bold leading-tight tracking-tight text-white md:text-4xl lg:text-5xl">
				Let me introduce myself
			</h1>
			<div style="margin-top: 3rem; display: flex; flex-direction: column; gap: 1.25rem;">
				<p class="text-base leading-relaxed text-white/60 md:text-lg">
					Heyo, I'm Miray, a 2D animator and character designer based near Cologne, Germany.
				</p>
				<p class="text-base leading-relaxed text-white/60 md:text-lg">
					I graduated with a Bachelor of Arts in Game Design and Interactive Media from Media University Cologne in 2025, with a focus on game design, animation and storytelling. Funny enough, I started animating digitally before I ever really drew digitally, my first canvas was basically just a timeline! I'm glad that I switched to proper software, and yet drew with my finger on the phone (no idea how I did it for so long).
				</p>
			</div>
		</section>

		<hr class="divider" />

		<!-- ── What I Do ── -->
		<section style="margin-bottom: 1rem;">
			<h2 class="text-2xl font-bold leading-tight tracking-tight text-white md:text-3xl">
				What I Do
			</h2>
			<div style="margin-top: 3rem; display: flex; flex-direction: column; gap: 1.25rem;">
				<p class="text-base leading-relaxed text-white/60 md:text-lg">
					I bring characters to life... whether that's a steampunk warrior mid-attack, a dragon soaring through a sunset, or a tiny creature just trying to be the hero for once. Frame by frame, I put a lot of love (and a lot of hours) into making movement feel alive and expressive. Someone to color hundreds of pages or handle the programming would be greatly appreciated, just saying.
				</p>
				<p class="text-base leading-relaxed text-white/60 md:text-lg">
					My toolkit includes Procreate, Adobe After Effects, Premiere Pro, Photoshop, and Unreal Engine – though honestly, Procreate and I are basically inseparable at this point.
				</p>
			</div>
		</section>

		<hr class="divider" />

		<!-- ── A Bit More About Me ── -->
		<section style="margin-bottom: 1rem;">
			<h2 class="text-2xl font-bold leading-tight tracking-tight text-white md:text-3xl">
				A Bit More About Me
			</h2>
			<div style="margin-top: 3rem; display: flex; flex-direction: column; gap: 1.25rem;">
				<p class="text-base leading-relaxed text-white/60 md:text-lg">
					I speak German, English, and Turkish, which comes in handy more often than you'd think. When I'm not animating, I'm probably deep in a creative rabbit hole, watching way too many animated films "for research purposes," or losing track of time in a blocky video game.
				</p>
				<p class="text-base leading-relaxed text-white/60 md:text-lg">
					I'm endlessly fascinated by creature design, fantasy worlds, and the kind of storytelling that doesn't need a single word to make you feel something.
				</p>
			</div>
		</section>

		<hr class="divider" />

		<!-- ── Let's Work Together ── -->
		<section style="margin-bottom: 1rem;">
			<h2 class="text-2xl font-bold leading-tight tracking-tight text-white md:text-3xl">
				Let's Work Together
			</h2>
			<div style="margin-top: 3rem; display: flex; flex-direction: column; gap: 1.25rem;">
				<p class="text-base leading-relaxed text-white/60 md:text-lg">
					Whether you're looking for a collaborator on a passion project, need animation work, or just want to talk about dragons, feel free to reach out!!
				</p>
				<div class="flex flex-col gap-5 pt-2">
					<a
						href="mailto:miray@cleli.de"
						class="group flex items-center gap-3 text-white/50 transition-colors hover:text-white"
					>
						<span class="text-xl">✉️</span>
						<span class="text-base tracking-wide underline-offset-4 group-hover:underline">miray@cleli.de</span>
					</a>
					<a
						href="https://www.cleli.de"
						target="_blank"
						rel="noopener noreferrer"
						class="group flex items-center gap-3 text-white/50 transition-colors hover:text-white"
					>
						<span class="text-xl">🌐</span>
						<span class="text-base tracking-wide underline-offset-4 group-hover:underline">www.cleli.de</span>
					</a>
				</div>
			</div>
		</section>

	</div>
</main>

<!-- ══════════════════════════ FOOTER ══════════════════════════ -->
<footer class="bg-[#080808] border-t border-white/10 py-8 px-6">
	<div class="mx-auto max-w-2xl flex flex-col items-center gap-3 md:flex-row md:justify-between">
		<span class="text-xs text-white/30 tracking-wide">© 2026 Miray Diri</span>
		<div class="flex flex-col items-center gap-1 md:flex-row md:gap-6">
			<a
				href="mailto:miray@cleli.de"
				class="text-xs text-white/30 tracking-wide transition-colors hover:text-white/70"
			>
				miray@cleli.de
			</a>
			<a
				href="https://www.cleli.de"
				target="_blank"
				rel="noopener noreferrer"
				class="text-xs text-white/30 tracking-wide transition-colors hover:text-white/70"
			>
				www.cleli.de
			</a>
		</div>
	</div>
</footer>

<style>
	.nav-bar {
		background: transparent;
	}

	.nav-link {
		color: rgba(255, 255, 255, 0.65);
	}
	.nav-link:hover {
		color: rgba(255, 255, 255, 1);
	}
	.nav-link--active {
		color: rgba(255, 255, 255, 0.9);
	}

	.divider {
		border: none;
		border-top: 1px solid rgba(255, 255, 255, 0.35);
		margin-top: 0rem;
		margin-bottom: 2.5rem;
	}
</style>
