import matplotlib.font_manager as fm
import matplotlib.lines as lines
import matplotlib.pyplot as plt
import matplotlib.collections as collections
import matplotlib.gridspec as gridspec
from matplotlib import cm, colors
import numpy as np

class Figure:
    fig = None
    title = None
    ax1 = None
    ax2 = None
    ax3 = None

    def __init__(self, title, instances, quadrants, clusters, culled_clusters):
        self.fig = plt.figure()
        self.title = title
        # Set up separate axes
        self.ax1 = self.fig.add_axes([0.1,0.1,0.6,0.8])
        plt.title(self.title)
        self.ax1.set_xlabel('x')
        self.ax1.set_ylabel('y')

        self.ax2 = self.fig.add_axes([0.75,0.7,0.2,0.2])
        plt.title('Legend')
        plt.setp(self.ax2, xticks=[], yticks=[])


        self.ax3 = self.fig.add_axes([0.75,0.3,0.2,0.3])
        plt.title('Distribution')
        plt.setp(self.ax3, xticks=[], yticks=[])

        """
        if type(instances[0].klass()) is str:
            for instance in instances:
                if instance.klass().lower() == "true":
                    self.ax1.plot(instance.coord.x, instance.coord.y, "bo", markersize=2, alpha=0.5)
                else:
                    self.ax1.plot(instance.coord.x, instance.coord.y, "ro", markersize=2, alpha=0.5)
        else:
            for instance in instances:
                ax1.plot(instance.coord.x, instance.coord.y, 'o', markersize=2, alpha=0.5)
        """
        colors = self.make_n_colors(cm.cool, len(clusters)*30)

        #for i in range(len(clusters)):
        #    if clusters[i].mark:
        #        self.color_quadrants(clusters[i].quadrants, 'purple')
        #    else:
        #        self.color_quadrants(clusters[i].quadrants, colors[i*30])
        #    for quadrant in clusters[i].quadrants:
        #        for instance in quadrant.instances:
        #            if instance.klass().lower() == "true":
        #                self.ax1.plot(instance.coord.x, instance.coord.y, "bo", markersize=2, alpha=0.5)
        #            else:
        #                self.ax1.plot(instance.coord.x, instance.coord.y, "ro", markersize=2, alpha=0.5)

        for instance in instances:
            if instance.klass().lower() == "true":
                self.ax1.plot(instance.coord.x, instance.coord.y, "bo", markersize=2, alpha=0.5)
            else:
                self.ax1.plot(instance.coord.x, instance.coord.y, "ro", markersize=2, alpha=0.5)

        for cluster in clusters:
            self.color_quadrants(cluster.quadrants, colors[clusters.index(cluster)*30])

    def color_quadrants(self, quadrants, color):
        for i in range(len(quadrants)):
            xmin = quadrants[i].xmin
            xmax = quadrants[i].xmax
            ymin = quadrants[i].ymin
            ymax = quadrants[i].ymax
            self.ax1.bar(xmin, (ymax-ymin), width=(xmax-xmin), bottom=ymin, facecolor=color, visible=True, linewidth=0.5)

    def write_png(self):
        plt.savefig("%s.png" % self.title)

    def make_n_colors(self, cmap_name, n):
        cmap = cm.get_cmap(cmap_name, n)
        return cmap(np.arange(n))
        
        
        
        