#############################################
# Assignment 1
# Question 3
# CS 486 W 17
# By Sarah Fraser
# 20458408
#############################################

# Default Ruby Gem
# 	Used to timeout the program if it takes over 10 min
require 'timeout'
# Brian Schroeder (2005) PriorityQueue (0.1.2) ruby-gem. https://rubygems.org/gems/PriorityQueue/versions/0.1.2.
# 	Used to hold a queue of items based on a given priority value
require 'priority_queue'

## Globals
$cities = {}
$num_cities = 0
$nodes_expanded = 0


## Helpers

# Calculate the euclidean_distance
# Return the value as a float
def euclidean_distance(x_1,y_1,x_2,y_2)
	sq_x = (x_1.to_f - x_2.to_f)**2
	sq_y = (y_1.to_f - y_2.to_f)**2
	sum = sq_x + sq_y
	Math.sqrt(sum)
end

## Classes

class State_Node

	def initialize(id, parent_path, parent_id)
		@id = id
		if (parent_id != nil)
			@path = parent_path + [parent_id]
		else
			@path = []
		end
		@g_val = nil
		@h_val = nil
	end

	def get_path
		return @path
	end

	def get_g_val
		return @g_val
	end

	def set_g_val(g_val)
		@g_val = g_val
	end

	def get_h_val
		return @h_val
	end

	def set_h_val(h_val)
		@h_val = h_val
	end

	def get_id
		return @id
	end

	def get_f_val
		if @g_val != nil && @h_val != nil
			return @g_val + @h_val
		else
			return nil
		end
	end
end

class City
	def initialize(id, x_val, y_val)
		@id = id
		@x_val = x_val
		@y_val = y_val
		@successors = {}
	end

	def add_successors
		tmp_list = $cities.keys.sort
		tmp_list.each do |s|
			cost = $cities[s].get_distance(@id)
			if cost != nil
				@successors[s] = cost
			else
				x1 = @x_val
				y1 = @y_val
				x2 = $cities[s].get_x
				y2 = $cities[s].get_y
				cost = euclidean_distance(@x_val,@y_val,x2,y2)
				@successors[s] = cost
			end
		end
	end

	def been_visited
		return @visited
	end

	def get_successors
		return @successors
	end

	def get_x
		return @x_val
	end

	def get_y
		return @y_val
	end

	def get_id
		return @id
	end

	def get_distance(successor)
		return @successors[successor]
	end

	def is_successor?(successor)
		return @successors.has_key?(successor)
	end

	def delete_succesor(successor)
		@successors.delete(successor)
	end
end

class MST

  def initialize(map)
    # Give the MST class the map it is working with
    # Array of unvisited cities
    @map = map

    # This queue has all of the MST city nodes
    @mst = Queue.new 

    # When a city is "visited", add to the visited hash
    @visited = Hash.new 

    # Holds the costs, ordered by minimal cost (hence why we use the priority queue)
    @cost_queue = PriorityQueue.new 

    # Total cost of the MST so far
    @total_cost = 0 

    # For each city node in the map, run Prim's ALGO (if it hasn't been visited already)
    @map.each do |city|
      prim_algo(city) if !visited?(city) # We run prim from vertex if not already visited
    end
  end

  def get_mst_cost
  	return @total_cost
  end

  def get_mst_tree
  	return @mst
  end

  def visited?(city)
    @visited.has_key?(city)
  end

  def prim_algo(city)

    # Scan the city node
    scan(city)
    until @cost_queue.empty?
      # get the next lowest cost road (edge)
      road = @cost_queue.delete_min

      # Get the road's cities
      from = road[0][0]
      to = road[0][1]

      # If both cities have been visited, then move on (aka don't add the edge)
      next if(visited?(from) && visited?(to))
      # Else, Add the road to our MST & update the MST cost
      @mst.push(road)
      @total_cost += road[1]

      # Scan the cities if they haven't been visited already
      scan(from) if !visited?(from)
      scan(to) if !visited?(to)
    end
  end

  def scan(city)

    # Check to make sure we aren't given an already visited city
    raise '[+] ERROR: City already visited: ' + city if visited?(city)

    # Mark the city as visited
    @visited[city] = true

    # For each "unvisted" neighbour in the city, add the edge to cost_queue if the joining city hasn't been visited

    @map.each do |successor|
    	# make sure we aren't checking ourselves
    	if successor != city
    		@cost_queue[[city,successor]] = $cities[city].get_distance(successor)
    	end
    end
  end
