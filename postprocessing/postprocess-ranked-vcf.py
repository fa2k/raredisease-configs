import argparse
import gzip
import sys
import logging

# Setup command-line argument parser
parser = argparse.ArgumentParser(description='Extract and annotate most severe consequences from VCF CSQ field.')
parser.add_argument('input_vcf', help='Input VCF file (can be .vcf or .vcf.gz)')
parser.add_argument('output_vcf', type=argparse.FileType('w'), nargs='?', default='-',
                    help='Output VCF file (uncompressed .vcf). If not provided, will be written to stdout.')
parser.add_argument('--severity-file', help='File with sorted list of consequences by severity', default='ref/variant_consequences_v2.txt')
parser.add_argument('--filter-variants-severity', default='intergenic_variant,downstream_gene_variant,upstream_gene_variant', 
                    help='Remove variants with these specific consequences (comma-separated list)')

args = parser.parse_args()

def severity_order_key(severity_order, consequence_index, canonical_index, consequence):
    """Return a key for sorting consequences by severity, and preferring canonical transcripts
    as a tie-breaker."""

    consequence_string = consequence.split('|')[consequence_index]
    top_severity = min(
        [severity_order.index(cons) for cons in consequence_string.split('&')]
    )
    canonical_string = consequence.split('|')[canonical_index]
    # Return a tuple for sorting. Lower value is more severe, and canonical is preferred.
    return (top_severity, canonical_string != 'YES')

# Function to parse the CSQ field and find the most severe consequence
def find_most_severe(severity_order, consequence_index, canonical_index, csq_string):
    consequences = csq_string.split(',')
    prioritised_consequences = sorted(
        consequences,
        key=lambda x: severity_order_key(severity_order, consequence_index, canonical_index, x)
    )
    return prioritised_consequences[0]

# Load severity order from a file
with open(args.severity_file, 'r') as f:
    severity_order = [line.strip() for line in f]

def process_vcf(input_vcf, out_vcf, severity_order, filter_variants_severity):
    if input_vcf.endswith('.gz'):
        open_func = gzip.open
    else:
        open_func = open
    consequence_index = None
    canonical_index = None
    total_variants = 0
    kept_variants = 0
    with open_func(input_vcf, 'rt') as vcf:
        for line in vcf:
            if line.startswith('##INFO=<ID=CSQ'):
                format_index = line.index('Format:') + len('Format:')
                format_string = line[format_index:].strip()
                consequence_index = format_string.split('|').index('Consequence')
                canonical_index = format_string.split('|').index('CANONICAL')
            if line.startswith('##'):
                # VCF header lines
                out_vcf.write(line)
            elif line.startswith('#CHROM'): # This is the table header, containing the column names
                # Add informative header about this program execution
                out_vcf.write("##postprocess_vcf=1.0.0\n")
                out_vcf.write("##postprocess_vcf_args=" + " ".join(sys.argv[1:]) + "\n")
                out_vcf.write(line)
                # Check that the required information was present in the CSQ field
                if consequence_index is None or canonical_index is None:
                    raise ValueError("Missing information in VCF header. Make sure there is a CSQ field with "
                                     "Consequence and CANONICAL fields.")
            else:
                # Data section of vcf
                total_variants += 1
                parts = line.strip().split('\t')
                info_field = parts[7]  # INFO column
                info_data = dict(item.split('=') for item in info_field.split(';') if '=' in item)
                if 'CSQ' in info_data:
                    most_severe = find_most_severe(severity_order, consequence_index, canonical_index, info_data['CSQ'])
                    # Create new INFO entry
                    info_data['CSQ'] = most_severe

                    # Implement filtering by skipping variants with irrelevant consequences
                    if most_severe.split('|')[consequence_index] in filter_variants_severity:
                        continue
                # List of compounds can grow too large for downstream, and we can't make use of it at
                # the moment.
                info_data.pop("Compounds", None)
                info_data.pop("CompoundsNormalized", None)

                info_field = ";".join(f"{k}={v}" for k, v in info_data.items())
                parts[7] = info_field
                kept_variants += 1
                out_vcf.write('\t'.join(parts) + '\n')
    logging.info(f"Postprocessing complete")
    print (genetic_models)
    logging.info(f"Consequence severity filter kept {kept_variants} out of {total_variants} variants")

process_vcf(args.input_vcf, args.output_vcf, severity_order, args.filter_variants_severity.split(','))
