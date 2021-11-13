import numpy as np
from sklearn.linear_model import LinearRegression
import matplotlib.pyplot as plt
from sklearn.metrics import mean_squared_error, r2_score
import argparse
import matplotlib as mpl
mpl.rc('figure', max_open_warning = 0) # Mute plt max_opening_warning
import csv
from csv import reader

class bcolors:
    """
    Reference from: 
    https://svn.blender.org/svnroot/bf-blender/trunk/blender/build_files/scons/tools/bcolors.py
    """
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def plot_charts(
    labels, scaled_area, scaled_leakage, scaled_dynamic, computing, path
):
    fig = plt.figure()
    ax1 = fig.add_subplot(221)
    ax1.pie(scaled_area*1000000, labels=labels,startangle=90, explode = [0.1]*6, autopct='%1.1f%%')
    ax1.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
    ax1.set_title("Area Breakdown")

    ax2 = fig.add_subplot(222)
    ax2.pie(scaled_leakage*1000000, labels=labels,startangle=90, explode = [0.1]*6, autopct='%1.1f%%')
    ax2.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
    ax2.set_title("Leakage Power Breakdown")

    ax3 = fig.add_subplot(223)
    ax3.pie(scaled_dynamic*1000000, labels=labels,startangle=90, explode = [0.1]*6, autopct='%1.1f%%')
    ax3.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
    ax3.set_title("Dynamic Power Breakdown")
    
    #plt.legend(labels)
    #labels = [f'{l}, {s:0.1f}%' for l, s in zip(labels, len(labels))]
    #plt.legend(loc='right', labels=labels)
    plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))
    fig.suptitle(f'{path}{computing}')

    plt.savefig(f"{path}/breakdown_{computing}.png")

def power_report(
    dir_string = None
):
    """
    Partition format = [cnt, rng, reg, cmp, pc, rest]
    """
    flat_file = open(dir_string + "FC_flat_power.txt", "r")
    hier_file = open(dir_string + "FC_hier_power.txt", "r")
    real_power = power_total_report(flat_file)
    pct_power = power_hier_report(hier_file)
    #print(pct_power)

    pct_power = np.array(pct_power)
    # print(pct_power)
    # print(real_power)
    partition_power = [(x[0]*real_power[0], x[1]*real_power[1]) for x in pct_power ]
    #partition_power = np.array(partition_power)
    # print(partition_power)
    # check result
    sum_dy = sum([x[0] for x in partition_power])
    tot_dy = real_power[0]
    if abs(sum_dy-tot_dy)>0.05: 
        print(bcolors.WARNING + f"Warning: check dynamic sum, sum={sum([x[0] for x in partition_power])}, real={real_power[0]}"+ bcolors.ENDC)
    if abs(sum([x[1] for x in partition_power])-real_power[1])>0.05:
        print(bcolors.WARNING + f"Warning: check leakage sum, sum={sum([x[1] for x in partition_power])}, real={real_power[1]}" + bcolors.ENDC)

    return real_power, partition_power

