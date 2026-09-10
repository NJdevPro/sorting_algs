use std::time::{Instant, SystemTime, UNIX_EPOCH};

fn in_order(arr: &[i32]) -> bool {
    let n = arr.len();
    for i in 0..n.saturating_sub(1) {
        if arr[i + 1] < arr[i] {
            return false;
        }
    }
    true
}

fn print_array(arr: &[i32]) {
    for v in arr {
        print!("{} ", v);
    }
    println!();
}

#[allow(dead_code)]
fn i_cant_believe_it_can_sort(arr: &mut [i32]) {
    let n = arr.len();
    for i in 1..n {
        for j in 0..i {
            if arr[i] < arr[j] {
                arr.swap(i, j);
            }
        }
    }
    println!("{}", in_order(arr));
    // print_array(arr);
}

fn selection_sort(arr: &mut [i32]) {
    let n = arr.len();
    for i in 0..n {
        let mut min_index = i;
        for j in (i + 1)..n {
            if arr[j] < arr[min_index] {
                min_index = j;
            }
        }
        arr.swap(i, min_index);
    }
    println!("{}", in_order(arr));
}

fn insertion_sort(arr: &mut [i32]) {
    let n = arr.len();
    for i in 1..n {
        let key = arr[i];
        let mut j = i;
        while j > 0 && arr[j - 1] > key {
            arr[j] = arr[j - 1];
            j -= 1;
        }
        arr[j] = key;
    }
}

fn shell_sort(arr: &mut [i32]) {
    let n = arr.len();
    let mut gap = n / 2;
    while gap > 0 {
        for i in gap..n {
            let temp = arr[i];
            let mut j = i;
            while j >= gap && arr[j - gap] > temp {
                arr[j] = arr[j - gap];
                j -= gap;
            }
            arr[j] = temp;
        }
        gap = ((gap - 1) as f64 / 2.25) as usize;
    }
}

fn median_of_three(a: i32, b: i32, c: i32) -> i32 {
    if (a <= b && b <= c) || (c <= b && b <= a) {
        b
    } else if (b <= a && a <= c) || (c <= a && a <= b) {
        a
    } else {
        c
    }
}

fn partition(vec: &mut [i32], low: isize, high: isize) -> isize {
    let mid = low + (high - low) / 2;
    let pivot = median_of_three(vec[low as usize], vec[mid as usize], vec[high as usize]);
    let mut i = low - 1;
    let mut j = high + 1;
    loop {
        i += 1;
        while vec[i as usize] < pivot {
            i += 1;
        }
        j -= 1;
        while vec[j as usize] > pivot {
            j -= 1;
        }
        if i >= j {
            return j;
        }
        vec.swap(i as usize, j as usize);
    }
}

fn quick_sort(vec: &mut [i32], low_in: isize, high_in: isize) {
    let mut low = low_in;
    let mut high = high_in;
    while low < high {
        let pi = partition(vec, low, high);
        if pi - low < high - pi {
            quick_sort(vec, low, pi); // trie récursivement la partie la plus petite
            low = pi + 1; // optimisation en récursion terminale
        } else {
            quick_sort(vec, pi + 1, high); // trie récursivement la partie la plus grande
            high = pi; // optimisation en récursion terminale
        }
    }
}

// Fusionne a[0..mid] et a[mid..] en utilisant `buf` (de même taille que `a`)
// comme mémoire de travail. `buf` est réutilisé par tous les niveaux de
// récursion : un seul tableau auxiliaire est alloué, une seule fois, dans
// merge_sort ci-dessous.
fn merge_using(a: &mut [i32], buf: &mut [i32], mid: usize) {
    buf.copy_from_slice(a);
    let (left, right) = buf.split_at(mid);
    let mut i = 0;
    let mut j = 0;
    let mut k = 0;
    while i < left.len() && j < right.len() {
        if left[i] <= right[j] {
            a[k] = left[i];
            i += 1;
        } else {
            a[k] = right[j];
            j += 1;
        }
        k += 1;
    }
    while i < left.len() {
        a[k] = left[i];
        i += 1;
        k += 1;
    }
    while j < right.len() {
        a[k] = right[j];
        j += 1;
        k += 1;
    }
}

