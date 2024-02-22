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

    if (item.type === "knocked_out") {
        show("You've been knocked out unconsious");
    } else if (item.type === "knocked_down") {
        show("You are knocked down and injured")
    } else if (item.type === "eliminated") {
        show("You are dead");
    } else if (item.type === "ambulance_reset") {
        const container = document.querySelector(".injured");
        container.style.display = "none";
    } else if (item.type === "update_respawn_timer") {
        show(`You are dead\nRespawn available in ${item.time} seconds`);
    } else if (item.type === "update_respawn_available") {
        show(`Press ${item.keybind} to respawn`);
    }
});
