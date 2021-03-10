import matplotlib.pyplot as plt 
from matplotlib.collections import PathCollection
from matplotlib.legend_handler import HandlerPathCollection, HandlerLine2D

import numpy as np 
from def_plots import * 



labels = {'y':['Infectious','Count','Count'],'x':['Time','Infections prevented','Infections prevented \nper isolation']}

plot_dimension = (3,3)
labelsize = 6
insetnumbersize = 10
color_face = '#E0E0E0'

fig_res(2,labels)
plt.figure(2)
inset = (0,0)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
ax.set_title('Indistinguishable')
plot_line_alt(ax,'I_curves_NodesDistinguishable0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0.txt','plot_file','k','No intervention')
plot_line_alt(ax,'I_curves_NodesDistinguishable0_ps0.050_pt0.000_ShapeFlat_Ignoreparents0.txt','plot_file','orange','Isolation')
plot_line_alt(ax,'I_curves_NodesDistinguishable0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0.txt','plot_file','m','Isolation, Trace')
plot_line_alt(ax,'I_curves/I_curves_NodesDistinguishable0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1.txt','plot_file','g','Isolation, Trace, \n(no parents)')
ax.legend(loc=1,frameon=False,handler_map={PathCollection : HandlerPathCollection(update_func= update),
                        plt.Line2D : HandlerLine2D(update_func = update)},fontsize=4.)
add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'A',insetnumbersize)
give_ticksize(ax,labelsize)



inset = (0,1)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
ax.set_title('Distinguishable')

plot_line_alt(ax,'I_curves/I_curves_NodesDistinguishable1_ps0.000_pt0.000_ShapeFlat_Ignoreparents0.txt','plot_file','k','No intervention')
plot_line_alt(ax,'I_curves/I_curves_NodesDistinguishable1_ps0.050_pt0.000_ShapeFlat_Ignoreparents0.txt','plot_file','orange','Isolation')
plot_line_alt(ax,'I_curves/I_curves_NodesDistinguishable1_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0.txt','plot_file','m','Iso. and Trace')
plot_line_alt(ax,'I_curves/I_curves_NodesDistinguishable1_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1.txt','plot_file','g','Iso., Trace, no parents')
ax.set_facecolor(color_face)
add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'B',insetnumbersize)
give_ticksize(ax,labelsize)

inset = (0,2)

ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
ax.set_title('Skewed infectiousness')

plot_line_alt(ax,'I_curves/I_curves_NodesDistinguishable1_Daysasymp4_ps0.000_pt0.000_ShapeSkewed_Ignoreparents0.txt','plot_file','k','No intervention')
plot_line_alt(ax,'I_curves/I_curves_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.000_ShapeSkewed_Ignoreparents0.txt','plot_file','orange','Isolation')
plot_line_alt(ax,'I_curves/I_curves_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0.txt','plot_file','m','Iso. and Trace')
plot_line_alt(ax,'I_curves/I_curves_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1.txt','plot_file','g','Iso., Trace, no parents')
add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'C',insetnumbersize)
give_ticksize(ax,labelsize)

# CUMSUM
inset = (1,0)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)

#plot_line_alt(ax,'Exposednew_NodesDistinguishable0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0.txt','cumplot_file','k','No intervention')
#plot_line_alt(ax,'Exposednew_NodesDistinguishable0_ps0.050_pt0.000_ShapeFlat_Ignoreparents0.txt','cumplot_file','orange','Isolation')
#plot_line_alt(ax,'Exposednew_NodesDistinguishable0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0.txt','cumplot_file','m','Iso. and Trace')
#plot_line_alt(ax,'Exposednew/Exposednew_NodesDistinguishable0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1.txt','cumplot_file','g','Iso., Trace, no parents')
binnumber = 10
hist_inf_prev(ax,filename='Exposednew_NodesDistinguishable0_ps0.050_pt0.000_ShapeFlat_Ignoreparents0.txt',filename_benchmark='Exposednew_NodesDistinguishable0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0.txt',color='orange',label='Isolation',nbins=binnumber)
hist_inf_prev(ax,filename='Exposednew_NodesDistinguishable0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0.txt',filename_benchmark='Exposednew_NodesDistinguishable0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0.txt',color='m',label='Iso. and Trace',nbins=binnumber)
hist_inf_prev(ax,filename='Exposednew/Exposednew_NodesDistinguishable0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1.txt',filename_benchmark='Exposednew_NodesDistinguishable0_ps0.000_pt0.000_ShapeFlat_Ignoreparents0.txt',color='g',label='Iso., Trace, no parents',nbins=binnumber)
add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'D',insetnumbersize)
give_ticksize(ax,labelsize)



inset = (1,1)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)

#plot_line_alt(ax,'Exposednew/Exposednew_NodesDistinguishable1_ps0.000_pt0.000_ShapeFlat_Ignoreparents0.txt','cumplot_file','k','No intervention')
#plot_line_alt(ax,'Exposednew/Exposednew_NodesDistinguishable1_ps0.050_pt0.000_ShapeFlat_Ignoreparents0.txt','cumplot_file','orange','Isolation')
#plot_line_alt(ax,'Exposednew/Exposednew_NodesDistinguishable1_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0.txt','cumplot_file','m','Iso. and Trace')
#plot_line_alt(ax,'Exposednew/Exposednew_NodesDistinguishable1_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1.txt','cumplot_file','g','Iso., Trace, no parents')

