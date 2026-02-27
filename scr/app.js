const template = document.querySelector("template"); //Grabs the template from HTML
customElements.define("labeled-input", class extends HTMLElement { //Defines a custom element called "labeled-input"
    static get observedAttributes() { return ["name"]; }
    constructor() {
        super();
        this.attachShadow({ mode: "open" });
        this.shadowRoot.appendChild(template.content.cloneNode(true));
    }
    connectedCallback() {
        this.shadowRoot.querySelector("label").textContent = this.getAttribute("name");
    }
});
