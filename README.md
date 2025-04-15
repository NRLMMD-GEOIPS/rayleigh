    # # # This source code is subject to the license referenced at
    # # # https://github.com/NRLMMD-GEOIPS.

rayleigh GeoIPS Plugin
======================

The rayleigh package is a GeoIPS-compatible plugin, intended to be used within the GeoIPS ecosystem.
Please see the
[GeoIPS Documentation](https://github.com/NRLMMD-GEOIPS/geoips#readme)
for more information on the GeoIPS plugin architecture and base infrastructure.

Package Overview
-----------------

The rayleigh package includes fortran code for applying Rayleigh
scattering corrections.

System Requirements
---------------------

* geoips >= 1.12.1
* fortran_utils >= 1.12.1
* ancildat >= 1.12.1
* rayleigh >= 1.12.1
* Test data repos contained in $GEOIPS_TESTDATA_DIR for tests to pass.

IF REQUIRED: Install base geoips package
------------------------------------------------------------
SKIP IF YOU HAVE ALREADY INSTALLED BASE GEOIPS ENVIRONMENT

If GeoIPS Base is not yet installed, follow the
[installation instructions](https://github.com/NRLMMD-GEOIPS/geoips#installation)
within the geoips source repo documentation:

Install rayleigh package
----------------------------
```bash
    # Ensure GeoIPS environment is enabled.
    git clone https://github.com/NRLMMD-GEOIPS/fortran_utils $GEOIPS_PACKAGES_DIR/fortran_utils
    git clone https://github.com/NRLMMD-GEOIPS/ancildat $GEOIPS_PACKAGES_DIR/ancildat
    git clone https://github.com/NRLMMD-GEOIPS/rayleigh $GEOIPS_PACKAGES_DIR/rayleigh

    # NOTE: currently, fortran dependencies must be installed separately, initially
    # including in pyproject.toml resulted in incorrect installation paths.
    # More work required to get the pip dependencies working properly for fortran
    # installations via pyproject.toml with the poetry backend.
    pip install -e $GEOIPS_PACKAGES_DIR/fortran_utils
    pip install -e $GEOIPS_PACKAGES_DIR/ancildat
    pip install -e $GEOIPS_PACKAGES_DIR/rayleigh
```

Test rayleigh installation
-----------------------------
```bash

    # Ensure GeoIPS Python environment is enabled.

    # rayleigh package is used for True Color, GeoColor, and other products.
    # Test those products to test rayleigh functionality
```
