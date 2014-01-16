# Extracts a pair of system call names given a unique integer that
# identifes the pair

import sys

def import_sys_call_list():
    global num_of_sys_calls
    global sys_call_dict

    num_of_sys_calls = 0
    sys_call_dict = dict()

    with open("../data/syscalls-list", 'r') as f:
        for line in f:
            sys_call_dict[num_of_sys_calls] = line[:-1]
            num_of_sys_calls += 1

def name(index):
    return sys_call_dict[index]

if __name__ == "__main__":
    sys_call_dict = dict()
    num_of_sys_calls = 0
    import_sys_call_list()

    for line in sys.stdin:
        index = int(line[:-1])
        s1 = index / num_of_sys_calls
        s2 = index % num_of_sys_calls
        print "%d = (%d, %d) = (%s, %s)" % (index, s1, s2, name(s1), name(s2))
