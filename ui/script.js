function fetchCallback(name, data, cb) {
    fetch(`https://${GetParentResourceName()}/${name}`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify(data)
    }).then(resp => resp.json()).then(resp =>
        cb(resp)
    );
}

function show(text) {
    const injuredText = document.querySelector(".injured > p");
    injuredText.textContent = text;
    
    const container = document.querySelector(".injured");
    container.style.display = "block";
}

window.addEventListener("message", function(event) {
    const item = event.data;

    if (item.type === "ambulance_reset") {
        const container = document.querySelector(".injured");
        container.style.display = "none";
    } else {
        show(item.text);
    }
});