def power_hier_report(
    file=None
):
    """
    all outputs have the unit of mW
    """
    assert "hier_power" in file.name, print("Only hier report should be parsed to get subcomponent power!") 
    hier_power = (-1, -1)
    print(file.name)
    for entry in file:
        elems = entry.strip().split(' ')
        elems = prune(elems)
        
        if len(elems) <= 2 and len(elems) > 0:
            if str(elems[0]) == "U_weight_temporal_cnt" and str(elems[1]) == "(cnt_temporal)":
                #print("Found", elems)
                elems_n = next(file, '').strip().split(' ')
                elems_n = prune(elems_n)
                #print(elems_n)
                dy_cnt = float(elems_n[0]) + float(elems_n[1])
                lk_cnt= float(elems_n[2])

        elif len(elems) >= 4:
            ##### unit ####
            if str(elems[0]) == "Dynamic" and str(elems[1]) == "Power" and str(elems[2]) == "Units" and str(elems[3]) == "=":
                if "uW" in elems[4]:
                    dynamic_div_const = 1000.0
                elif "nW" in elems[4]:
                    dynamic_div_const = 1000000.0
                elif "mW" in elems[4]:
                    dynamic_div_const = 1
                elif "pW" in elems[4]:
                    dynamic_div_const = 1000000000.0
            if str(elems[0]) == "Leakage" and str(elems[1]) == "Power" and str(elems[2]) == "Units" and str(elems[3]) == "=":
                if "uW" in elems[4]:
                    leakage_div_const = 1000.0
                elif "nW" in elems[4]:
                    leakage_div_const = 1000000.0
                elif "mW" in elems[4]:
                    leakage_div_const = 1
                elif "pW" in elems[4]:
                    leakage_div_const = 1000000000.0

            if str(elems[0]) == "FC":
                dy_hier = float(elems[1]) + float(elems[2])
                lk_hier = float(elems[3])

            if str(elems[0]) == "U_ReLU" and str(elems[1]) == "(ReLU)":
                dy_rest_relu = float(elems[2]) + float(elems[3])
                lk_rest_relu = float(elems[4])

            if str(elems[0]) == "U_accumulator" and str(elems[1]) == "(accumulator)":
                dy_reg_acc = float(elems[2]) + float(elems[3])
                lk_reg_acc= float(elems[4])

            if str(elems[0]) == "U_pc" and str(elems[1]) == "(PC)":
                dy_pc = float(elems[2]) + float(elems[3])
                lk_pc = float(elems[4])

            if str(elems[0]) == "U_comb_mult" and str(elems[1]) == "(comb_mult)":
                dy_rest_mul = float(elems[2]) + float(elems[3])
                lk_rest_mul = float(elems[4])

            if str(elems[0]) == "U_weight_temporal_cmp" and str(elems[1]) == "(cmp_weight)":
                dy_cmp_wei = float(elems[2]) + float(elems[3])
                lk_cmp_wei= float(elems[4])

            if str(elems[0]) == "U_input_rate_cmp" and str(elems[1]) == "(cmp_input)":
                dy_cmp_input = float(elems[2]) + float(elems[3])
                lk_cmp_input = float(elems[4])

            if str(elems[0]) == "U_input_rng" and str(elems[1]) == "(SobolRNGDim1)":
                dy_rng = float(elems[2]) + float(elems[3])
                lk_rng= float(elems[4])
            
            if str(elems[0]) == "U_reg_weight" and str(elems[1]) == "(wreg)":
                dy_reg_wreg = float(elems[2]) + float(elems[3])
                lk_reg_wreg = float(elems[4])


    cnt_ = (dy_cnt, lk_cnt)
    rng_ = (dy_rng, lk_rng)
    reg_ = (dy_reg_acc + dy_reg_wreg, lk_reg_acc+lk_reg_wreg)
    cmp_ = (dy_cmp_input + dy_cmp_wei, lk_cmp_input+lk_cmp_wei)
    pc_ = (dy_pc, lk_pc)
    rest_ = (dy_rest_mul + dy_rest_relu, lk_rest_relu + lk_rest_mul)
    power = [cnt_, rng_, reg_, cmp_, pc_, rest_] # absolute val
    if abs(sum([x[0] for x in power]) - dy_hier) > 0.05*dynamic_div_const: 
        print(bcolors.WARNING + f"Warning: Check parsing, dynamic sum()={sum([x[0] for x in power])}, total={dy_hier}" + bcolors.ENDC)
    if abs(sum([x[1] for x in power]) - lk_hier) > 0.05*leakage_div_const: 
        print(bcolors.WARNING + f"Warning: Check parsing, leakage sum()={sum([x[1] for x in power])}, total={lk_hier}" + bcolors.ENDC)
    abs_power = [(x[0]/dynamic_div_const, x[1]/leakage_div_const) for x in power]
    pct_power = [(x[0]/dy_hier, x[1]/lk_hier) for x in power]
    return pct_power

def power_total_report(
    file=None
):
    """
    all outputs have the unit of mW
    """
    assert "flat" in file.name, print("Only flat report should be parsed to get total power!") 
    for entry in file:
        elems = entry.strip().split(' ')
        elems = prune(elems)
        if len(elems) >= 6:
            if elems[0] == "Total" and elems[1] == "Dynamic" and elems[2] == "Power" and elems[3] == "=":
                dynamic = float(elems[4])
                unit = str(elems[5])
                if unit == "nW":
                    dynamic /= 1000000.0
                elif unit == "uW":
                    dynamic /= 1000.0
                elif unit == "mW":
                    dynamic *= 1.0
                else:
                    print("Unknown unit for dynamic power:" + unit)

            if elems[0] == "Cell" and elems[1] == "Leakage" and elems[2] == "Power" and elems[3] == "=":
                leakage = float(elems[4])
                unit = str(elems[5])
                if unit == "nW":
                    leakage /= 1000000.0
                elif unit == "uW":
                    leakage /= 1000.0
                elif unit == "mW":
                    leakage *= 1.0
                else:
                    print("Unknown unit for leakage power:" + unit)

    return leakage, dynamic

