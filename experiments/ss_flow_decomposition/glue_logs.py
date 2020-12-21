import csv
import sys

DATA_DIR = 'results/data/'

input_logs = [DATA_DIR + 'run-cnb-d102-47a_FlyingThings3D_1587646901-tag-EPE3D_loss_validation.csv',
              DATA_DIR + 'run-cnb-d102-47a_FlyingThings3D_1587900003-tag-EPE3D_loss_validation.csv',
              DATA_DIR + 'run-cnb-d102-47a_FlyingThings3D_1588194901-tag-EPE3D_loss_validation.csv']

concat_name = input_logs[-1].split('.')[0] + "_concat.csv"

buffer_csv = []
head_step = sys.maxsize
for in_path in reversed(input_logs):
    with open(in_path, 'r') as in_csv:
        reader = csv.DictReader(in_csv)
        for row in reversed(list(reader)):
            if int(row['Step']) < head_step:
                buffer_csv.append(row)
    head_step = int(row['Step'])

with open(concat_name, 'w') as concat_file:
    fieldnames = ['Wall time', 'Step', 'Value']
    writer = csv.DictWriter(concat_file, fieldnames=fieldnames)
    writer.writeheader()
    for line in reversed(buffer_csv):
        writer.writerow(line)
