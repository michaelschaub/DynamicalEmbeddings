#!/usr/bin/env python
import networkx as nx
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Circle
import numpy as np


def draw_network(G, pos, ax, mode='down'):
    setup = '4cat'
    # draw nodes
    i = 1
    for n in G:
        location = G.node[n]['Location'].strip()
        if setup == '5cat':
            if location == 'Canada':
                color = "#0099f8"
            elif location == 'Midwest':
                color = '#e16e45'
            elif location == 'Northeast':
                color = '#3da34c'
            elif location == 'South':
                color = '#c270d1'
            else:  # West
                color = '#ab8c17'
        else:
            if location == 'Midwest':
                color = "#0099f8"
            elif location == 'Northeast':
                color = '#e16e45'
            elif location == 'South':
                color = '#3da34c'
            else:  # West
                color = '#c270d1'

        c = Circle(pos[n], radius=1, alpha=0.4, color=color, lw=0)
        ax.add_patch(c)
        G.node[n]['patch'] = c
        G.node[n]['color'] = color
        text = str(i) + ". " + G.node[n]['Name'] + " (" + str(n) + ")"
        i = i + 1
        ax.annotate(text, xy=pos[n] + np.array([1, 0]), xytext=pos[n] + np.array([16, 0]),
                    verticalalignment="center",
                    arrowprops=dict(facecolor='black', arrowstyle="-"),
                    annotation_clip=False)

    for (u, v, d) in G.edges(data=True):
        n1 = G.node[u]['patch']
        n2 = G.node[v]['patch']
        # if (u,v) in seen:
        # rad=seen.get((u,v))
        # rad=(rad+np.sign(rad)*0.1)*-1
        alpha = 0.5
        rad = 0.5
        color = (0.8, 0.2, 0.2)

        if mode == 'down' and G.node[u]['RankingPsi'] < G.node[v]['RankingPsi']:
            e = FancyArrowPatch(n1.center, n2.center, patchA=n1, patchB=n2,
                                arrowstyle='fancy',
                                connectionstyle='arc3,rad=%s' % rad,
                                mutation_scale=10 * G[u][v]['weight'],
                                lw=G[u][v]['weight'],
                                alpha=alpha,
                                color=color)
            ax.add_patch(e)
        elif mode == 'down' and u == v and G[u][v]['weight'] != 0:
            r = np.sqrt(G[u][v]['weight'] / G.out_degree(u, weight='weight'))
            print(r, G[u][v]['weight'], G.out_degree(u, weight='weight'))
            c2 = Circle(pos[u], radius=r, alpha=1, color=G.node[u]['color'])
            ax.add_patch(c2)
        elif mode == 'up' and G.node[u]['RankingPsi'] > G.node[v]['RankingPsi']:
            e = FancyArrowPatch(n1.center, n2.center, patchA=n1, patchB=n2,
                                arrowstyle='fancy',
                                connectionstyle='arc3,rad=%s' % rad,
                                mutation_scale=10 * G[u][v]['weight'],
                                lw=G[u][v]['weight'],
                                alpha=alpha,
                                color=color)
            ax.add_patch(e)


def read_network_data(self_loops=True):
    filename_vertex = "./TopkNodes.csv"
    filename_edges = "./TopkNodesEdges.csv"
    G = nx.DiGraph()
    i = 1
    with open(filename_vertex) as f:
        for rawline in f:
            line = rawline.split(';')
            nodeIDClauset = int(line[0])
            name = line[5].strip()
            loc = line[4].strip()
            G.add_node(nodeIDClauset, Name=name, Location=loc, RankingPsi=i)
            i = i + 1
    with open(filename_edges) as f:
        for rawline in f:
            line = rawline.split(',')
            source = int(line[0])
            target = int(line[1])
            weight = int(line[2]) / 10.0
            if self_loops or source != target:
                G.add_edge(source, target, weight=weight)
    return G


G = read_network_data()
# number of nodes to plot
n = G.number_of_nodes()
pos = {}
for node in G.nodes():
    pos[node] = np.array([-30., -4 * G.node[node]['RankingPsi']])
ax = plt.gca()
draw_network(G, pos, ax, 'down')
draw_network(G, pos, ax, 'up')
ax.autoscale()
plt.axis('equal')
plt.axis('off')
plt.savefig("graph.pdf")
plt.show()
