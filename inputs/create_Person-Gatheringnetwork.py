import os
import sys
import random

import networkx as nx
import numpy as np

def draw_powerlaw_numbers(exponent,min_value,max_value,number_of_draws):
    x_range=np.arange(min_value,max_value+1)                    # Possible degrees
    x_topower = np.power(x_range,exponent)                      # Possible degrees to exponent
    pdf_unnormalized = 1/x_topower
    pdf_normalized=pdf_unnormalized/np.sum(pdf_unnormalized)    # Normalized pdf (which is proportional to degrees to exponent)
    cdf_normalized = np.cumsum(pdf_normalized)                  # Corresponding cdf.

    random_numbers = np.random.random(number_of_draws)

    drawn_degrees = []
    for number in random_numbers : # For each random number, find out what drawn degree this corresponds to.
        try_entry = 0
        found=False
        while (found == False) :
            difference = number-cdf_normalized[try_entry]
            if (difference <= 0) :
                found = True
            else :
                try_entry +=1 

        drawn_degrees.append(min_value + try_entry)


    return drawn_degrees

def align_stub_numbers(people_degrees,gathering_degrees) :

    stub_differences = np.sum(people_degrees)-np.sum(gathering_degrees) # Positive if more stubs for people.

    if (stub_differences > 0) :
        add_edges_to = np.random.randint(0,len(gathering_degrees),size=stub_differences)

        for node in add_edges_to :
            gathering_degrees[node] += 1

    elif (stub_differences < 0) :
        add_edges_to = np.random.randint(0,len(people_degrees),size=-stub_differences)

        for node in add_edges_to :
            people_degrees[node] += 1
    return people_degrees,gathering_degrees

def bipartite_configuration_model(degrees_A,degrees_B) :
    
    
    
    # Create list of stubs
    stublist_A = []
    stublist_B = []


    for nodenumber in range (len(degrees_A)) :
        for stub in range (degrees_A[nodenumber]) :
            stublist_A.append(nodenumber) 

    offsetnumber = len(degrees_A) # nodes in group B have node IDs starting where node IDs in group A ended.
    for nodenumber in range (len(degrees_B)) :
        for stub in range (degrees_B[nodenumber]) :
            stublist_B.append(nodenumber+offsetnumber )

    # permute stubs.
    #stublist_A.shuffle()
    random.shuffle(stublist_B)

    return stublist_A,stublist_B

def save_edgelist(stublist_A,stublist_B,filename):

    f = open(filename,'w')
    f.write("Node1,Node2,Brackets")
    for edgenumber in range (len(stublist_A)) :
        f.write("\n%i,%i,{}"%(stublist_A[edgenumber],stublist_B[edgenumber]))
    f.close()

# Now draw degree sequences
n_people = 200000
n_gatherings=85000

gathering_degrees = draw_powerlaw_numbers(exponent=3,
                            min_value=2,
                            max_value=n_people,
                            number_of_draws=n_gatherings) # Gatherings have at least 2 people. 

people_degrees = draw_powerlaw_numbers(exponent=3,
                            min_value=1,
                            max_value=n_people,
                            number_of_draws=n_people) #People have at least degree 1.

print("BEFORE")
print("--------------")
print("Sum of gathering degrees",np.sum(gathering_degrees), "Av degree:",np.sum(gathering_degrees)/n_gatherings)
print("Sum of people degrees",np.sum(people_degrees), "Av degree:",np.sum(people_degrees)/n_people)
print("Difference between degree sums (people-gath)",np.sum(people_degrees)-np.sum(gathering_degrees))

print("Highest gathering degree",np.max(gathering_degrees))
print("Highest people degree",np.max(people_degrees))



# It is very unlikely that there are now equally many stubs for people and gatherings.
# Add edges to make stubs match each other. (This makes the degree distribution for either gatherings or people. Kojaku et al. did something different but similar)
people_degrees,gathering_degrees = align_stub_numbers(people_degrees,gathering_degrees)


print("AFTER")
print("--------------")
print("Sum of gathering degrees",np.sum(gathering_degrees), "Av degree:",np.sum(gathering_degrees)/n_gatherings)
print("Sum of people degrees",np.sum(people_degrees), "Av degree:",np.sum(people_degrees)/n_people)
print("Difference between degree sums (people-gath)",np.sum(people_degrees)-np.sum(gathering_degrees))

print("Highest gathering degree",np.max(gathering_degrees))
print("Highest people degree",np.max(people_degrees))


# Now create the configuration model graph
# Gatherings have labels [0, n_gathering[
gathering_stubs,people_stubs=bipartite_configuration_model(gathering_degrees,people_degrees)

# save to file.
filename = 'person_gathering_network.csv'
save_edgelist(gathering_stubs,people_stubs,filename)






