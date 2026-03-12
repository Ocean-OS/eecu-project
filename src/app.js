// @ts-check
// @ts-expect-error
import { Chart } from 'https://cdn.jsdelivr.net/npm/chart.js@4.5.1/+esm';
// @ts-expect-error
import { compile } from 'https://dy.github.io/watr/watr.js';
const graph = document.querySelector('#graph');
const next = document.querySelector('#next-btn');
const back = document.querySelector('#back-btn');
const text = await fetch('./app.wat').then(res => res.text());
const compiled = await WebAssembly.compile(compile(text));
/** @type {Map<number, any>} */
const objects = new Map();

async function careerOptions() {
    const selectCareer = document.getElementById('career-inputs');
    const careerAnnualSalary = new Map();
    const salary = selectCareer?.nextElementSibling?.firstElementChild;
    try {
        const response = await fetch(
            'https://eecu-data-server.vercel.app/data'
        );
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        const users = /** @type {Array<Record<String, number | string>>} */ (
            await response.json()
        );

        users.forEach(user => {
            careerAnnualSalary.set(user['Occupation'], user['Salary']);
            const option = new Option(user['Occupation'], user['Occupation']);
            selectCareer?.add(option);
        });

        selectCareer?.addEventListener('change', () => {
            salary.value =
                careerAnnualSalary.get(selectCareer.value) || '';
        });
    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
    }
}

careerOptions();

let freed = 0;

/**
 * @param {number} ptr
 */
function find_until_null(ptr) {
    const buffer = new Uint8Array(
        /** @type {WebAssembly.Memory} */ (memory).buffer.slice(ptr)
    );
    let i = 0;
    while (i < buffer.byteLength) {
        if (buffer[i++] === 0) {
            return i - 1;
        }
    }
}

const {
    exports: { sum, sum_category, memory: _memory }
} = await WebAssembly.instantiate(compiled, {
    env: {
        /**
         * @param {number} ptr_to_selector
         */
        'document.querySelector': ptr_to_selector => {
            const string = new TextDecoder().decode(
                /** @type {WebAssembly.Memory} */ (memory).buffer.slice(
                    ptr_to_selector,
                    find_until_null(ptr_to_selector)
                )
            );
            const res = document.querySelector(string);
            if (res === null) {
                objects.set(objects.size, null);
                return objects.size - 1;
            }
            objects.set(objects.size, new WeakRef(res));
            return objects.size - 1;
        },
        /**
         * @param {number} target
         * @param {number} property
         */
        'Reflect.get': (target, property) => {
            const object = objects.get(target);
            if (object === null || object === undefined) {
                throw new TypeError('Cannot read properties of null');
            }
            const string = new TextDecoder().decode(
                /** @type {WebAssembly.Memory} */ (memory).buffer.slice(
                    property,
                    find_until_null(property)
                )
            );
            const value = Reflect.get(object, string);
            if (value === null) {
                objects.set(objects.size, null);
                return objects.size - 1;
            }
            objects.set(objects.size, new WeakRef(value));
            return objects.size - 1;
        },
        'Reflect.set': (
            /** @type {number} */ target,
            /** @type {number} */ property,
            /** @type {number} */ value
        ) => {
            const object = objects.get(target);
            const key = new TextDecoder().decode(
                /** @type {WebAssembly.Memory} */ (memory).buffer.slice(
                    property,
                    find_until_null(property)
                )
            );
            const v = objects.has(value) ? objects.get(value) : value;
            Reflect.set(object, key, v);
        },
        /**
         * @param {number} ptr_to_selector
         */
        'document.querySelectorAll': ptr_to_selector => {
            const string = new TextDecoder().decode(
                /** @type {WebAssembly.Memory} */ (memory).buffer.slice(
                    ptr_to_selector,
                    find_until_null(ptr_to_selector)
                )
            );
            const res = document.querySelectorAll(string);
            const ptr = objects.size;
            for (const element of res) {
                objects.set(objects.size, element);
            }
            return ptr;
        },
        localStorage: (objects.set(objects.size, localStorage), objects.size - 1),
        /**
         * @param {number} object
         */
        'JSON.stringify': object => {
            const value = objects.get(object);
            const string = JSON.stringify(value);
            const u8array = new Uint8Array(memory.buffer);
            const ptr = freed;
            for (let i = 0; i < string.length; i++) {
                u8array[freed++] = string.charCodeAt(i);
            }
            return ptr;
        },
        /**
         * @param {number} string
         */
        'JSON.parse': string => {
            const str = new TextDecoder().decode(
                /** @type {WebAssembly.Memory} */ (memory).buffer.slice(
                    string,
                    find_until_null(string)
                )
            );
            const value = JSON.parse(str);
            objects.set(objects.size, value);
            return objects.size - 1;
        },
        'Object.create': () => {
            objects.set(objects.size, {});
            return objects.size - 1;
        }
    }
});

