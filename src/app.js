import { Chart } from 'https://cdn.jsdelivr.net/npm/chart.js@4.5.1/+esm'
const graph = document.querySelector("#graph")
const chart = new Chart(graph, {
    type: "pie", data: {
        labels: []
    }
})

const nav_header = document.querySelector("nav>h1");
let current_section = 0;
const sections = document.querySelectorAll("section");
console.log(2);
if (window.matchMedia("screen and (max-width: 600px)").matches) {
    console.log(1);
    nav_header.textContent = sections.item(current_section).firstElementChild.textContent;
}