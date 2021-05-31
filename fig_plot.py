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
im_skewed_empirical = plt.imread('figures/q_skewed_empirical.png')

fig_res(3,labels,length=10,factor=0.5)
plt.figure(3)
inset = (0,0)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                color='m',label='Backward',nbins=binnumber,smallfig=False)
hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1_Ntrace30_IsolateRightAwaytrue.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1_Ntrace30_IsolateRightAwaytrue.txt',                
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1_Ntrace30_IsolateRightAwaytrue.txt',
                color='g',label='Forward',nbins=binnumber,smallfig=False)

add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'A',insetnumbersize)
add_insetimage(ax,height="50%",loc=1,image=im_flat)

give_ticksize(ax,labelsize)


inset = (0,1)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
#ax.set_title('Distinguishable')
hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.000_pt0.000_ShapeSkewed_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',                
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                color='m',label='Backward contact tracing',nbins=binnumber,smallfig=False)
hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1_Ntrace30_IsolateRightAwaytrue.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.000_pt0.000_ShapeSkewed_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1_Ntrace30_IsolateRightAwaytrue.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Dayspresymp3_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1_Ntrace30_IsolateRightAwaytrue.txt',
                color='g',label='Forward contact tracing',nbins=binnumber,smallfig=False)

add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'B',insetnumbersize)
add_insetimage(ax,height="50%",loc=1,image=im_skewed_empirical)
give_ticksize(ax,labelsize)


ax.legend(loc=4,frameon=False,handler_map={PathCollection : HandlerPathCollection(update_func= update),
                        plt.Line2D : HandlerLine2D(update_func = update)},fontsize=5.,markerfirst=True)


plt.tight_layout()
plt.savefig('figures/resfig_isolate.png',dpi=400)


plot_dimension = (1,1)
fig_res(4,labels,length=5,factor=1)
plt.figure(4)
inset = (0,0)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)

hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents22_Ntrace30_IsolateRightAwayfalse.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents22_Ntrace30_IsolateRightAwayfalse.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents22_Ntrace30_IsolateRightAwayfalse.txt',
                color='orange',label='Contact tracing',nbins=binnumber,smallfig=False)

            
hist_inf_prev_per_isolate(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.000_ShapeFlat_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',
                filename_nfound = 'Found/Found_NodesDistinguishable1_Dayspresymp3_Daysasymp0_ps0.050_pt0.000_ShapeFlat_Ignoreparents0_Ntrace30_IsolateRightAwaytrue.txt',                
                filename_ntraced = '',
                color='blue',label='Case isolation',nbins=binnumber,smallfig=False)


add_label(ax,inset,labels,labelsize)
add_insetimage(ax,height="50%",loc=1,image=im_flat)


ax.legend(loc=4,frameon=False,handler_map={PathCollection : HandlerPathCollection(update_func= update),
                        plt.Line2D : HandlerLine2D(update_func = update)},fontsize=5.,markerfirst=True)

ax.set_xlim([0,6])
plt.tight_layout()
plt.savefig('figures/resfig_notrace.png',dpi=400)