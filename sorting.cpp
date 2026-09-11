#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <random>
#include <vector>

constexpr std::size_t numElems = 2'000'000;

// Au-delà de cette taille, les tris en O(n²) prendraient des heures.
constexpr std::size_t quadraticLimit = 50'000;

// Sous ce seuil, le tri par insertion est plus rapide que la fusion.
constexpr std::size_t insertionCutoff = 12;


// ------------------------------------------------------------
// Utilitaires
// ------------------------------------------------------------

void swapElements(std::vector<int>& a,
                  std::size_t i,
                  std::size_t j)
{
    std::swap(a[i], a[j]);
}


// ------------------------------------------------------------
// I Can't Believe It Can Sort
// ------------------------------------------------------------

void iCantBelieveItCanSort(std::vector<int>& a)
{
    for (std::size_t i = 1; i < a.size(); ++i) {
        for (std::size_t j = 0; j < i; ++j) {
            if (a[i] < a[j]) {
                swapElements(a, i, j);
            }
        }
    }
}


// ------------------------------------------------------------
// Selection Sort
// ------------------------------------------------------------

void selectionSort(std::vector<int>& a)
{
    const std::size_t n = a.size();
    if (n < 2)
        return;
    for (std::size_t i = 0; i < n - 1; ++i) {
        std::size_t minIndex = i;
        for (std::size_t j = i + 1; j < n; ++j) {
            if (a[j] < a[minIndex]) {
                minIndex = j;
            }
        }
        swapElements(a, i, minIndex);
    }
}


// ------------------------------------------------------------
// Insertion Sort
// ------------------------------------------------------------

void insertionSort(std::vector<int>& a)
{
    for (std::size_t i = 1; i < a.size(); ++i) {
        const int key = a[i];
        std::size_t j = i;
        while (j > 0 && a[j - 1] > key) {
            a[j] = a[j - 1];
            --j;
        }
        a[j] = key;
    }
}


// ------------------------------------------------------------
// Shell Sort
// ------------------------------------------------------------

void shellSort(std::vector<int>& a)
{
    const std::size_t n = a.size();
    if (n < 2)
        return;
    std::size_t gap = n / 2;
    while (gap > 0) {
        for (std::size_t i = gap; i < n; ++i) {
            const int temp = a[i];
            std::size_t j = i;
            while (j >= gap && a[j - gap] > temp) {
                a[j] = a[j - gap];
                j -= gap;
            }
            a[j] = temp;
        }

        // Force la dernière passe avec gap = 1.
        if (gap == 1)
            break;
      
        const double newGap = static_cast<double>(gap - 1) / 2.25;
        gap = std::max<std::size_t>(1, static_cast<std::size_t>(newGap)
        );
    }
}


// ------------------------------------------------------------
// Median of Three
// ------------------------------------------------------------

int medianOfThree(int a, int b, int c)
{
    if ((a <= b && b <= c) || (c <= b && b <= a)) {
        return b;
    }
    if ((b <= a && a <= c) || (c <= a && a <= b)) {
        return a;
    }
    return c;
}


// ------------------------------------------------------------
// QuickSort : partition
// ------------------------------------------------------------

std::size_t partition(std::vector<int>& a,
                      std::size_t low,
                      std::size_t high)
{
    const std::size_t mid = low + (high - low) / 2;
    const int pivot = medianOfThree(a[low], a[mid], a[high]);

    // On utilise des indices signés parce que
    // l'algorithme commence à low - 1 et high + 1.
    std::int64_t i = static_cast<std::int64_t>(low) - 1;
    std::int64_t j = static_cast<std::int64_t>(high) + 1;

    while (true) {
        do {
            ++i;
        } while (a[static_cast<std::size_t>(i)] < pivot);

        do {
            --j;
        } while (a[static_cast<std::size_t>(j)] > pivot);

        if (i >= j) {
            return static_cast<std::size_t>(j);
        }

        swapElements(
            a,
            static_cast<std::size_t>(i),
            static_cast<std::size_t>(j)
        );
    }
}


// ------------------------------------------------------------
// QuickSort
// ------------------------------------------------------------

void quickSortRange(std::vector<int>& a,
                    std::size_t initialLow,
                    std::size_t initialHigh)
{
    std::size_t low = initialLow;
    std::size_t high = initialHigh;

    while (low < high) {
        const std::size_t pi = partition(a, low, high);

        // Trie récursivement la plus petite partie.
        // Cela limite la profondeur de récursion.
        if (pi - low < high - pi) {
            quickSortRange(a, low, pi);
            // Optimisation de la récursion terminale :
            // on continue directement avec la grande partie.
            low = pi + 1;
        } else {
            quickSortRange(a, pi + 1, high);
            high = pi;
        }
    }
}


void quickSort(std::vector<int>& a)
{
    if (a.size() > 1) {
        quickSortRange(a, 0, a.size() - 1);
    }
}


// ------------------------------------------------------------
// Merge Sort
// ------------------------------------------------------------
//
// Le buffer contient seulement n/2 éléments.
// Il est alloué UNE SEULE FOIS et réutilisé pendant
// toute la récursion.
//
// Comme dans la version Go, on ne copie que la moitié
// gauche lors de la fusion.
// ------------------------------------------------------------

