#Additional Test Stocks
myDir <- "dhennen"  #change to your network home name
sourcePath <- file.path("/home",myDir,"EIEIO","ASAR","MapLegacyAutoUpdateToAsar")
source(file.path(sourcePath,"MapAutoUpdateToAsar.R"))


rdata_path <- file.path("/home","dhennen","EIEIO","ASAR","MapLegacyAutoUpdateToAsar"
                        ,"testStocks","BUTUNITAutoAss.RData")
BUTUNIT <- map_autoUpdate_to_stockplotr(rdata_path) #this is meant to mimic stockplotr::convert_output
#structure for use in other stockplotr functions
#str(BUTUNIT)
#test <- BUTUNIT |> dplyr::filter(module_name=="survey") |> str()

stockplotr::plot_biomass(dat = BUTUNIT)
#how about for fishing mortality?
stockplotr::plot_fishing_mortality(
  dat = BUTUNIT
  #,era = "current"
  ,ref_line = "msy"
)

#Nothing available specifically for catch in stockplotr - so make our own!
source(file.path(sourcePath,"plot_total_catch.R"))
plot_total_catch(dat = BUTUNIT)
#or if you want to keep the legacy style
plot_total_catch(dat = BUTUNIT, type = "bar")

# Let's see how the indices look - once again make a function to copy our figure style,
# but using stockplotr's style and inputs.
source(file.path(sourcePath,"plot_survey_indices.R"))
plot_survey_indices(dat = BUTUNIT)

#Recruitment - this one seems to work fine
stockplotr::plot_recruitment(dat = BUTUNIT)

#%%%%%%%%%%%%%%%%%%%% How about tables? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# stockplotr::table_landings() is the only one in production currently, but 
# we can copy their style...
source(file.path(sourcePath,"table_brp1.1.R"))
table_brp(dat = BUTUNIT)


#Next we need our catch and status table 
source(file.path(sourcePath,"table_catch_status1.1.R"))
table_catch_status(dat = BUTUNIT)

#projection table
source(file.path(sourcePath,"table_projections1.1.R"))
table_projections(dat = BUTUNIT)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#_______________________________________________
# Example of using the metadata 
metadata <- attr(BUTUNIT, "metadata")

#to plot a rho adjusted value and previous assessment 
# Generate the comparison plot
stockplotr::plot_biomass(BUTUNIT) + 
  
  # Add the previous assessment line by filtering for the 'prev' era
  ggplot2::geom_line(
    data = dplyr::filter(BUTUNIT, 
                         module_name == "model_results", 
                         label == "biomass", 
                         era == "prev"),
    ggplot2::aes(x = year, y = estimate, color = "Previous"),
    linetype = "dashed", 
    linewidth = 0.8
  ) +
  
  # Add the Rho Adjusted terminal point from metadata attributes
  ggplot2::geom_point(
    ggplot2::aes(x = metadata$term_yr, y = metadata$terminal_b_adj, color = "Rho Adj"), 
    size = 3
  ) +
  
  # Text annotation for the Rho Adjusted point
  ggplot2::annotate(
    "text", 
    x = metadata$term_yr, 
    y = metadata$terminal_b_adj, 
    label = "Rho Adj", 
    color = "red", 
    vjust = -1.5
  ) +
  
  # Define the aesthetic mapping for the legend and line colors
  ggplot2::scale_color_manual(
    name = "Assessment",
    values = c("Current" = "black", "Previous" = "blue", "Rho Adj" = "red")
  ) +
  
  # Update labels to reflect the inclusion of the comparison data
  ggplot2::labs(
    subtitle = "Current Assessment vs. Previous and Rho-Adjusted Terminal Year"
  )
#________________________________________________________________________
#make a report!
source(file.path(sourcePath,"create_asar_object.R"))

# Load the existing Source of Truth
stock <- create_asar_object(BUTUNIT)

# Check if everything is still correct
if(validate_asar_object(stock)) {
  model_results <- stock 
  metadata      <- attr(stock, "metadata")
  fname         <- gsub(" ","_",metadata$spp_name) |> paste0(metadata$report_yr) |> paste0(".rda")
  save(model_results, file = fname)
}

# Define Quarto global execution options
# This ensures all chunks default to no echo, no warnings, and no messages
report_options <- list(
  execute = list(
    warning = FALSE,
    message = FALSE,
    echo    = FALSE
  )
)

# Create a new assessment directory and template
asar::create_template(
  office        = "NEFSC",
  format        = "pdf", 
  region        = "Northeast",
  authors       = c("Joe Blow"="NEFSC"),
  species       = metadata$spp_name,
  year          = metadata$report_yr,
  model_results = fname,
  title         = glue::glue("Management Track Assessment of {metadata$spp_name} {metadata$report_yr}"),
  # Pass the execution rules here
  quarto_options = report_options
)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#Additional Test Stocks
myDir <- "dhennen"  #change to your network home name
sourcePath <- file.path("/home",myDir,"EIEIO","ASAR","MapLegacyAutoUpdateToAsar")
source(file.path(sourcePath,"MapAutoUpdateToAsar.R"))


