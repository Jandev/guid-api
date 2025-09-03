import './theme.css';

declare const __GUID_API_URL__: string;

/**
 * Fetches a new GUID from the API
 * @returns Promise containing the GUID string
 */
async function fetchNewGuid(): Promise<string> {
    // For Static Web Apps, use relative path to the API
    const response: Response = await fetch('/api/newguid');
    const data: string = await response.text();
    return data;
}

/**
 * Renews the GUID elements in the UI
 */
function renewElements(): void {
    fetchNewGuid()
        .then((guid: string) => {
            const guidElement = document.getElementById('newGuid') as HTMLInputElement;
            if (guidElement) {
                guidElement.value = guid;
            }
        })
        .catch((error: unknown) => {
            const contextElement = document.getElementById('newGuidContext');
            if (contextElement) {
                contextElement.innerHTML = `Failed to retrieve a new guid. Please check if the API is running.`;
            }
            console.error('Error fetching GUID:', error);
        });
}

/**
 * Fallback function to copy text to clipboard using legacy method
 * @param text - The text to copy to clipboard
 */
function fallbackCopyTextToClipboard(text: string): void {
    const textArea: HTMLTextAreaElement = document.createElement("textarea");
    textArea.value = text;

    // Avoid scrolling to bottom
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.position = "fixed";

    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
        const successful: boolean = document.execCommand('copy');
        const msg: string = successful ? 'successful' : 'unsuccessful';
        console.log('Fallback: Copying text command was ' + msg);
    } catch (err: unknown) {
        console.error('Fallback: Oops, unable to copy', err);
    }

    document.body.removeChild(textArea);
}

/**
 * Copies the current GUID to clipboard
 */
function copyTextToClipboard(): void {
    const guidElement = document.getElementById('newGuid') as HTMLInputElement;
    if (!guidElement) {
        console.error('GUID element not found');
        return;
    }
    
    const text: string = guidElement.value;
    
    if (!navigator.clipboard) {
        fallbackCopyTextToClipboard(text);
        return;
    }
    
    navigator.clipboard.writeText(text)
        .then(() => {
            console.log('Async: Copying to clipboard was successful!');
        })
        .catch((err: unknown) => {
            console.error('Async: Could not copy text:', err);
        });
}

// Initialize the application when the window loads
window.addEventListener("load", (): void => {
    renewElements();
});

// Export functions for potential testing or external use
export { fetchNewGuid, renewElements, copyTextToClipboard, fallbackCopyTextToClipboard };