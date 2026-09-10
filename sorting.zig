const std = @import("std");

fn swap(arr: []i32, i: usize, j: usize) void {
    const temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
}

fn inOrder(arr: []const i32) bool {
    const n = arr.len;
    var i: usize = 0;
    while (i < n - 1) : (i += 1) {
        if (arr[i + 1] < arr[i]) return false;
    }
    return true;
}

fn printArray(arr: []const i32) void {
    for (arr) |v| {
        std.debug.print("{d} ", .{v});
    }
    std.debug.print("\n", .{});
}

fn iCantBelieveItCanSort(arr: []i32) void {
    const n = arr.len;
    var i: usize = 1;
    while (i < n) : (i += 1) {
        var j: usize = 0;
        while (j < i) : (j += 1) {
            if (arr[i] < arr[j]) swap(arr, i, j);
        }
    }
    std.debug.print("{}\n", .{inOrder(arr)});
    // printArray(arr);
}

fn selectionSort(arr: []i32) void {
    const n = arr.len;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var minIndex = i;
        var j = i + 1;
        while (j < n) : (j += 1) {
            if (arr[j] < arr[minIndex]) minIndex = j;
        }
        swap(arr, i, minIndex);
    }
    std.debug.print("{}\n", .{inOrder(arr)});
}

fn insertionSort(arr: []i32) void {
    const n = arr.len;
    var i: usize = 1;
    while (i < n) : (i += 1) {
        const key = arr[i];
        var j: usize = i;
        while (j > 0 and arr[j - 1] > key) : (j -= 1) {
            arr[j] = arr[j - 1];
        }
        arr[j] = key;
    }
}

fn shellSort(arr: []i32) void {
    const n = arr.len;
    var gap: usize = n / 2;
    while (gap > 0) : (gap = @intFromFloat(@as(f64, @floatFromInt(gap - 1)) / 2.25)) {
        var i: usize = gap;
        while (i < n) : (i += 1) {
            const temp = arr[i];
            var j: usize = i;
            while (j >= gap and arr[j - gap] > temp) : (j -= gap) {
                arr[j] = arr[j - gap];
            }
            arr[j] = temp;
        }
    }
    // std.debug.print("{}\n", .{inOrder(arr)});
}

fn medianOfThree(a: i32, b: i32, c: i32) i32 {
    if ((a <= b and b <= c) or (c <= b and b <= a)) return b;
    if ((b <= a and a <= c) or (c <= a and a <= b)) return a;
    return c;
}

fn partition(vec: []i32, low: isize, high: isize) isize {
    const mid = low + @divTrunc(high - low, 2);
    const pivot = medianOfThree(vec[@intCast(low)], vec[@intCast(mid)], vec[@intCast(high)]);
    var i: isize = low - 1;
    var j: isize = high + 1;
    while (true) {
        i += 1;
        while (vec[@intCast(i)] < pivot) : (i += 1) {}
        j -= 1;
        while (vec[@intCast(j)] > pivot) : (j -= 1) {}
        if (i >= j) return j;
        swap(vec, @intCast(i), @intCast(j));
    }
}

fn quickSort(vec: []i32, low_in: isize, high_in: isize) void {
    var low = low_in;
    var high = high_in;
    while (low < high) {
        const pi = partition(vec, low, high);
        if (pi - low < high - pi) {
            quickSort(vec, low, pi); // trie récursivement la partie la plus petite
            low = pi + 1; // optimisation en récursion terminale
        } else {
            quickSort(vec, pi + 1, high); // trie récursivement la partie la plus grande
            high = pi; // optimisation en récursion terminale
        }
    }
}

fn merge(a: []i32, l: []const i32, r: []const i32, left: usize, right: usize) void {
    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;
    while (i < left and j < right) {
        if (l[i] <= r[j]) {
            a[k] = l[i];
            i += 1;
        } else {
            a[k] = r[j];
            j += 1;
        }
        k += 1;
    }
    while (i < left) : (i += 1) {
        a[k] = l[i];
        k += 1;
    }
    while (j < right) : (j += 1) {
        a[k] = r[j];
        k += 1;
    }
}