def area_report(
    dir_string = None
):
    """
    Partition format = [cnt, rng, reg, cmp, pc, rest]
    """
    flat_file = open(dir_string + "FC_flat_area.txt", "r")
    hier_file = open(dir_string + "FC_hier_area.txt", "r")
    real_area = area_total_report(flat_file)
    pct_area = area_hier_report(hier_file)

    partition_area = [x*real_area for x in pct_area ]
    if abs(sum(partition_area)-real_area)>0.05: 
        print(bcolors.WARNING + f"check sum, sum={sum(partition_area)}, real={real_area}" + bcolors.ENDC)
    return real_area, partition_area
    
def area_hier_report(
    file=None
):
    """
    output has the unit of mm^2
    """
    assert "hier_area" in file.name, print("Only hier report should be parsed to get subcomponent area!") 
    icn_area = -1
    hier_area = -1
    print(file.name)
    for entry in file:
        elems = entry.strip().split(' ')
        elems = prune(elems)
        
        if len(elems) >= 1:
            if str(elems[0]) == "Net" and str(elems[1]) == "Interconnect" and str(elems[2]) == "area:":
                rest_icn = float(elems[3]) # Note this is absolute val
                #print("ICN DONE ", rest_icn)

            if str(elems[0]) == "Total" and str(elems[1]) == "cell" and str(elems[2]) == "area:":
                hier_area = float(elems[3])
                #print("HIER DONE ", hier_area)

            if str(elems[0]) == "Total" and str(elems[1]) == "area:":
                if str(elems[2]) != "undefined":
                    if hier_area < float(elems[2]):
                        hier_area = float(elems[2])
                        #print("HIER UPDATED ", hier_area)

            # CMP (input)
            if str(elems[0]) == "U_in_bsg/U_input_rate_cmp":
                cmp_input = float(elems[1])

            # RNG
            if str(elems[0]) == "U_in_bsg/U_input_rng":
                rng_rng = float(elems[1])
            
            # REST (RELU)
            if str(elems[0]) == "U_neuron/U_ReLU":
                rest_relu = float(elems[1])
            
            # REG (ACC)
            if str(elems[0]) == "U_neuron/U_accumulator":
                reg_acc = float(elems[1])
            
            # REST (Mul)
            if str(elems[0]) == "U_neuron/U_comb_mult":
                rest_mul = float(elems[1])
            
            # PC
            if str(elems[0]) == "U_neuron/U_pc":
                pc_ = float(elems[1])
            
            # REG (wreg)
            if str(elems[0]) == "U_reg_weight":
                reg_wreg = float(elems[1])
            
            # CMP (weight)
            if str(elems[0]) == "U_weight_bsg/U_weight_temporal_cmp":
                elems_n = next(file, '').strip().split(' ')
                elems_n = prune(elems_n)
                cmp_wei = float(elems_n[0])

            
            # CNT
            if str(elems[0]) == "U_weight_bsg/U_weight_temporal_cnt":
                elems_n = next(file, '').strip().split(' ')
                elems_n = prune(elems_n)
                cnt_ = float(elems_n[0])
    
    rng_ = rng_rng
    reg_ = reg_acc + reg_wreg
    cmp_ = cmp_input + cmp_wei
    rest_ = rest_mul + rest_relu + rest_icn
    area = [cnt_, rng_, reg_, cmp_, pc_, rest_] # absolute val
    if abs(sum(area) - hier_area) > 0.05: 
        print(bcolors.WARNING + f"Warning: Check parsing, sum()={sum(area)}, total={hier_area}" + bcolors.ENDC)
    abs_area = [x/1000000.0 for x in area]
    pct_area = [x/hier_area for x in area]
    return pct_area

