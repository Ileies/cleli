<script lang="ts">
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	onMount(() => {
		goto('/', { replaceState: true });
	});
</script>

<svelte:head>
	<title>Miray Diri – Portfolio</title>
	<meta http-equiv="refresh" content="0; url=/" />
</svelte:head>
