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


// // how graph is created with prior code
// const context = document.getElementById('graph');
// const graph = new Chart(context, {
//     type: 'pie',
//     data: data,
//     options: // name of options
// });


const nav_header = document.querySelector("nav>h1");
let current_section = 0;
const sections = document.querySelectorAll("section");
console.log(2);
window.matchMedia("screen and (max-width: 600px)").addEventListener("change", (event) => {
    if (event.matches) {
        nav_header.textContent = sections.item(current_section).firstElementChild.textContent;
        
    } else {
        nav_header.textContent = "Budget Calculator";
    }
})

if (window.matchMedia("screen and (max-width: 600px)").matches) {
    console.log(1);
    nav_header.textContent = sections.item(current_section).firstElementChild.textContent;
}

next.addEventListener("click", () => {
    navigate(current_section + 1);

});

back.addEventListener("click", () => {
    navigate(current_section - 1);

});

function navigate (page)  {
    if (page == current_section || page < 0 || page > sections.length - 1) {
        return;
    
    }
    console.log(sections, current_section);
    sections.item(current_section).classList.remove("active");
    sections.item(current_section).classList.add("mobile-inactive");
    const section = sections.item(current_section = page);
    section.classList.add("active");
    section.classList.remove("mobile-inactive");
    nav_header.textContent = sections.item(current_section).firstElementChild.textContent;

}   