def area_total_report(
    file=None
):
    """
    output has the unit of mm^2
    """
    assert "flat" in file.name, print("Only flat report should be parsed to get total area!") 
    #print(file)
    for entry in file:
        elems = entry.strip().split(' ')
        elems = prune(elems)
        if len(elems) >= 3:
            if str(elems[0]) == "Total" and str(elems[1]) == "cell" and str(elems[2]) == "area:":
                area = float(elems[3])

            if str(elems[0]) == "Total" and str(elems[1]) == "area:":
                if str(elems[2]) != "undefined":
                    if area < float(elems[2]):
                        area = float(elems[2])
                    
    area /= 1000000.0
    return area

def profile(
    path=None,
    computing=None,
    prefix=None,
    multiplication_const=1
):
    """
    unit: area (mm^2), leakage (mW), dynamic (mW)
    """
    area_file = open(path + "/" + computing + "/" + prefix + "_area.txt", "r")
    area = area_report(area_file)
    power_file = open(path + "/" + computing + "/" + prefix + "_power.txt", "r")
    leakage, dynamic = power_report(power_file)
    area_file.close()
    power_file.close()
    return area*multiplication_const, leakage*multiplication_const, dynamic*multiplication_const

def get_list(cfg='rvt', data='area', item='Total'):
    """
    Returns [data] list of [item] under [cfg] config.
    By default returns 'area' list of 'Total' under 'rvt' config.
    Format: [fc5, fc6, fc3_fold0, fc3_fold2, fc3_fold4]
    Unit: 
        - Frequency: KHz
        - Area: mm^2
        - Power: uW
    """
    
    if data == 'freq': 
        freq_H0 = 131.072 #kHz
        freq_H1 = 262.144 #kHz
        freq_H2 = 524.288 #kHz
        return [freq_H0, freq_H0, freq_H0, freq_H1, freq_H2]
    ## Parse cfg
    if cfg == 'rvt': file_ = 'report_32nm_rvt.csv'
    elif cfg == 'hvt': file_ = 'report_32nm_hvt.csv'
    else: 
        print(f'Bad cfg {cfg}. Valid options are rvt and hvt')
        exit()
        
    # Parse item
    try:
        with open(file_, 'r') as read_obj:
            csv_reader = reader(read_obj)
            for header_row in csv_reader:
                break
    except IOError:
        print(bcolors.FAIL + f"Error: No {file_} found! Did you forget to call regen_stats()?\n" + bcolors.ENDC)
        exit()

    if item == '': 
        print(f"Bad item {item}. Valid options are {header_row[2:]}. Note: all caps for components.")
        exit()
    
    # Parse data
    gather_ind = [0,3,6,9,12]
    if data == 'area': pass
    elif data == 'leakage': gather_ind = [x+1 for x in gather_ind];#print(gather_ind)
    elif data == 'dynamic': gather_ind = [x+2 for x in gather_ind]
    elif data == 'power':
        leakage_list = get_list(cfg, 'leakage', item)
        dynamic_list = get_list(cfg, 'dynamic', item)
        list_ = [x + y for x, y in zip(leakage_list, dynamic_list)]
        return list_
    else:
        print(f'Bad data {data}. Valid options are area, leakage, dynamic, power')
        exit()
    
    list_ = []
    ind = header_row.index(item)
    #print(ind)
    all_data = return_indexed_elems(input_csv=file_, index=ind)
    
    list_.append(np.take(all_data, gather_ind)) # fold 0 2 4
    return list_

def return_indexed_elems(input_csv=None, index=None):
    l = []

    csv_file = open(input_csv, "r")
    
    first = True
    for entry in csv_file:
        if first == True:
            first = False
            continue

        elems = entry.strip().split(',')
        elems = prune(elems)
        if len(elems) > 0:
            l.append(float(elems[index]))
    
    csv_file.close()

    return l

def prune(input_list):
    l = []

    for e in input_list:
        e = e.strip() # remove the leading and trailing characters, here space
        if e != '' and e != ' ':
            l.append(e)

    return l

def main():
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('--silence', default=False, action='store_true', help='Mute ploting figures')
    parser.add_argument('--no_update', default=False, action='store_true', help='Skip regenerating updated stats csv')
    args = parser.parse_args()

    if args.no_update == False:
        # Call regen_stats() once before get_list()
        regen_stats(args.silence)
    else: # no update, direct parse
        print(get_list('rvt', 'area', 'Total'))
        print(get_list('rvt', 'leakage', 'CMP'))
        print(get_list('rvt', 'freq'))
    