fn mergeSort(allocator: std.mem.Allocator, a: []i32, n: usize) !void {
    if (n < 2) return;

    const mid = n / 2;
    const l = try allocator.alloc(i32, mid);
    defer allocator.free(l);
    const r = try allocator.alloc(i32, n - mid);
    defer allocator.free(r);

    @memcpy(l, a[0..mid]);
    @memcpy(r, a[mid..n]);
    try mergeSort(allocator, l, mid);
    try mergeSort(allocator, r, n - mid);
    merge(a, l, r, mid, n - mid);
}

fn heapify(array: []i32, length: usize, i: usize) void {
    const left = 2 * i + 1;
    const right = 2 * i + 2;
    var largest = i;
    if (left < length and array[left] > array[largest])
        largest = left;
    if (right < length and array[right] > array[largest])
        largest = right;
    if (largest != i) {
        swap(array, i, largest);
        heapify(array, length, largest);
    }
}

fn heapSort(array: []i32) void {
    if (array.len == 0) return;
    const length = array.len;

    // Part du premier élément qui n'est pas une feuille, en remontant vers la racine.
    var i: usize = length / 2;
    while (i > 0) {
        i -= 1;
        heapify(array, length, i);
    }

    i = length;
    while (i > 0) {
        i -= 1;
        swap(array, 0, i);
        heapify(array, i, 0);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const NUM_NUM: usize = 1_000_000;

    var arr = try allocator.alloc(i32, NUM_NUM);
    defer allocator.free(arr);

    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    for (0..NUM_NUM) |i| {
        arr[i] = rand.intRangeAtMost(i32, 1, @intCast(NUM_NUM));
    }

    var timer = try std.time.Timer.start();

    timer.reset();
    // iCantBelieveItCanSort(try allocator.dupe(i32, arr));
    const iCantBelieveItCanSortTime = timer.read();

    timer.reset();
    // selectionSort(try allocator.dupe(i32, arr));
    const selectionSortTime = timer.read();

    timer.reset();
    // insertionSort(try allocator.dupe(i32, arr));
    const insertionSortTime = timer.read();

    timer.reset();
    {
        const clone = try allocator.dupe(i32, arr);
        defer allocator.free(clone);
        shellSort(clone);
    }
    const shellSortTime = timer.read();

    timer.reset();
    {
        const clone = try allocator.dupe(i32, arr);
        defer allocator.free(clone);
        // mergeSort alloue de nombreux petits tableaux temporaires ; une
        // arena est nettement plus rapide qu'un allocateur généraliste ici.
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        try mergeSort(arena.allocator(), clone, clone.len);
    }
    const mergeSortTime = timer.read();

    timer.reset();
    {
        const clone = try allocator.dupe(i32, arr);
        defer allocator.free(clone);
        heapSort(clone);
    }
    const heapSortTime = timer.read();

    timer.reset();
    {
        const clone = try allocator.dupe(i32, arr);
        defer allocator.free(clone);
        quickSort(clone, 0, @as(isize, @intCast(clone.len)) - 1);
    }
    const quickSortTime = timer.read();

    std.debug.print("iCantBelieveItcan Sort time (ms): {d}\n", .{iCantBelieveItCanSortTime / 1_000_000});
    std.debug.print("Selection Sort time (ms): {d}\n", .{selectionSortTime / 1_000_000});
    std.debug.print("Insertion Sort time (ms): {d}\n", .{insertionSortTime / 1_000_000});
    std.debug.print("Shell Sort time (ms)    : {d}\n", .{shellSortTime / 1_000_000});
    std.debug.print("mergeSort Sort time (ms): {d}\n", .{mergeSortTime / 1_000_000});
    std.debug.print("heapSort Sort time (ms): {d}\n", .{heapSortTime / 1_000_000});
    std.debug.print("Quicksort Sort time (ms): {d}\n", .{quickSortTime / 1_000_000});
}
