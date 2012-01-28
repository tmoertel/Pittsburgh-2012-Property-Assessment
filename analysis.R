#!/usr/bin/Rscript

### Analysis of Pittsburgh 2012 real-estate assessments
### Tom Moertel <tom@moertel.org>
###
### Sources:
###
### [1] Chris Briem's data set
###     http://nullspace2.blogspot.com/2012/01/statisticum-collegium.html
###     http://www.briem.com/data/CityPittsburgh2012assessment_firstrelease.csv


library(ggplot2)


### Load the data set

pghre <- read.csv("data/CityPittsburgh2012assessment_firstrelease.csv",
                  na.strings = "<")


### Compute assessment and property-tax increases

anti_windfall_scale_factor <-
  with(pghre, (sum(as.numeric(assessment2011), na.rm = T) /
               sum(as.numeric(assessment2012), na.rm = T)))

pghre <- mutate(pghre,
                rel_asm = assessment2012 / assessment2011,
                asm_increase = rel_asm - 1.0,
                ptx_increase = anti_windfall_scale_factor * rel_asm - 1.0)


## Given a data frame and ddply-style arguments, partition the frame
## using ddply and summarize the values in each partition with a
## quantized ecdf.  The resulting data frame for each partition has
## two columns: value and value_ecdf.

dd_ecdf <- function(df, ..., .quantizer = identity, .value = value) {
  value_colname <- deparse(substitute(.value))
  ddply(df, ..., .fun = function(rdf) {
    xs <- rdf[[value_colname]]
    qxs <- sort(unique(.quantizer(xs)))
    data.frame(value = qxs, value_ecdf = ecdf(xs)(qxs))
  })
}

rounder <- function(...) function(x) round_any(x, ...)

pghre_cdf <- dd_ecdf(pghre, .(), .value = ptx_increase,
                     .quantizer = rounder(0.0025))


## Plot the cumulative distribution of property-tax increases

p <-
qplot(value, value_ecdf, geom = "step",
      data = subset(pghre_cdf, value < 2),
      main = "Pgh 2012 assessment: lower taxes for over half of properties",
      xlab = "Effective change in property taxes (% increase)",
      ylab = "Percentage of properties having the given increase or less") +
  scale_x_continuous(formatter = "percent") +
  scale_y_continuous(formatter = "percent")

ggsave(p, file = "out/pgh-2012-assm-property-tax-increases-ecdf.pdf",
       height = 5, width = 7)


## What percentage of properties will have their property taxes decrease?

## Method 1:  Use the full data set
ptx_increase_cdf <- ecdf(pghre$ptx_increase)
print("percentage of properties (all) that will have lower taxes:")
ptx_increase_cdf(0)  # --> 0.54

## Method 2:  Drop properties w/ 2011 assessment < $3K
pghre_3k <- subset(pghre, assessment2011 >= 3000)
ptx_3k_increase_cdf <- ecdf(pghre_3k$ptx_increase)
print("percentage of properties (>= $3K) that will have lower taxes:")
ptx_3k_increase_cdf(0)  # --> 0.57


