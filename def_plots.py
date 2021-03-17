import matplotlib.pyplot as plt 
import numpy as np 
from matplotlib.offsetbox import TextArea, DrawingArea, OffsetImage, AnnotationBbox
from mpl_toolkits.axes_grid.inset_locator import inset_axes
def test_imp() :
    print("Hello world")
# convert cm to inches
def cm_to_inch(cm) :
    return 0.3937007874*cm


def plot_file(filename,ax,plotcolor,plotlabel) :

    # No intervention, not distinguishable
    f = open('outputs/'+filename,'r')
    counter = -1
    for line in f: 
        counter +=1
        line.strip()
        #data = line[:-1]
        I_vec = []

        #data = '250 250 250 319 392 439 554 732 924 1334 1815 2169 3010 4176 5474 7162 9111 11364 14068 17140 20439 24142 28124 32309 36681 41140 45347 49618 53531 56950 60059 62645 64575 65836 66523 66246 65504 64250 62185 59887 57389 54294 51046 47577 44259 40746 37418 34001 30866 28041 25252 22491 20104 17839 15958 14113 12445 11033 9792 8597 7538 6658 5844 5189 4621 4033 3528 3145 2728 2425 2144 1911 1671 1501 1325 1153 1029 882 769 701 613 532 461 401 352 310 283 240 218 187 159 127 112 102 93 85 69 57 49 41 38 32 30 23 21 16 15 14 11 11 9 8 6 6 6 4 5 5 4 5 4 4 3 3 2 2 2 1 1 1'
        data = line.split(' ')[:-1]
        for number in data :
            I_vec.append(int(number))
        I_vec = np.array(I_vec)
        #print(I_vec)

        #plt.figure(fignum)
        if (counter == 0) :
            ax.plot(I_vec,color=plotcolor,linestyle='-',alpha=0.10,label=plotlabel)    
        else :
            ax.plot(I_vec,color=plotcolor,linestyle='-',alpha=0.10)    
    f.close()

    ax.set_ylim([0,69000])
    ax.set_xticks([0,60,120])


    return ax

def cumplot_file(filename,ax,plotcolor,plotlabel) :

    # No intervention, not distinguishable
    f = open('outputs/'+filename,'r')
    counter = -1
    for line in f: 
        counter +=1
        line.strip()
        #data = line[:-1]
        I_vec = []

        #data = '250 250 250 319 392 439 554 732 924 1334 1815 2169 3010 4176 5474 7162 9111 11364 14068 17140 20439 24142 28124 32309 36681 41140 45347 49618 53531 56950 60059 62645 64575 65836 66523 66246 65504 64250 62185 59887 57389 54294 51046 47577 44259 40746 37418 34001 30866 28041 25252 22491 20104 17839 15958 14113 12445 11033 9792 8597 7538 6658 5844 5189 4621 4033 3528 3145 2728 2425 2144 1911 1671 1501 1325 1153 1029 882 769 701 613 532 461 401 352 310 283 240 218 187 159 127 112 102 93 85 69 57 49 41 38 32 30 23 21 16 15 14 11 11 9 8 6 6 6 4 5 5 4 5 4 4 3 3 2 2 2 1 1 1'
        data = line.split(' ')[:-1]
        for number in data :
            I_vec.append(int(number))
        I_vec = np.array(I_vec)
        #print(I_vec)

        #plt.figure(fignum)
        if (counter == 0) :
            ax.plot(np.cumsum(I_vec),color=plotcolor,linestyle='-',alpha=0.10,label=plotlabel)    
        else :
            ax.plot(np.cumsum(I_vec),color=plotcolor,linestyle='-',alpha=0.10)    

    f.close()

