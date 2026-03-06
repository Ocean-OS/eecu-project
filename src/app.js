import { Chart } from 'https://cdn.jsdelivr.net/npm/chart.js@4.5.1/+esm'
const graph = document.querySelector("#graph")
const next = document.querySelector('#next-btn');
const back = document.querySelector('#back-btn');

// const chart = new Chart(graph, {
//     type: "pie", data: {
//         labels: []
//     }
// });

// //getting the data
const data = {
    labels: ['Orange', 'Red', 'Yellow'],
    datasets: [{
        label: 'dataset:',
        data: [40, 30, 30], // then put them as percentage
        backgroundColor: ['rgba(255, 139, 82, 1)', 'rgba(233, 52, 52, 1)', 'rgba(241, 217, 81, 1)']
    }]
}


// how graph is created with prior code
const context = document.getElementById('graph');
const graph = new Chart(context, {
    type: 'pie',
    data: data,
    options: // name of options
});


const nav_header = document.querySelector("nav>h1");
let current_section = 0;
const sections = document.querySelectorAll("section");
console.log(2);
window.matchMedia("screen and (max-width: 600px)").addEventListener("change", (event) => {
    if (event.matches) {
        nav_header.textContent = sections.item(current_section).firstElementChild.textContent;
        console.log(nav_header);
    } else {
        nav_header.textContent = "Budget Calculator";
    }

});
if (window.matchMedia("screen and (max-width: 600px)").matches) {
    nav_header.textContent = sections.item(current_section).firstElementChild.textContent;
    console.log(1);
}

next.addEventListener("click", () => {

});