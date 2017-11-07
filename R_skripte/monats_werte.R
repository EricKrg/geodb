#script for the computation of the weekly values of "pegel-messdaten"
#database connection with r
#
#database access:
#
#

require("RPostgreSQL")

pacman::p_load(dplyr, tidyverse)
