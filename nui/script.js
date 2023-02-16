const imagesUrl = "http://localhost/imagensRotas/";

function getRandomIntInclusive(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

class MainRoutes {
    constructor() {
        this.items = []
    }
    load(items) {
        let arr = []
        for (let i in items) {
            items[i].index = i
            arr.push(items[i])
        }
        this.items = arr
        this.renderItemsPage()
    }
    renderItemsPage() {
        let container = document.querySelector('.main')
        container.innerHTML = ''

        for (let i in this.items) {
            container.innerHTML +=
                `<div class="item content" onclick="Main.selectRoute(event)" data-code="${this.items[i].index}">
            <div class="pin">
                <i class="fa-solid fa-location-pin"></i>
            </div>
            <div class="imagem" style="background: url(imgs/${getRandomIntInclusive(1, 5)}.png);"></div>
            <div class="texto">
                <h1>${this.items[i].mode} ${this.items[i].name}</h1>
                <p>AVISAR POLÍCIA: <span>${this.items[i].avisarpolicia}</span></p>
            </div>
        </div>`
        }
    }
    selectRoute(event) {
        if (document.querySelector('.activeItem')) {
            document.querySelector('.activeItem').classList.remove('activeItem')
        }
        let element = event.currentTarget
        element.classList.add('activeItem')
        Main.startRoute()
    }
    startRoute() {
        let activeItem = document.querySelector('.activeItem')
        if (!activeItem) return
        this.callServer("selectRoute", { code: activeItem.dataset.code });
    }
    callServer(endpoint, data, callback) {
        $.post("http://tkzRotas/" + endpoint, JSON.stringify(data), callback);
    }
    exit() {
        $("body").fadeOut();
        this.callServer("exit", {});
    }
};
var Main = new MainRoutes()
document.onkeyup = function (data) {
    if (data.which == 27) {
        Main.callServer("exit", {});
    }
};

window.addEventListener("message", function (event) {
    var action = event.data.action;
    switch (action) {
        case "open":
            $("body").fadeIn();
            Main.load(event.data.items);
            break;
        case "exit":
            $("body").fadeOut();
            break;
    }
});