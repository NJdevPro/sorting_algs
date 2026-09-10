const std = @import("std");

const num_elems: usize = 2_500_000;
const quadratic_limit: usize = 50_000;
const insertion_cutoff: usize = 12;

// ============================================================
// Utilitaires
// ============================================================

fn swap(a: []i32, i: usize, j: usize) void {
    const tmp = a[i];
    a[i] = a[j];
    a[j] = tmp;
}

// ============================================================
// I Can't Believe It Can Sort
// ============================================================
//
// Algorithme volontairement absurde : on parcourt le tableau
// et, dès qu'une inversion est trouvée, on recommence depuis
// le début.
//
// Cela reste quadratique dans le pire cas et sert ici
// essentiellement d'algorithme "joke".
// ============================================================

fn i_cant_believe_it_can_sort(a: []i32) void {
    if (a.len < 2) return;

    var sorted = false;

    while (!sorted) {
        sorted = true;

        var i: usize = 1;
        while (i < a.len) : (i += 1) {
            if (a[i - 1] > a[i]) {
                swap(a, i - 1, i);
                sorted = false;
                break;
            }
        }
    }
}

// ============================================================
// Selection Sort
// ============================================================

fn selection_sort(a: []i32) void {
    if (a.len < 2) return;

    var i: usize = 0;

    while (i + 1 < a.len) : (i += 1) {
        var min_index = i;

        var j = i + 1;
        while (j < a.len) : (j += 1) {
            if (a[j] < a[min_index]) {
                min_index = j;
            }
        }

        if (min_index != i) {
            swap(a, i, min_index);
        }
    }
}

// ============================================================
// Insertion Sort
// ============================================================

fn insertion_sort(a: []i32) void {
    if (a.len < 2) return;

    var i: usize = 1;

    while (i < a.len) : (i += 1) {
        const value = a[i];
        var j = i;
        while (j > 0 and a[j - 1] > value) : (j -= 1) {
            a[j] = a[j - 1];
        }
        a[j] = value;
    }
}

// ============================================================
// Shell Sort
// ============================================================

fn shell_sort(a: []i32) void {
    const n = a.len;

    if (n < 2)
        return;

    var gap = n / 2;

    while (gap > 0) {
        var i = gap;
        while (i < n) : (i += 1) {
            const temp = a[i];
            var j = i;
            while (j >= gap and a[j - gap] > temp) {
                a[j] = a[j - gap];
                j -= gap;
            }
            a[j] = temp;
        }

        // Force la passe finale avec gap = 1.
        if (gap == 1)
            break;

        const next_gap_f =
            @as(f64, @floatFromInt(gap - 1)) / 2.25;

        const next_gap =
            @as(usize, @intFromFloat(next_gap_f));

        gap = if (next_gap < 1) 1 else next_gap;
    }
}

// ============================================================
// Quick Sort
// ============================================================

fn median_of_three(a: i32, b: i32, c: i32) i32 {
    if (a < b) {
        if (b < c) return b;
        if (a < c) return c;
        return a;
    } else {
        if (a < c) return a;
        if (b < c) return c;
        return b;
    }
}

fn partition(a: []i32, low: usize, high: usize) usize {
    const mid = low + (high - low) / 2;
    const pivot = median_of_three(a[low], a[mid], a[high]);

    var i = low;
    var j = high;

    while (true) {
        while (a[i] < pivot) {
            i += 1;
        }
        while (a[j] > pivot) {
            j -= 1;
        }
        if (i >= j) {
            return j;
        }
        swap(a, i, j);
        i += 1;

        // Évite un éventuel underflow de usize.
        if (j == 0) {
            return 0;
        }
        j -= 1;
    }
}

