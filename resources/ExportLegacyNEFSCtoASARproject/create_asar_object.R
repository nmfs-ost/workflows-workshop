# Constructor for a standardized ASAR stock object
# This bakes in the data, metadata, and BRP sidecar into a single RDS-ready unit
create_asar_object <- function(main_data, 
                               metadata    = NULL, 
                               legacy_brp  = NULL,
                               stock_id    = NULL) {
  
  # Ensure the primary data is a clean tibble
  # This facilitates compatibility with dplyr and stockplotr
  asar_obj <- tibble::as_tibble(main_data)
  
  # If metadata isn't provided, we check if it exists as an attribute 
  # This allows the function to 'refresh' an existing object
  if (is.null(metadata)) {
    metadata <- attr(main_data, "metadata")
  }
  
  if (is.null(legacy_brp)) {
    legacy_brp <- attr(main_data, "legacy_brp")
  }
  
  # Add a stock_id to the metadata for easier report indexing
  if (!is.null(stock_id)) {
    metadata$stock_id <- stock_id
  }
  
  # Attach the Source of Truth attributes
  # These are the 'glue' that table_brp() and table_catch_status() rely on
  attr(asar_obj, "metadata")   <- metadata
  attr(asar_obj, "legacy_brp") <- legacy_brp
  
  # Assign the custom class for S3 method dispatching in ASAR
  class(asar_obj) <- c("asar_stock", class(asar_obj))
  
  return(asar_obj)
}
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Add a new row of data to the object while maintaining structure
# This version handles the 'dots' safely to avoid duplicated column errors
add_stock_data <- function(dat, module, label, year, estimate, ...) {
  
  # Capture additional arguments from dots
  extra_args <- list(...)
  
  # Controlled Vocabulary Check
  valid_labels <- c("biomass", "total_catch", "fishing_mortality", "recruitment", "index")
  if (!(label %in% valid_labels)) {
    warning(paste0("'", label, "' is not in the standard vocabulary (", 
                   paste(valid_labels, collapse=", "), "). Tables may not render correctly."))
  }
  
  # Define baseline values for a new row
  # We use a list first so we can check for user-supplied overrides in extra_args
  row_list <- list(
    module_name  = module,
    label        = label,
    year         = year,
    estimate     = estimate,
    estimate_chr = as.character(estimate),
    era          = "time"
  )
  
  # Merge extra_args into our row_list
  # If the user provided 'era' or 'estimate_chr', their values will overwrite the defaults
  for (n in names(extra_args)) {
    row_list[[n]] <- extra_args[[n]]
  }
  
  # Convert the finalized list to a single-row tibble
  new_row <- tibble::as_tibble(row_list)
  
  # Save current metadata and class before merging
  # This ensures the 'Sidecar' data stays attached to the main data frame
  meta_tmp <- attr(dat, "metadata")
  brp_tmp  <- attr(dat, "legacy_brp")
  cls_tmp  <- class(dat)
  
  # Use bind_rows to merge the new data
  # Missing columns (like age, sex, etc.) will be filled with NA automatically
  updated_dat <- dplyr::bind_rows(dat, new_row)
  
  # Restore the metadata and original object class
  attr(updated_dat, "metadata")   <- meta_tmp
  attr(updated_dat, "legacy_brp") <- brp_tmp
  class(updated_dat) <- cls_tmp
  
  return(updated_dat)
}
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Add a new row of data to the object while maintaining the 33-column structure
# This is now compatible with the 'estimate_chr' column used for Surfclam/Butterfish
add_stock_data <- function(dat, module, label, year, estimate, ...) {
  
  # Controlled Vocabulary Check for core metrics
  valid_labels <- c("biomass", "total_catch", "fishing_mortality", "recruitment", "index")
  if (!(label %in% valid_labels)) {
    warning(paste0("'", label, "' is not in the standard vocabulary (", 
                   paste(valid_labels, collapse=", "), "). Tables may not render correctly."))
  }
  
  # Create the new observation with standard structure
  # We include estimate_chr to match the mapper's output
  new_row <- tibble::tibble(
    module_name = module,
    label = label,
    year = year,
    estimate = estimate,
    estimate_chr = as.character(estimate), # Default string version of the estimate
    era = "time", # Default to time series era
    ...
  )
  
  # Save attributes and class before binding
  # dplyr::bind_rows can be aggressive with stripping custom metadata
  meta_tmp <- attr(dat, "metadata")
  brp_tmp  <- attr(dat, "legacy_brp")
  cls_tmp  <- class(dat)
  
  # Use rows_append or bind_rows to merge the new data
  # This ensures the new row gets NAs for all the columns not explicitly named (like bio_pattern)
  updated_dat <- dplyr::bind_rows(dat, new_row)
  
  # Restore the metadata and legacy sidecar attributes
  attr(updated_dat, "metadata")   <- meta_tmp
  attr(updated_dat, "legacy_brp") <- brp_tmp
  class(updated_dat) <- cls_tmp
  
  return(updated_dat)
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Pre-flight check to ensure the object is ready for ASAR reporting
validate_asar_object <- function(dat) {
  
  issues <- c()
  
  # Check 1: Structure and Class
  if (!inherits(dat, "asar_stock")) {
    issues <- c(issues, "Object is missing 'asar_stock' class. Use create_asar_object().")
  }
  
  # Check 2: Required Columns
  req_cols <- c("module_name", "label", "year", "estimate") # uncertainty column is also required
  missing_cols <- setdiff(req_cols, colnames(dat))
  if (length(missing_cols) > 0) {
    issues <- c(issues, paste("Missing required data columns:", paste(missing_cols, collapse = ", ")))
  }
  
  # Check 3: Metadata Integrity
  meta <- attr(dat, "metadata")
  if (is.null(meta)) {
    issues <- c(issues, "Metadata attribute is missing.")
  } else {
    req_meta <- c("spp_name", "report_yr", "cap_brp", "cap_status", "cap_proj")
    missing_meta <- setdiff(req_meta, names(meta))
    if (length(missing_meta) > 0) {
      issues <- c(issues, paste("Missing metadata fields:", paste(missing_meta, collapse = ", ")))
    }
  }
  
  # Check 4: BRP Sidecar
  if (is.null(attr(dat, "legacy_brp"))) {
    issues <- c(issues, "Legacy BRP sidecar is missing. BRP tables will not render.")
  }
  
  # Check 5: Comprehensive Vocabulary Check
  # This list now includes the reference point labels generated by the mapping function
  valid_labels <- c(
    "biomass", "total_catch", "fishing_mortality", "recruitment", "index",
    "biomass_msy", "biomass_target", "biomass_threshold",
    "fishing_mortality_msy", "fishing_mortality_target", "fishing_mortality_threshold",
    "msy", "median_recruits"
  )
  
  found_labels <- unique(dat$label)
  invalid_labels <- setdiff(found_labels, valid_labels)
  invalid_labels <- invalid_labels[!is.na(invalid_labels)]
  
  if (length(invalid_labels) > 0) {
    issues <- c(issues, paste("Non-standard labels found:", paste(invalid_labels, collapse = ", ")))
  }
  
  # Final Reporting
  if (length(issues) == 0) {
    cli::cli_alert_success("Object '{substitute(dat)}' passed all ASAR validation checks.")
    return(TRUE)
  } else {
    cli::cli_alert_danger("Validation failed with {length(issues)} issue(s):")
    bullet_list <- setNames(issues, rep("*", length(issues)))
    cli::cli_bullets(bullet_list)
    return(FALSE)
  }
}




