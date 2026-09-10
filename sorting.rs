use std::time::Instant;

const NUM_ELEMS: usize = 2_000_000;
const QUADRATIC_LIMIT: usize = 50_000;
const INSERTION_CUTOFF: usize = 12;

// ============================================================
// Utilitaires
// ============================================================

#[inline]
fn swap(a: &mut [i32], i: usize, j: usize) {
    a.swap(i, j);
}

// ============================================================
// I Can't Believe It Can Sort
// ============================================================

fn i_cant_believe_it_can_sort(a: &mut [i32]) {
    if a.len() < 2 {
        return;
    }

    let mut sorted = false;

    while !sorted {
        sorted = true;

        for i in 1..a.len() {
            if a[i - 1] > a[i] {
                a.swap(i - 1, i);
                sorted = false;
                break;
            }
        }
    }
}

// ============================================================
// Selection Sort
// ============================================================

fn selection_sort(a: &mut [i32]) {
    if a.len() < 2 {
        return;
    }

    for i in 0..a.len() - 1 {
        let mut min_index = i;

        for j in i + 1..a.len() {
            if a[j] < a[min_index] {
                min_index = j;
            }
        }

        if min_index != i {
            a.swap(i, min_index);
        }
    }
}

// ============================================================
// Insertion Sort
// ============================================================

fn insertion_sort(a: &mut [i32]) {
    if a.len() < 2 {
        return;
    }

    for i in 1..a.len() {
        let value = a[i];
        let mut j = i;

        while j > 0 && a[j - 1] > value {
            a[j] = a[j - 1];
            j -= 1;
        }

        a[j] = value;
    }
}

// ============================================================
// Shell Sort
// ============================================================

fn shell_sort(a: &mut [i32]) {
    let n = a.len();

    if n < 2 {
        return;
    }

    // Knuth sequence: 1, 4, 13, 40, ...
    let mut gap = 1;

    while gap < n / 3 {
        gap = gap * 3 + 1;
    }

    loop {
        for i in gap..n {
            let value = a[i];
            let mut j = i;

            while j >= gap && a[j - gap] > value {
                a[j] = a[j - gap];
                j -= gap;
            }

            a[j] = value;
        }

        if gap == 1 {
            break;
        }

        gap = (gap - 1) / 3;
    }
}

// ============================================================
// QuickSort
// ============================================================

fn median_of_three(a: i32, b: i32, c: i32) -> i32 {
    if a < b {
        if b < c {
            b
        } else if a < c {
            c
        } else {
            a
        }
    } else if a < c {
        a
    } else if b < c {
        c
    } else {
        b
    }
}

fn partition(a: &mut [i32], low: usize, high: usize) -> usize {
    let mid = low + (high - low) / 2;
    let pivot = median_of_three(a[low], a[mid], a[high]);

    let mut i = low;
    let mut j = high;

    loop {
        while a[i] < pivot {
            i += 1;
        }

        while a[j] > pivot {
            j -= 1;
        }

        if i >= j {
            return j;
        }

        a.swap(i, j);

        i += 1;
        j -= 1;
    }
}

fn quick_sort_range(a: &mut [i32], initial_low: usize, initial_high: usize) {
    let mut low = initial_low;
    let mut high = initial_high;

    while low < high {
        let p = partition(a, low, high);

        let left_size = p - low + 1;
        let right_size = high - p;

        // Trier récursivement la plus petite partition.
        // Cela limite la profondeur de récursion.
        if left_size < right_size {
            if p > low {
                quick_sort_range(a, low, p);
            }

            low = p + 1;
        } else {
            if p + 1 < high {
                quick_sort_range(a, p + 1, high);
            }

            high = p;
        }
    }
}

fn quick_sort(a: &mut [i32]) {
    if a.len() < 2 {
        return;
    }

    quick_sort_range(a, 0, a.len() - 1);
}

// ============================================================
// Merge Sort
// ============================================================
//
// Buffer de taille n, réutilisé par toute la récursion.
//
// Chaque fusion :
//   1. les deux moitiés sont déjà triées ;
//   2. le segment entier est copié dans buf ;
//   3. buf est fusionné vers a.
// ============================================================

fn merge_sort_buf(a: &mut [i32], buf: &mut [i32]) {
    let n = a.len();

    if n <= 1 {
        return;
    }

    if n <= INSERTION_CUTOFF {
        insertion_sort(a);
        return;
    }

    let mid = n / 2;

    // Les deux moitiés utilisent le même buffer.
    merge_sort_buf(&mut a[..mid], buf);
    merge_sort_buf(&mut a[mid..], buf);

    // Déjà trié : aucune fusion nécessaire.
    if a[mid - 1] <= a[mid] {
        return;
    }

    // Copie du segment courant dans le buffer.
    buf[..n].copy_from_slice(a);

    let mut i = 0;
    let mut j = mid;
    let mut k = 0;

    while i < mid && j < n {
        if buf[i] <= buf[j] {
            a[k] = buf[i];
            i += 1;
        } else {
            a[k] = buf[j];
            j += 1;
        }

        k += 1;
    }

    // Éléments restants à gauche.
    while i < mid {
        a[k] = buf[i];
        i += 1;
        k += 1;
    }

    // Éléments restants à droite.
    while j < n {
        a[k] = buf[j];
        j += 1;
        k += 1;
    }
}

fn merge_sort(a: &mut [i32], buf: &mut [i32]) {
    merge_sort_buf(a, buf);
}

// ============================================================
// Heap Sort
// ============================================================

