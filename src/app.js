import { Chart } from 'https://cdn.jsdelivr.net/npm/chart.js@4.5.1/+esm'
const graph = document.querySelector("#graph")
const next = document.querySelector('#next-btn');
const back = document.querySelector('#back-btn');

async function careerOptions () {
    const selectCareer = document.getElementById('career-inputs');
    const careerAnnualSalary = new Map();
    try {
        const response = await fetch ('https://eecu-data-server.vercel.app/data');
        if (!response.ok) {
            throw new Error ('Network response was not ok');
        }

        const users = await response.json();

        users.forEach(user => {
            careerAnnualSalary.set(user["Occupation"], user["Salary"]);
            const option = new Option(user["Occupation"], user["Occupation"]);
            selectCareer.add(option);
        });

        selectCareer.addEventListener('change', () => {
            salary.textContent = careerAnnualSalary.get(selectCareer.value) || '';
        })
    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
    }
}

careerOptions();

const compiled = await WebAssembly.compileStreaming(await fetch('data:application/wasm;base64,AGFzbQEAAAABDwNefwFgAX8Bf2ACf38BfwIPAQNlbnYHc3lzY2FsbAABAwIBAgUEAQCACAYMAWQAAUEAQQD7BgALBxACBm1lbW9yeQIAA3N1bQABCl4BXAIBZAADfyABQQD7BwAhAgNAIAQgAGooAgAhBSACIAQgBfsOACAEQQFqIQQgBCABTA0AC0EAIQNBACEEA0AgAyACIAT7CwBqIQMgBEEBaiEEIAQgAUwNAAsgAw8L'));
const { exports: { sum } } = await WebAssembly.instantiate(compiled, {
    env: {
        syscall() {

        }
    }
});

console.log(sum([1, 2, 3]));

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

function navigate(page) {
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
let current_chart;
const chart_container = () => document.querySelector("#graph").getContext("2d");

/*
function updatePieChart() {
    current_chart?.destroy();
    current_chart = new Chart(chart_container(), {
        type: 'pie',
        data: {
            datasets: [
                {
                    label: 'Monthly Expenses',
                    data: categories.map(category =>
                        category.inputs
                            .values()
                            .map(value => value.value)
                            .reduce((a, b) => a + b, 0)
                    )
                }
            ],
            labels: categories.map(category => category.name)
        }
    });
    console.log(categories.map(category =>
        category.inputs
            .values()
            .map(value => value.value)
            .reduce((a, b) => a + b, 0
            )))
}

updatePieChart() */