def regen_stats(silence=False):
    print("************ Parsing Syn Results**************\n")

    syn_cfg = ['32nm_rvt', '32nm_hvt']
    cfg_layer = ["fc5_6", "fold0", "fold2", "fold4"]
    layers_last = ["fc_64_2", "fc_64_5"]
    layers_regress = ["fc_regress1_110_4", "fc_regress2_110_8", "fc_regress3_110_16"]
    

    labels = ['Total','CNT', 'RNG', 'REG', 'CMP', 'PC', 'REST']
    #generate report for each synthesis configuration
    for cfg in syn_cfg:
        print(bcolors.OKGREEN + cfg + bcolors.ENDC)

        # write the csv header
        filename = f'report_{cfg}.csv'
        with open(filename, 'w', newline="") as f:
            csvwriter = csv.writer(f)
            csvwriter.writerow(np.hstack((['',''], labels)))
            f.close()
        
        for l_cfg in cfg_layer:
            print(bcolors.OKBLUE + l_cfg + bcolors.ENDC)
            if "fold" not in l_cfg: 
                layers = layers_last

                for layer in layers:
                    #Area report
                    real_area, partition_area = area_report(f"./{cfg}/{l_cfg}/{layer}/")
                    partition_area_ = np.hstack((real_area, partition_area))

                    #Power report
                    real_power, partition_power = power_report(f"./{cfg}/{l_cfg}/{layer}/")
                    partition_power_ = np.vstack((real_power, partition_power))
                    

                    # Write report to csv
                    with open(filename, 'a', newline="") as f:
                        csvwriter = csv.writer(f)
                        str_cfg = layer
                        csvwriter.writerow(np.hstack((str_cfg, 'area',partition_area_)))
                        csvwriter.writerow(np.hstack((str_cfg,'leakage',[power[1] for power in partition_power_])))
                        csvwriter.writerow(np.hstack((str_cfg,'dynamic',[power[0] for power in partition_power_])))
                        f.close()
                    
                    # Plot pie chart
                    if silence == False: 
                        partition_dynamic = [x[0] for x in partition_power]
                        partition_leakage = [x[1] for x in partition_power]
                        plot_charts(
                            labels=labels[1:], 
                            scaled_area=np.array(partition_area), 
                            scaled_leakage=np.array(partition_leakage), 
                            scaled_dynamic=np.array(partition_dynamic), 
                            computing=layer, 
                            path=f"./{cfg}/{l_cfg}/{layer}/")
            else: 
                regress_area = []
                regress_dynamic = []
                regress_leakage = []

                layers = layers_regress

                for layer in layers:
                    #Area report
                    real_area, partition_area = area_report(f"./{cfg}/{l_cfg}/{layer}/")
                    partition_area = np.hstack((real_area, partition_area))

                    #Power report
                    real_power, partition_power = power_report(f"./{cfg}/{l_cfg}/{layer}/")
                    partition_power = np.vstack((real_power, partition_power))
                    partition_power = np.array(partition_power)
                
                    partition_dynamic = [x[0] for x in partition_power]
                    partition_leakage = [x[1] for x in partition_power]

                    regress_area.append(partition_area)
                    regress_dynamic.append(partition_dynamic)
                    regress_leakage.append(partition_leakage)
                
                # Regression
                reg_log = ""

                reg_log, pred_area, pred_leakage, pred_dynamic = fc_regression(
                    f"./{cfg}/{l_cfg}/",
                    reg_log, np.array(regress_area), 
                    np.array(regress_leakage), 
                    np.array(regress_dynamic),
                    silence)

                file = open(f"./{cfg}/{l_cfg}/reg.cfg", "w")
                file.write(reg_log)
                file.close()

                pred_area_f = np.array(pred_area).flatten().tolist()
                pred_leakage_f = np.array(pred_leakage).flatten().tolist()
                pred_dynamic_f = np.array(pred_dynamic).flatten().tolist()

                # write to csv
                with open(filename, 'a', newline="") as f:
                    csvwriter = csv.writer(f)
                    str_cfg = l_cfg
                    csvwriter.writerow(np.hstack((str_cfg, 'area', pred_area_f)))
                    csvwriter.writerow(np.hstack((str_cfg,'leakage', pred_leakage_f)))
                    csvwriter.writerow(np.hstack((str_cfg,'dynamic',pred_dynamic_f)))
                    f.close()

                # Plot pie chart
                if silence == False:
                    plot_charts(
                        labels=labels[1:], 
                        scaled_area=np.array(pred_area_f[1:]), 
                        scaled_leakage=np.array(pred_leakage_f[1:]), 
                        scaled_dynamic=np.array(pred_dynamic_f[1:]), 
                        computing=l_cfg, 
                        path=f"./{cfg}/{l_cfg}/")

