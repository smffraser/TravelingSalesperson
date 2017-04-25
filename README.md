# TravelingSalesperson

A TSP (Traveling Salesperson) problem solved two ways, one using A\* Search and the other using Simulated Annealing. 

Created for CS486 (AI) Assignment 1 & 2 (Winter 2017, Kate Larson, University of Waterloo). 

The A\* Search algorithm uses a heuristic function that tries to get a smaller approximation of the path cost to get from the current state’s current city to city A after going through all the other cities. For example, if there are 7 cities (A, B, C, D, E, F, G) and the current state is { B, [A, C, D] } then the heuristic function will provide a smaller approximation of the cost to go from city B, travel to cities E, F, G and back to A.

The Simulated Annealing algorithm uses a local search operator that takes a valid tour and switches the order of two random cities in the tour (excluding the start city A).

Both alogorithms use euclidean distance as the actual cost between cities. 

**To Run:**

    $tsp.rb randTSP/<problem_set #>/<instance #>.txt
