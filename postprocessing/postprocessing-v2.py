#!/usr/bin/env python3

import argparse
import gzip
import sys
import logging
import tempfile
import shutil

# --------------------------------------------------------------------------
# Functions
# --------------------------------------------------------------------------

def severity_order_key(severity_order, consequence_index, canonical_index, annotation):
    """
    Returns a tuple for sorting each annotation string by:
      1) severity (lowest index in severity_order is more severe),
      2) canonical transcript preference (CANONICAL == 'YES' is favored).
    """
    fields = annotation.split('|')
    # The 'Consequence' can be multiple values separated by '&'
    # We find the "most severe" by looking for the min index in severity_order
    all_cons = fields[consequence_index].split('&')
    top_sev = min(severity_order.index(cons) for cons in all_cons if cons in severity_order)

    # canonical_index points to the CANONICAL field
    canonical_val = fields[canonical_index] if canonical_index is not None else 'NO'
    # Sort by severity, then by canonical (YES -> prefer -> sort as False)
    return (top_sev, canonical_val != 'YES')

def find_most_severe(severity_order, consequence_index, canonical_index, csq_string):
    """
    Given a comma-separated string of VEP annotations in `csq_string`,
    return the single most-severe annotation (lowest severity_order index).
    """
    annotations = csq_string.split(',')
    prioritized = sorted(
        annotations,
        key=lambda ann: severity_order_key(severity_order, consequence_index, canonical_index, ann)
    )
    return prioritized[0]