def get_plotarray(filename) :
    f = open('outputs/'+filename,'r')
    counter = -1
    for line in f: 
        counter +=1
        line.strip()
        #data = line[:-1]
        I_vec = []

        #data = '250 250 250 319 392 439 554 732 924 1334 1815 2169 3010 4176 5474 7162 9111 11364 14068 17140 20439 24142 28124 32309 36681 41140 45347 49618 53531 56950 60059 62645 64575 65836 66523 66246 65504 64250 62185 59887 57389 54294 51046 47577 44259 40746 37418 34001 30866 28041 25252 22491 20104 17839 15958 14113 12445 11033 9792 8597 7538 6658 5844 5189 4621 4033 3528 3145 2728 2425 2144 1911 1671 1501 1325 1153 1029 882 769 701 613 532 461 401 352 310 283 240 218 187 159 127 112 102 93 85 69 57 49 41 38 32 30 23 21 16 15 14 11 11 9 8 6 6 6 4 5 5 4 5 4 4 3 3 2 2 2 1 1 1'
        data = line.split(' ')[:-1]
        for number in data :
            I_vec.append(int(number))
        I_vec = np.array(I_vec)

    return I_vec

def get_array_finalval(filename) :
    finalvals = []

    f = open('outputs/'+filename,'r')
    counter = -1
    for line in f: 
        counter +=1
        line.strip()
        #data = line[:-1]
        I_vec = []

        #data = '250 250 250 319 392 439 554 732 924 1334 1815 2169 3010 4176 5474 7162 9111 11364 14068 17140 20439 24142 28124 32309 36681 41140 45347 49618 53531 56950 60059 62645 64575 65836 66523 66246 65504 64250 62185 59887 57389 54294 51046 47577 44259 40746 37418 34001 30866 28041 25252 22491 20104 17839 15958 14113 12445 11033 9792 8597 7538 6658 5844 5189 4621 4033 3528 3145 2728 2425 2144 1911 1671 1501 1325 1153 1029 882 769 701 613 532 461 401 352 310 283 240 218 187 159 127 112 102 93 85 69 57 49 41 38 32 30 23 21 16 15 14 11 11 9 8 6 6 6 4 5 5 4 5 4 4 3 3 2 2 2 1 1 1'
        data = line.split(' ')[:-1]
        for number in data :
            I_vec.append(int(number))

        finalvals.append(np.cumsum(I_vec)[-1])
        #print(I_vec[-1])
        #I_vec = np.array(I_vec)

    return np.array(finalvals)