def fc_regression(
    name = None,
    reg_log=None,
    s_area = None,
    s_leakage = None,
    s_dynamic = None,
    silence_plot = False
):
    
    input = np.array([[4],[8],[16]])
    area_reg = [LinearRegression() for i in range(7)]
    leakage_reg = [LinearRegression() for i in range(7)]
    dynamic_reg = [LinearRegression() for i in range(7)]
    for i in range(7):
        area_reg[i].fit(input, s_area.T[i])
        reg_log += "Area"+str(i)+":\t"
        reg_log += str(area_reg[i].coef_[0]) + ",\t" + str(area_reg[i].intercept_) + ",\t\n"
        
        leakage_reg[i].fit(input, s_leakage.T[i])
        reg_log += "Leakage"+str(i)+":\t"
        reg_log += str(leakage_reg[i].coef_[0]) + ",\t" + str(leakage_reg[i].intercept_) + ",\t\n"
        
        dynamic_reg[i].fit(input, s_dynamic.T[i])
        reg_log += "Dynamic"+str(i)+":\t"
        reg_log += str(dynamic_reg[i].coef_[0]) + ",\t" + str(dynamic_reg[i].intercept_) + ",\t\n"
        
        reg_log += f"area \nMSE[{i}]={mean_squared_error(s_area.T[i], area_reg[i].predict(input))}, R2score={r2_score(s_area.T[i], area_reg[i].predict(input))}\n"
        reg_log += f"dynamic \nMSE[{i}]={mean_squared_error(s_dynamic.T[i], dynamic_reg[i].predict(input))}, R2score={r2_score(s_dynamic.T[i], dynamic_reg[i].predict(input))}\n"
        reg_log += f"leakage \nMSE[{i}]={mean_squared_error(s_leakage.T[i], leakage_reg[i].predict(input))}, R2score={r2_score(s_leakage.T[i], leakage_reg[i].predict(input))}\n\n"

    reg_log += f'110x256 Projection:\n'
    pred = np.log2([[256]])
    pred = [[256]]
    pred_area = [area_reg[i].predict(pred) for i in range(7)]
    pred_leakage = [leakage_reg[i].predict(pred) for i in range(7)]
    pred_dynamic = [dynamic_reg[i].predict(pred) for i in range(7)]
    for i in range(7):
        reg_log += f"predicted area[{i}] = {pred_area[i]}\npredicted dynamic[{i}] = {pred_dynamic[i]}\npredicted leakage[{i}] = {pred_leakage[i]}\n\n"
    
    if silence_plot==False: 
        plot_range = 256
        plot_regress_model(area_reg, plot_range, input, s_area, name, 'Area')
        plot_regress_model(leakage_reg, plot_range, input, s_leakage, name, 'Leakage')
        plot_regress_model(dynamic_reg, plot_range, input, s_dynamic, name, 'Dynamic')
    
    
    return reg_log, pred_area, pred_leakage, pred_dynamic

def plot_regress_model(model, range_, x_train, y_train, path, type='Area'):
    # TODO: fix fig wierd spacing
    xs = np.tile(np.arange(range_), (range_,1))
    fig = plt.figure()
    for i in range(7):
        coefs = model[i].coef_
        intercept = model[i].intercept_
        zs = xs*coefs[0]+intercept
        ax = fig.add_subplot(4,2,i+1)
        ax.scatter(x_train, y_train.T[i], marker='^', color='red')
        ax.set_xlabel("DIM_OUT")
        ax.set_ylabel(type+str(i))
        ax.plot(xs,zs, marker='.', color='black',markersize=1)
    
    fig.suptitle('{} regression for {}'.format(type, path))
    plt.savefig(f'{path}{type}_model.png')

if __name__ == "__main__":
    main()