const memory = /** @type {WebAssembly.Memory} */ (_memory);

/**
 * @param {number[]} nums
 */
function wasm_sum(nums) {
    const int32array = new Int32Array(
        /** @type {WebAssembly.Memory} */ (memory).buffer
    );
    const ptr = freed;
    for (let i = 0; i < nums.length; i++) {
        int32array[freed++] = nums[i];
    }
    const res = sum(ptr, (nums.length - 1) * 16);
    // for (let i = 0; i < nums.length; i++) {
    //     int32array[--freed] = 0;
    // }
    return res;
}

/**
 * @param {Array<{ yearly: boolean; value: number }>} inputs
 */
function wasm_sum_category(inputs) {
    const f64array = new Float64Array(
        /** @type {WebAssembly.Memory} */ (memory).buffer
    );
    const ptr = freed;
    for (let i = 0; i < inputs.length; i++) {
        const input = inputs[i];
        f64array[freed++] = input.value;
        f64array[freed++] = input.yearly ? 1 : 0;
    }
    const res = sum_category(ptr, (inputs.length - 1) * 32);
    // for (let i = 0; i < inputs.length; i++) {
    //     f64array[--freed] = f64array[--freed] = 0;
    // }
    return res;
}

console.log(memory);
console.log(wasm_sum([1, 2, 3, 4, 5, 6]));
console.log(
    wasm_sum_category([
        {
            value: 500,
            yearly: true
        },
        {
            value: 50,
            yearly: false
        }
    ])
);
console.log();

// const chart = new Chart(graph, {
//     type: "pie", data: {
//         labels: []
//     }
// });

// //getting the data
const data = {
    labels: ['Orange', 'Red', 'Yellow'],
    datasets: [
        {
            label: 'dataset:',
            data: [40, 30, 30], // then put them as percentage
            backgroundColor: [
                'rgba(255, 139, 82, 1)',
                'rgba(233, 52, 52, 1)',
                'rgba(241, 217, 81, 1)'
            ]
        }
    ]
};

// // how graph is created with prior code
// const context = document.getElementById('graph');
// const graph = new Chart(context, {
//     type: 'pie',
//     data: data,
//     options: // name of options
// });

const nav_header = document.querySelector('nav>h1');
let current_section = 0;
const sections = document.querySelectorAll('section');
console.log(2);
window
    .matchMedia('screen and (max-width: 600px)')
    .addEventListener('change', event => {
        if (event.matches) {
            nav_header.textContent =
                sections.item(current_section)?.firstElementChild?.textContent;
        } else {
            nav_header.textContent = 'Budget Calculator';
        }
    });

if (window.matchMedia('screen and (max-width: 600px)').matches) {
    console.log(1);
    nav_header.textContent =
        sections.item(current_section)?.firstElementChild?.textContent;
}

next?.addEventListener('click', () => {
    navigate(current_section + 1);
});

back?.addEventListener('click', () => {
    navigate(current_section - 1);
});

/**
 * @param {number} page
 */
function navigate(page) {
    if (page == current_section || page < 0 || page > sections.length - 1) {
        return;
    }
    console.log(sections, current_section);
    sections.item(current_section).classList.remove('active');
    sections.item(current_section).classList.add('mobile-inactive');
    const section = sections.item((current_section = page));
    section.classList.add('active');
    section.classList.remove('mobile-inactive');
    nav_header.textContent =
        sections.item(current_section)?.firstElementChild?.textContent;
}
let current_chart;
const chart_container = () =>
    document.querySelector('#graph')?.getContext('2d');

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

//     }
//     console.log(sections, current_section);
//     sections.item(current_section).classList.remove('active');
//     sections.item(current_section).classList.add('mobile-inactive');
//     const section = sections.item((current_section = page));
//     section.classList.add('active');
//     section.classList.remove('mobile-inactive');
//     nav_header.textContent =
//         sections.item(current_section).firstElementChild.textContent;
// }