void mergeSortBuf(std::vector<int>& a,
                  std::vector<int>& buf,
                  std::size_t begin,
                  std::size_t end)
{
    const std::size_t n = end - begin;

    // Pour les petits tableaux :
    // insertion sort est plus rapide.
    if (n <= insertionCutoff) {
        for (std::size_t i = begin + 1; i < end; ++i) {
            const int key = a[i];
            std::size_t j = i;
            while (j > begin && a[j - 1] > key) {
                a[j] = a[j - 1];
                --j;
            }
            a[j] = key;
        }
        return;
    }

    const std::size_t mid = begin + n / 2;

    // Tri des deux moitiés.
    mergeSortBuf(a, buf, begin, mid);
    mergeSortBuf(a, buf, mid, end);

    // Optimisation :
    // les deux moitiés sont déjà dans le bon ordre.
    if (a[mid - 1] <= a[mid]) {
        return;
    }

    // --------------------------------------------------------
    // Copie de la moitié gauche dans le buffer.
    // --------------------------------------------------------
    const std::size_t leftSize = mid - begin;
    std::copy(
        a.begin() + begin,
        a.begin() + mid,
        buf.begin()
    );

    // --------------------------------------------------------
    // Fusion.
    // --------------------------------------------------------
    std::size_t i = 0;       // buffer / moitié gauche
    std::size_t j = mid;     // moitié droite
    std::size_t k = begin;   // destination

    while (i < leftSize && j < end) {
        if (buf[i] <= a[j]) {
            a[k] = buf[i];
            ++i;
        } else {
            a[k] = a[j];
            ++j;
        }
        ++k;
    }

    // Les éléments restants de la moitié gauche
    // doivent être copiés.
    //
    // Ceux de la moitié droite n'ont pas besoin de l'être :
    // ils sont déjà à leur position finale.
    std::copy(buf.begin() + i, buf.begin() + leftSize, a.begin() + k);
}


void mergeSort(std::vector<int>& a)
{
    if (a.size() < 2)
        return;
    // Un seul buffer de n/2 éléments.
    std::vector<int> buf(a.size() / 2);
    mergeSortBuf(a, buf, 0, a.size());
}


// ------------------------------------------------------------
// Heap Sort
// ------------------------------------------------------------

void heapify(std::vector<int>& a,
             std::size_t length,
             std::size_t initialI)
{
    std::size_t i = initialI;
    while (true) {
        std::size_t largest = i;
        const std::size_t left = 2 * i + 1;
        const std::size_t right = 2 * i + 2;

        if (left < length &&
            a[left] > a[largest]) {
            largest = left;
        }
        if (right < length &&
            a[right] > a[largest]) {
            largest = right;
        }
        if (largest == i) {
            return;
        }
        swapElements(a, i, largest);
        i = largest;
    }
}


void heapSort(std::vector<int>& a)
{
    const std::size_t n = a.size();
    if (n < 2)
        return;

    // Construction du tas.
    for (std::size_t i = n / 2; i > 0; --i) {
        heapify(a, n, i - 1);
    }

    // Extraction des éléments.
    for (std::size_t i = n - 1; i > 0; --i) {
        swapElements(a, 0, i);
        heapify(a, i, 0);
    }
}


// ------------------------------------------------------------
// Sorter
// ------------------------------------------------------------

struct Sorter
{
    const char* name;
    void (*fn)(std::vector<int>&);
    bool quadratic;
};


// ------------------------------------------------------------
// Main
// ------------------------------------------------------------

int main()
{
    // --------------------------------------------------------
    // Génération des données.
    // --------------------------------------------------------

    std::random_device rd;
    std::mt19937 rng(rd());

    std::uniform_int_distribution<int> distribution(
        1,
        static_cast<int>(numElems)
    );

    std::vector<int> arr(numElems);

    for (int& x : arr) {
        x = distribution(rng);
    }


    // --------------------------------------------------------
    // Référence : std::sort
    // --------------------------------------------------------

    std::vector<int> ref = arr;
    auto start = std::chrono::steady_clock::now();
    std::sort(ref.begin(), ref.end());

    auto elapsed =
        std::chrono::duration_cast<
            std::chrono::milliseconds
        >(
            std::chrono::steady_clock::now() - start
        ).count();

    std::printf(
        "%-24s %6lld ms\n",
        "std::sort (stdlib)",
        static_cast<long long>(elapsed)
    );


    // --------------------------------------------------------
    // Liste des algorithmes.
    // --------------------------------------------------------

    const Sorter sorters[] = {
        {
            "iCantBelieveItCanSort",
            iCantBelieveItCanSort,
            true
        },
        {
            "Selection Sort",
            selectionSort,
            true
        },
        {
            "Insertion Sort",
            insertionSort,
            true
        },
        {
            "Shell Sort",
            shellSort,
            false
        },
        {
            "Merge Sort",
            mergeSort,
            false
        },
        {
            "Heap Sort",
            heapSort,
            false
        },
        {
            "QuickSort",
            quickSort,
            false
        }
    };


    // --------------------------------------------------------
    // Tableau de travail réutilisé.
    // --------------------------------------------------------
    std::vector<int> work(numElems);


    // --------------------------------------------------------
    // Benchmark.
    // --------------------------------------------------------
    for (const Sorter& s : sorters) {
        if (s.quadratic &&
            numElems > quadraticLimit) {
            std::printf(
                "%-24s ignoré (O(n²) avec n > %zu)\n",
                s.name,
                quadraticLimit
            );
            continue;
        }

        // Même entrée pour chaque algorithme.
        work = arr;
        start = std::chrono::steady_clock::now();

        s.fn(work);

        elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::steady_clock::now() - start
            ).count();


        // Vérification complète : mêmes valeurs ET même ordre.
        const bool correct = (work == ref);
        std::printf(
            "%-24s %6lld ms  %s\n",
            s.name,
            static_cast<long long>(elapsed),
            correct ? "OK" : "ERREUR"
        );
    }

    return 0;
}
