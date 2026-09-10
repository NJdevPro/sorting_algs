//
// Rename this file into Main.java
//

import java.util.Random;

public class Main {

    private static void swap(int[] arr, int i, int j){
        int temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }

    public static void selectionSort(int[] arr) {
        int n = arr.length;
        for (int i = 0; i < n; i++) {
            int minIndex = i;
            for (int j = i + 1; j < n; j++) {
                if (arr[j] < arr[minIndex]) {
                    minIndex = j;
                }
            }
            swap(arr, i, minIndex);
        }
    }

    public static void insertionSort(int[] arr) {
        int n = arr.length;
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

    public static void  shellSort(int arr[]) {
        int n = arr.length;
        for (int gap = n/2; gap > 0; gap /= 2) {
            for (int i = gap; i < n; i += 1) {
                int temp = arr[i];
                int j = i;
                for (; j >= gap && arr[j - gap] > temp; j -= gap)
                    arr[j] = arr[j - gap];
                arr[j] = temp;
            }
        }
    }

    private static int partition(int[] vec, int low, int high) {
        int mid = low + (high - low) / 2;
        int pivot = medianOfThree(vec[low], vec[mid], vec[high]);
        int i = low - 1, j = high + 1;

        while (true) {
            do i++; while (vec[i] < pivot);
            do j--; while (vec[j] > pivot);
            if (i >= j) return j;
            swap(vec, i, j);
        }
    }

    private static int medianOfThree(int a, int b, int c) {
        if ((a <= b && b <= c) || (c <= b && b <= a)) return b;
        if ((b <= a && a <= c) || (c <= a && a <= b)) return a;
        return c;
    }

    public static void quickSort(int[] vec, int low, int high) {
        while (low < high) {
            int pi = partition(vec, low, high);
            if (pi - low < high - pi) {
                quickSort(vec, low, pi); // Recursively sort the smaller part
                low = pi + 1; // Tail-recursive optimization
            } else {
                quickSort(vec, pi + 1, high); // Recursively sort the larger part
                high = pi; // Tail-recursive optimization
            }
        }
    }

    public static void mergeSort(int[] a, int n) {
        if (n < 2)  return;

        int mid = n / 2;
        int[] l = new int[mid];
        int[] r = new int[n - mid];

        for (int i = 0; i < mid; i++) l[i] = a[i];
        for (int i = mid; i < n; i++) r[i - mid] = a[i];
        mergeSort(l, mid);
        mergeSort(r, n - mid);
        merge(a, l, r, mid, n - mid);
    }

    private static void merge(int[] a, int[] l, int[] r, int left, int right) {
        int i = 0, j = 0, k = 0;
        while (i < left && j < right) {
            if (l[i] <= r[j]) a[k++] = l[i++];
            else a[k++] = r[j++];
        }
        while (i < left) a[k++] = l[i++];
        while (j < right) {a[k++] = r[j++];}
    }

    private static void heapify(int[] array, int length, int i) {
        int left = 2 * i + 1;
        int right = 2 * i + 2;
        int largest = i;
        if (left < length && array[left] > array[largest]) 
            largest = left;
        if (right < length && array[right] > array[largest]) 
            largest = right;
        if (largest != i) {
            swap(array, i, largest);
            heapify(array, length, largest);
        }
    }

    public static void heapSort(int[] array) {
        if (array.length == 0) return;
        int length = array.length;
        
        // Moving from the first element that isn't a leaf towards the root
        for (int i = length / 2 - 1; i >= 0; i--) {
            heapify(array, length, i);
        }
        
        for (int i = length - 1; i >= 0; i--) {
            swap(array, 0, i);
            heapify(array, i, 0);
        }
    }

    static void printArray(int arr[], int n) {
        for (int i = 0; i < n; ++i)
        System.out.print(arr[i] + " ");
        System.out.println();
    }

    public static void main(String[] args) {
        
        int NUM_NUM = 100_000;
        int[] arr = new int[NUM_NUM];
        int[] ord = new int[NUM_NUM];
        Random rand = new Random();
        for (int i = 0; i < NUM_NUM; i++) {
            arr[i] = rand.nextInt(NUM_NUM) + 1;
            ord[i] = i;
        }

        long startTime = System.nanoTime();
        selectionSort(arr.clone());
        long selectionSortTime = System.nanoTime() - startTime;

        startTime = System.nanoTime();
        insertionSort(arr.clone());
        long insertionSortTime = System.nanoTime() - startTime;

        startTime = System.nanoTime();
        shellSort(arr.clone());
        long shellSortTime = System.nanoTime() - startTime;

        startTime = System.nanoTime();
        mergeSort(arr.clone(),arr.length);
        long mergeSortTime = System.nanoTime() - startTime;

        startTime = System.nanoTime();
        heapSort(arr.clone());
        long heapSortTime = System.nanoTime() - startTime;

        startTime = System.nanoTime();
        quickSort(arr.clone(),0, arr.length-1);
        long quickSortTime = System.nanoTime() - startTime;
        

        System.out.println("Selection Sort time (ms): " + selectionSortTime/1000_000);
        System.out.println("Insertion Sort time (ms): " + insertionSortTime/1000_000);
        System.out.println("Shell Sort time (ms)    : " + shellSortTime/1000_000);
        System.out.println("mergeSort Sort time (ms): " + mergeSortTime/1000_000);
        System.out.println("heapSort Sort time (ms): " + heapSortTime/1000_000);
        System.out.println("Quicksort Sort time (ms): " + quickSortTime/1000_000);
    }
}