fn merge_sort_with_buf(a: &mut [i32], buf: &mut [i32]) {
    let n = a.len();
    if n < 2 {
        return;
    }
    let mid = n / 2;
    let (a_left, a_right) = a.split_at_mut(mid);
    let (buf_left, buf_right) = buf.split_at_mut(mid);
    merge_sort_with_buf(a_left, buf_left);
    merge_sort_with_buf(a_right, buf_right);
    merge_using(a, buf, mid);
}

fn merge_sort(a: &mut [i32], n: usize) {
    if n < 2 {
        return;
    }
    let mut buf = vec![0i32; n];
    merge_sort_with_buf(&mut a[0..n], &mut buf);
}

fn heapify(array: &mut [i32], length: usize, i: usize) {
    let left = 2 * i + 1;
    let right = 2 * i + 2;
    let mut largest = i;
    if left < length && array[left] > array[largest] {
        largest = left;
    }
    if right < length && array[right] > array[largest] {
        largest = right;
    }
    if largest != i {
        array.swap(i, largest);
        heapify(array, length, largest);
    }
}

fn heap_sort(array: &mut [i32]) {
    if array.is_empty() {
        return;
    }
    let length = array.len();

    // Part du premier élément qui n'est pas une feuille, en remontant vers la racine.
    for i in (0..length / 2).rev() {
        heapify(array, length, i);
    }

    for i in (0..length).rev() {
        array.swap(0, i);
        heapify(array, i, 0);
    }
}

/// Petit xorshift64* : évite de dépendre de la crate `rand` pour un simple
/// tableau d'entiers aléatoires dans ce benchmark.
struct Xorshift64 {
    state: u64,
}

impl Xorshift64 {
    fn new(seed: u64) -> Self {
        Xorshift64 {
            state: if seed == 0 {
                0x9E37_79B9_7F4A_7C15
            } else {
                seed
            },
        }
    }

    fn next_u64(&mut self) -> u64 {
        let mut x = self.state;
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        self.state = x;
        x
    }

    /// Entier aléatoire dans [low, high] inclus (équivalent à
    /// `rand.nextInt(bound) + 1` pour low = 1).
    fn next_range_inclusive(&mut self, low: i32, high: i32) -> i32 {
        let span = (high - low + 1) as u64;
        low + (self.next_u64() % span) as i32
    }
}

fn random_seed() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_nanos() as u64
}

fn main() {
    const NUM_NUM: usize = 1000_000;

    let mut rng = Xorshift64::new(random_seed());
    let arr: Vec<i32> = (0..NUM_NUM)
        .map(|_| rng.next_range_inclusive(1, NUM_NUM as i32))
        .collect();

    let start = Instant::now();
    // let mut a = arr.clone();
    // i_cant_believe_it_can_sort(&mut a);
    let i_cant_believe_it_can_sort_time = start.elapsed();

    let start = Instant::now();
    // let mut a = arr.clone();
    // selection_sort(&mut a);
    let selection_sort_time = start.elapsed();

    let start = Instant::now();
    // let mut a = arr.clone();
    // insertion_sort(&mut a);
    let insertion_sort_time = start.elapsed();

    let start = Instant::now();
    {
        let mut a = arr.clone();
        shell_sort(&mut a);
    }
    let shell_sort_time = start.elapsed();

    let start = Instant::now();
    {
        let mut a = arr.clone();
        let n = a.len();
        merge_sort(&mut a, n);
    }
    let merge_sort_time = start.elapsed();

    let start = Instant::now();
    {
        let mut a = arr.clone();
        heap_sort(&mut a);
    }
    let heap_sort_time = start.elapsed();

    let start = Instant::now();
    {
        let mut a = arr.clone();
        let high = (a.len() as isize) - 1;
        quick_sort(&mut a, 0, high);
    }
    let quick_sort_time = start.elapsed();

    println!(
        "iCantBelieveItcan Sort time (ms): {}",
        i_cant_believe_it_can_sort_time.as_millis()
    );
    println!(
        "Selection Sort time (ms): {}",
        selection_sort_time.as_millis()
    );
    println!(
        "Insertion Sort time (ms): {}",
        insertion_sort_time.as_millis()
    );
    println!("Shell Sort time (ms)    : {}", shell_sort_time.as_millis());
    println!("mergeSort Sort time (ms): {}", merge_sort_time.as_millis());
    println!("heapSort Sort time (ms): {}", heap_sort_time.as_millis());
    println!("Quicksort Sort time (ms): {}", quick_sort_time.as_millis());
}