fn heapify(a: &mut [i32], length: usize, initial_i: usize) {
    let mut i = initial_i;

    loop {
        let left = 2 * i + 1;
        let right = left + 1;

        let mut largest = i;

        if left < length && a[left] > a[largest] {
            largest = left;
        }

        if right < length && a[right] > a[largest] {
            largest = right;
        }

        if largest == i {
            return;
        }

        a.swap(i, largest);
        i = largest;
    }
}

fn heap_sort(a: &mut [i32]) {
    let n = a.len();

    if n < 2 {
        return;
    }

    // Construction du tas.
    for i in (0..n / 2).rev() {
        heapify(a, n, i);
    }

    // Extraction successive du maximum.
    for end in (1..n).rev() {
        a.swap(0, end);
        heapify(a, end, 0);
    }
}

// ============================================================
// Description des algorithmes
// ============================================================

#[derive(Clone, Copy)]
enum SortAlgorithm {
    ICantBelieveItCanSort,
    SelectionSort,
    InsertionSort,
    ShellSort,
    MergeSort,
    HeapSort,
    QuickSort,
}

struct Sorter {
    name: &'static str,
    algorithm: SortAlgorithm,
    quadratic: bool,
}

fn run_sort(
    algorithm: SortAlgorithm,
    a: &mut [i32],
    merge_buf: &mut [i32],
) {
    match algorithm {
        SortAlgorithm::ICantBelieveItCanSort =>
            i_cant_believe_it_can_sort(a),

        SortAlgorithm::SelectionSort =>
            selection_sort(a),

        SortAlgorithm::InsertionSort =>
            insertion_sort(a),

        SortAlgorithm::ShellSort =>
            shell_sort(a),

        SortAlgorithm::MergeSort =>
            merge_sort(a, merge_buf),

        SortAlgorithm::HeapSort =>
            heap_sort(a),

        SortAlgorithm::QuickSort =>
            quick_sort(a),
    }
}

// ============================================================
// Génération pseudo-aléatoire
// ============================================================
//
// Petit générateur xorshift64 :
// pas besoin d'une crate externe.
// ============================================================

struct XorShift64 {
    state: u64,
}

impl XorShift64 {
    fn new(seed: u64) -> Self {
        Self {
            state: if seed == 0 {
                0x9E3779B97F4A7C15
            } else {
                seed
            },
        }
    }

    #[inline]
    fn next_u64(&mut self) -> u64 {
        let mut x = self.state;

        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;

        self.state = x;
        x
    }

    #[inline]
    fn gen_range(&mut self, max: i32) -> i32 {
        (self.next_u64() % max as u64) as i32 + 1
    }
}

// ============================================================
// Main
// ============================================================

fn main() {
    // --------------------------------------------------------
    // Génération du tableau initial
    // --------------------------------------------------------

    let mut rng = XorShift64::new(
        Instant::now().elapsed().as_nanos() as u64
    );

    let mut arr = Vec::with_capacity(NUM_ELEMS);

    for _ in 0..NUM_ELEMS {
        arr.push(rng.gen_range(NUM_ELEMS as i32));
    }

    // --------------------------------------------------------
    // Tableau de référence
    // --------------------------------------------------------

    let mut reference = arr.clone();

    let start = Instant::now();
    reference.sort_unstable();
    let reference_ms = start.elapsed().as_millis();

    println!();
    println!("Sorting {} elements\n", NUM_ELEMS);

    println!(
        "{:<28} {:>8} ms  OK",
        "Reference (std::sort)",
        reference_ms
    );

    // --------------------------------------------------------
    // Liste des algorithmes
    // --------------------------------------------------------

    let sorters = [
        Sorter {
            name: "I Can't Believe It Can Sort",
            algorithm: SortAlgorithm::ICantBelieveItCanSort,
            quadratic: true,
        },
        Sorter {
            name: "Selection Sort",
            algorithm: SortAlgorithm::SelectionSort,
            quadratic: true,
        },
        Sorter {
            name: "Insertion Sort",
            algorithm: SortAlgorithm::InsertionSort,
            quadratic: true,
        },
        Sorter {
            name: "Shell Sort",
            algorithm: SortAlgorithm::ShellSort,
            quadratic: false,
        },
        Sorter {
            name: "Merge Sort",
            algorithm: SortAlgorithm::MergeSort,
            quadratic: false,
        },
        Sorter {
            name: "Heap Sort",
            algorithm: SortAlgorithm::HeapSort,
            quadratic: false,
        },
        Sorter {
            name: "QuickSort",
            algorithm: SortAlgorithm::QuickSort,
            quadratic: false,
        },
    ];

    // --------------------------------------------------------
    // Tableau de travail + buffer Merge Sort
    // --------------------------------------------------------

    let mut work = vec![0i32; NUM_ELEMS];
    let mut merge_buf = vec![0i32; NUM_ELEMS];

    // --------------------------------------------------------
    // Benchmarks
    // --------------------------------------------------------

    for sorter in &sorters {
        if sorter.quadratic && NUM_ELEMS > QUADRATIC_LIMIT {
            println!(
                "{:<28} SKIPPED (quadratic)",
                sorter.name
            );

            continue;
        }

        // Même entrée pour chaque algorithme.
        work.copy_from_slice(&arr);

        let start = Instant::now();

        run_sort(
            sorter.algorithm,
            &mut work,
            &mut merge_buf,
        );

        let elapsed_ms = start.elapsed().as_millis();

        let correct = work == reference;

        println!(
            "{:<28} {:>8} ms  {}",
            sorter.name,
            elapsed_ms,
            if correct { "OK" } else { "ERREUR" }
        );
    }

    println!();
}