hist_inf_prev(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_ps0.050_pt0.000_ShapeFlat_Ignoreparents0.txt',filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_ps0.000_pt0.000_ShapeFlat_Ignoreparents0.txt',color='orange',label='Isolation',nbins=binnumber)
hist_inf_prev(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0.txt',filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_ps0.000_pt0.000_ShapeFlat_Ignoreparents0.txt',color='m',label='Iso. and Trace',nbins=binnumber)
hist_inf_prev(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1.txt',filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_ps0.000_pt0.000_ShapeFlat_Ignoreparents0.txt',color='g',label='Iso., Trace, no parents',nbins=binnumber)
ax.set_facecolor(color_face)
add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'E',insetnumbersize)
give_ticksize(ax,labelsize)


inset = (1,2)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)

#plot_line_alt(ax,'Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.000_pt0.000_ShapeSkewed_Ignoreparents0.txt','cumplot_file','k','No intervention')
#plot_line_alt(ax,'Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.000_ShapeSkewed_Ignoreparents0.txt','cumplot_file','orange','Isolation')
#plot_line_alt(ax,'Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0.txt','cumplot_file','m','Iso. and Trace')
#plot_line_alt(ax,'Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1.txt','cumplot_file','g','Iso., Trace, no parents')

hist_inf_prev(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.000_ShapeSkewed_Ignoreparents0.txt',filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.000_pt0.000_ShapeSkewed_Ignoreparents0.txt',color='orange',label='Isolation',nbins=binnumber)
hist_inf_prev(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0.txt',filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.000_pt0.000_ShapeSkewed_Ignoreparents0.txt',color='m',label='Iso. and Trace',nbins=binnumber)
hist_inf_prev(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1.txt',filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.000_pt0.000_ShapeSkewed_Ignoreparents0.txt',color='g',label='Iso., Trace, no parents',nbins=binnumber)
add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'F',insetnumbersize)
give_ticksize(ax,labelsize)




inset = (2,0)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
hist_inf_prev_per_trace(ax,filename='Exposednew/Exposednew_NodesDistinguishable0_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0_Ntrace30.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable0_Dayspresymp3_Daysasymp0_ps0.050_pt0.000_ShapeFlat_Ignoreparents0_Ntrace30.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable0_Dayspresymp3_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0_Ntrace30.txt',
                color='m',label='Iso. and Trace',nbins=binnumber)
hist_inf_prev_per_trace(ax,filename='Exposednew/Exposednew_NodesDistinguishable0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1.txt',
                filename_benchmark='Exposednew_NodesDistinguishable0_ps0.050_pt0.000_ShapeFlat_Ignoreparents0.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1.txt',
                color='g',label='Iso., Trace, no parents',nbins=binnumber)
add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'G',insetnumbersize)
give_ticksize(ax,labelsize)



inset = (2,1)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
hist_inf_prev_per_trace(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_ps0.050_pt0.000_ShapeFlat_Ignoreparents0.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents0.txt',
                color='m',label='Iso. and Trace',nbins=binnumber)
hist_inf_prev_per_trace(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_ps0.050_pt0.000_ShapeFlat_Ignoreparents0.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Daysasymp0_ps0.050_pt0.500_ShapeFlat_Ignoreparents1.txt',
                color='g',label='Iso., Trace, no parents',nbins=binnumber)
ax.set_facecolor(color_face)
add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'H',insetnumbersize)
give_ticksize(ax,labelsize)





inset = (2,2)
ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)
hist_inf_prev_per_trace(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.000_ShapeSkewed_Ignoreparents0.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents0.txt',
                color='m',label='Iso. and Trace',nbins=binnumber)
hist_inf_prev_per_trace(ax,filename='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1.txt',
                filename_benchmark='Exposednew/Exposednew_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.000_ShapeSkewed_Ignoreparents0.txt',
                filename_ntraced = 'Isolated/Isolated_NodesDistinguishable1_Daysasymp4_ps0.050_pt0.500_ShapeSkewed_Ignoreparents1.txt',
                color='g',label='Iso., Trace, no parents',nbins=binnumber)

add_label(ax,inset,labels,labelsize)
add_insetlabel(ax,'I',insetnumbersize)
give_ticksize(ax,labelsize)

'''for i in range (plot_dimension[0]) :
    for j in range (plot_dimension[1]) :
        #ax = plt.subplot2grid(plot_dimension,(i,j),rowspan=1,colspan=1)

        if (i== 0) :
            ax.set_ylabel(labels['y'][j],fontsize=SMALL_SIZE)
        #if (j== plot_dimension[1]-1) :
        ax.set_xlabel(labels['x'][i],fontsize=SMALL_SIZE)
'''

#ax.tick_params(axis='both', which='major', labelsize=labelsize)
#ax.tick_params(axis='both', which='minor', labelsize=labelsize)
give_ticksize(ax,labelsize)
plt.tight_layout()
plt.savefig('figures/resfig.png',dpi=400)