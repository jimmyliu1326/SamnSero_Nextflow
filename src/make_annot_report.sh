#! /usr/bin/env sh
args=$@
R -e 'rmarkdown::render("/annot_report.Rmd")' --args $args