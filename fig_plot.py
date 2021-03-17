import matplotlib.pyplot as plt 
from matplotlib.collections import PathCollection
from matplotlib.legend_handler import HandlerPathCollection, HandlerLine2D

import numpy as np 
from def_plots import * 


# Fig with only 2 states
labels = {'y':['Count'],'x':['Infections prevented \nper isolation']}
binnumber = 10

plot_dimension = (1,2)
labelsize = 6
insetnumbersize = 10
color_face = '#E0E0E0'
im_flat = plt.imread('figures/q_flat.png')
im_skewed = plt.imread('figures/q_skewed.png')

fig_res(3,labels,length=10,factor=0.5)
plt.figure(3)
inset = (0,0)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
#ax.set_title('Indistinguishable')
hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0_Ntrace30.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0_Ntrace30.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0_Ntrace30.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0_Ntrace30.txt',
                color='m',label='Backward',nbins=binnumber,smallfig=False)
hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1_Ntrace30.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0_Ntrace30.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1_Ntrace30.txt',                
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1_Ntrace30.txt',
                color='g',label='Forward',nbins=binnumber,smallfig=False)
#ax.set_facecolor(color_face)

add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'A',insetnumbersize)
add_insetimage(ax,height="50%",loc=1,image=im_flat)
# ax.legend(loc=4,frameon=False,handler_map={PathCollection : HandlerPathCollection(update_func= update),
#                         plt.Line2D : HandlerLine2D(update_func = update)},fontsize=5.,markerfirst=True)

give_ticksize(ax,labelsize)


inset = (0,1)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
#ax.set_title('Distinguishable')
hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0_Ntrace30.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.000_pt0.000_ShapeSkewed_Ignoreparents0_Ntrace30.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0_Ntrace30.txt',                
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0_Ntrace30.txt',
                color='m',label='Backward contact tracing',nbins=binnumber,smallfig=False)
hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1_Ntrace30.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.000_pt0.000_ShapeSkewed_Ignoreparents0_Ntrace30.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1_Ntrace30.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1_Ntrace30.txt',
                color='g',label='Forward contact tracing',nbins=binnumber,smallfig=False)

add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'B',insetnumbersize)
add_insetimage(ax,height="50%",loc=1,image=im_skewed)
give_ticksize(ax,labelsize)


ax.legend(loc=4,frameon=False,handler_map={PathCollection : HandlerPathCollection(update_func= update),
                        plt.Line2D : HandlerLine2D(update_func = update)},fontsize=5.,markerfirst=True)


plt.tight_layout()
plt.savefig('figures/resfig_isolate.png',dpi=400)


# PER ISOLATE
# Fig with only 2 states
labels = {'y':['Count'],'x':['Infections prevented \nper isolation']}
binnumber = 10

plot_dimension = (1,1)
labelsize = 6
insetnumbersize = 10
color_face = '#E0E0E0'
im_flat = plt.imread('figures/q_flat.png')
im_skewed = plt.imread('figures/q_skewed.png')

fig_res(3,labels,length=3,factor=1)
plt.figure(3)
inset = (0,0)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
#ax.set_title('Indistinguishable')
hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable0_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents22_Ntrace30.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable0_Dayspresymp3_Daysasymp0_ps0.000_pt0.000_ShapeFlat_Ignoreparents22_Ntrace30.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable0_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents22_Ntrace30.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable0_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents22_Ntrace30.txt',
                color='k',label='Indistinguishable',nbins=binnumber,smallfig=False)
#ax.set_facecolor(color_face)


ax.legend(loc=4,frameon=False,handler_map={PathCollection : HandlerPathCollection(update_func= update),
                        plt.Line2D : HandlerLine2D(update_func = update)},fontsize=5.,markerfirst=True)


plt.tight_layout()
plt.savefig('figures/resfig_isolate_indistinguishable.png',dpi=400)