end

## Setup Functions

# Get data from file input & setup map
def init_map(filename)
	# Get data from the file
	lines = File.open(filename, "r"){ |datafile| 
   		datafile.readlines
	}
	# Record num cities
	$num_cities = lines[0].to_i
	# Record cities in a directory
	lines[1..-1].each do |line|
		line_arr = line.split
		$cities[line_arr[0]] = City.new(line_arr[0],line_arr[1],line_arr[2])
	end
	$cities.each do |city|
		city[1].add_successors()
	end
end

## A* Functions

# Check if the current state node is the goal state
# return true if so
def is_goal(node)
	if (node.get_id == "A" && node.get_path.length == $num_cities)
		return true
	else
		return false
	end
end

# Heuristic Function
def get_h_value(state)
	# 1) distance to the nearest unvisited city from the current city PLUS
	# 2) estimated distance to travel all the unvisited cities (MST value used here) PLUS
	# 3) nearest distance from an unvisited city to the start city.

	current_city = state.get_id
	# Notice this does NOT include the current node. Hence, this is how we incorporate steps 1) & 2) together
	cities_visited = state.get_path
	cities_not_visited = $cities.keys - cities_visited

	# 1) & 2) Cost to travel all univisted cities
	mst_cost = MST.new(cities_not_visited).get_mst_cost

	# 3) Nearest distance from univisted city back to A

	if cities_not_visited.empty?
		min_cost_2 = 0
	else 
		min_cost_2 = Float::INFINITY
		#min_city_2 = nil

		cities_not_visited.each do |city|
			c = $cities[city]
			if (c.get_distance("A") < min_cost_2)
				min_cost_2 = c.get_distance("A")
			end
		end
	end

	return mst_cost + min_cost_2
end


## MAIN

# Timeout after 10 min
status = Timeout::timeout(600) {
  # Setup
	init_map(ARGV[0])
	undiscov_nodes = PriorityQueue.new

	# Add "A" as the first node in the undiscovered queue
	start = State_Node.new("A",nil,nil)
	start.set_h_val(get_h_value(start))
	start.set_g_val(0)
	undiscov_nodes.push start,start.get_f_val

	# While there are nodes in the undiscovered queue...
	while !undiscov_nodes.empty?

		# Get the current state node
		current_node = undiscov_nodes.delete_min

		# Check if the state node is the goal node
		if is_goal(current_node[0])
			print current_node[0].get_path
			print "\n"
			print current_node[0].get_g_val
			print "\n"
			break
		end

		city_list = $cities.keys.sort

		cities_already_visited = (current_node[0].get_path + [current_node[0].get_id]).sort

		cities_to_visit = city_list - cities_already_visited

		# There are no more children to visit, so we go back to A
		if (cities_to_visit == [])
			cities_to_visit = ["A"]
		end

		cities_to_visit.each do |successor|
			# Create State Node
			# Figure out g val
			# Figure out h val
			# Add to priority que

			# Create new State Node
			Marshal.load(Marshal.dump(current_node[0].get_path))
			node = State_Node.new(successor,Marshal.load(Marshal.dump(current_node[0].get_path)),current_node[0].get_id)

			# Calculate the g value of this node (parents g value plus its distance from itself to the parent)
			if $DEBUG
				puts "New City"
				puts "Current node"
				puts current_node[0].get_id
				puts current_node[0].get_path
				puts "Successor Node"
				puts node.get_id
				puts node.get_path
				puts current_node[0].get_g_val
				puts $cities[node.get_id].get_distance(current_node[0].get_id)
			end

			current_g_val = current_node[0].get_g_val

			node.set_g_val(current_node[0].get_g_val + $cities[node.get_id].get_distance(current_node[0].get_id))

			# Calculate the h value of this node
			node.set_h_val(get_h_value(node))

			# Add to priority queue
			undiscov_nodes.push node,node.get_f_val
			$nodes_expanded += 1
			#puts $nodes_expanded
		end
	end

	puts "node expanded: " + $nodes_expanded.to_s
}