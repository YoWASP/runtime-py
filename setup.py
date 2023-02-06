from setuptools import setup
from setuptools_scm.git import parse as parse_git


def version():
    git = parse_git(".")
    version = f"1.{git.distance}"
    if git.dirty:
        version += f"+dirty"
    return version


setup(
    version=version(),
)
