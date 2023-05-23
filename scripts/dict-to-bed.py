import sys

for line in open(sys.argv[1]):
    parts = line.strip().split('\t')
    key_values = dict(
        kv.split(":")
        for kv in parts
        if kv.count(":") == 1
    )
    if 'SN' in key_values:
        if not any(bl in key_values['SN'] for bl in ['random', 'chrUn', 'chrEBV']):
            print(key_values['SN'], 1, key_values['LN'], sep='\t')