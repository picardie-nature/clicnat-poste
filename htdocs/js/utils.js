/**
 * @brief confirmation avant de charger
 */
function q(message, url) {
	if (confirm(message))
		document.location.href = url;
}
