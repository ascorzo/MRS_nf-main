import numpy as np
import matplotlib.pyplot as plt

glu = []
filename = 'ocd/ocd0748b_acc_m_8_glu.txt'
basename = filename.split('.')
with open(filename, 'r') as f:
	content = f.readlines()
	for x in content:
		row = x.split()
		glu.append(int(float(row[0])))
f.close()

group_glu =[
	list( glu[i] for i in [3,6,9,12,16,18]),
	list( glu[i] for i in [1,2,7,8,16,17]),
	list( glu[i] for i in [4,5,10,11,13,14]),
]

group_mean = [
        np.mean(group_glu[0]),
        np.mean(group_glu[1]),
        np.mean(group_glu[2]),
]
group_std = [
        np.std(group_glu[0], ddof = 1),
        np.std(group_glu[1], ddof = 1),
        np.std(group_glu[2], ddof = 1)
]
group_sem = group_std / np.sqrt(len(glu))
x = np.linspace(0,len(group_mean),len(group_mean))

fig = plt.figure()
ax = fig.add_subplot(111)
#ax.axis([min(x)-1,max(x)+1,min(group_mean)-100,max(group_mean)+100])


x = ["A","D","E"]
ax.violinplot(group_glu)
#ax.errorbar(x,group_mean, yerr = group_sem, ecolor = "black", fmt='none', capsize = 10)
#ax.scatter(x,group_mean, c = "red", marker = 'o', s=16 )

#mu = np.mean(glu)
#median = np.median(glu)
#sd = np.std(glu, ddof=1)
#cv = sd / mu
#textstr = '\n'.join((
#    r'$\bar{X}=%.2f$' % (mu, ),
#    r'$\mathrm{SD}=%.2d$' % (sd, ),
#    r'CV={:.2%}'.format(cv)))

#props = dict(boxstyle='square', facecolor='white', alpha=0.5)

ax.set_ylabel("Glu")
ax.set_xlabel("Condition")
ax.set_title("Glutamate per Condition")
#ax.text(0.025, 0.19, textstr,
#        verticalalignment='top', horizontalalignment='left',
#        transform=ax.transAxes,
#        color='black', fontsize=11, bbox = props)

fig.savefig(basename[0] + '_glutamate_condition_violin' + '.png')

print("[plot_glu.py]:" + basename[0] + "_glutamate_condition_violin.png created")
