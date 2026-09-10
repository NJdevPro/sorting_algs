#include <iostream>
#include <vector>
#include <random>
#include <chrono>
#include <algorithm>

using namespace std;

class SortingAlgorithms {

private:

    static void swap(vector<int>& arr, int i, int j) {
        int temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }

public:

    static void iCantBelieveItCanSort(vector<int>& arr) {
        int n = arr.size();

        for (int i = 1; i < n; i++) {
            for (int j = 0; j < i; j++) {
                if (arr[i] < arr[j])
                    swap(arr, i, j);
            }
        }

        cout << boolalpha << inOrder(arr) << endl;
    }

    static void selectionSort(vector<int>& arr) {
        int n = arr.size();

        for (int i = 0; i < n; i++) {
            int minIndex = i;

            for (int j = i + 1; j < n; j++) {
                if (arr[j] < arr[minIndex]) {
                    minIndex = j;
                }
            }

            swap(arr, i, minIndex);
        }

        cout << boolalpha << inOrder(arr) << endl;
    }

    static void insertionSort(vector<int>& arr) {
        int n = arr.size();

        for (int i = 1; i < n; i++) {
            int key = arr[i];
            int j = i - 1;

            while (j >= 0 && arr[j] > key) {
                arr[j + 1] = arr[j];
                j--;
            }

            arr[j + 1] = key;
        }
    }

    static void shellSort(vector<int>& arr) {
        int n = arr.size();

        for (int gap = n / 2;
             gap > 0;
             gap = static_cast<int>((gap - 1) / 2.25)) {

            for (int i = gap; i < n; i++) {
                int temp = arr[i];
                int j = i;

                for (; j >= gap && arr[j - gap] > temp; j -= gap)
                    arr[j] = arr[j - gap];

                arr[j] = temp;
            }
        }
    }

private:

    static int partition(vector<int>& vec, int low, int high) {
        int mid = low + (high - low) / 2;

        int pivot = medianOfThree(
            vec[low],
            vec[mid],
            vec[high]
        );

        int i = low - 1;
        int j = high + 1;

        while (true) {

            do {
                i++;
            } while (vec[i] < pivot);

            do {
                j--;
            } while (vec[j] > pivot);

            if (i >= j)
                return j;

            swap(vec, i, j);
        }
    }

    static int medianOfThree(int a, int b, int c) {
        if ((a <= b && b <= c) ||
            (c <= b && b <= a))
            return b;

        if ((b <= a && a <= c) ||
            (c <= a && a <= b))
            return a;

        return c;
    }

public:

    static void quickSort(vector<int>& vec, int low, int high) {

        while (low < high) {

            int pi = partition(vec, low, high);

            if (pi - low < high - pi) {

                // Sortie récursive de la plus petite partie
                quickSort(vec, low, pi);

                // Optimisation de la récursion terminale
                low = pi + 1;

            } else {

                // Sortie récursive de la plus grande partie
                quickSort(vec, pi + 1, high);

                // Optimisation de la récursion terminale
                high = pi;
            }
        }
    }

    static void mergeSort(vector<int>& a, int n) {

        if (n < 2)
            return;

        int mid = n / 2;

        vector<int> l(mid);
        vector<int> r(n - mid);

        for (int i = 0; i < mid; i++)
            l[i] = a[i];

        for (int i = mid; i < n; i++)
            r[i - mid] = a[i];

        mergeSort(l, mid);
        mergeSort(r, n - mid);

        merge(a, l, r, mid, n - mid);
    }

private:

    static void merge(
        vector<int>& a,
        vector<int>& l,
        vector<int>& r,
        int left,
        int right
    ) {
        int i = 0;
        int j = 0;
        int k = 0;

        while (i < left && j < right) {

            if (l[i] <= r[j])
                a[k++] = l[i++];
            else
                a[k++] = r[j++];
        }

        while (i < left)
            a[k++] = l[i++];

        while (j < right)
            a[k++] = r[j++];
    }

    static void heapify(
        vector<int>& array,
        int length,
        int i
    ) {
        int left = 2 * i + 1;
        int right = 2 * i + 2;
        int largest = i;

        if (left < length &&
            array[left] > array[largest])
            largest = left;

        if (right < length &&
            array[right] > array[largest])
            largest = right;

        if (largest != i) {
            swap(array, i, largest);
            heapify(array, length, largest);
        }
    }

public:

