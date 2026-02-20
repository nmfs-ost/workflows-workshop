# Example conversion from autoUpdate script to asar/stockplotr
# use the R container for this and asar/stockplotr are loaded and available

myDir <- "dhennen"  #change to your network home name
sourcePath <- file.path("/home",myDir,"EIEIO","ASAR","MapLegacyAutoUpdateToAsar")
source(file.path(sourcePath,"MapAutoUpdateToAsar.R"))

                 
rdata_path <- file.path("/home","dhennen","EIEIO","ASAR","MapLegacyAutoUpdateToAsar"
                        ,"testStocks","CODWGOMAutoAss.RData")
CODWGOM <- map_autoUpdate_to_stockplotr(rdata_path) #this is meant to mimic stockplotr::convert_output
#structure for use in other stockplotr functions
str(CODWGOM)

#%%%%%%%%%%%% Recreating Figures and Tables we use, but with asar/stockplotr %%%%%%%%%%%%%%%%

#try using this object in a stockplotr plotting function
stockplotr::plot_biomass(
  dat = CODWGOM, # dataset
  geom = "line", # show a line graph
  group = NULL, # don't group by sex, fleet, etc.
  facet = NULL, # not faceting by any variable
  ref_line = "MSY", # set reference line at unfished
  unit_label = "mt", # unit label: metric tons
  scale_amount = 1, # do not scale biomass
  relative = FALSE, # show biomass, NOT relative biomass
  interactive = TRUE, # prompt user for MODULE_NAME in console
  module = NULL # MODULE_NAME not specified here
)  

#how about for fishing mortality?
stockplotr::plot_fishing_mortality(
  dat = CODWGOM
  #,era = "current"
  ,ref_line = "msy"
)

#Nothing available specifically for catch in stockplotr - so make our own!
source(file.path(sourcePath,"plot_total_catch.R"))
plot_total_catch(dat = CODWGOM)
#or if you want to keep the legacy style
plot_total_catch(dat = CODWGOM, type = "bar")

# Let's see how the indices look - once again make a function to copy our figure style,
# but using stockplotr's style and inputs.
source(file.path(sourcePath,"plot_survey_indices.R"))
plot_survey_indices(dat = CODWGOM)

#Recruitment - this one seems to work fine
stockplotr::plot_recruitment(dat = CODWGOM)

#%%%%%%%%%%%%%%%%%%%% How about tables? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# stockplotr::table_landings() is the only one in production currently, but 
# we can copy their style...
source(file.path(sourcePath,"table_brp1.1.R"))
table_brp(dat = CODWGOM)


#Next we need our catch and status table 
source(file.path(sourcePath,"table_catch_status1.1.R"))
table_catch_status(dat = CODWGOM)

#projection table
source(file.path(sourcePath,"table_projections1.1.R"))
table_projections(dat = CODWGOM)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#How to update and produce a new report
source(file.path(sourcePath,"create_asar_object.R"))

#library(asarTableUtils) # Assuming we wrap these

# Load the existing Source of Truth
cod <- create_asar_object(CODWGOM)

# Update the numbers for the new year
cod <- cod |>
  add_stock_data(module = "catch"
                 , label = "total_catch"
                 , year = 2024
                 , estimate = 712
                 ,era = "time"
                 , fleet = "Total") |>
  update_stock_info(report_yr = 2026
                    , cap_proj = "Updated based on 2026 spring survey.")

# Check if everything is still correct
if(validate_asar_object(cod)) {
  # Rename the object to what the template likely expects internally
  model_results <- cod 
  save(model_results, file = "CODWGOM_2026.rda")
}

# Generate the report tables immediately
table_catch_status(cod)



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Time to try to use asar


# Create a new assessment directory and template
asar::create_template(
  office = "NEFSC"
  ,output_dir = "CODWGOM_2026_Report"
  ,format = "pdf" 
  ,stock = "Western Gulf of Maine Cod"
  ,region = "Northeast"
  ,authors =  c("Jane Doe"="NEFSC")
  ,species       = attr(cod, "metadata")$spp_name
  ,year          = attr(cod, "metadata")$report_yr
  ,model_results = "CODWGOM_2026.rda"
)

#open the report directory and find sar_N_Your_Stock_Name_skeleton.qmd
# you can access all the variables from your autoReport like this:
metadata <- attr(CODWGOM, "metadata") #paste into the above .qmd file
#and you will have all you need to make an MT style report. 
#metadata$spp_name #etc...
metadata$preamble




# %%%%%%%%%%%%%% TROUBLE SHOOTING RENDER ISSUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LatexErrors = FALSE # Change to TRUE if you can't render due to LaTeX/LuaTeX errors

if (LatexErrors) {
  # Standard R package check
  if (!requireNamespace("tinytex", quietly = TRUE)) {
    install.packages("tinytex")
  }
  
  # Check if the current root is a system path or empty
  current_root <- tinytex::tinytex_root()
  is_system_path <- grepl("/usr/local", current_root)
  
  if (current_root == "" || is_system_path) {
    message("System LaTeX found or root empty. Installing local TinyTeX for user permissions...")
    # 'force = TRUE' is key here to ignore the /usr/local version
    tinytex::install_tinytex(force = TRUE)
  }
  
  # Final check/link to the local home directory version
  # Quarto will now use this local version to install missing .sty files
  # Manually point to the directory we just saw the installer create
  tinytex::use_tinytex(from = glue::glue("/home/{myDir}/.TinyTeX") )
  
  # Now verify it stuck
  if(tinytex::tinytex_root()== glue::glue("/home/{myDir}/.TinyTeX")){cli::cli_alert_success("Active LaTeX Root: {tinytex::tinytex_root()}")
  } else cli::cli_alert_danger("Active LaTeX Root: {tinytex::tinytex_root()}")
  # Tell Quarto specifically where your new, writable pdflatex lives
  Sys.setenv(QUARTO_PDF_LATEX = glue::glue("/home/{myDir}/.TinyTeX/bin/x86_64-linux/pdflatex"))
  

  }



