import networkx as nx
#import sys


#RES_FILENAME = sys.argv[1]
RES_FILENAME = 'ER_network.csv'
# Make gnp graph
G=nx.fast_gnp_random_graph(250000,4/250000)

# Get largest connected component
largest_cc_nodes = max(nx.connected_components(G), key=len)
cc=G.subgraph(largest_cc_nodes)

# Relabel nodes to get labels from 1 to len(cc.nodes())
mapping = {}
next_label=0
for nodelabel in cc.nodes() :
    mapping[nodelabel]=next_label +0
    next_label +=1

cc_relabelled = nx.relabel_nodes(cc, mapping)




nx.write_edgelist(cc_relabelled, RES_FILENAME,delimiter=',')

