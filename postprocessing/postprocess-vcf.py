import argparse
import gzip
import sys

# Setup command-line argument parser
parser = argparse.ArgumentParser(description='Extract and annotate most severe consequences from VCF CSQ field.')
parser.add_argument('input_vcf', help='Input VCF file (can be .vcf or .vcf.gz)')
parser.add_argument('output_vcf', type=argparse.FileType('w'), nargs='?', default='-',
                    help='Output VCF file (uncompressed .vcf). If not provided, will be written to stdout.')
parser.add_argument('--severity_file', help='File with sorted list of consequences by severity', default='ref/variant_consequences_v2.txt')

args = parser.parse_args()

# Function to parse the CSQ field and find the most severe consequence
def find_most_severe(csq_string, severity_order):
    consequences = csq_string.split(',')
    parsed_consequences = [c.split('|') for c in consequences]
    parsed_consequences.sort(key=lambda x: severity_order.index(x[1]) if x[1] in severity_order else len(severity_order))
    return parsed_consequences[0]

# Load severity order from a file
with open(args.severity_file, 'r') as f:
    severity_order = [line.strip() for line in f]

def process_vcf(input_vcf, out_vcf):
    if input_vcf.endswith('.gz'):
        open_func = gzip.open
    else:
        open_func = open
    with open_func(input_vcf, 'rt') as vcf:
        for line in vcf:
            if line.startswith('##'):
                # VCF header lines
                out_vcf.write(line)
            elif line.startswith('#CHROM'): # This is the table header, containing the column names
                # Add informative header about this program execution
                out_vcf.write("##postprocess_vcf=1.0.0\n")
                out_vcf.write("##postprocess_vcf_args=" + " ".join(sys.argv[1:]) + "\n")
                out_vcf.write(line)
            else:
                # Data section of vcf
                parts = line.strip().split('\t')
                info_field = parts[7]  # INFO column
                info_data = dict(item.split('=') for item in info_field.split(';') if '=' in item)
                if 'CSQ' in info_data:
                    most_severe = find_most_severe(info_data['CSQ'], severity_order)
                    # Create new INFO entry
                    info_data['CSQ'] = "|".join(most_severe)
                    info_field = ";".join(f"{k}={v}" for k, v in info_data.items())
                parts[7] = info_field
                out_vcf.write('\t'.join(parts) + '\n')

process_vcf(args.input_vcf, args.output_vcf)