fn quick_sort_range(a: []i32, initial_low: usize, initial_high: usize) void {
    var low = initial_low;
    var high = initial_high;

    while (low < high) {
        const p = partition(a, low, high);

        // On trie récursivement la plus petite partition
        // afin de limiter la profondeur de récursion.
        const left_size = if (p >= low) p - low + 1 else 0;
        const right_size = if (high > p) high - p else 0;

        if (left_size < right_size) {
            if (p > low) {
                quick_sort_range(a, low, p);
            }
            if (p + 1 > high) {
                return;
            }
            low = p + 1;
        } else {
            if (p + 1 < high) {
                quick_sort_range(a, p + 1, high);
            }
            if (p == 0) {
                return;
            }
            high = p;
        }
    }
}

fn quick_sort(a: []i32) void {
    if (a.len < 2) return;

    quick_sort_range(a, 0, a.len - 1);
}

// ============================================================
// Merge Sort
// ============================================================
//
// Le buffer est de taille n.
//
// À chaque niveau de récursion :
//   1. les deux moitiés sont déjà triées ;
//   2. on copie l'ensemble dans buf ;
//   3. on fusionne buf[0..mid] et buf[mid..n] vers a.
//
// Cette organisation évite tout problème lié au partage
// du buffer entre les appels récursifs.
// ============================================================

fn merge_sort_buf(a: []i32, buf: []i32) void {
    const n = a.len;

    if (n <= 1) return;

    if (n <= insertion_cutoff) {
        insertion_sort(a);
        return;
    }

    const mid = n / 2;

    // Tri des deux moitiés.
    merge_sort_buf(a[0..mid], buf);
    merge_sort_buf(a[mid..], buf);

    // Si les deux parties sont déjà dans le bon ordre,
    // aucune fusion n'est nécessaire.
    if (a[mid - 1] <= a[mid]) {
        return;
    }

    // Copie de toute la séquence dans le buffer.
    @memcpy(buf[0..n], a);

    var i: usize = 0;
    var j: usize = mid;
    var k: usize = 0;

    // Fusion des deux moitiés.
    while (i < mid and j < n) {
        if (buf[i] <= buf[j]) {
            a[k] = buf[i];
            i += 1;
        } else {
            a[k] = buf[j];
            j += 1;
        }

        k += 1;
    }

    // Éléments restants de la moitié gauche.
    while (i < mid) : (i += 1) {
        a[k] = buf[i];
        k += 1;
    }

    // Éléments restants de la moitié droite.
    while (j < n) : (j += 1) {
        a[k] = buf[j];
        k += 1;
    }
}

fn merge_sort(a: []i32, buf: []i32) void {
    merge_sort_buf(a, buf);
}

// ============================================================
// Heap Sort
// ============================================================

fn heapify(a: []i32, length: usize, initial_i: usize) void {
    var i = initial_i;

    while (true) {
        const left = 2 * i + 1;
        const right = left + 1;

        var largest = i;

        if (left < length and a[left] > a[largest]) {
            largest = left;
        }

        if (right < length and a[right] > a[largest]) {
            largest = right;
        }

        if (largest == i) {
            return;
        }

        swap(a, i, largest);
        i = largest;
    }
}

fn heap_sort(a: []i32) void {
    const n = a.len;

    if (n < 2) return;

    // Construction du tas.
    var i = n / 2;

    while (i > 0) {
        i -= 1;
        heapify(a, n, i);
    }

    // Extraction successive du maximum.
    var end = n;

    while (end > 1) {
        end -= 1;

        swap(a, 0, end);
        heapify(a, end, 0);
    }
}

// ============================================================
// Description des algorithmes
// ============================================================

const SortAlgorithm = enum {
    i_cant_believe_it_can_sort,
    selection_sort,
    insertion_sort,
    shell_sort,
    merge_sort,
    heap_sort,
    quick_sort,
};

const Sorter = struct {
    name: []const u8,
    algorithm: SortAlgorithm,
    quadratic: bool,
};

fn run_sort(
    algorithm: SortAlgorithm,
    a: []i32,
    merge_buf: []i32,
) void {
    switch (algorithm) {
        .i_cant_believe_it_can_sort =>
            i_cant_believe_it_can_sort(a),

        .selection_sort =>
            selection_sort(a),

        .insertion_sort =>
            insertion_sort(a),

        .shell_sort =>
            shell_sort(a),

        .merge_sort =>
            merge_sort(a, merge_buf),

        .heap_sort =>
            heap_sort(a),

        .quick_sort =>
            quick_sort(a),
    }
}

