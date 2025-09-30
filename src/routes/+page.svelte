<script lang="ts">
	import { onMount } from 'svelte';
	import { Moon, Sun, Mail, Github } from 'lucide-svelte';
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
		discordServer: 'https://discord.gg/7nZKeT5ZTQ',
		github: 'https://github.com/cleli61'
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
					<Moon class="w-6 h-6" />
				{:else}
					<Sun class="w-6 h-6" />
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
									<Mail class="w-6 h-6 text-primary" />
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
									I love Dragons
								</a>
							</div>

							<!-- GitHub -->
							<div class="flex items-center gap-4">
								<div class="p-3 bg-primary/10 rounded-full">
									<Github class="w-6 h-6 text-primary" />
								</div>
								<a
									class="link link-primary font-medium text-lg"
									href={contactInfo.github}
									rel="noopener noreferrer"
									target="_blank"
								>
									GitHub
								</a>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
