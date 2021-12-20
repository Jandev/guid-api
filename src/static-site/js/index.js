async function fetchNewGuid() {
    let response = await fetch('https://api.guid.codes/api/DefaultNewGuid');
    let data = await response.text()
    return data;
}

function renewElements() {
    fetchNewGuid().then(v => {
        document.getElementById('newGuid').value = v
    }).catch(r => {
        document.getElementById('newGuidContext').innerHTML = 'Failed to retrieve a new guid. Please navigate to <a href="https://api.guid.codes/">https://api.guid.codes/</a>'
    })
}



function fallbackCopyTextToClipboard(text) {
    var textArea = document.createElement("textarea");
    textArea.value = text;

    // Avoid scrolling to bottom
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.position = "fixed";

    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
        var successful = document.execCommand('copy');
        var msg = successful ? 'successful' : 'unsuccessful';
        console.log('Fallback: Copying text command was ' + msg);
    } catch (err) {
        console.error('Fallback: Oops, unable to copy', err);
    }

    document.body.removeChild(textArea);
}
function copyTextToClipboard() {
    let text = document.getElementById('newGuid').value
    if (!navigator.clipboard) {
        fallbackCopyTextToClipboard(text);
        return;
    }
    navigator.clipboard.writeText(text).then(function () {
        console.log('Async: Copying to clipboard was successful!');
    }, function (err) {
        console.error('Async: Could not copy text: ', err);
    });
}

window.addEventListener("load", function(){
    renewElements();
});