rdata_path <- file.path("/home","dhennen","EIEIO","ASAR","MapLegacyAutoUpdateToAsar"
                        ,"testStocks","SCUNITAutoAss.RData")
SCUNIT <- map_autoUpdate_to_stockplotr(rdata_path) #this is meant to mimic stockplotr::convert_output
#structure for use in other stockplotr functions
#str(SCUNIT)
# test <- SCUNIT |> dplyr::filter(module_name=="model_results" & label=="biomass") |> 
#   dplyr::pull(estimate) |> range()


#Surfclam has weird reference point plots where the values i nthe BRP table are not useful in 
#the plot - we can use ggplot to address this
p <- stockplotr::plot_biomass(
  dat = SCUNIT
  ,ref_line = "") #don't plot the reference line here - there may be a better way to do this!

# Add your custom horizontal line
threshold_val <- 1 

p_updated <- p +  
  ggplot2::geom_hline(yintercept = threshold_val, 
                      color = "darkred", 
                      linetype = "dashed", 
                      linewidth = 1) +
  # Place the text at the middle year, slightly above the line
  ggplot2::annotate("text", 
                    x = mean(range(as.numeric(SCUNIT$year), na.rm = TRUE)), 
                    y = 1.2, 
                    label = "Threshold", 
                    color = "darkred", 
                    fontface = "bold")
plot(p_updated)


#how about for fishing mortality?
p <- stockplotr::plot_fishing_mortality(
  dat = SCUNIT
  #,era = "current"
  ,ref_line = ""
)
# Add your custom horizontal line
threshold_val <- 1 

p_updated <- p +  
  ggplot2::geom_hline(yintercept = threshold_val, 
                      color = "darkred", 
                      linetype = "dashed", 
                      linewidth = 1) +
  # Place the text at the middle year, slightly above the line
  ggplot2::annotate("text", 
                    x = mean(range(as.numeric(SCUNIT$year), na.rm = TRUE)), 
                    y = 1.05, 
                    label = "Threshold", 
                    color = "darkred", 
                    fontface = "bold")
plot(p_updated)


#Nothing available specifically for catch in stockplotr - so make our own!
source(file.path(sourcePath,"plot_total_catch.R"))
plot_total_catch(dat = SCUNIT)
#or if you want to keep the legacy style
plot_total_catch(dat = SCUNIT, type = "bar")

# Let's see how the indices look - once again make a function to copy our figure style,
# but using stockplotr's style and inputs.
source(file.path(sourcePath,"plot_survey_indices.R"))
plot_survey_indices(dat = SCUNIT)
plot_survey_indices(SCUNIT, show_line = TRUE)


#Recruitment - this one seems to work fine
stockplotr::plot_recruitment(dat = SCUNIT)

#%%%%%%%%%%%%%%%%%%%% How about tables? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# surfclam is weird because the f and ssb model results are relative
# we have to supply the status because the automation won't work.
source(file.path(sourcePath,"table_brp1.1.R"))
table_brp(dat = SCUNIT)


#Next we need our catch and status table 
source(file.path(sourcePath,"table_catch_status1.1.R"))
table_catch_status(dat = SCUNIT)

#projection table
source(file.path(sourcePath,"table_projections1.1.R"))
table_projections(dat = SCUNIT)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#attr(SCUNIT, "metadata")

#make a report!
source(file.path(sourcePath,"create_asar_object.R"))

# Load the existing Source of Truth
stock <- create_asar_object(SCUNIT)

# Check if everything is still correct
if(validate_asar_object(stock)) {
  model_results <- stock 
  metadata      <- attr(stock, "metadata")
  fname         <- gsub(" ","_",metadata$spp_name) |> paste0(metadata$report_yr) |> paste0(".rda")
  save(model_results, file = fname)
}

# Define Quarto global execution options
# This ensures all chunks default to no echo, no warnings, and no messages
report_options <- list(
  execute = list(
    warning = FALSE,
    message = FALSE,
    echo    = FALSE
  )
)

# Create a new assessment directory and template
asar::create_template(
  office        = "NEFSC",
  format        = "pdf", 
  region        = "Northeast",
  authors       = c("Joe Blow"="NEFSC"),
  species       = metadata$spp_name,
  year          = metadata$report_yr,
  model_results = fname,
  title         = glue::glue("Management Track Assessment of {metadata$spp_name} {metadata$report_yr}"),
  # Pass the execution rules here
  quarto_options = report_options
)













