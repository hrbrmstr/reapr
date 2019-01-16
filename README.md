
[![Travis-CI Build
Status](https://travis-ci.org/hrbrmstr/reapr.svg?branch=master)](https://travis-ci.org/hrbrmstr/reapr)
[![Coverage
Status](https://codecov.io/gh/hrbrmstr/reapr/branch/master/graph/badge.svg)](https://codecov.io/gh/hrbrmstr/reapr)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/reapr)](https://cran.r-project.org/package=reapr)

# reapr

Reap Information from Websites

## Description

This will eventually be a clever description about web scraping with
reapr.

## What’s Inside The Tin

The following functions are implemented:

  - `reap_url`: Read HTML content from a URL

## Installation

``` r
devtools::install_git("https://gitlab.com/hrbrmstr/reapr.git")
# or
devtools::install_github("hrbrmstr/reapr")
```

## Usage

``` r
library(reapr)

# current version
packageVersion("reapr")
## [1] '0.1.0'
```

## Basic Reaping

``` r
x <- reap_url("http://rud.is/b")

x
##                Title: rud.is | "In God we trust. All others must bring data"
##         Original URL: http://rud.is/b
##            Final URL: https://rud.is/b/
##           Crawl-Date: 2019-01-16 13:24:44
##               Status: 200
##         Content-Type: text/html; charset=UTF-8
##                 Size: 50 kB
##           IP Address: 104.236.112.222
##                 Tags: body[1], center[1], form[1], h2[1], head[1], hgroup[1], html[1],
##                       label[1], noscript[1], section[1], title[1],
##                       aside[2], nav[2], ul[2], style[5], img[6],
##                       input[6], article[8], time[8], footer[9], h1[9],
##                       header[9], p[10], li[19], meta[20], div[31],
##                       script[40], span[49], link[53], a[94]
##           # Comments: 17
##   Total Request Time: 1.949s
```

## reapr Metrics

| Lang | \# Files |  (%) | LoC |  (%) | Blank lines |  (%) | \# Lines |  (%) |
| :--- | -------: | ---: | --: | ---: | ----------: | ---: | -------: | ---: |
| R    |        6 | 0.67 | 112 | 0.81 |          46 | 0.64 |       86 | 0.69 |
| C    |        2 | 0.22 |  17 | 0.12 |           5 | 0.07 |        4 | 0.03 |
| Rmd  |        1 | 0.11 |   9 | 0.07 |          21 | 0.29 |       34 | 0.27 |

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
