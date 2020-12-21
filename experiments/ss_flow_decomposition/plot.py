import csv
import matplotlib.pyplot as plt
import numpy as np

DATA_DIR = 'results/data/'
OUT_DIR = 'results/img/'


def _extract_data_csv(file_path, epoch_size=1):
    with open(file_path) as csvfile:
        reader = csv.DictReader(csvfile)
        steps = []
        values = []
        for row in reader:
            steps.append(float(row['Step']) / epoch_size)
            values.append(float(row['Value']))
    return steps, values


def _smooth_i(x, window_len=11, window='hanning'):
    x = np.array(x)
    if x.ndim != 1:
        raise ValueError("smooth only accepts 1 dimension arrays.")
    if x.size < window_len:
        raise ValueError("Input vector needs to be bigger than window size.")
    if window_len < 3:
        return x
    if window not in ['flat', 'hanning', 'hamming', 'bartlett', 'blackman']:
        raise ValueError("Window is on of 'flat', 'hanning', 'hamming', 'bartlett', 'blackman'")

    s = np.r_[x[window_len - 1:0:-1], x, x[-1:-window_len:-1]]

    if window == 'flat':  # moving average
        w = np.ones(window_len, 'd')
    else:
        w = eval('np.' + window + '(window_len)')

    y = np.convolve(w / w.sum(), s, mode='valid')
    return y


def plot_loss_double(in_files, out_file, labels, colors, smooth_val, limits, dims=(640, 480),
              yticks=None, xticks=None, linewidth=None, epoch_size=1):
    num_models = len(in_files)
    limits_x = []
    limits_y = []
    for i in range(num_models):
        steps, values = _extract_data_csv(in_files[i], epoch_size)
        limits_x.append(max(steps))
        limits_y.append(max(values))

        linewidth = [2] * len(in_files) if linewidth is None else linewidth

        if smooth_val[i] != -1:
            values_smooth = _smooth_i(values, smooth_val[i])
            cut_val = min(len(steps), len(values))
            plt.plot(steps[:cut_val],
                     values_smooth[:cut_val],
                     color=colors[i],
                     alpha=1.0,
                     label=labels[i],
                     linewidth=linewidth[i])

        plt.plot(steps,
                 values,
                 color=colors[i],
                 alpha=0.8,
                 linewidth=linewidth[i])

    # MIN
    if limits[2] == -1:
        plt.xlim(xmin=0)
    else:
        plt.xlim(xmin=limits[2])

    if limits[3] == -1:
        plt.ylim(ymin=0)
    else:
        plt.ylim(ymin=limits[3])

    # MAX
    if limits[0] == -1:
        plt.xlim(xmax=max(limits_x))
    else:
        plt.xlim(xmax=limits[0])
    if limits[1] == -1:
        plt.ylim(ymax=max(limits_y))
    else:
        plt.ylim(ymax=limits[1])

    plt.grid(linestyle='dashed')
    plt.xlabel('Epochs', fontsize=14)
    plt.ylabel('EPE3D', fontsize=14)
    if len(labels) > 1:
        plt.legend(labels)

    if yticks is not None:
        plt.yticks(yticks)
    if xticks is not None:
        plt.xticks(xticks)

    # set dims
    fig = plt.gcf()
    DPI = fig.get_dpi()
    fig.set_size_inches(dims[0] / float(DPI), dims[1] / float(DPI))

    plt.savefig(out_file, bbox_inches='tight', dpi=1200, format='eps')
    plt.gcf().clear()


def plot_loss(in_files, out_file, labels, colors, smooth_val, limits, dims=(640, 480),
              yticks=None, xticks=None, linewidth=None, epoch_size=1):
    num_models = len(in_files)
    limits_x = []
    limits_y = []
    for i in range(num_models):
        steps, values = _extract_data_csv(in_files[i], epoch_size)
        limits_x.append(max(steps))
        limits_y.append(max(values))

        if smooth_val[i] != -1:
            values = _smooth_i(values, smooth_val[i])

        cut_val = min(len(steps), len(values))
        if linewidth != None:
            plt.plot(steps[:cut_val], values[:cut_val], color=colors[i], alpha=1.0, label=labels[i], linewidth=linewidth[i])
        else:
            plt.plot(steps[:cut_val], values[:cut_val], color=colors[i], alpha=1.0, label=labels[i])

    # MIN
    if limits[2] == -1:
        plt.xlim(xmin=0)
    else:
        plt.xlim(xmin=limits[2])

    if limits[3] == -1:
        plt.ylim(ymin=0)
    else:
        plt.ylim(ymin=limits[3])

    # MAX
    if limits[0] == -1:
        plt.xlim(xmax=max(limits_x))
    else:
        plt.xlim(xmax=limits[0])
    if limits[1] == -1:
        plt.ylim(ymax=max(limits_y))
    else:
        plt.ylim(ymax=limits[1])

    plt.grid(linestyle='dashed')
    plt.xlabel('Epochs', fontsize=14)
    plt.ylabel('EPE3D', fontsize=14)
    if len(labels) > 1:
        plt.legend(labels)

    if yticks is not None:
        plt.yticks(yticks)
    if xticks is not None:
        plt.xticks(xticks)

    # set dims
    fig = plt.gcf()
    DPI = fig.get_dpi()
    fig.set_size_inches(dims[0] / float(DPI), dims[1] / float(DPI))

    plt.savefig(out_file, bbox_inches='tight', dpi=1200, format='eps')
    plt.gcf().clear()


