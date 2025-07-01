# -----------------------------------------------------------------------------
# FX Major-4 Currencies Correlations Script
# -----------------------------------------------------------------------------

options(repos = c(CRAN = "https://cloud.r-project.org/"))
required <- c("data.table", "xts", "corrplot", "ggcorrplot")
for (pkg in required) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    if (pkg == "ggcorrplot") {
      install.packages("remotes")
      remotes::install_github("kassambara/ggcorrplot")
    } else {
      install.packages(pkg)
    }
  }
  library(pkg, character.only = TRUE)
}

# 2. User parameters
data_dir    <- "m1"  
file_glob   <- "\\.csv$"                      
tz          <- "UTC"

# 1=M1, 5=M5, 15=M15, 60=H1, etc.
resample_k  <- 1       
resample_on <- "minutes" #"seconds", "minutes", "hours", "days", "weeks"  

# Loading M1 CSVs into xts
if (!dir.exists(data_dir)) stop("Folder not found: ", data_dir)
files <- list.files(data_dir, file_glob, full.names = TRUE)
if (length(files) < 2) stop("Need ≥2 CSVs, found ", length(files))

read_close_xts <- function(path, tz) {
  dt <- data.table::fread(path,
                          select     = c("date","time","close"),
                          colClasses = list(character = c("date","time","close")))
  dt[, close    := as.numeric(close)]
  dt[, datetime := as.POSIXct(paste(date, time),
                              format = "%Y.%m.%d %H:%M:%S",
                              tz     = tz)]
  data.table::setorder(dt, datetime)
  
  sym <- tools::file_path_sans_ext(basename(path))
  x   <- xts::xts(dt$close, order.by = dt$datetime)
  colnames(x) <- sym
  x
}

xts_list <- lapply(files, read_close_xts, tz = tz)

# Merge & resample 

prices <- do.call(merge, c(xts_list, list(join = "inner")))
if (ncol(prices) < 2) stop("Less than 2 symbols after merge")

if (resample_k > 1) {
  ep     <- xts::endpoints(prices, on = resample_on, k = resample_k)
  prices <- prices[ep, ]
}

# Log-returns & correlation
rets    <- stats::na.omit(diff(log(prices)))
cor_mat <- cor(coredata(rets), method = "pearson")

# Label matrix for timeframe
timeframe_label <- if (resample_k == 1) {
  "M1"
} else {
  paste0(resample_k, toupper(substr(resample_on, 1, 1)))
}
syms   <- colnames(cor_mat)
labels <- paste0(syms, ".", timeframe_label)
cor_plot <- cor_mat
dimnames(cor_plot) <- list(labels, labels)

# Correlation CSV
if (!dir.exists("results")) dir.create("results")
csv_out <- file.path("results", paste0("correlations_", timeframe_label, ".csv"))
write.csv(cor_mat, file = csv_out, row.names = TRUE)

# Plotting helper: open new device
new_dev <- function(w = 6, h = 6) {
  if (.Platform$OS.type == "windows") {
    windows(width = w, height = h)
  } else if (Sys.info()["sysname"] == "Darwin") {
    quartz(width = w, height = h)
  } else {
    X11(width = w, height = h)
  }
}

# Each plot will be displayed on its own window

# 8.1 Upper-triangle color
new_dev()
corrplot::corrplot(cor_plot,
                   method      = "color",
                   type        = "upper",
                   tl.col      = "black",
                   tl.srt      = 45,
                   tl.cex      = 0.7,
                   addCoef.col = "white",
                   number.cex  = 0.7,
                   main        = paste(timeframe_label, "Pearson"))

# 8.2 Clustered ellipse
new_dev()
corrplot::corrplot(cor_plot,
                   method    = "ellipse",
                   type      = "lower",
                   order     = "hclust",
                   addrect   = 2,
                   tl.cex    = 0.7,
                   main      = paste(timeframe_label, "Clustered"))

# 8.3 ggcorrplot
new_dev()
print(
  ggcorrplot::ggcorrplot(cor_plot,
                         hc.order  = TRUE,
                         type      = "lower",
                         lab       = TRUE,
                         lab_size  = 3,
                         colors    = c("red", "white", "green"),
                         title     = paste(timeframe_label, "FX Correlations"))
)
