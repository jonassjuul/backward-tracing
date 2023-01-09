import os
import sys
import random
import pandas as pd

import networkx as nx
import numpy as np



def save_network(df,filename):
    # df : type:dataframe.      edgelist. Each edge listed once.
    # filename type:string.

    f = open(filename,"w")
    f.write("Node1,Node2,Brackets")

    for row in range (len(df.Node1)) :
        f.write("\n%i,%i,{}"%(df.Node1[row],df.Node2[row]))

def draw_one_node(df) :
    # df : type:dataframe.      edgelist. Each edge listed once.


    # Rewire an edge..
    nodes_drawn = []
    
    while (len(nodes_drawn) < 1) :
        # Draw each node proportional to the number of edges it already has..
        columnnumber = random.randrange(0,2) # Draws 1 or 2
        column = ["Node1","Node2"][columnnumber]
        
        entrynumber = random.randrange(0,len(df[column]))
        drawn_node = df[column][entrynumber]
        if (len(nodes_drawn) == 0 or drawn_node!=nodes_drawn[0]) :
            nodes_drawn.append(drawn_node)
    nodes_drawn.sort()
    return nodes_drawn


def draw_two_nodes(df) :
    # df : type:dataframe.      edgelist. Each edge listed once.


    # Rewire an edge..
    nodes_drawn = []
    
    while (len(nodes_drawn) < 2) :
        # Draw each node proportional to the number of edges it already has..
        columnnumber = random.randrange(0,2) # Draws 1 or 2
        column = ["Node1","Node2"][columnnumber]
        
        entrynumber = random.randrange(0,len(df[column]))
        drawn_node = df[column][entrynumber]
        if (len(nodes_drawn) == 0 or drawn_node!=nodes_drawn[0]) :
            nodes_drawn.append(drawn_node)
    nodes_drawn.sort()
    return nodes_drawn

# import ER network
df_edges = pd.read_csv("github/backward-tracing/inputs/ER_network.csv")

max_node_id = max(max(df_edges.Node1),max(df_edges.Node2))

# make BA network, get array with stubs.
G_BA=nx.barabasi_albert_graph(n=250000,m=2)
BA_degree_sequence = sorted((d for n, d in G_BA.degree()), reverse=True)[0:max_node_id+1]
BA_stubs = np.array([])
for node in range (len(BA_degree_sequence)) :
    BA_stubs = np.concatenate((BA_stubs,[node]*BA_degree_sequence[node]))




fractions_rewire = [0.30,0.50]#[0.001,0.01,0.10,1.0] # Fraction of edges to rewire.
fractions_rewire.sort()

order_rewire = []
for idx in df_edges.index :
    order_rewire.append(idx)

#order_rewire = copy.copy(indices)
random.shuffle(order_rewire)


numbers_rewire = [] # Number of nodes to (attempt to) rewire
for fraction in fractions_rewire :
    numbers_rewire.append(int(len(order_rewire)*fraction))

filename = "github/backward-tracing/inputs/ERtoPowerlaw_%.3frewired.csv"

# get degrees
degree_dist = np.zeros(max(max(df_edges.Node1),max(df_edges.Node2))+1)
for edgenumber in range (len((df_edges["Node1"]))) :
    degree_dist[int(df_edges.Node1[edgenumber])] += 1
    degree_dist[int(df_edges.Node2[edgenumber])] += 1


# Now rewire..
number_rewire_so_far = 0
times_saved = 0
print("Now rewiring %s of edges"%fractions_rewire[times_saved])
for edgenumber in (order_rewire) :
    
    

    #nodes_drawn_sorted = draw_two_nodes(df_edges)

    # draw a node proportional to its degree
    node_drawn = draw_one_node(df_edges)
    
    degrees_edgenodes = np.array([degree_dist[df_edges.loc[edgenumber].Node1],degree_dist[df_edges.loc[edgenumber].Node2]])
    
    if (degrees_edgenodes[0]>=3) :
        new_edge0 = np.random.choice(BA_stubs)
        if (df_edges.loc[edgenumber].Node1 != new_edge0) : 
            degree_dist[df_edges.loc[edgenumber].Node1]-=1
            degree_dist[int(new_edge0)]+=1

    else : 
        new_edge0 = df_edges.loc[edgenumber].Node1

    if (degrees_edgenodes[1]>=3) :
        new_edge1 = np.random.choice(BA_stubs)

        if (df_edges.loc[edgenumber].Node2 != new_edge1) : 
            degree_dist[df_edges.loc[edgenumber].Node2]-=1
            degree_dist[int(new_edge1)]+=1
    else : 
        new_edge1 = df_edges.loc[edgenumber].Node2

    df_edges.loc[edgenumber] = int(new_edge0),int(new_edge1),'{}'
    number_rewire_so_far +=1

    
    # Check if it is time to save network
    if (number_rewire_so_far == numbers_rewire[times_saved]) :
        save_network(df_edges,filename%fractions_rewire[times_saved])
        times_saved +=1
        if (times_saved < len(fractions_rewire)) :
            print("Now rewiring %s of edges"%fractions_rewire[times_saved])
        else : 
            break