# Produce PNGs
# BLUE, ORANGE, RED, GREEN
color_map = {'blue': (57/255, 106/255, 177/255),
             'orange': (218/255, 124/255, 48/255),
             'red': (204/255, 37/255, 41/255),
             'green': (62/255, 150/255, 81/255)}

step_x = 50
step_y = 0.05
start_x = 0
end_x = 300
start_y = 0
end_y = 0.4
# 1 Train
plot_loss([DATA_DIR + "1/leon_FlyingThings3D_1577447407_train_concat.csv",
           DATA_DIR + "2/leon_FlyingThings3D_1588456633_train_concat.csv",
           DATA_DIR + "3/leon_FlyingThings3D_1588919274_train.csv"],
          out_file=OUT_DIR + 'ss_train.eps',
          labels=["Supervised", "Self-supervisory signals", "Full self-supervision"],
          colors=[color_map['red'], color_map['blue'], color_map['green']],
          smooth_val=[50, 50, 50],
          linewidth=[1, 1, 1],
          limits=[end_x, end_y, -1, -1],
          dims=(1280, 800),
          xticks=np.arange(start_x, end_x + step_x, step_x),
          yticks=np.arange(start_y, end_y + step_y, step_y),
          epoch_size=4910)

# 1 Val
plot_loss([DATA_DIR + "1/leon_FlyingThings3D_1577447407_val_concat.csv",
           DATA_DIR + "2/leon_FlyingThings3D_1588456633_val_concat.csv",
           DATA_DIR + "3/leon_FlyingThings3D_1588919274_val.csv"],
          out_file=OUT_DIR + 'ss_val.eps',
          labels=["Supervised", "Self-supervisory signals", "Full self-supervision"],
          colors=[color_map['red'], color_map['blue'], color_map['green']],
          smooth_val=[-1, -1, -1],
          linewidth=[1, 1, 1],
          limits=[end_x, end_y, -1, -1],
          dims=(1280, 800),
          xticks=np.arange(start_x, end_x + step_x, step_x),
          yticks=np.arange(start_y, end_y + step_y, step_y),
          epoch_size=4910)

step_x = 50
step_y = 0.05
start_x = 0
end_x = 300
start_y = 0
end_y = 0.4
# 2 Train
plot_loss([DATA_DIR + "5/cnb-d102-47a_FlyingThings3DPoses_1588544756_train.csv",
           DATA_DIR + "6/cnb-d102-47_FlyingThings3DPoses_1588603623_train_concat.csv",
           DATA_DIR + "7/leon_FlyingThings3DPoses_1588945975_train.csv"],
          out_file=OUT_DIR + 'decompose_train.eps',
          labels=["Supervised", "Self-supervisory signals", "Full self-supervision"],
          colors=[color_map['red'], color_map['blue'], color_map['green']],
          smooth_val=[50, 50, 50],
          linewidth=[1, 1, 1],
          limits=[end_x, end_y, -1, -1],
          dims=(1280, 800),
          xticks=np.arange(start_x, end_x + step_x, step_x),
          yticks=np.arange(start_y, end_y + step_y, step_y),
          epoch_size=4897)

# 2 Val
plot_loss([DATA_DIR + "5/cnb-d102-47a_FlyingThings3DPoses_1588544756_val.csv",
           DATA_DIR + "6/cnb-d102-47_FlyingThings3DPoses_1588603623_val_concat.csv",
           DATA_DIR + "7/leon_FlyingThings3DPoses_1588945975_val.csv"],
          out_file=OUT_DIR + 'decompose_val.eps',
          labels=["Supervised", "Self-supervisory signals", "Full self-supervision"],
          colors=[color_map['red'], color_map['blue'], color_map['green']],
          smooth_val=[-1, -1, -1],
          linewidth=[1, 1, 1],
          limits=[end_x, end_y, -1, -1],
          dims=(1280, 800),
          xticks=np.arange(start_x, end_x + step_x, step_x),
          yticks=np.arange(start_y, end_y + step_y, step_y),
          epoch_size=4897)

step_x = 50
step_y = 0.05
start_x = 0
end_x = 500
start_y = 0
end_y = 0.25
plot_loss([DATA_DIR + "poc/cnb-d102-47a_RefRESH_1582893455_train.csv",
           DATA_DIR + "poc/cnb-d102-47_RefRESH_1583327107_train.csv"],
          out_file=OUT_DIR + 'poc_train.eps',
          labels=["Total flow prediction", "Theoretical limit"],
          colors=[color_map['blue'], color_map['red']],
          smooth_val=[50, 50],
          linewidth=[1, 1],
          limits=[end_x, end_y, -1, -1],
          dims=(1280, 800),
          xticks=np.arange(start_x, end_x + step_x, step_x),
          yticks=np.arange(start_y, end_y + step_y, step_y),
          epoch_size=5039)

plot_loss([DATA_DIR + "poc/cnb-d102-47a_RefRESH_1582893455_val.csv",
           DATA_DIR + "poc/cnb-d102-47_RefRESH_1583327107_val.csv"],
          out_file=OUT_DIR + 'poc_val.eps',
          labels=["Total flow prediction", "Theoretical limit"],
          colors=[color_map['blue'], color_map['red']],
          smooth_val=[-1, -1],
          linewidth=[1, 1],
          limits=[end_x, end_y, -1, -1],
          dims=(1280, 800),
          xticks=np.arange(start_x, end_x + step_x, step_x),
          yticks=np.arange(start_y, end_y + step_y, step_y),
          epoch_size=5039)