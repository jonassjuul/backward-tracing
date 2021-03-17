import networkx as nx
#import sys


#RES_FILENAME = sys.argv[1]
RES_FILENAME = 'BA_network.csv'
G = nx.barabasi_albert_graph(250000, 2)
nx.write_edgelist(G, RES_FILENAME,delimiter=',')
