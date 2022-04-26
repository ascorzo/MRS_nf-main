import numpy as np
import matplotlib.pyplot as plt

glu = []
with open('glu.txt', 'r') as f:
	content = f.readlines()
	for x in content:
		row = x.split()
		glu.append(int(float(row[0])))
f.close()
x = np.linspace(1,len(glu),len(glu))

fig = plt.figure()
ax = fig.add_subplot(111)
ax.axis([min(x)-1,max(x)+1,min(glu)-100,max(glu)+100])


ax.scatter(x,glu, c = "black", marker = 'o', s=16 )
ax.plot(x,glu, c = "blue")

mu = np.mean(glu)
median = np.median(glu)
sd = np.std(glu, ddof=1)
cv = sd / mu
textstr = '\n'.join((
    r'$\bar{X}=%.2f$' % (mu, ),
#    r'$\mathrm{median}=%.2f$' % (median, ),
    r'$\mathrm{SD}=%.2d$' % (sd, ),
    r'CV={:.2%}'.format(cv)))

props = dict(boxstyle='square', facecolor='white', alpha=0.5)

ax.set_ylabel("Glu")
ax.set_xlabel("Samples")
ax.set_title("Time series Glu")
ax.text(0.025, 0.19, textstr,
        verticalalignment='top', horizontalalignment='left',
        transform=ax.transAxes,
        color='black', fontsize=11, bbox = props)

fig.savefig('glu_plot.png')

print("[plot_glu.py]: glu_plot.png created")