def fig_res(fignum,labels,length=12,factor=1) :

    #length = 12
    figsize = (cm_to_inch(length),cm_to_inch(length)*factor)

    fig = plt.figure(fignum,figsize=figsize)

    # General: 
    plot_dimension = (3,3)



    # INSET NUMBERING
    numberingfontsize = 14
    halignment = 'right'
    valignment='center'

    # FONTS
    EXTREMELY_SMALL_SIZE = 3.6#4.2
    EVEN_SMALLER_SIZE = 5.5
    SMALL_SIZE = 7
    MEDIUM_SIZE = 10
    BIGGER_SIZE = 12

    # GENERAL SETTINGS
    plt.rc('font', size=SMALL_SIZE)          # controls default text sizes
    plt.rc('axes', titlesize=SMALL_SIZE)     # fontsize of the axes title
    plt.rc('axes', labelsize=SMALL_SIZE)    # fontsize of the x and y labels
    plt.rc('xtick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
    plt.rc('ytick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
    plt.rc('legend', fontsize=EVEN_SMALLER_SIZE)    # legend fontsize
    plt.rc('figure', titlesize=BIGGER_SIZE)  # fontsize of the figure title

    hide_yticklabels = True
    hide_xticklabels = False

    show_inset_labels = True
    inset_tickwidth = .4
    inset_ticklength = 2
    inset_pad =1

    horizontal_space_between_subplots = 0#1.
    vertical_space_between_subplots = .4#.2


def plot_line(fignum,plot_dimension,inset,filename,plottype,color,label) :
    plt.figure(fignum)
    ax = plt.subplot2grid(plot_dimension,inset,rowspan=1,colspan=1)

    if (plottype == 'plot_file') :
        return plot_file(filename,ax,color,label)


    elif (plottype == 'cumplot_file') :
        return cumplot_file(filename,ax,color,label)

    #return ax

def plot_line_alt(ax,filename,plottype,color,label) :

    if (plottype == 'plot_file') :
        ax= plot_file(filename,ax,color,label)
        return ax


    elif (plottype == 'cumplot_file') :
        ax= cumplot_file(filename,ax,color,label)    
        return ax

def hist_inf_prev(ax,filename,filename_benchmark,color,label,nbins) :
    
    exposed = get_array_finalval(filename)
    exposed_benchmark = get_array_finalval(filename_benchmark)

    #print(exposed)
    #print(exposed_benchmark)
    print(len(exposed_benchmark))
    ax.hist(exposed_benchmark-exposed,bins=nbins,facecolor=color,label=label,density=False,alpha=0.5)
    #ax.axvline(np.mean(exposed_benchmark-exposed),color=color,linewidth=.4)

    ax.set_ylim([0,25])
    ax.set_xlim([0,62000])

    return ax

def hist_inf_prev_per_trace(ax,filename,filename_benchmark,filename_ntraced,color,label,nbins,smallfig=False) :

    exposed = get_array_finalval(filename)
    exposed_benchmark = get_array_finalval(filename_benchmark)

    ntrace = get_array_finalval(filename_ntraced)

    plotarr_prevpertrace = get_plotarr_prevpertrace(exposed,exposed_benchmark,ntrace)

    print(len(exposed_benchmark))
    ax.hist(plotarr_prevpertrace,bins=nbins,facecolor=color,label=label,density=False,alpha=0.5)    
    ax.set_ylim([0,30])
    if (smallfig==False) :
        ax.set_xlim([0,0.035])
        ax.set_xticks([0,0.015,0.030])

    else : 
        ax.set_xlim([0,5])
        ax.set_xticks([0,2.5,5.0])   
    return ax

def hist_inf_prev_per_isolate(ax,filename,filename_benchmark,filename_nfound,filename_ntraced,color,label,nbins,smallfig=False) :

    exposed = get_array_finalval(filename)
    exposed_benchmark = get_array_finalval(filename_benchmark)

    nfound = get_array_finalval(filename_nfound)
    ntrace = get_array_finalval(filename_ntraced)
    print(len(nfound),len(ntrace))

    plotarr_prevpertrace = get_plotarr_prevpertrace(exposed,exposed_benchmark,(ntrace+nfound))

    print(len(exposed_benchmark))
    ax.hist(plotarr_prevpertrace,bins=nbins,facecolor=color,label=label,density=False,alpha=0.5)    
    ax.set_ylim([0,30])
    if (smallfig==False) :
        ax.set_xlim([0,6])
        ax.set_xticks([0,2,4,6]) 

    else : 
       ax.set_xlim([0,6])
       ax.set_xticks([0,2,4,6])    
    return ax


def get_plotarr_prevpertrace(exposed,exposed_benchmark,ntrace) :
    res = []
    for i in range (len(exposed)) :
        res.append((exposed_benchmark[i]-exposed[i])/max(1,ntrace[i]))
    return np.array(res)


def update(handle, orig):
    handle.update_from(orig)
    handle.set_alpha(1)
    #return ax

def add_label(ax,inset,labels,labelsize) :
    SMALL_SIZE = 4.5
    i,j = inset[0],inset[1]
    if (j==0) :
        ax.set_ylabel(labels['y'][i],fontsize=labelsize)
    #if (j== plot_dimension[1]-1) :
    ax.set_xlabel(labels['x'][i],fontsize=labelsize)
    return ax

def add_insetlabel(ax,insetlabel,numberingfontsize) :
    xlim = ax.get_xlim()
    ylim = ax.get_ylim()
    frac = 0.05
    ax.text(xlim[0]+frac*xlim[1],ylim[1]-frac*ylim[1],insetlabel,fontsize=numberingfontsize,horizontalalignment='left',verticalalignment='top')
    return ax

def give_ticksize(ax,labelsize) :
    ax.tick_params(axis='both', which='major', labelsize=labelsize)
    ax.tick_params(axis='both', which='minor', labelsize=labelsize)
    return ax

def add_insetimage(ax,height,loc,image) :
    im_ax01 = inset_axes(ax,
                        height=height, # set height
                        width=height, # and width
                        loc=loc,
                        #facecolor='b'
                        ) # center, you can check the different codes in plt.legend?
    im_ax01.imshow(image)
    #im_ax01.patch.set_facecolor('red')    

    im_ax01.axis('off')    
    
    #im_ax01.set_alpha(0.1)
    #im_ax01.set_facecolor('blue')



    return ax