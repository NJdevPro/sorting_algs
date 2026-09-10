package main

import (
	"fmt"
	"math/rand"
	"time"
)

func swap(arr []int, i, j int) {
	temp := arr[i]
	arr[i] = arr[j]
	arr[j] = temp
}

func iCantBelieveItCanSort(arr []int) {
	n := len(arr)

	for i := 1; i < n; i++ {
		for j := 0; j < i; j++ {
			if arr[i] < arr[j] {
				swap(arr, i, j)
			}
		}
	}

	fmt.Println(inOrder(arr))
}

func selectionSort(arr []int) {
	n := len(arr)

	for i := 0; i < n; i++ {
		minIndex := i

		for j := i + 1; j < n; j++ {
			if arr[j] < arr[minIndex] {
				minIndex = j
			}
		}

		swap(arr, i, minIndex)
	}

	fmt.Println(inOrder(arr))
}

func insertionSort(arr []int) {
	n := len(arr)

	for i := 1; i < n; i++ {
		key := arr[i]
		j := i - 1

		for j >= 0 && arr[j] > key {
			arr[j+1] = arr[j]
			j--
		}

		arr[j+1] = key
	}
}

func shellSort(arr []int) {
	n := len(arr)

	for gap := n / 2; gap > 0; gap = int(float64(gap-1) / 2.25) {

		for i := gap; i < n; i++ {
			temp := arr[i]
			j := i

			for j >= gap && arr[j-gap] > temp {
				arr[j] = arr[j-gap]
				j -= gap
			}

			arr[j] = temp
		}
	}
}

func medianOfThree(a, b, c int) int {
	if (a <= b && b <= c) || (c <= b && b <= a) {
		return b
	}

	if (b <= a && a <= c) || (c <= a && a <= b) {
		return a
	}

	return c
}

func partition(vec []int, low, high int) int {
	mid := low + (high-low)/2

	pivot := medianOfThree(
		vec[low],
		vec[mid],
		vec[high],
	)

	i := low - 1
	j := high + 1

	for {
		for {
			i++
			if vec[i] >= pivot {
				break
			}
		}

		for {
			j--
			if vec[j] <= pivot {
				break
			}
		}

		if i >= j {
			return j
		}

		swap(vec, i, j)
	}
}

func quickSort(vec []int, low, high int) {
	for low < high {
		pi := partition(vec, low, high)

		if pi-low < high-pi {
			// Trie récursivement la plus petite partie
			quickSort(vec, low, pi)

			// Optimisation de la récursion terminale
			low = pi + 1
		} else {
			// Trie récursivement la plus grande partie
			quickSort(vec, pi+1, high)

			// Optimisation de la récursion terminale
			high = pi
		}
	}
}

func mergeSort(a []int, n int) {
	if n < 2 {
		return
	}

	mid := n / 2

	l := make([]int, mid)
	r := make([]int, n-mid)

	for i := 0; i < mid; i++ {
		l[i] = a[i]
	}

	for i := mid; i < n; i++ {
		r[i-mid] = a[i]
	}

	mergeSort(l, mid)
	mergeSort(r, n-mid)

	merge(a, l, r, mid, n-mid)
}

func merge(a, l, r []int, left, right int) {
	i := 0
	j := 0
	k := 0

	for i < left && j < right {
		if l[i] <= r[j] {
			a[k] = l[i]
			i++
		} else {
			a[k] = r[j]
			j++
		}

		k++
	}

	for i < left {
		a[k] = l[i]
		i++
		k++
	}

	for j < right {
		a[k] = r[j]
		j++
	}
}

func heapify(array []int, length, i int) {
	left := 2*i + 1
	right := 2*i + 2
	largest := i

	if left < length && array[left] > array[largest] {
		largest = left
	}

	if right < length && array[right] > array[largest] {
		largest = right
	}

	if largest != i {
		swap(array, i, largest)
		heapify(array, length, largest)
	}
}

func heapSort(array []int) {
	if len(array) == 0 {
		return
	}

	length := len(array)

	// Construction du tas
	for i := length/2 - 1; i >= 0; i-- {
		heapify(array, length, i)
	}

	// Extraction des éléments
	for i := length - 1; i >= 0; i-- {
		swap(array, 0, i)
		heapify(array, i, 0)
	}
}

func printArray(arr []int, n int) {
	for i := 0; i < n; i++ {
		fmt.Print(arr[i], " ")
	}

	fmt.Println()
}

func inOrder(arr []int) bool {
	n := len(arr)

	for i := 0; i < n-1; i++ {
		if arr[i+1] < arr[i] {
			return false
		}
	}

	return true
}

func main() {

	const NUM_NUM = 1_000_000

	arr := make([]int, NUM_NUM)
	ord := make([]int, NUM_NUM)

	// Générateur aléatoire
	rand.Seed(time.Now().UnixNano())

	for i := 0; i < NUM_NUM; i++ {
		arr[i] = rand.Intn(NUM_NUM) + 1
		ord[i] = i
	}

	// iCantBelieveItCanSort
	startTime := time.Now()
	// iCantBelieveItCanSort(append([]int(nil), arr...))
	iCantBelieveItCanSortTime := time.Since(startTime)


	// Selection Sort
	startTime = time.Now()
	// selectionSort(append([]int(nil), arr...))
	selectionSortTime := time.Since(startTime)


	// Insertion Sort
	startTime = time.Now()
	// insertionSort(append([]int(nil), arr...))
	insertionSortTime := time.Since(startTime)


	// Shell Sort
	shellArray := append([]int(nil), arr...)
	startTime = time.Now()
	shellSort(shellArray)
	shellSortTime := time.Since(startTime)


	// Merge Sort
	mergeArray := append([]int(nil), arr...)
	startTime = time.Now()
	mergeSort(mergeArray, len(mergeArray))
	mergeSortTime := time.Since(startTime)


	// Heap Sort
	heapArray := append([]int(nil), arr...)
	startTime = time.Now()
	heapSort(heapArray)
	heapSortTime := time.Since(startTime)


	// Quick Sort
	quickArray := append([]int(nil), arr...)
	startTime = time.Now()
	quickSort(quickArray, 0, len(quickArray)-1)
	quickSortTime := time.Since(startTime)


	// Affichage des temps
	fmt.Println(
		"iCantBelieveItCanSort time (ms):",
		iCantBelieveItCanSortTime.Milliseconds(),
	)

	fmt.Println(
		"Selection Sort time (ms):",
		selectionSortTime.Milliseconds(),
	)

	fmt.Println(
		"Insertion Sort time (ms):",
		insertionSortTime.Milliseconds(),
	)

	fmt.Println(
		"Shell Sort time (ms)    :",
		shellSortTime.Milliseconds(),
	)

	fmt.Println(
		"Merge Sort time (ms)    :",
		mergeSortTime.Milliseconds(),
	)

	fmt.Println(
		"Heap Sort time (ms)     :",
		heapSortTime.Milliseconds(),
	)

	fmt.Println(
		"QuickSort time (ms)     :",
		quickSortTime.Milliseconds(),
	)

}
