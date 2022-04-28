#! /usr/bin/env sh
args=$@
R -e 'rmarkdown::render("/qc_report.Rmd")' --args $args