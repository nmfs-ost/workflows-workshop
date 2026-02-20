#Additional Test Stocks
myDir <- "~/Stock Assessment Workflow/NEFSC transition/ExportLegacyNEFSCtoASARproject"  #change to your network home name
sourcePath <- file.path(myDir) # ,"EIEIO","ASAR","MapLegacyAutoUpdateToAsar"
source(file.path(sourcePath,"MapAutoUpdateToAsar.R"))
source(file.path(sourcePath,"create_asar_object.R"))

AutoAss <- "BSBUNITAutoAss.RData"
rdata_path <- file.path(myDir
                        ,"testStocks",AutoAss)

#make a report!
# Load the existing Source of Truth
stock <- create_asar_object(map_autoUpdate_to_stockplotr(rdata_path))

# Check if everything is correct for use in stockplotr
if(validate_asar_object(stock)) {
  model_results <- stock 
  metadata      <- attr(stock, "metadata")
  fname         <- gsub(" ","_",metadata$spp_name) |> paste0(metadata$report_yr) |> paste0(".rda")
  save(model_results, file = fname)
}

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