    static void heapSort(vector<int>& array) {

        if (array.empty())
            return;

        int length = array.size();

        // Construction du tas
        for (int i = length / 2 - 1; i >= 0; i--) {
            heapify(array, length, i);
        }

        // Extraction des éléments du tas
        for (int i = length - 1; i >= 0; i--) {
            swap(array, 0, i);
            heapify(array, i, 0);
        }
    }

    static void printArray(
        const vector<int>& arr,
        int n
    ) {
        for (int i = 0; i < n; ++i)
            cout << arr[i] << " ";

        cout << endl;
    }

    static bool inOrder(const vector<int>& arr) {

        int n = arr.size();

        for (int i = 0; i < n - 1; ++i) {
            if (arr[i + 1] < arr[i])
                return false;
        }

        return true;
    }
};


int main() {

    const int NUM_NUM = 1'000'000;

    vector<int> arr(NUM_NUM);
    vector<int> ord(NUM_NUM);

    // Générateur aléatoire
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<int> distribution(1, NUM_NUM);

    for (int i = 0; i < NUM_NUM; i++) {
        arr[i] = distribution(gen);
        ord[i] = i;
    }

    using namespace chrono;

    // iCantBelieveItCanSort
    auto startTime = high_resolution_clock::now();

    // SortingAlgorithms::iCantBelieveItCanSort(arr);

    auto endTime = high_resolution_clock::now();

    auto iCantBelieveItCanSortTime =
        duration_cast<nanoseconds>(
            endTime - startTime
        ).count();


    // Selection Sort
    startTime = high_resolution_clock::now();

    // SortingAlgorithms::selectionSort(arr);

    endTime = high_resolution_clock::now();

    auto selectionSortTime =
        duration_cast<nanoseconds>(
            endTime - startTime
        ).count();


    // Insertion Sort
    startTime = high_resolution_clock::now();

    // SortingAlgorithms::insertionSort(arr);

    endTime = high_resolution_clock::now();

    auto insertionSortTime =
        duration_cast<nanoseconds>(
            endTime - startTime
        ).count();


    // Shell Sort
    startTime = high_resolution_clock::now();

    vector<int> shellArray = arr;
    SortingAlgorithms::shellSort(shellArray);

    endTime = high_resolution_clock::now();

    auto shellSortTime =
        duration_cast<nanoseconds>(
            endTime - startTime
        ).count();


    // Merge Sort
    startTime = high_resolution_clock::now();

    vector<int> mergeArray = arr;
    SortingAlgorithms::mergeSort(
        mergeArray,
        mergeArray.size()
    );

    endTime = high_resolution_clock::now();

    auto mergeSortTime =
        duration_cast<nanoseconds>(
            endTime - startTime
        ).count();


    // Heap Sort
    startTime = high_resolution_clock::now();

    vector<int> heapArray = arr;
    SortingAlgorithms::heapSort(heapArray);

    endTime = high_resolution_clock::now();

    auto heapSortTime =
        duration_cast<nanoseconds>(
            endTime - startTime
        ).count();


    // Quick Sort
    startTime = high_resolution_clock::now();

    vector<int> quickArray = arr;
    SortingAlgorithms::quickSort(
        quickArray,
        0,
        quickArray.size() - 1
    );

    endTime = high_resolution_clock::now();

    auto quickSortTime =
        duration_cast<nanoseconds>(
            endTime - startTime
        ).count();


    // Affichage des temps
    cout << "iCantBelieveItCanSort time (ms): "
         << iCantBelieveItCanSortTime / 1'000'000
         << endl;

    cout << "Selection Sort time (ms): "
         << selectionSortTime / 1'000'000
         << endl;

    cout << "Insertion Sort time (ms): "
         << insertionSortTime / 1'000'000
         << endl;

    cout << "Shell Sort time (ms)    : "
         << shellSortTime / 1'000'000
         << endl;

    cout << "Merge Sort time (ms)    : "
         << mergeSortTime / 1'000'000
         << endl;

    cout << "Heap Sort time (ms)     : "
         << heapSortTime / 1'000'000
         << endl;

    cout << "QuickSort time (ms)     : "
         << quickSortTime / 1'000'000
         << endl;

    return 0;
}
