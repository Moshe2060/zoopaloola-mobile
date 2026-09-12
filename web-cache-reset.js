// Build marker: friend-room-redesign-v1
(async () => {
	const currentBuild = document.documentElement.dataset.build || "unknown";
	const storageKey = "zoovortex-active-build";
	if (localStorage.getItem(storageKey) === currentBuild) return;

	localStorage.setItem(storageKey, currentBuild);
	if ("serviceWorker" in navigator) {
		const registrations = await navigator.serviceWorker.getRegistrations();
		await Promise.all(registrations.map((registration) => registration.unregister()));
	}
	if ("caches" in window) {
		const keys = await caches.keys();
		await Promise.all(keys.filter((key) => key.startsWith("ZOOVORTEX-sw-cache-")).map((key) => caches.delete(key)));
	}

	const url = new URL(window.location.href);
	url.searchParams.set("build", currentBuild);
	window.location.replace(url.toString());
})().catch((error) => console.warn("Could not reset the previous game cache", error));
