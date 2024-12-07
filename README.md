## The global Spplice package repository
This is the default repository which [spplice-cpp](https://github.com/p2r3/spplice-cpp) fetches its packages from.

Here, the code for each package is available in its raw, unpackaged, uncompressed form. A GitHub Actions workflow is responsible for automatically building VPKs, packaging everything up, and uploading the resulting `tar.xz` files as a release. The repository index and package icons are served through a GitHub Pages deployment.

## Structure
- Each package has its own directory under `packages/`, named using a descriptive codename in **kebab-case**. This directory must contain at least two entries - a `sources` directory with the source code and assets of the package, and an `icon` file with either the `.jpg` or `.png` extension, at a 16:9 aspect ratio.
- Sources _must_ be provided unpackaged and unobfuscated wherever possible. The GitHub Actions workflow automatically creates a VPK file out of anything located within `sources/pak01_dir`. Packages are compressed with `xzutils` at level 9, so don't worry about minifying code either.
- If you wish to apply a specific license to your work, include it with the sources. If the package contains work which requires other licenses or copyright notices to be present, bundle those with your sources as necessary.
- The `index.json` file at the root of the project is the repository index - a single file containing information about the packages present here, and links to the relevant assets.

## Contributing
If you want to feature your own Spplice mod or package on this repository, simply open a pull request. Make sure to:
1. Adhere to the file structure and format mentioned before. I.e., a `sources` directory and an `icon` file.
2. Respect licenses and copyrights if using custom assets. Include license files along with your sources where applicable.
3. Upload unpackaged and unobfuscated sources wherever possible.
4. Be modest with your package's placement in the repository index.