// ============================================================
// Main
// ============================================================

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    // --------------------------------------------------------
    // Génération du tableau initial
    // --------------------------------------------------------

    const arr = try allocator.alloc(i32, num_elems);
    defer allocator.free(arr);

    var prng = std.Random.DefaultPrng.init(
        @as(u64, @intCast(std.time.nanoTimestamp())),
    );

    const random = prng.random();

    for (arr) |*value| {
        value.* = random.intRangeAtMost(
            i32,
            1,
            @as(i32, @intCast(num_elems)),
        );
    }

    // --------------------------------------------------------
    // Tableau de référence
    // --------------------------------------------------------

    const reference = try allocator.alloc(i32, num_elems);
    defer allocator.free(reference);

    @memcpy(reference, arr);

    var timer = try std.time.Timer.start();

    std.mem.sortUnstable(
        i32,
        reference,
        {},
        std.sort.asc(i32),
    );

    const reference_ms = timer.read() / std.time.ns_per_ms;

    std.debug.print(
        "\nSorting {} elements\n\n",
        .{num_elems},
    );

    std.debug.print(
        "{s:<28} {:>8} ms  {s}\n",
        .{
            "Reference (std.sort)",
            reference_ms,
            "OK",
        },
    );

    // --------------------------------------------------------
    // Liste des algorithmes
    // --------------------------------------------------------

    const sorters = [_]Sorter{
        .{
            .name = "I Can't Believe It Can Sort",
            .algorithm = .i_cant_believe_it_can_sort,
            .quadratic = true,
        },
        .{
            .name = "Selection Sort",
            .algorithm = .selection_sort,
            .quadratic = true,
        },
        .{
            .name = "Insertion Sort",
            .algorithm = .insertion_sort,
            .quadratic = true,
        },
        .{
            .name = "Shell Sort",
            .algorithm = .shell_sort,
            .quadratic = false,
        },
        .{
            .name = "Merge Sort",
            .algorithm = .merge_sort,
            .quadratic = false,
        },
        .{
            .name = "Heap Sort",
            .algorithm = .heap_sort,
            .quadratic = false,
        },
        .{
            .name = "QuickSort",
            .algorithm = .quick_sort,
            .quadratic = false,
        },
    };

    // --------------------------------------------------------
    // Tableau de travail
    // --------------------------------------------------------

    const work = try allocator.alloc(i32, num_elems);
    defer allocator.free(work);

    // Buffer de Merge Sort.
    //
    // IMPORTANT :
    // Il fait maintenant n éléments et non n/2.
    //
    const merge_buf = try allocator.alloc(i32, num_elems);
    defer allocator.free(merge_buf);

    // --------------------------------------------------------
    // Benchmarks
    // --------------------------------------------------------

    for (sorters) |sorter| {
        if (sorter.quadratic and num_elems > quadratic_limit) {
            std.debug.print(
                "{s:<28} {s}\n",
                .{
                    sorter.name,
                    "SKIPPED (quadratic)",
                },
            );

            continue;
        }

        // Restaurer exactement le même tableau initial
        // pour chaque algorithme.
        @memcpy(work, arr);

        timer.reset();

        run_sort(
            sorter.algorithm,
            work,
            merge_buf,
        );

        const elapsed_ms =
            timer.read() / std.time.ns_per_ms;

        const correct =
            std.mem.eql(i32, work, reference);

        if (correct) {
            std.debug.print(
                "{s:<28} {:>8} ms  OK\n",
                .{
                    sorter.name,
                    elapsed_ms,
                },
            );
        } else {
            std.debug.print(
                "{s:<28} {:>8} ms  ERREUR\n",
                .{
                    sorter.name,
                    elapsed_ms,
                },
            );
        }
    }

    std.debug.print("\n", .{});
}
