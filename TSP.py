"""
Assignment 2 Question 1
CS 486 W17
Sarah Fraser
20458408
"""

import sys
import math
import random

# Globals
num_cities = 0
cities = {}
min_state = None
min_cost = None

# Classes
class City:

    def __init__(self, id, x_val, y_val):
        self.id = id
        self.x_val = x_val
        self.y_val = y_val
        self.successors = {}

    def get_successors(self):
        return self.successors

    def get_x(self):
        return self.x_val

    def get_y(self):
        return self.y_val

    def get_id(self):
        return self.id

    def get_distance(self, successor):
        if successor in self.successors:
            return self.successors[successor]
        else:
            return None

    def is_successor(self, successor):
        return successor in self.successors

    def add_successors(self):
        global cities
        tmp_list = cities.keys()
        tmp_list.sort()
        for s in tmp_list:
            cost = cities[s].get_distance(self.id)
            if cost is not None:
                self.successors[s] = cost
            else:
                self.successors[s] = euclidean_distance(self.x_val, self.y_val, cities[s].get_x(), cities[s].get_y())


# Helper Functions
# Distance between two points
def euclidean_distance(x_1, y_1, x_2, y_2):
    sq_x = (float(x_1) - float(x_2)) ** 2
    sq_y = (float(y_1) - float(y_2)) ** 2
    sum = sq_x + sq_y
    return math.sqrt(sum)


# Initialize the city map from a file
def init_map(filename):
    # Get data form the file

    global num_cities
    global cities

    lines = open(filename, "r").readlines()

    num_cities = int(lines[0])

    for line in lines[1:]:
        line_arr = line.split()
        cities[line_arr[0]] = City(line_arr[0], line_arr[1], line_arr[2])

    for city in cities:
        cities[city].add_successors()


# Local Search Operator
def switch_two(state):
    # Choose two random cities (except the starting city A)
    global num_cities

    # If there are only two cities, you cannot "switch" them
    if len(state) == 2:
        return state

    #start = random.randint(1, num_cities-2)
    #end = random.randint(start+1, num_cities-1) + 1

    new_state = state[:]
    #new_state[start:end] = reversed(new_state[start:end])

    pos1 = random.randint(1, num_cities-1)
    pos2 = random.randint(1, num_cities-1)

    while pos1 == pos2:
        pos1 = random.randint(1, num_cities - 1)
        pos2 = random.randint(1, num_cities - 1)

    # Switch Cities
    new_state[pos1], new_state[pos2] = new_state[pos2], new_state[pos1]
    return new_state


# Get the cost of a given tour/walk
def get_walk_cost(state):

    total_cost = 0

    for index,city in enumerate(state[:-1]):
        # Get the cost from the current city to the next one
        cost = cities[city].get_distance(state[index+1])
        total_cost += cost

    # Add the cost from the last city back to city A
    total_cost += cities[state[-1]].get_distance('A')

    return total_cost


# Determine the probability of choosing to a given state
def prob_val(old_state, new_state, t):
    if new_state < old_state:
        return 1.0
    else:
        diff_v = old_state - new_state
        prob = math.exp(diff_v/t)
        if prob > 1:
            print("PROB IS TOO BIG: " + str(prob) + " diff_v: " + str(diff_v) + " t: " + str(t))
            exit()
        return prob


# Annealing Schedule Function
def get_temp(curr_temp):
    temp_schedule = 0.999
    return curr_temp * temp_schedule


# MAIN
init_map(sys.argv[1])

# Start with a random state
# - Get cities & shuffle their order
# - always start with A though
init_state = cities.keys()
init_cost = get_walk_cost(init_state)
random.shuffle(init_state)
init_state.insert(0, init_state.pop(init_state.index('A')))

# Set beginning variables
current_state = init_state
current_cost = init_cost
temp = 15.0
min_state = init_state
min_cost = init_cost

# While the temperature is above zero and we have more than one city...
while temp > 1.0 and num_cities > 1:
    # Pick new state
    new_state = switch_two(current_state)

    # Get the cost of the new walk state
    new_state_cost = get_walk_cost(new_state)

    # Get temp val
    temp = get_temp(temp)

    if new_state_cost < current_cost:
        # Accept as new state
        current_state = new_state
        current_cost = new_state_cost
        min_state = new_state
        min_cost = new_state_cost
    elif prob_val(current_cost, new_state_cost, temp) >= random.uniform(0.0, 1.0):
        # Accept as new state by a certain percentage
        current_state = new_state
        current_cost = new_state_cost

    print(str(temp) + "," + str(current_cost))

if min_cost < current_cost:
    #print(min_state)
    print(min_cost)
else:
    #print(current_state)
    print(current_cost)















