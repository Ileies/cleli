<script lang="ts">
	import { onMount } from 'svelte';

	let theme = $state('light');
	let counter = $state(0);
	let inputValue = $state('');
	let todos = $state<string[]>([]);
	let newTodo = $state('');

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

	function addTodo() {
		if (newTodo.trim()) {
			todos = [...todos, newTodo.trim()];
			newTodo = '';
		}
	}

	function removeTodo(index: number) {
		todos = todos.filter((_, i) => i !== index);
	}

	function handleKeydown(event: KeyboardEvent) {
		if (event.key === 'Enter') {
			addTodo();
		}
	}
</script>

<svelte:head>
	<title>Tests - Cleli</title>
	<meta name="description" content="Test page for various components and functionality" />
</svelte:head>

<div class="min-h-screen bg-base-100 p-8">
	<!-- Header with Theme Toggle -->
	<div class="flex justify-between items-center mb-8">
		<div>
			<h1 class="text-4xl font-bold text-base-content mb-2">Test Page</h1>
			<p class="text-base-content/70">Testing various components and functionality</p>
		</div>
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

	<!-- Navigation -->
	<div class="mb-8">
		<div class="breadcrumbs text-sm">
			<ul>
				<li><a href="/" class="link link-primary">Home</a></li>
				<li>Tests</li>
			</ul>
		</div>
	</div>

	<!-- Test Components Grid -->
	<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
		<!-- Counter Component -->
		<div class="card bg-base-200 shadow-xl">
			<div class="card-body">
				<h2 class="card-title">Counter Test</h2>
				<div class="text-center py-4">
					<div class="text-4xl font-bold text-primary mb-4">{counter}</div>
					<div class="flex gap-2 justify-center">
						<button class="btn btn-secondary" onclick={() => counter--}>-</button>
						<button class="btn btn-primary" onclick={() => counter++}>+</button>
						<button class="btn btn-outline" onclick={() => counter = 0}>Reset</button>
					</div>
				</div>
			</div>
		</div>

		<!-- Input Test -->
		<div class="card bg-base-200 shadow-xl">
			<div class="card-body">
				<h2 class="card-title">Input Test</h2>
				<div class="form-control">
					<label class="label" for="test-input">
						<span class="label-text">Enter some text:</span>
					</label>
					<input
						id="test-input"
						type="text"
						placeholder="Type here..."
						class="input input-bordered"
						bind:value={inputValue}
					/>
					<div class="label">
						<span class="label-text-alt">
							{inputValue.length} characters
						</span>
					</div>
				</div>
				{#if inputValue}
					<div class="mt-4 p-4 bg-base-300 rounded-lg">
						<p class="text-sm font-medium">You typed:</p>
						<p class="text-lg">{inputValue}</p>
					</div>
				{/if}
			</div>
		</div>

		<!-- Todo List Test -->
		<div class="card bg-base-200 shadow-xl">
			<div class="card-body">
				<h2 class="card-title">Todo List Test</h2>
				<div class="form-control">
					<div class="input-group">
						<input
							type="text"
							placeholder="Add a todo..."
							class="input input-bordered flex-1"
							bind:value={newTodo}
							onkeydown={handleKeydown}
						/>
						<button class="btn btn-primary" onclick={addTodo}>Add</button>
					</div>
				</div>
				
				{#if todos.length > 0}
					<div class="mt-4 space-y-2">
						{#each todos as todo, index (index)}
							<div class="flex items-center justify-between p-2 bg-base-300 rounded">
								<span>{todo}</span>
								<button
									class="btn btn-ghost btn-xs text-error"
									onclick={() => removeTodo(index)}
								>
									×
								</button>
							</div>
						{/each}
					</div>
				{:else}
					<div class="mt-4 text-center text-base-content/50">
						No todos yet. Add one above!
					</div>
				{/if}
			</div>
		</div>

		<!-- Alert Test -->
		<div class="card bg-base-200 shadow-xl">
			<div class="card-body">
				<h2 class="card-title">Alert Test</h2>
				<div class="space-y-4">
					<div class="alert alert-info">
						<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
						</svg>
						<span>Info alert example</span>
					</div>
					<div class="alert alert-success">
						<svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
						</svg>
						<span>Success alert example</span>
					</div>
					<div class="alert alert-warning">
						<svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.464 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z" />
						</svg>
						<span>Warning alert example</span>
					</div>
				</div>
			</div>
		</div>

		<!-- Button Test -->
		<div class="card bg-base-200 shadow-xl">
			<div class="card-body">
				<h2 class="card-title">Button Test</h2>
				<div class="space-y-3">
					<button class="btn btn-primary w-full">Primary</button>
					<button class="btn btn-secondary w-full">Secondary</button>
					<button class="btn btn-accent w-full">Accent</button>
					<button class="btn btn-outline w-full">Outline</button>
					<button class="btn btn-ghost w-full">Ghost</button>
					<button class="btn btn-link w-full">Link</button>
				</div>
			</div>
		</div>

		<!-- Progress Test -->
		<div class="card bg-base-200 shadow-xl">
			<div class="card-body">
				<h2 class="card-title">Progress Test</h2>
				<div class="space-y-4">
					<div>
						<div class="flex justify-between text-sm mb-1">
							<span>Progress</span>
							<span>70%</span>
						</div>
						<progress class="progress progress-primary w-full" value="70" max="100"></progress>
					</div>
					<div>
						<div class="flex justify-between text-sm mb-1">
							<span>Loading</span>
							<span>45%</span>
						</div>
						<progress class="progress progress-secondary w-full" value="45" max="100"></progress>
					</div>
					<div>
						<div class="flex justify-between text-sm mb-1">
							<span>Complete</span>
							<span>100%</span>
						</div>
						<progress class="progress progress-accent w-full" value="100" max="100"></progress>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- Back to Home -->
	<div class="mt-12 text-center">
		<a href="/" class="btn btn-primary btn-lg">
			← Back to Home
		</a>
	</div>
</div>
