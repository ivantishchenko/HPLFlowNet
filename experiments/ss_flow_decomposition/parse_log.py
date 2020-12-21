import csv
import re

DATA_DIR = 'results/data/'
LOG_FILE = 'leon_FlyingThings3D_1576143920_log'
OUT_TRAIN = 'leon_FlyingThings3D_1576143920_train.csv'
OUT_VAL = 'leon_FlyingThings3D_1576143920_val.csv'

with open(DATA_DIR + LOG_FILE, 'r') as log_file, \
        open(DATA_DIR + OUT_TRAIN, 'w') as train_file, open(DATA_DIR + OUT_VAL, 'w') as val_file:

    fieldnames = ['Step', 'Value']
    train_writer = csv.DictWriter(train_file, fieldnames=fieldnames)
    train_writer.writeheader()
    val_writer = csv.DictWriter(val_file, fieldnames=fieldnames)
    val_writer.writeheader()

    for line in log_file:
        # Train loss
        if line.startswith('train_dataset:'):
            next_line = next(log_file)
            train_size = int(re.search("Number of datapoints: ([0-9]+)", next_line).group(1))
        elif line.startswith('Epoch: ['):
            train_loss = float(re.search("EPE3D Loss [0-9]+[.][0-9]+ [(]([0-9]+[.][0-9]+)[)][\t\n]", line).group(1))
            epoch = int(re.search("Epoch: [[](.+)[]][[](.+)/", line).group(1))
            local_step = int(re.search("Epoch: [[](.+)[]][[](.+)/", line).group(2))
            global_train_step = (epoch - 1) * train_size + local_step
            train_writer.writerow({'Step': global_train_step, 'Value': train_loss})
        # Val loss
        elif line.startswith(' * EPE3D loss'):
            val_loss = float(re.search(" [*] EPE3D loss ([0-9]+[.][0-9]+)[\t\n]", line).group(1))
            global_val_step = epoch * train_size
            val_writer.writerow({'Step': global_val_step, 'Value': val_loss})
