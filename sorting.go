package main

import (
	"fmt"
	"math/rand/v2"
	"slices"
	"time"
)

const (
	numElems = 2_000_000

	// Au-delà de cette taille, les tris en O(n²) prendraient des heures.
	quadraticLimit = 50_000
	// Sous ce seuil, le tri par insertion est plus rapide que la fusion.
	insertionCutoff = 12
)

func swap(a []int, i, j int) {
	a[i], a[j] = a[j], a[i]
}

func iCantBelieveItCanSort(a []int) {
	for i := 1; i < len(a); i++ {
		for j := 0; j < i; j++ {
			if a[i] < a[j] {
				swap(a, i, j)
			}
		}
	}
}

func selectionSort(a []int) {
	n := len(a)
	for i := 0; i < n-1; i++ {
		minIndex := i
		for j := i + 1; j < n; j++ {
			if a[j] < a[minIndex] {
				minIndex = j
			}
		}
		swap(a, i, minIndex)
	}
}

func insertionSort(a []int) {
	for i := 1; i < len(a); i++ {
		key := a[i]
		j := i - 1
		for j >= 0 && a[j] > key {
			a[j+1] = a[j]
			j--
		}
		a[j+1] = key
	}
}

// Correction : l'ancienne suite d'écarts pouvait passer de 2 ou 3 directement
// à 0, sans jamais faire la passe finale avec un écart de 1 (tableau mal trié
// pour n = 4 à 7, 12 à 19, 30 à 47...). On force désormais cette dernière passe.
func shellSort(a []int) {
	n := len(a)
	for gap := n / 2; gap > 0; {
		for i := gap; i < n; i++ {
			temp := a[i]
			j := i
			for j >= gap && a[j-gap] > temp {
				a[j] = a[j-gap]
				j -= gap
			}
			a[j] = temp
		}
		if gap == 1 {
			break
		}
		gap = max(1, int(float64(gap-1)/2.25))
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

func partition(a []int, low, high int) int {
	mid := low + (high-low)/2
	pivot := medianOfThree(a[low], a[mid], a[high])
	i := low - 1
	j := high + 1
	for {
		for {
			i++
			if a[i] >= pivot {
				break
			}
		}
		for {
			j--
			if a[j] <= pivot {
				break
			}
		}
		if i >= j {
			return j
		}
		swap(a, i, j)
	}
}

func quickSort(a []int) {
	if len(a) > 1 {
		quickSortRange(a, 0, len(a)-1)
	}
}

func quickSortRange(a []int, low, high int) {
	for low < high {
		pi := partition(a, low, high)
		if pi-low < high-pi {
			// Trie récursivement la plus petite partie
			quickSortRange(a, low, pi)
			// Optimisation de la récursion terminale
			low = pi + 1
		} else {
			quickSortRange(a, pi+1, high)
			high = pi
		}
	}
}

// Allocations : un seul buffer de n/2 éléments pour tout le tri, au lieu de
// deux slices à chaque appel récursif (~2 millions d'allocations et ~164 Mo
// alloués pour 1M d'éléments dans la version d'origine).
func mergeSort(a []int) {
	if len(a) < 2 {
		return
	}
	buf := make([]int, len(a)/2)
	mergeSortBuf(a, buf)
}

func mergeSortBuf(a, buf []int) {
	n := len(a)
	if n <= insertionCutoff {
		insertionSort(a)
		return
	}
	mid := n / 2
	mergeSortBuf(a[:mid], buf)
	mergeSortBuf(a[mid:], buf)
	if a[mid-1] <= a[mid] {
		return // les deux moitiés sont déjà dans l'ordre
	}
	// On ne copie que la moitié gauche : l'écriture en k ne rattrape jamais
	// la lecture en j, donc la moitié droite peut être lue sur place.
	left := buf[:mid]
	copy(left, a[:mid])
	i, j, k := 0, mid, 0
	for i < mid && j < n {
		if left[i] <= a[j] {
			a[k] = left[i]
			i++
		} else {
			a[k] = a[j]
			j++
		}
		k++ // correction : l'original oubliait cet incrément dans une boucle
	}
	// Les éléments restants à droite sont déjà à leur place finale.
	copy(a[k:], left[i:])
}

// Version itérative : une boucle au lieu d'un appel récursif par niveau du tas.
func heapify(a []int, length, i int) {
	for {
		largest := i
		left, right := 2*i+1, 2*i+2
		if left < length && a[left] > a[largest] {
			largest = left
		}
		if right < length && a[right] > a[largest] {
			largest = right
		}
		if largest == i {
			return
		}
		swap(a, i, largest)
		i = largest
	}
}

func heapSort(a []int) {
	n := len(a)
	// Construction du tas
	for i := n/2 - 1; i >= 0; i-- {
		heapify(a, n, i)
	}
	// Extraction des éléments
	for i := n - 1; i > 0; i-- {
		swap(a, 0, i)
		heapify(a, i, 0)
	}
}

type sorter struct {
	name      string
	fn        func([]int)
	quadratic bool
}

func main() {
	// Plus besoin de rand.Seed (obsolète) : math/rand/v2 est initialisé automatiquement.
	arr := make([]int, numElems)
	for i := range arr {
		arr[i] = rand.IntN(numElems) + 1
	}
	
	// Référence : le tri de la bibliothèque standard, qui sert aussi à vérifier
	// chaque résultat (valeurs identiques, pas seulement ordre croissant).
	ref := slices.Clone(arr)
	start := time.Now()
	slices.Sort(ref)
	fmt.Printf("%-24s %6d ms\n", "slices.Sort (stdlib)", time.Since(start).Milliseconds())
	
	sorters := []sorter{
		{"iCantBelieveItCanSort", iCantBelieveItCanSort, true},
		{"Selection Sort", selectionSort, true},
		{"Insertion Sort", insertionSort, true},
		{"Shell Sort", shellSort, false},
		{"Merge Sort", mergeSort, false},
		{"Heap Sort", heapSort, false},
		{"QuickSort", quickSort, false},
	}
	
	// Un seul buffer de travail réutilisé, au lieu d'une copie allouée par tri.
	work := make([]int, numElems)
	for _, s := range sorters {
		if s.quadratic && numElems > quadraticLimit {
			fmt.Printf("%-24s ignoré (O(n²) avec n > %d)\n", s.name, quadraticLimit)
			continue
		}
		copy(work, arr)
		start := time.Now()
		s.fn(work)
		elapsed := time.Since(start)
		status := "OK"
		if !slices.Equal(work, ref) {
			status = "ERREUR"
		}
		fmt.Printf("%-24s %6d ms  %s\n", s.name, elapsed.Milliseconds(), status)
	}
}
