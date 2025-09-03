/**
 * Fetches a new GUID from the API
 * @returns Promise containing the GUID string
 */
async function fetchNewGuid() {
    const response = await fetch('https://api.guid.codes/api/DefaultNewGuid');
    const data = await response.text();
    return data;
}
/**
 * Renews the GUID elements in the UI
 */
function renewElements() {
    fetchNewGuid()
        .then((guid) => {
        const guidElement = document.getElementById('newGuid');
        if (guidElement) {
            guidElement.value = guid;
        }
    })
        .catch((error) => {
        const contextElement = document.getElementById('newGuidContext');
        if (contextElement) {
            contextElement.innerHTML = 'Failed to retrieve a new guid. Please navigate to <a href="https://api.guid.codes/">https://api.guid.codes/</a>';
        }
        console.error('Error fetching GUID:', error);
    });
}
/**
 * Fallback function to copy text to clipboard using legacy method
 * @param text - The text to copy to clipboard
 */
function fallbackCopyTextToClipboard(text) {
    const textArea = document.createElement("textarea");
    textArea.value = text;
    // Avoid scrolling to bottom
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.position = "fixed";
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    try {
        const successful = document.execCommand('copy');
        const msg = successful ? 'successful' : 'unsuccessful';
        console.log('Fallback: Copying text command was ' + msg);
    }
    catch (err) {
        console.error('Fallback: Oops, unable to copy', err);
    }
    document.body.removeChild(textArea);
}
/**
 * Copies the current GUID to clipboard
 */
function copyTextToClipboard() {
    const guidElement = document.getElementById('newGuid');
    if (!guidElement) {
        console.error('GUID element not found');
        return;
    }
    const text = guidElement.value;
    if (!navigator.clipboard) {
        fallbackCopyTextToClipboard(text);
        return;
    }
    navigator.clipboard.writeText(text)
        .then(() => {
        console.log('Async: Copying to clipboard was successful!');
    })
        .catch((err) => {
        console.error('Async: Could not copy text:', err);
    });
}
// Initialize the application when the window loads
window.addEventListener("load", () => {
    renewElements();
});
// Export functions for potential testing or external use
export { fetchNewGuid, renewElements, copyTextToClipboard, fallbackCopyTextToClipboard };