class DataTypeInferrer:

    def __init__(self):
        self.is_int = True
        self.is_float = True
    
    def update(self, value):
        if value != "":
            if self.is_int:
                try:
                    int(value)
                except:
                    self.is_int = False
            if self.is_float:
                try:
                    float(value)
                except:
                    self.is_float = False

    def typename(self):
        if self.is_int:
            return "Integer"
        elif self.is_float:
            return "Float"
        else:
            return "String"

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description='''
        Read a VCF (possibly .gz), extract the single most severe VEP annotation
        (from INFO/CSQ), and convert it into separate INFO fields with a VEP_
        prefix. CSQ is then removed. Optionally skip variants by severity.
    ''')
    parser.add_argument('input_vcf', help='Input VCF file (can be .vcf or .vcf.gz)')
    parser.add_argument('output_vcf', type=argparse.FileType('w'), nargs='?', default='-',
                        help='Output VCF file (uncompressed .vcf). If not provided, stdout.')
    parser.add_argument('--severity-file', default='ref/variant_consequences_v2.txt',
                        help='File with ordered list of consequences, from most to least severe.')
    parser.add_argument('--tempfile', type=str, help='Temporary file to write (uses system temp by default).')
    parser.add_argument('--filter-variants-severity', default='intergenic_variant,downstream_gene_variant,upstream_gene_variant',
                        help='Comma-separated list of consequences to skip (filter) entirely.')
    parser.add_argument('--compounds-max-length', default=1000,
                        help='Truncate Compounds and CompoundsNormalized INFO fields to this length.')
    args = parser.parse_args()

    logging.basicConfig(stream=sys.stderr, level=logging.INFO)

    # Read in severity order
    with open(args.severity_file, 'r') as f:
        severity_order = [line.strip() for line in f if line.strip()]

    # Parse user-specified severities to remove
    filter_out_severities = set(args.filter_variants_severity.split(','))

    # Decide how to open the VCF
    if args.input_vcf.endswith(".gz"):
        open_func = gzip.open
    else:
        open_func = open

    # Creates a temp file to write the body of the VCF before creating the headers.
    # It's necessary to first process the entire VCF in order to infer the data types to use in the
    # header.
    if args.tempfile:
        temp_body = open(args.tempfile, "w+")
    else:
        temp_body = tempfile.TemporaryFile(mode="w+")

    # We will collect the CSQ field structure (so we know which index is Consequence, CANONICAL, etc.)
    csq_fields = []
    consequence_index = None
    canonical_index = None

    total_variants = 0
    kept_variants = 0

    with open_func(args.input_vcf, 'rt') as vcf:
        header_lines = []
        chrom_line = None

        for line in vcf:
            if line.startswith('##INFO=<ID=CSQ'):
                # Example line:
                # ##INFO=<ID=CSQ,Number=.,Type=String,Description="Consequence annotations from Ensembl VEP. Format: Allele|Consequence|IMPACT|...">
                # We'll extract the portion after 'Format: '
                if 'Format:' in line:
                    format_index = line.index('Format:') + len('Format:')
                    format_string = line[format_index:].strip().strip('">')
                    csq_fields = format_string.split('|')
                    csq_datatypes = [DataTypeInferrer() for _ in csq_fields]
                    # Identify these positions, if present
                    if 'Consequence' in csq_fields:
                        consequence_index = csq_fields.index('Consequence')
                    if 'CANONICAL' in csq_fields:
                        canonical_index = csq_fields.index('CANONICAL')

                # Keep original CSQ header line? No, we remove that annotation.
                #args.output_vcf.write(line)

            elif line.startswith('##'):
                # Other VCF header lines (meta-information). Can write immediately, we don't need to change them.
                args.output_vcf.write(line)

            elif line.startswith('#CHROM'):
                chrom_line = line

                # Validate we found essential fields
                if consequence_index is None:
                    raise ValueError("Consequence field not found in the CSQ format description.")
                # CANONICAL is optional, but let's warn if it's not there
                if canonical_index is None:
                    logging.warning("No CANONICAL field found in CSQ header; canonical transcripts won't be prioritized.")
                    
            else:
                if not chrom_line:
                    raise ValueError("Invalid format, missing #CHROM line.")
                # Data line (a variant)
                total_variants += 1
                parts = line.strip().split('\t')

                # Parse the INFO column
                info_field = parts[7]
                info_items = [x for x in info_field.split(';') if '=' in x]
                info_data = dict(item.split('=', 1) for item in info_items)

                # It's also possible some info flags have no '='. We'll keep them as well.
                # E.g. "DP=100;SOMATIC;AN=2"
                # We'll store them here for re-adding later:
                info_flags = [x for x in info_field.split(';') if '=' not in x]

                # If CSQ present, find the single most severe annotation
                if 'CSQ' in info_data:
                    csq_string = info_data['CSQ']
                    most_severe = find_most_severe(severity_order, consequence_index,
                                                   canonical_index, csq_string)
                    consequence_value = most_severe.split('|')[consequence_index]
                    if consequence_value in filter_out_severities:
                        # Skip/continue, do not write
                        continue

                    # Convert the most severe annotation to separate INFO keys:
                    annotation_fields = most_severe.split('|')
                    for idx, value in enumerate(annotation_fields):
                        key = f'VEP_{csq_fields[idx]}'
                        # Store in info_data
                        # If a field is empty, we might choose to skip it or set it to '.'
                        info_data[key] = value if value else '.'
                        csq_datatypes[idx].update(value)

                    # Remove the original CSQ so that downstream tools don't get confused
                    del info_data['CSQ']
                
                # Truncate long strings
                if args.compounds_max_length != -1:
                    if "Compounds" in info_data:
                        info_data["Compounds"] = info_data["Compounds"][:args.compounds_max_length]
                    if "CompoundsNormalized" in info_data:
                        info_data["CompoundsNormalized"] = info_data["CompoundsNormalized"][:args.compounds_max_length]

                # Rebuild the INFO string
                new_info_list = []
                for k, v in info_data.items():
                    new_info_list.append(f"{k}={v}")
                # Also add back in any flags (those that had no '=')
                new_info_list.extend(info_flags)

                parts[7] = ";".join(new_info_list)
                temp_body.write('\t'.join(parts) + '\n')
                kept_variants += 1

    # Add an INFO header for each of the new VEP_ fields:
    #   E.g. ##INFO=<ID=VEP_Allele,Number=1,Type=String,Description="From VEP CSQ: Allele">
    # This can help downstream tools. We'll do it if we found the CSQ fields:
    if csq_fields:
        for f_name, f_type in zip(csq_fields, csq_datatypes):
            info_hdr = f'##INFO=<ID=VEP_{f_name},Number=1,Type={f_type.typename()},Description="From VEP CSQ: {f_name}">\n'
            args.output_vcf.write(info_hdr)

    # The VCF column header line
    # Insert a note about this script
    args.output_vcf.write("##postprocess_vcf=convertCSQtoINFO\n")
    args.output_vcf.write("##postprocess_vcf_args=" + " ".join(sys.argv[1:]) + "\n")
    args.output_vcf.write(chrom_line)

    logging.info("Reformatting complete, copying temporary data.")

    temp_body.flush()
    temp_body.seek(0)
    shutil.copyfileobj(temp_body, args.output_vcf)

    logging.info("Processing complete.")
    logging.info(f"Kept {kept_variants} out of {total_variants} variants.")

if __name__ == '__main__':
    main()

