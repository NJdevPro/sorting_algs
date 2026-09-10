import std.stdio : writeln, write;
import std.random : Random, unpredictableSeed, uniform;
import std.datetime.stopwatch : StopWatch, AutoStart;
import std.algorithm.mutation : swap;

bool inOrder(const int[] arr) {
    immutable n = arr.length;
    if (n < 2) return true;
    foreach (i; 0 .. n - 1) {
        if (arr[i + 1] < arr[i]) return false;
    }
    return true;
}

void printArray(const int[] arr) {
    foreach (v; arr) write(v, " ");
    writeln();
}

void iCantBelieveItCanSort(int[] arr) {
    immutable n = arr.length;
    foreach (i; 1 .. n) {
        foreach (j; 0 .. i) {
            if (arr[i] < arr[j]) swap(arr[i], arr[j]);
        }
    }
    writeln(inOrder(arr));
    // printArray(arr);
}

void selectionSort(int[] arr) {
    immutable n = arr.length;
    foreach (i; 0 .. n) {
        size_t minIndex = i;
        foreach (j; i + 1 .. n) {
            if (arr[j] < arr[minIndex]) minIndex = j;
        }
        swap(arr[i], arr[minIndex]);
    }
    writeln(inOrder(arr));
}

void insertionSort(int[] arr) {
    immutable n = arr.length;
    foreach (i; 1 .. n) {
        immutable key = arr[i];
        size_t j = i;
        while (j > 0 && arr[j - 1] > key) {
            arr[j] = arr[j - 1];
            j--;
        }
        arr[j] = key;
    }
}

void shellSort(int[] arr) {
    immutable n = arr.length;
    size_t gap = n / 2;
    while (gap > 0) {
        foreach (i; gap .. n) {
            immutable temp = arr[i];
            size_t j = i;
            while (j >= gap && arr[j - gap] > temp) {
                arr[j] = arr[j - gap];
                j -= gap;
            }
            arr[j] = temp;
        }
        gap = cast(size_t)((gap - 1) / 2.25);
    }
    // writeln(inOrder(arr));
}

int medianOfThree(int a, int b, int c) {
    if ((a <= b && b <= c) || (c <= b && b <= a)) return b;
    if ((b <= a && a <= c) || (c <= a && a <= b)) return a;
    return c;
}

ptrdiff_t partition(int[] vec, ptrdiff_t low, ptrdiff_t high) {
    immutable mid = low + (high - low) / 2;
    immutable pivot = medianOfThree(vec[low], vec[mid], vec[high]);
    ptrdiff_t i = low - 1;
    ptrdiff_t j = high + 1;
    while (true) {
        i++;
        while (vec[i] < pivot) i++;
        j--;
        while (vec[j] > pivot) j--;
        if (i >= j) return j;
        swap(vec[i], vec[j]);
    }
}

void quickSort(int[] vec, ptrdiff_t lowIn, ptrdiff_t highIn) {
    ptrdiff_t low = lowIn;
    ptrdiff_t high = highIn;
    while (low < high) {
        immutable pi = partition(vec, low, high);
        if (pi - low < high - pi) {
            quickSort(vec, low, pi); // recursively sort the smaller part
            low = pi + 1; // tail-recursive optimization
        } else {
            quickSort(vec, pi + 1, high); // recursively sort the larger part
            high = pi; // tail-recursive optimization
        }
    }
}

// Merges a[0 .. mid] and a[mid .. $] using `buf` (same length as `a`) as
// scratch space. `buf` is reused by every recursion level: mergeSort below
// allocates a single auxiliary array, once.
private void mergeUsing(int[] a, int[] buf, size_t mid) {
    buf[] = a[];
    auto left = buf[0 .. mid];
    auto right = buf[mid .. $];
    size_t i = 0, j = 0, k = 0;
    while (i < left.length && j < right.length) {
        if (left[i] <= right[j]) {
            a[k] = left[i];
            i++;
        } else {
            a[k] = right[j];
            j++;
        }
        k++;
    }
    while (i < left.length) {
        a[k] = left[i];
        i++;
        k++;
    }
    while (j < right.length) {
        a[k] = right[j];
        j++;
        k++;
    }
}

private void mergeSortWithBuf(int[] a, int[] buf) {
    immutable n = a.length;
    if (n < 2) return;
    immutable mid = n / 2;
    mergeSortWithBuf(a[0 .. mid], buf[0 .. mid]);
    mergeSortWithBuf(a[mid .. n], buf[mid .. n]);
    mergeUsing(a, buf, mid);
}

void mergeSort(int[] a, size_t n) {
    if (n < 2) return;
    auto buf = new int[](n);
    mergeSortWithBuf(a[0 .. n], buf);
}

void heapify(int[] array, size_t length, size_t i) {
    immutable left = 2 * i + 1;
    immutable right = 2 * i + 2;
    size_t largest = i;
    if (left < length && array[left] > array[largest])
        largest = left;
    if (right < length && array[right] > array[largest])
        largest = right;
    if (largest != i) {
        swap(array[i], array[largest]);
        heapify(array, length, largest);
    }
}

void heapSort(int[] array) {
    if (array.length == 0) return;
    immutable length = array.length;

    // Start from the first non-leaf element, moving toward the root.
    for (size_t i = length / 2; i-- > 0;)
        heapify(array, length, i);

    for (size_t i = length; i-- > 0;) {
        swap(array[0], array[i]);
        heapify(array, i, 0);
    }
}

void main() {
    enum size_t NUM_NUM = 1_000_000;

    auto rnd = Random(unpredictableSeed);
    auto arr = new int[](NUM_NUM);
    foreach (i; 0 .. NUM_NUM) {
        arr[i] = uniform(1, cast(int) NUM_NUM + 1, rnd);
    }

    auto sw = StopWatch(AutoStart.yes);
    // iCantBelieveItCanSort(arr.dup);
    immutable iCantBelieveItCanSortTime = sw.peek();

    sw = StopWatch(AutoStart.yes);
    // selectionSort(arr.dup);
    immutable selectionSortTime = sw.peek();

    sw = StopWatch(AutoStart.yes);
    // insertionSort(arr.dup);
    immutable insertionSortTime = sw.peek();

    sw = StopWatch(AutoStart.yes);
    shellSort(arr.dup);
    immutable shellSortTime = sw.peek();

    sw = StopWatch(AutoStart.yes);
    {
        auto a = arr.dup;
        mergeSort(a, a.length);
    }
    immutable mergeSortTime = sw.peek();

    sw = StopWatch(AutoStart.yes);
    heapSort(arr.dup);
    immutable heapSortTime = sw.peek();

    sw = StopWatch(AutoStart.yes);
    {
        auto a = arr.dup;
        quickSort(a, 0, cast(ptrdiff_t) a.length - 1);
    }
    immutable quickSortTime = sw.peek();

    writeln("iCantBelieveItcan Sort time (ms): ", iCantBelieveItCanSortTime.total!"msecs");
    writeln("Selection Sort time (ms): ", selectionSortTime.total!"msecs");
    writeln("Insertion Sort time (ms): ", insertionSortTime.total!"msecs");
    writeln("Shell Sort time (ms)    : ", shellSortTime.total!"msecs");
    writeln("mergeSort Sort time (ms): ", mergeSortTime.total!"msecs");
    writeln("heapSort Sort time (ms): ", heapSortTime.total!"msecs");
    writeln("Quicksort Sort time (ms): ", quickSortTime.total!"msecs");
}
