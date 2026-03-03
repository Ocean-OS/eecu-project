import { Chart } from "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.5.0/chart.min.js"
const graph = document.querySelector("#graph")
const chart = new Chart(graph, {
    type: "pie", data: {
        labels: []
    }
})