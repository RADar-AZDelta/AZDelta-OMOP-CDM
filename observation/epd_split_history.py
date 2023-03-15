## Run this script on the epd_usagi file in the observation_concept_id folder and epd_value_usagi in the value_as_concept_id folder
## Adds procedures following "History of event" to the epd_value_usagi

from argparse import ArgumentParser
from pathlib import Path
import polars as pl


def main() -> None:
    """Postprocess epd usagi"""
    parser = ArgumentParser()
    parser.add_argument(
        "--usagi",
        nargs="?",
        type=Path,
        help="name of the unprocessed usagi file (with extension)",
    )
    parser.add_argument(
        "--values",
        nargs="?",
        type=Path,
        help="name of the unprocessed usagi_value file (with extension)",
    )
    args = parser.parse_args()

    usagi_file_path = Path(args.usagi).resolve()
    values_file_path = Path(args.values).resolve()
    
    usagi = pl.read_csv(usagi_file_path)
    values = pl.read_csv(values_file_path)

    history_sourcecodes = usagi.filter(pl.col("conceptId") == 1340204).get_column("sourceCode").unique().to_list()
    history_value_usagi = usagi.filter(pl.col("sourceCode").is_in(history_sourcecodes) & (pl.col("conceptId") != 1340204))
    values = values.vstack(history_value_usagi).unique()
    values.write_csv(values_file_path)

if __name__ == "__main__":
    main()
