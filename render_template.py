from argparse import ArgumentParser
import yaml
from pathlib import Path

import jinja2 as jj
from jinja2.utils import select_autoescape

def main() -> None:
    """Render template query"""
    parser = ArgumentParser()
    parser.add_argument(
        "template",
        nargs="?",
        type=str,
        help="name of the template file to render (with extensions)",
    )
    parser.add_argument(
        "--path",
        nargs="?",
        type=str,
        default=None,
        help="relative path to file",
    )
    args = parser.parse_args()

    with open("config.yaml", mode='r', encoding="utf-8") as config_file:
        config = yaml.load(config_file, Loader=yaml.FullLoader)

    template_dir = Path(__file__).resolve().parent / (args.path if args.path else "")
    print(template_dir)
    template_dir = [path for path in template_dir.glob("**") if path.is_dir()]

    template_loader = jj.FileSystemLoader(searchpath=template_dir)
    _template_env = jj.Environment(
        autoescape=select_autoescape(["sql"]), loader=template_loader
    )
    template = _template_env.get_template(
        args.template
    )
    rendered_template = template.render(config)

    print(rendered_template)

    with open("rendered_sql.txt", mode='w', encoding="utf-8") as sql_file:
        sql_file.write(rendered_template)

if __name__ == "__main__":
    main()
