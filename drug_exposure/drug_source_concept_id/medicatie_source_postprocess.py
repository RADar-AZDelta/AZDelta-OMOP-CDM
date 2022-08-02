## Run this script on the mzg_usagi file in the condition_concept_id folder
from argparse import ArgumentParser
from pathlib import Path
import polars as pl


def main() -> None:
    """Postprocess medication usagi"""
    parser = ArgumentParser()
    parser.add_argument(
        "source",
        nargs="?",
        type=Path,
        help="name of the unprocessed usagi file (with extension)",
    )
    parser.add_argument(
        "--target",
        nargs="?",
        type=str,
        default="medicatie_source_usagi.csv",
        help="name of the post-processed usagi file (with extension)",
    )
    args = parser.parse_args()

    file_path = Path(args.source).resolve()

    usagi = pl.read_csv(file_path)
    usagi.drop_in_place("conceptId")
    usagi = usagi.rename({"ADD_INFO:ATC":"conceptId"})

    usagi.to_csv(Path(__file__).parent / args.target)


if __name__ == "__main__":
    main()
