from argparse import ArgumentParser
from pathlib import Path
import polars as pl


def main() -> None:
    """Postprocess medication usagi"""
    parser = ArgumentParser()
    parser.add_argument(
        "source",
        nargs="?",
        type=str,
        help="name of the unprocessed usagi file (with extension)",
    )
    parser.add_argument(
        "--target",
        nargs="?",
        type=str,
        default="medicatie_usagi.csv",
        help="name of the post-processed usagi file (with extension)",
    )
    args = parser.parse_args()

    file_path = Path(args.source).resolve()

    usagi = pl.read_csv(file_path)
    usagi = usagi.filter((pl.col("mappingStatus") == "APPROVED") & (pl.col("conceptId") != 0))
    usagi = usagi.with_column(pl.col("ADD_INFO:prescriptionID").str.split('-'))
    usagi = usagi.explode("ADD_INFO:prescriptionID")
    usagi_without_prescr = usagi.filter(pl.col("ADD_INFO:prescriptionID").is_null())
    usagi_with_prescr = usagi.filter(pl.col("ADD_INFO:prescriptionID").is_not_null())
    usagi_with_prescr = usagi_with_prescr.with_column(pl.col("sourceCode") + "_" + pl.col("ADD_INFO:prescriptionID"))
    usagi = pl.concat([usagi_without_prescr, usagi_with_prescr])
    usagi.write_csv(file_path.parent / args.target)


if __name__ == "__main__":
    main()
