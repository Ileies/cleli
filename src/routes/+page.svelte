<script lang="ts">
	import { onMount } from 'svelte';
	import DiscordIcon from '$lib/DiscordIcon.svelte';

	let theme = $state('light');

	onMount(() => {
		// Get saved theme or default to light
		const savedTheme = localStorage.getItem('theme') || 'light';
		theme = savedTheme;
		document.documentElement.setAttribute('data-theme', theme);
	});

	function toggleTheme() {
		theme = theme === 'light' ? 'dark' : 'light';
		localStorage.setItem('theme', theme);
		document.documentElement.setAttribute('data-theme', theme);
	}

	const contactInfo = {
		email: 'hello@cleli.de',
		discord: '@cleli',
		discordServer: 'https://discord.gg/7nZKeT5ZTQ'
	};
</script>

<div class="min-h-screen bg-base-100 flex items-center justify-center p-4">
	<div class="text-center max-w-md mx-auto">
		<!-- Theme Toggle -->
		<div class="absolute top-6 right-6">
			<button
				aria-label="Toggle theme"
				class="btn btn-ghost btn-circle"
				onclick={toggleTheme}
			>
				{#if theme === 'light'}
					<svg class="w-6 h-6 fill-current" viewBox="0 0 24 24">
						<path
							d="M21.64,13a1,1,0,0,0-1.05-.14,8.05,8.05,0,0,1-3.37.73A8.15,8.15,0,0,1,9.08,5.49a8.59,8.59,0,0,1,.25-2A1,1,0,0,0,8,2.36,10.14,10.14,0,1,0,22,14.05,1,1,0,0,0,21.64,13Zm-9.5,6.69A8.14,8.14,0,0,1,7.08,5.22v.27A10.15,10.15,0,0,0,17.22,15.63a9.79,9.79,0,0,0,2.1-.22A8.11,8.11,0,0,1,12.14,19.73Z" />
					</svg>
				{:else}
					<svg class="w-6 h-6 fill-current" viewBox="0 0 24 24">
						<path
							d="M5.64,17l-.71.71a1,1,0,0,0,0,1.41,1,1,0,0,0,1.41,0l.71-.71A1,1,0,0,0,5.64,17ZM5,12a1,1,0,0,0-1-1H3a1,1,0,0,0,0,2H4A1,1,0,0,0,5,12Zm7-7a1,1,0,0,0,1-1V3a1,1,0,0,0-2,0V4A1,1,0,0,0,12,5ZM5.64,7.05a1,1,0,0,0,.7.29,1,1,0,0,0,.71-.29,1,1,0,0,0,0-1.41l-.71-.71A1,1,0,0,0,4.93,6.34Zm12,.29a1,1,0,0,0,.7-.29l.71-.71a1,1,0,1,0-1.41-1.41L17,5.64a1,1,0,0,0,0,1.41A1,1,0,0,0,17.66,7.34ZM21,11H20a1,1,0,0,0,0,2h1a1,1,0,0,0,0-2Zm-9,8a1,1,0,0,0-1,1v1a1,1,0,0,0,2,0V20A1,1,0,0,0,12,19ZM18.36,17A1,1,0,0,0,17,18.36l.71.71a1,1,0,0,0,1.41,0,1,1,0,0,0,0-1.41ZM12,6.5A5.5,5.5,0,1,0,17.5,12,5.51,5.51,0,0,0,12,6.5Zm0,9A3.5,3.5,0,1,1,15.5,12,3.5,3.5,0,0,1,12,15.5Z" />
					</svg>
				{/if}
			</button>
		</div>

		<!-- Favicon -->
		<div class="mb-8">
			<img
				alt="Cleli Logo"
				class="w-20 h-20 mx-auto rounded-2xl"
				src="/favicon.png"
			/>
		</div>

		<!-- Main Content -->
		<div class="space-y-6">
			<div>
				<h1 class="text-4xl font-bold text-base-content mb-2">
					Website in Development
				</h1>
				<p class="text-base-content/70 text-lg">
					Something amazing is coming soon
				</p>
			</div>

			<!-- Contact Information -->
			<div class="card bg-base-200 shadow-xl">
				<div class="card-body py-6">
					<h2 class="card-title text-xl justify-center mb-4 text-base-content">
						Get in Touch
					</h2>
					<div class="flex justify-center">
						<div class="space-y-4">
							<!-- Email -->
							<div class="flex items-center gap-4">
								<div class="p-3 bg-primary/10 rounded-full">
									<svg class="w-6 h-6 text-primary" fill="currentColor" viewBox="0 0 20 20">
										<path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" />
										<path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
									</svg>
								</div>
								<a
									class="link link-primary font-medium text-lg"
									href="mailto:{contactInfo.email}"
								>
									{contactInfo.email}
								</a>
							</div>

							<!-- Discord Username -->
							<div class="flex items-center gap-4">
								<div class="p-3 bg-primary/10 rounded-full">
									<DiscordIcon />
								</div>
								<span class="text-base-content font-medium text-lg">
									{contactInfo.discord}
								</span>
							</div>

							<!-- Discord Server -->
							<div class="flex items-center gap-4">
								<div class="p-3 bg-primary/10 rounded-full">
									<DiscordIcon />
								</div>
								<a
									class="link link-primary font-medium text-lg"
									href={contactInfo.discordServer}
									rel="noopener noreferrer"
									target="_blank"
								>
									Join Discord Server
								</a>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
