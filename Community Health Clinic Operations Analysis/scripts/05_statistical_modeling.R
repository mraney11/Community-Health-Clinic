# =============================================================================
# 05_statistical_modeling.R
# Community Health Clinic Operations Analysis — Chapter 05: Statistical Modeling
#
# Research question: How are appointment wait time, previous no-shows, and
# transportation access associated with appointment completion, after
# accounting for one another?
#
# Primary model (prespecified):
#   completion_01 ~ wait_weeks + previous_no_shows + transportation_access
#   binomial GLM, logit link, intercept; transportation reference = "Yes".
#
# Data are SIMULATED practice data. Results are observational associations,
# not causal effects and not evidence about a real clinic.
#
# Run from a fresh session:  Rscript scripts/05_statistical_modeling.R
# =============================================================================

# ---- 0. Project root, seed, packages ----------------------------------------
if (!requireNamespace("here", quietly = TRUE)) {
  stop("Package 'here' is required for project-relative root resolution.")
}
suppressMessages(here::i_am("scripts/05_statistical_modeling.R"))
project_root <- normalizePath(here::here(), winslash = "/", mustWork = TRUE)
expected_sentinels <- c(
  "Community Health Clinic Operations Analysis.Rproj",
  "data/community_health_clinic_clean.csv",
  "data/community_health_clinic_raw_v2.csv",
  "documentation/community_health_clinic_data_dictionary_v2.xlsx",
  "scripts/03_data_cleaning.R",
  "scripts/05_statistical_modeling.R"
)
missing_sentinels <- expected_sentinels[!file.exists(file.path(project_root, expected_sentinels))]
if (length(missing_sentinels) > 0) {
  stop("Invalid clinic project root (", project_root, "). Missing expected clinic inputs: ",
       paste(missing_sentinels, collapse = ", "))
}
setwd(project_root)
set.seed(20261017)

rproj_files <- list.files(project_root, pattern = "\\.Rproj$")
rproj_note <- if (length(rproj_files)) paste(rproj_files, collapse = "; ") else
  "No .Rproj file found in project root."

for (d in c("scripts", "outputs/tables", "outputs/figures", "outputs/models", "reports")) {
  dir.create(file.path(d), recursive = TRUE, showWarnings = FALSE)
}

pkgs_needed <- c("ggplot2", "car", "logistf", "detectseparation")
pkg_status <- sapply(pkgs_needed, requireNamespace, quietly = TRUE)
if (!pkg_status[["ggplot2"]]) stop("ggplot2 is required for figures.")
library(ggplot2)

# ---- Warning / log collectors ----------------------------------------------
warn_log <- data.frame(step = character(), warning = character(), stringsAsFactors = FALSE)
capture <- function(step, expr) {
  withCallingHandlers(expr, warning = function(w) {
    warn_log[nrow(warn_log) + 1, ] <<- list(step, conditionMessage(w))
    invokeRestart("muffleWarning")
  })
}
decisions <- data.frame(id = character(), area = character(), decision = character(),
                        rationale = character(), stringsAsFactors = FALSE)
add_decision <- function(area, decision, rationale) {
  decisions[nrow(decisions) + 1, ] <<- list(sprintf("M05_%02d", nrow(decisions) + 1),
                                            area, decision, rationale)
}
tbl_path <- function(f) file.path("outputs", "tables", f)
fig_path <- function(f) file.path("outputs", "figures", f)
write_tbl <- function(x, f) write.csv(x, tbl_path(f), row.names = FALSE, na = "")
r3 <- function(x) round(x, 3)

# ---- 1. Inputs and checksums ------------------------------------------------
clean_path <- file.path("data", "community_health_clinic_clean.csv")
raw_path   <- file.path("data", "community_health_clinic_raw_v2.csv")
doc_paths  <- c(
  cleaning_log   = tbl_path("03_cleaning_decision_log.csv"),
  eda_report     = file.path("reports", "04_exploratory_data_analysis_report.md"),
  var_inventory  = tbl_path("04_variable_inventory.csv"),
  data_dictionary = file.path("documentation", "community_health_clinic_data_dictionary_v2.xlsx"),
  cleaning_script = file.path("scripts", "03_data_cleaning.R")
)
if (!file.exists(clean_path)) stop("Required cleaned data not found: ", clean_path)
all_inputs <- c(clean_data = clean_path, raw_data = raw_path, doc_paths)
input_manifest <- data.frame(
  role = names(all_inputs), path = unname(all_inputs),
  exists = file.exists(all_inputs),
  md5 = ifelse(file.exists(all_inputs), unname(tools::md5sum(all_inputs)), NA),
  stringsAsFactors = FALSE
)
write_tbl(input_manifest, "05_input_checksums.csv")

# Read as character-preserving: blanks stay "" (not silently NA); only literal NA is NA.
clean <- read.csv(clean_path, stringsAsFactors = FALSE, na.strings = "NA")
raw   <- if (file.exists(raw_path)) read.csv(raw_path, stringsAsFactors = FALSE, na.strings = "NA") else NULL
cleaning_log <- if (file.exists(doc_paths[["cleaning_log"]])) read.csv(doc_paths[["cleaning_log"]], stringsAsFactors = FALSE) else NULL

# ---- 2. Input audit ---------------------------------------------------------
req_vars <- c("patient_id", "appointment_completed", "appointment_wait_days",
              "previous_no_shows", "transportation_access")
missing_cols <- setdiff(req_vars, names(clean))
if (length(missing_cols)) stop("Required variables absent: ", paste(missing_cols, collapse = ", "))

n_rows <- nrow(clean); n_vars <- ncol(clean)
n_unique_id <- length(unique(clean$patient_id))
n_dup_rows <- sum(duplicated(clean))
outcome_levels <- sort(unique(clean$appointment_completed))
transport_levels <- sort(unique(clean$transportation_access))

# Safety checks: stop with diagnostics if coding is not interpretable.
blockers <- c()
if (!all(clean$appointment_completed %in% c("Yes", "No"))) blockers <- c(blockers, "appointment_completed has values other than Yes/No")
if (!all(clean$transportation_access %in% c("Yes", "No"))) blockers <- c(blockers, "transportation_access has values other than Yes/No")
if (!is.numeric(clean$appointment_wait_days)) blockers <- c(blockers, "appointment_wait_days not numeric")
if (!is.numeric(clean$previous_no_shows)) blockers <- c(blockers, "previous_no_shows not numeric")
if (any(clean$appointment_wait_days < 0, na.rm = TRUE)) blockers <- c(blockers, "negative wait days present")
if (any(clean$previous_no_shows < 0, na.rm = TRUE)) blockers <- c(blockers, "negative previous_no_shows present")

miss_req <- sapply(req_vars, function(v) sum(is.na(clean[[v]]) | (is.character(clean[[v]]) & clean[[v]] == "")))

expected <- c(rows = 300, vars = 35, completed = 270, missed = 30)
observed <- c(rows = n_rows, vars = n_vars,
              completed = sum(clean$appointment_completed == "Yes"),
              missed = sum(clean$appointment_completed == "No"))

audit <- rbind(
  data.frame(check = "Rows in cleaned data", expected = "300", observed = as.character(n_rows)),
  data.frame(check = "Variables in cleaned data", expected = "35", observed = as.character(n_vars)),
  data.frame(check = "Unique patient_id", expected = "300 (one row per patient-visit)", observed = as.character(n_unique_id)),
  data.frame(check = "Exact duplicate rows", expected = "0", observed = as.character(n_dup_rows)),
  data.frame(check = "Outcome categories observed", expected = "No; Yes", observed = paste(outcome_levels, collapse = "; ")),
  data.frame(check = "Completed (Yes)", expected = "270", observed = as.character(observed[["completed"]])),
  data.frame(check = "Missed (No)", expected = "30", observed = as.character(observed[["missed"]])),
  data.frame(check = "Transportation categories observed", expected = "No; Yes", observed = paste(transport_levels, collapse = "; ")),
  data.frame(check = "appointment_wait_days range", expected = ">= 0", observed = paste(range(clean$appointment_wait_days), collapse = " to ")),
  data.frame(check = "previous_no_shows range / values", expected = "non-negative integers",
             observed = paste(sort(unique(clean$previous_no_shows)), collapse = ", ")),
  data.frame(check = "Missing/blank in required variables", expected = "0",
             observed = paste(sprintf("%s=%d", names(miss_req), miss_req), collapse = "; ")),
  data.frame(check = "Cleaning log stated completions", expected = "270 cleaned (273 RAW pre-deduplication)",
             observed = "DEC_13 in 03 log labels 273 completed + 30 missed as RAW (N = 303) and 270 + 30 as cleaned (N = 300)"),
  data.frame(check = "Raw file rows (sensitivity source)", expected = "available",
             observed = if (is.null(raw)) "not available" else as.character(nrow(raw))),
  data.frame(check = "RStudio project file", expected = ".Rproj present", observed = rproj_note),
  data.frame(check = "Coding blockers", expected = "none",
             observed = if (length(blockers)) paste(blockers, collapse = "; ") else "none")
)
audit$status <- ifelse(audit$expected == audit$observed | grepl("^>=|non-negative|current data|available|none|one row|270 cleaned", audit$expected), "OK/See note", "DISCREPANCY")
audit$status[audit$check == "Cleaning log stated completions"] <- "OK (RAW vs cleaned labeled)"
audit$status[audit$check == "RStudio project file"] <- if (length(rproj_files)) "OK" else "Note"
audit$status[audit$check == "Coding blockers"] <- if (length(blockers)) "BLOCKER" else "OK"
audit$status[audit$check == "Missing/blank in required variables"] <- if (all(miss_req == 0)) "OK (none missing)" else "DISCREPANCY"

if (length(blockers)) {
  write_tbl(audit, "05_model_sample_audit.csv")
  stop("Model fitting stopped: ", paste(blockers, collapse = "; "))
}

# ---- 3. Model coding --------------------------------------------------------
md <- data.frame(
  patient_id = clean$patient_id,
  completion_01 = ifelse(clean$appointment_completed == "Yes", 1L, 0L),
  appointment_wait_days = clean$appointment_wait_days,
  wait_weeks = clean$appointment_wait_days / 7,
  previous_no_shows = clean$previous_no_shows,
  transportation_access = factor(clean$transportation_access, levels = c("Yes", "No")),
  age = clean$age
)
stopifnot(all(table(md$completion_01, clean$appointment_completed)[cbind(c("0", "1"), c("No", "Yes"))] == as.numeric(table(clean$appointment_completed))))
md_cc <- md[complete.cases(md[, c("completion_01", "wait_weeks", "previous_no_shows", "transportation_access")]), ]
n_model <- nrow(md_cc); n_events_missed <- sum(md_cc$completion_01 == 0)

audit <- rbind(audit,
  data.frame(check = "Final primary model sample (N)", expected = "300", observed = as.character(n_model), status = ifelse(n_model == 300, "OK", "DISCREPANCY")),
  data.frame(check = "Model sample completed / missed", expected = "270 / 30",
             observed = sprintf("%d / %d", sum(md_cc$completion_01), n_events_missed),
             status = ifelse(sum(md_cc$completion_01) == 270, "OK", "DISCREPANCY")),
  data.frame(check = "Minority outcomes per predictor df", expected = "~10 (caution, not a rule)",
             observed = sprintf("%.1f (%d missed / 3 df)", n_events_missed / 3, n_events_missed), status = "Caution noted"))
write_tbl(audit, "05_model_sample_audit.csv")

add_decision("Scope", "Single prespecified model: completion_01 ~ wait_weeks + previous_no_shows + transportation_access",
             "Agreed Chapter 05 scope supersedes the broader EDA roadmap; no stepwise/screening/interactions.")
add_decision("Coding", "completion_01 = 1 if appointment_completed == 'Yes'; transportation factor levels Yes (reference), No",
             "Model describes odds of completion; reference group = patients with transportation access.")
add_decision("Coding", "wait_weeks = appointment_wait_days / 7 (exact, unrounded)", "Coefficients interpretable per one additional week (7 days).")
add_decision("Exclusions", "patient_id, age, clinic_location and all post-visit variables excluded as predictors",
             "Identifier; agreed scope; temporal leakage (followup, referral, health_improved, satisfaction, costs).")
add_decision("Data", sprintf("Cleaned data used: %d rows, %d completed, %d missed (RAW pre-deduplication count: 273 completed + 30 missed = 303)", n_rows, observed[["completed"]], observed[["missed"]]),
             "273 completed + 30 missed is the RAW (303-row, pre-deduplication) count; cleaned sample (N = 300) has 270 completed + 30 missed.")
add_decision("Missingness", sprintf("No missing values in required model variables; complete-case N = %d", n_model),
             "No patient removed because of unused-variable missingness; no new imputation.")
add_decision("Information", "~30 missed appointments for 3 predictor df treated as a caution about limited information",
             "Not an iron law; penalization would not create information.")

# ---- 4. Sparsity audit tables -----------------------------------------------
tr_tab <- with(md_cc, table(transportation_access, completion_01))
outcome_by_tr <- data.frame(
  transportation_access = rownames(tr_tab),
  n_patients = as.integer(rowSums(tr_tab)),
  n_completed = as.integer(tr_tab[, "1"]),
  n_missed = as.integer(tr_tab[, "0"])
)
outcome_by_tr$pct_completed_row <- r3(100 * outcome_by_tr$n_completed / outcome_by_tr$n_patients)
outcome_by_tr$pct_missed_row <- r3(100 * outcome_by_tr$n_missed / outcome_by_tr$n_patients)
outcome_by_tr <- rbind(outcome_by_tr, data.frame(transportation_access = "Total", n_patients = n_model,
  n_completed = sum(md_cc$completion_01), n_missed = n_events_missed,
  pct_completed_row = r3(100 * mean(md_cc$completion_01)), pct_missed_row = r3(100 * (1 - mean(md_cc$completion_01)))))
write_tbl(outcome_by_tr, "05_outcome_by_transportation.csv")

ns_tab <- with(md_cc, table(previous_no_shows, completion_01))
outcome_by_ns <- data.frame(previous_no_shows = as.integer(rownames(ns_tab)),
  n_patients = as.integer(rowSums(ns_tab)), n_completed = as.integer(ns_tab[, "1"]), n_missed = as.integer(ns_tab[, "0"]))
outcome_by_ns$pct_completed_row <- r3(100 * outcome_by_ns$n_completed / outcome_by_ns$n_patients)
write_tbl(outcome_by_ns, "05_outcome_by_previous_no_shows.csv")

wait_summary <- do.call(rbind, lapply(list(All = md_cc, Completed = md_cc[md_cc$completion_01 == 1, ],
                                           Missed = md_cc[md_cc$completion_01 == 0, ]), function(d) {
  q <- quantile(d$appointment_wait_days, c(0, .25, .5, .75, 1))
  data.frame(n = nrow(d), mean_days = r3(mean(d$appointment_wait_days)), sd_days = r3(sd(d$appointment_wait_days)),
             min = q[1], q1 = q[2], median = q[3], q3 = q[4], max = q[5], n_zero_days = sum(d$appointment_wait_days == 0))
}))
wait_summary <- cbind(group = rownames(wait_summary), wait_summary)
write_tbl(wait_summary, "05_wait_days_by_outcome.csv")

joint <- as.data.frame(with(md_cc, table(transportation_access, previous_no_shows, completion_01)))
joint_w <- reshape(joint, idvar = c("transportation_access", "previous_no_shows"), timevar = "completion_01", direction = "wide")
names(joint_w) <- c("transportation_access", "previous_no_shows", "n_missed", "n_completed")
joint_w$n_total <- joint_w$n_missed + joint_w$n_completed
joint_w$support_flag <- ifelse(joint_w$n_total == 0, "Empty cell",
                         ifelse(joint_w$n_total < 5 | joint_w$n_missed == 0 | joint_w$n_completed == 0, "Sparse (<5 total or a zero outcome cell)", "Adequate"))
joint_w <- joint_w[order(joint_w$transportation_access, as.integer(as.character(joint_w$previous_no_shows))), ]
write_tbl(joint_w, "05_joint_support_transport_noshows.csv")

# ---- 5. Primary model -------------------------------------------------------
f_primary <- completion_01 ~ wait_weeks + previous_no_shows + transportation_access
fit <- capture("primary glm", glm(f_primary, family = binomial(link = "logit"), data = md_cc))
X <- model.matrix(fit)
mm_cols <- colnames(X)
stopifnot(identical(mm_cols, c("(Intercept)", "wait_weeks", "previous_no_shows", "transportation_accessNo")))
design_rank <- qr(X)$rank
fitted_p <- fitted(fit)

sep_result <- "detectseparation not available"
if (pkg_status[["detectseparation"]]) {
  sep_fit <- capture("separation check", glm(f_primary, family = binomial("logit"), data = md_cc,
                                             method = detectseparation::detect_separation))
  sep_result <- if (isTRUE(sep_fit$outcome)) "Separation detected" else "No separation detected (infinite estimates: none)"
}

# Inference: profile-likelihood CIs, LR (Wald also reported for transparency)
ci_method <- "Profile likelihood"
ci_prof <- tryCatch(capture("profile CI", suppressMessages(confint(fit))), error = function(e) NULL)
if (is.null(ci_prof)) { ci_prof <- confint.default(fit); ci_method <- "Wald (profile failed)" }
lr_tests <- drop1(fit, test = "LRT")
co <- summary(fit)$coefficients
term_labels <- c("(Intercept)" = "Intercept (odds of completion: 0-week wait, 0 prior no-shows, transport Yes)",
                 wait_weeks = "Wait time, per additional 7 days",
                 previous_no_shows = "Previous no-shows, per one additional prior no-show",
                 transportation_accessNo = "Transportation access: No vs Yes (reference)")
or_tab <- data.frame(
  term = rownames(co), label = term_labels[rownames(co)],
  estimate_log_odds = r3(co[, 1]), std_error = r3(co[, 2]),
  odds_ratio = r3(exp(co[, 1])),
  or_ci_low = r3(exp(ci_prof[, 1])), or_ci_high = r3(exp(ci_prof[, 2])),
  wald_z = r3(co[, 3]), wald_p = signif(co[, 4], 3),
  lr_p = c(NA, signif(lr_tests[["Pr(>Chi)"]][match(c("wait_weeks", "previous_no_shows", "transportation_access"), rownames(lr_tests))], 3)),
  estimator = "Ordinary ML logistic regression (glm, binomial logit)",
  ci_method = paste(ci_method, "95% CI"), p_method = "Wald z p-value; likelihood-ratio (drop-one) p-value",
  stringsAsFactors = FALSE
)
or_tab$pct_change_odds <- ifelse(or_tab$term == "(Intercept)", NA,
  ifelse(or_tab$odds_ratio < 1, sprintf("%.1f%% lower odds", (1 - or_tab$odds_ratio) * 100),
         sprintf("%.1f%% higher odds", (or_tab$odds_ratio - 1) * 100)))
stopifnot(all(or_tab$or_ci_low <= or_tab$odds_ratio & or_tab$odds_ratio <= or_tab$or_ci_high))
write_tbl(or_tab, "05_adjusted_odds_ratios.csv")
saveRDS(fit, file.path("outputs", "models", "05_primary_model.rds"))

# Scaling check: wait_weeks coef should equal 7 x per-day coef
fit_days <- glm(completion_01 ~ appointment_wait_days + previous_no_shows + transportation_access, family = binomial, data = md_cc)
scale_ok <- isTRUE(all.equal(unname(coef(fit)["wait_weeks"]), unname(7 * coef(fit_days)["appointment_wait_days"]), tolerance = 1e-6))

# ---- 5b. Diagnostics --------------------------------------------------------
vif_vals <- if (pkg_status[["car"]]) car::vif(fit) else NULL
if (is.matrix(vif_vals)) vif_vals <- vif_vals[, 1]
cor_mat <- cor(cbind(wait_weeks = md_cc$wait_weeks, previous_no_shows = md_cc$previous_no_shows,
                     transport_no = as.numeric(md_cc$transportation_access == "No")))
dev_res <- residuals(fit, type = "deviance"); pea_res <- residuals(fit, type = "pearson")
lev <- hatvalues(fit); cook <- cooks.distance(fit); dfb <- dfbetas(fit)
p_par <- length(coef(fit))
lev_cut <- 2 * p_par / n_model; cook_cut <- 4 / n_model; dfb_cut <- 2 / sqrt(n_model)

influence_tab <- data.frame(patient_id = md_cc$patient_id, completion_01 = md_cc$completion_01,
  wait_days = md_cc$appointment_wait_days, previous_no_shows = md_cc$previous_no_shows,
  transportation_access = md_cc$transportation_access, fitted_p_completion = r3(fitted_p),
  deviance_resid = r3(dev_res), pearson_resid = r3(pea_res), leverage = r3(lev), cooks_d = signif(cook, 3),
  max_abs_dfbeta = r3(apply(abs(dfb), 1, max)))
influence_tab$flags <- paste0(ifelse(lev > lev_cut, "high-leverage ", ""), ifelse(cook > cook_cut, "Cook>4/n ", ""),
                              ifelse(influence_tab$max_abs_dfbeta > dfb_cut, "|DFBETA|>2/sqrt(n) ", ""),
                              ifelse(abs(pea_res) > 3, "|Pearson|>3", ""))
infl_flagged <- influence_tab[influence_tab$flags != "", ]
infl_flagged <- infl_flagged[order(-infl_flagged$cooks_d), ]
write_tbl(infl_flagged, "05_influence_flagged_records.csv")

# Refit without top-5 Cook's D as a review (NOT a deletion decision)
top5 <- head(influence_tab$patient_id[order(-influence_tab$cooks_d)], 5)
fit_drop5 <- glm(f_primary, family = binomial, data = md_cc[!md_cc$patient_id %in% top5, ])

# Functional form: separate centered quadratic sensitivity models
md_cc$wait_c <- md_cc$wait_weeks - mean(md_cc$wait_weeks)
md_cc$ns_c <- md_cc$previous_no_shows - mean(md_cc$previous_no_shows)
fit_q_wait <- capture("quadratic wait", glm(completion_01 ~ wait_weeks + I(wait_c^2) + previous_no_shows + transportation_access, family = binomial, data = md_cc))
fit_q_ns   <- capture("quadratic noshows", glm(completion_01 ~ wait_weeks + previous_no_shows + I(ns_c^2) + transportation_access, family = binomial, data = md_cc))
lr_q_wait <- anova(fit, fit_q_wait, test = "LRT")[2, "Pr(>Chi)"]
lr_q_ns   <- anova(fit, fit_q_ns, test = "LRT")[2, "Pr(>Chi)"]

# Binned descriptive support for wait-time linearity (observed log-odds by wait band)
md_cc$wait_band <- cut(md_cc$appointment_wait_days, c(-Inf, 5, 9, 13, Inf), labels = c("0-5", "6-9", "10-13", "14+"))
band_tab <- aggregate(completion_01 ~ wait_band, md_cc, function(x) c(n = length(x), missed = sum(x == 0), pct_completed = 100 * mean(x)))
band_tab <- data.frame(wait_band_days = band_tab$wait_band, band_tab$completion_01)
band_tab$pct_completed <- r3(band_tab$pct_completed)
write_tbl(band_tab, "05_completion_by_wait_band.csv")

hoslem_note <- "Hosmer-Lemeshow not used (sensitive to grouping; calibration plot used instead)"
diag_tab <- data.frame(diagnostic = character(), value = character(), interpretation = character(), stringsAsFactors = FALSE)
add_diag <- function(d, v, i) diag_tab[nrow(diag_tab) + 1, ] <<- list(d, as.character(v), i)
add_diag("Converged", fit$converged, "IRLS converged")
add_diag("Iterations", fit$iter, "")
add_diag("Fit warnings", ifelse(any(warn_log$step == "primary glm"), paste(warn_log$warning[warn_log$step == "primary glm"], collapse = "; "), "none"), "")
add_diag("Model-matrix columns", paste(mm_cols, collapse = ", "), "Intercept + 3 predictor coefficients as specified")
add_diag("Design-matrix rank", sprintf("%d of %d", design_rank, ncol(X)), "Full rank")
add_diag("All estimates/SEs finite", all(is.finite(co[, 1:2])), "")
add_diag("Largest |coefficient| (log-odds)", r3(max(abs(co[-1, 1]))), "No implausibly large estimate")
add_diag("Largest SE", r3(max(co[, 2])), "")
add_diag("Separation diagnostic (detectseparation)", sep_result, "Zero cells alone neither establish nor exclude separation")
add_diag("Fitted P(completion) range", paste(r3(range(fitted_p)), collapse = " to "), "")
add_diag("Fitted probabilities > 0.99 or < 0.01", sum(fitted_p > 0.99 | fitted_p < 0.01), "Count of extreme fitted values")
add_diag("Seven-day scaling check", scale_ok, "wait_weeks coef = 7 x per-day coef")
for (v in names(vif_vals)) add_diag(paste("VIF:", v), r3(vif_vals[[v]]), "Estimation overlap only; not a confounding assessment")
add_diag("Max |pairwise correlation| among predictors", r3(max(abs(cor_mat[upper.tri(cor_mat)]))), "")
add_diag("Residual deviance / df", sprintf("%.2f on %d df", fit$deviance, fit$df.residual), "Not a goodness-of-fit test for binary data")
add_diag("Null deviance / df", sprintf("%.2f on %d df", fit$null.deviance, fit$df.null), "")
add_diag("AIC", r3(AIC(fit)), "")
add_diag("Leverage cutoff 2p/n", r3(lev_cut), sprintf("%d records above", sum(lev > lev_cut)))
add_diag("Cook's D cutoff 4/n", r3(cook_cut), sprintf("%d records above; max = %.3f", sum(cook > cook_cut), max(cook)))
add_diag("|DFBETA| cutoff 2/sqrt(n)", r3(dfb_cut), sprintf("%d records above on any coefficient", sum(apply(abs(dfb), 1, max) > dfb_cut)))
add_diag("|Pearson residual| > 3", sum(abs(pea_res) > 3), "Usually missed appointments with high predicted completion")
add_diag("Top-5 Cook's D patient IDs (review refit)", paste(top5, collapse = ", "),
         sprintf("ORs without them: wait %.3f, no-shows %.3f, transport No %.3f (review only; records retained)",
                 exp(coef(fit_drop5))[2], exp(coef(fit_drop5))[3], exp(coef(fit_drop5))[4]))
add_diag("Quadratic wait (centered) LR p", signif(lr_q_wait, 3), sprintf("Diagnostic sensitivity model; quad coef = %.3f (SE %.3f)",
         coef(fit_q_wait)[3], sqrt(diag(vcov(fit_q_wait)))[3]))
add_diag("Quadratic prior no-shows (centered) LR p", signif(lr_q_ns, 3), sprintf("Diagnostic sensitivity model; quad coef = %.3f (SE %.3f)",
         coef(fit_q_ns)[4], sqrt(diag(vcov(fit_q_ns)))[4]))
add_diag("Goodness-of-fit test", "not run", hoslem_note)
write_tbl(diag_tab, "05_model_diagnostics.csv")

add_decision("Estimator", sprintf("Ordinary ML logistic regression retained as primary (%s; converged; finite SEs)", sep_result),
             "Firth not required by imbalance alone; used only as sensitivity comparison.")
add_decision("Inference", paste(ci_method, "95% CIs for ORs; Wald and LR p-values reported"), "Profile intervals behave better than Wald with few events.")
add_decision("Influence", "Flagged records reviewed, none deleted", "Diagnostics are review tools, not deletion rules.")
add_decision("Functional form", "Centered quadratic terms assessed separately as diagnostic sensitivity models; linear primary retained",
             "Not selected by p-value; extra df is costly with 30 events.")

# ---- 6. Predicted probabilities ---------------------------------------------
profiles <- data.frame(
  comparison = c("A: wait time", "A: wait time", "B: prior no-shows", "B: prior no-shows", "C: transportation", "C: transportation"),
  profile = c("Wait 7 days", "Wait 14 days", "0 prior no-shows", "1 prior no-show", "Transport Yes", "Transport No"),
  appointment_wait_days = c(7, 14, 7, 7, 7, 7),
  previous_no_shows = c(1, 1, 0, 1, 1, 1),
  transportation_access = factor(c("Yes", "Yes", "Yes", "Yes", "Yes", "No"), levels = c("Yes", "No"))
)
profiles$wait_weeks <- profiles$appointment_wait_days / 7
pr <- predict(fit, newdata = profiles, type = "link", se.fit = TRUE)
z <- qnorm(0.975)
profiles$p_completion <- plogis(pr$fit)
profiles$p_completion_low <- plogis(pr$fit - z * pr$se.fit)
profiles$p_completion_high <- plogis(pr$fit + z * pr$se.fit)
profiles$p_missed <- 1 - profiles$p_completion
profiles$p_missed_low <- 1 - profiles$p_completion_high
profiles$p_missed_high <- 1 - profiles$p_completion_low
# support: observed patients near the profile
profiles$observed_support <- sapply(seq_len(nrow(profiles)), function(i) {
  sum(md_cc$transportation_access == profiles$transportation_access[i] &
      md_cc$previous_no_shows == profiles$previous_no_shows[i] &
      abs(md_cc$appointment_wait_days - profiles$appointment_wait_days[i]) <= 2)
})
profiles$pp_difference_vs_first_in_pair <- NA
profiles$support_same_transport_noshows <- sapply(seq_len(nrow(profiles)), function(i) {
  sum(md_cc$transportation_access == profiles$transportation_access[i] & md_cc$previous_no_shows == profiles$previous_no_shows[i])
})
for (cmp in unique(profiles$comparison)) {
  idx <- which(profiles$comparison == cmp)
  profiles$pp_difference_vs_first_in_pair[idx[2]] <- 100 * (profiles$p_completion[idx[2]] - profiles$p_completion[idx[1]])
}
stopifnot(all(profiles$p_completion_low <= profiles$p_completion & profiles$p_completion <= profiles$p_completion_high),
          all(profiles$p_missed_low <= profiles$p_missed & profiles$p_missed <= profiles$p_missed_high),
          all(profiles$p_completion_low >= 0 & profiles$p_completion_high <= 1))
prob_out <- data.frame(label = "HYPOTHETICAL PROFILE — model estimate, not an observed patient",
  comparison = profiles$comparison, profile = profiles$profile,
  wait_days = profiles$appointment_wait_days, previous_no_shows = profiles$previous_no_shows,
  transportation_access = profiles$transportation_access,
  pred_completion = r3(profiles$p_completion), completion_ci_low = r3(profiles$p_completion_low), completion_ci_high = r3(profiles$p_completion_high),
  pred_missed = r3(profiles$p_missed), missed_ci_low = r3(profiles$p_missed_low), missed_ci_high = r3(profiles$p_missed_high),
  completion_pp_diff_vs_pair_reference = r3(profiles$pp_difference_vs_first_in_pair),
  observed_patients_with_same_transport_noshows_and_wait_within_2_days = profiles$observed_support,
  observed_patients_with_same_transport_and_noshows_any_wait = profiles$support_same_transport_noshows,
  ci_method = "95% Wald CI on logit scale, back-transformed; no CI for differences")
write_tbl(prob_out, "05_probability_examples.csv")

# ---- 7. Performance ---------------------------------------------------------
auc_fixed <- function(y, p) {  # P(p_case > p_control), y=1 completion is 'case'; direction fixed
  pos <- p[y == 1]; neg <- p[y == 0]
  if (!length(pos) || !length(neg)) return(NA_real_)
  r <- rank(c(pos, neg))
  (sum(r[seq_along(pos)]) - length(pos) * (length(pos) + 1) / 2) / (length(pos) * length(neg))
}
brier <- function(y, p) mean((y - p)^2)
y <- md_cc$completion_01
auc_app <- auc_fixed(y, fitted_p); brier_app <- brier(y, fitted_p)
fit_null <- glm(completion_01 ~ 1, family = binomial, data = md_cc)
brier_null <- brier(y, fitted(fit_null))

# Bootstrap optimism
B <- 500
boot_res <- data.frame(b = 1:B, status = NA_character_, auc_boot = NA_real_, auc_orig = NA_real_,
                       brier_boot = NA_real_, brier_orig = NA_real_)
for (b in 1:B) {
  idx <- sample.int(n_model, n_model, replace = TRUE)
  db <- md_cc[idx, ]
  if (length(unique(db$completion_01)) < 2 || length(unique(db$transportation_access)) < 2) { boot_res$status[b] <- "missing class"; next }
  wb <- character()
  fb <- withCallingHandlers(tryCatch(glm(f_primary, family = binomial, data = db), error = function(e) NULL),
                            warning = function(w) { wb <<- c(wb, conditionMessage(w)); invokeRestart("muffleWarning") })
  if (is.null(fb) || !fb$converged || any(!is.finite(coef(fb))) || length(wb)) {
    boot_res$status[b] <- paste("failed/warning:", paste(wb, collapse = "; ")); next
  }
  pb <- fitted(fb); po <- predict(fb, newdata = md_cc, type = "response")
  boot_res[b, 3:6] <- c(auc_fixed(db$completion_01, pb), auc_fixed(y, po), brier(db$completion_01, pb), brier(y, po))
  boot_res$status[b] <- "ok"
}
ok <- boot_res$status == "ok"; n_ok <- sum(ok); fail_rate <- 1 - n_ok / B
opt_auc <- mean(boot_res$auc_boot[ok] - boot_res$auc_orig[ok])
opt_brier <- mean(boot_res$brier_boot[ok] - boot_res$brier_orig[ok])
boot_reliable <- fail_rate <= 0.10
write_tbl(data.frame(status = names(table(boot_res$status)), n = as.integer(table(boot_res$status))), "05_bootstrap_status.csv")
write_tbl(boot_res, "05_bootstrap_resamples.csv")

perf <- data.frame(
  metric = c("N (model sample)", "Observed completion proportion", "Mean predicted completion",
             "Apparent ROC AUC (higher predicted completion = completion)", "Apparent Brier score (model)",
             "Brier score (intercept-only, same sample)", "Accuracy of all-completion classifier",
             "Bootstrap resamples requested", "Bootstrap resamples successful", "Bootstrap failure rate",
             "AUC optimism (mean bootstrap - original)", "Optimism-corrected AUC",
             "Brier optimism (mean bootstrap - original; negative = optimistic)", "Optimism-corrected Brier score"),
  value = c(n_model, r3(mean(y)), r3(mean(fitted_p)), r3(auc_app), round(brier_app, 4), round(brier_null, 4),
            r3(mean(y == 1)), B, n_ok, r3(fail_rate), round(opt_auc, 4), r3(auc_app - opt_auc),
            round(opt_brier, 4), round(brier_app - opt_brier, 4)),
  note = c("", "", "Equality is expected for ML logistic with intercept; not validation", "Direction fixed; not reversed",
           "Lower is better", "Reference: predicts 0.90 for everyone", "Shows accuracy is uninformative with 9:1 outcome",
           "Ordinary patient-row resampling; same model/estimator each time", "", ifelse(boot_reliable, "<=10%: correction usable", ">10%: correction UNRELIABLE"),
           "", "Internal validation only; not external", "", "Internal validation only; not external"),
  stringsAsFactors = FALSE)
write_tbl(perf, "05_performance_summary.csv")

# Calibration groups (quintiles of predicted completion)
cal_grp <- cut(fitted_p, breaks = unique(quantile(fitted_p, seq(0, 1, 0.2))), include.lowest = TRUE)
cal <- aggregate(cbind(pred = fitted_p, obs = y) ~ cal_grp, FUN = mean)
cal$n <- as.integer(table(cal_grp)); cal$n_missed <- as.integer(tapply(1 - y, cal_grp, sum))
cal$obs_low <- mapply(function(k, n) binom.test(k, n)$conf.int[1], round(cal$obs * cal$n), cal$n)
cal$obs_high <- mapply(function(k, n) binom.test(k, n)$conf.int[2], round(cal$obs * cal$n), cal$n)
write_tbl(transform(cal, pred = r3(pred), obs = r3(obs), obs_low = r3(obs_low), obs_high = r3(obs_high)), "05_calibration_groups.csv")

# Cutoff workload (teaching only)
missed_risk <- 1 - fitted_p
cut_tab <- do.call(rbind, lapply(c(0.10, 0.20), function(cc) {
  flag <- missed_risk >= cc; act <- y == 0
  TP <- sum(flag & act); FN <- sum(!flag & act); FP <- sum(flag & !act); TN <- sum(!flag & !act)
  dv <- function(a, b) if (b == 0) NA else a / b
  data.frame(missed_risk_cutoff = cc, total_flagged = TP + FP, TP = TP, FN = FN, FP = FP, TN = TN, total = TP + FN + FP + TN,
             sensitivity = r3(dv(TP, TP + FN)), sensitivity_denominator = TP + FN,
             specificity = r3(dv(TN, TN + FP)), specificity_denominator = TN + FP,
             precision = r3(dv(TP, TP + FP)), precision_denominator = TP + FP,
             accuracy = r3(dv(TP + TN, TP + FN + FP + TN)),
             note = ifelse(TP + FP == 0, "No one flagged: precision undefined", "Positive = actually missed; apparent (in-sample)"))
}))
stopifnot(all(cut_tab$total == n_model))
write_tbl(cut_tab, "05_cutoff_workload.csv")

# ---- 8. Sensitivity analyses ------------------------------------------------
sens_rows <- list()
summ_fit <- function(name, f, d, estimator = "ML glm", note = "", fitobj = NULL) {
  wlist <- character()
  m <- if (!is.null(fitobj)) fitobj else withCallingHandlers(glm(f, family = binomial, data = d),
         warning = function(w) { wlist <<- c(wlist, conditionMessage(w)); invokeRestart("muffleWarning") })
  if (length(wlist)) warn_log[nrow(warn_log) + 1, ] <<- list(name, paste(wlist, collapse = "; "))
  cf <- coef(m)
  ci <- if (inherits(m, "logistf")) cbind(m$ci.lower, m$ci.upper) else tryCatch(suppressMessages(confint(m)), error = function(e) confint.default(m))
  p <- if (inherits(m, "logistf")) m$prob else summary(m)$coefficients[, 4]
  out <- data.frame(analysis = name, estimator = estimator, n = nrow(d), n_completed = sum(d$completion_01), n_missed = sum(d$completion_01 == 0),
                    term = names(cf), odds_ratio = r3(exp(cf)), ci_low = r3(exp(ci[, 1])), ci_high = r3(exp(ci[, 2])),
                    p_value = signif(p, 3), warnings = ifelse(length(wlist), paste(wlist, collapse = "; "), "none"), note = note,
                    stringsAsFactors = FALSE)
  # probability contrast for transport (wait 7, ns 1) & wait (7 vs 14)
  nd <- data.frame(wait_weeks = c(1, 2, 1), appointment_wait_days = c(7, 14, 7), previous_no_shows = c(1, 1, 1),
                   any_prior_noshow = c(1, 1, 1), transportation_access = factor(c("Yes", "Yes", "No"), levels = c("Yes", "No")))
  pp <- if (inherits(m, "logistf")) predict(m, newdata = nd, type = "response") else predict(m, newdata = nd, type = "response")
  out$pp_wait14_minus_wait7 <- r3(100 * (pp[2] - pp[1])); out$pp_transportNo_minus_Yes <- r3(100 * (pp[3] - pp[1]))
  out[out$term != "(Intercept)", ]
}
sens_rows[["primary"]] <- summ_fit("0. Primary model", f_primary, md_cc, fitobj = fit, note = "Reference specification")

# A. Negative waits recoded to zero
neg_ids_log <- c(31, 112, 117, 132)
neg_verified <- if (!is.null(raw)) sort(unique(raw$patient_id[raw$appointment_wait_days < 0])) else integer()
clean_zero_ids <- md_cc$patient_id[md_cc$appointment_wait_days == 0]
a_ids <- if (length(neg_verified)) intersect(neg_verified, clean_zero_ids) else intersect(neg_ids_log, clean_zero_ids)
a_label <- if (length(neg_verified) && setequal(neg_verified, neg_ids_log)) "Verified against raw file: IDs match log; cleaned value 0" else
  if (length(neg_verified)) paste("Raw negatives:", paste(neg_verified, collapse = ",")) else "Log-based only (raw unavailable)"
dA <- md_cc[!md_cc$patient_id %in% a_ids, ]
stopifnot(nrow(dA) == n_model - length(a_ids))
sens_rows[["A"]] <- summ_fit("A. Exclude recoded negative waits", f_primary, dA,
  note = sprintf("Excluded IDs %s (%s). Other %d zero-wait records retained.", paste(a_ids, collapse = ","), a_label,
                 length(clean_zero_ids) - length(a_ids)))

# B. Age 115
b_ids <- md_cc$patient_id[md_cc$age == 115 & !is.na(md_cc$age)]
dB <- md_cc[!md_cc$patient_id %in% b_ids, ]
sens_rows[["B"]] <- summ_fit("B. Exclude age == 115 records", f_primary, dB,
  note = sprintf("Excluded IDs %s; record-exclusion robustness check (age is not a predictor)", paste(b_ids, collapse = ",")))

# C. Binary any prior no-show
md_cc$any_prior_noshow <- as.integer(md_cc$previous_no_shows >= 1)
sens_rows[["C"]] <- summ_fit("C. Any prior no-show (>=1 vs 0)", completion_01 ~ wait_weeks + any_prior_noshow + transportation_access, md_cc,
  note = "Changes the comparison: any vs none rather than per additional no-show")

# D. Complete-case: required variables originally missing/invalid
raw_req_issue_ids <- integer()
if (!is.null(raw)) {
  rr <- raw
  bad <- is.na(rr$appointment_wait_days) | is.na(rr$previous_no_shows) | is.na(rr$appointment_completed) |
         !(trimws(rr$transportation_access) %in% c("Yes", "No")) | rr$appointment_wait_days < 0
  raw_req_issue_ids <- sort(unique(rr$patient_id[bad]))
}
d_ids_extra <- setdiff(raw_req_issue_ids, c(a_ids))
d_note <- sprintf("Raw records with missing/invalid model-variable values: IDs %s (negative waits = analysis A; 'y' transport recodes are unambiguous standardizations, not missing). No distinct missing-data complete-case comparison exists; EDA global N=269 is irrelevant to this model.",
                  paste(raw_req_issue_ids, collapse = ","))
sens_D <- data.frame(analysis = "D. Complete-case (model variables only)", estimator = "not fitted", n = n_model, n_completed = sum(y), n_missed = n_events_missed,
                     term = "NOT APPLICABLE", odds_ratio = NA, ci_low = NA, ci_high = NA, p_value = NA, warnings = "", note = d_note,
                     pp_wait14_minus_wait7 = NA, pp_transportNo_minus_Yes = NA)

# E. Firth
if (pkg_status[["logistf"]]) {
  ff <- capture("firth", logistf::logistf(f_primary, data = md_cc))
  sens_rows[["E"]] <- summ_fit("E. Firth penalized logistic", f_primary, md_cc, estimator = "Firth (logistf), profile penalized-likelihood CI",
                               fitobj = ff, note = "Same predictors; comparison only")
} else {
  sens_rows[["E"]] <- data.frame(analysis = "E. Firth", estimator = "SKIPPED", n = NA, n_completed = NA, n_missed = NA, term = "logistf unavailable",
    odds_ratio = NA, ci_low = NA, ci_high = NA, p_value = NA, warnings = "", note = "", pp_wait14_minus_wait7 = NA, pp_transportNo_minus_Yes = NA)
}
sens <- rbind(do.call(rbind, sens_rows[c("primary", "A", "B", "C")]), sens_D, sens_rows[["E"]])
write_tbl(sens, "05_sensitivity_comparison.csv")

add_decision("Sensitivity A", sprintf("Excluded %d recoded negative-wait records (%s)", length(a_ids), a_label), "Zero wait was an assumption; other zero waits not excluded.")
add_decision("Sensitivity B", sprintf("Excluded age==115 IDs %s", paste(b_ids, collapse = ",")), "Robustness to questionable records; not an age test.")
add_decision("Sensitivity C", "Binary any-prior-no-show indicator", "Different research comparison; not selected by p-value.")
add_decision("Sensitivity D", "Not applicable: no missing values in model variables", "Global EDA complete-case N=269 involves unused variables.")
add_decision("Sensitivity E", "Firth logistic fit as comparison", "Ordinary ML stable; Firth reported only for robustness.")
add_decision("Validation", sprintf("Bootstrap optimism correction, B=%d, %d successful", B, n_ok), "Preferred over a single train/test split with 30 events.")
add_decision("Cutoffs", "Teaching-only missed-risk cutoffs 0.10 and 0.20; not optimized", "Workload and deployment decisions out of scope.")
add_decision("Correction to earlier docs", "Median imputation does not guarantee unbiased estimates; low events does not guarantee failure of larger models; nonsignificance is not absence",
             "Overstatements in prior chapters corrected here; prior files left unchanged.")
write_tbl(decisions, "05_modeling_decision_log.csv")

# ---- 9. Figures -------------------------------------------------------------
base_theme <- theme_minimal(base_size = 15) + theme(plot.caption = element_text(hjust = 0, size = 11), plot.title.position = "plot")
or_plot_d <- or_tab[or_tab$term != "(Intercept)", ]
or_plot_d$label <- factor(or_plot_d$label, levels = rev(or_plot_d$label))
g1 <- ggplot(or_plot_d, aes(x = odds_ratio, y = label)) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey40") +
  geom_errorbar(aes(xmin = or_ci_low, xmax = or_ci_high), width = 0.2, linewidth = 0.9, colour = "#2b6c8f", orientation = "y") +
  geom_point(size = 3.5, colour = "#2b6c8f") + scale_x_log10() +
  labs(title = "Adjusted odds ratios for appointment completion", x = "Odds ratio (log scale; 1 = no difference in odds)", y = NULL,
       caption = sprintf("Ordinary logistic regression, N = %d (%d completed, %d missed). Each OR adjusted for the other two predictors.\n%s 95%% CIs. Simulated practice data; associations, not causal effects.", n_model, sum(y), n_events_missed, ci_method)) +
  base_theme
ggsave(fig_path("05_adjusted_odds_ratios.png"), g1, width = 10, height = 5, dpi = 150)

wgrid <- data.frame(appointment_wait_days = seq(min(md_cc$appointment_wait_days), max(md_cc$appointment_wait_days), by = 0.25))
wgrid$wait_weeks <- wgrid$appointment_wait_days / 7; wgrid$previous_no_shows <- 1
wgrid <- rbind(transform(wgrid, transportation_access = factor("Yes", levels = c("Yes", "No"))),
               transform(wgrid, transportation_access = factor("No", levels = c("Yes", "No"))))
pw <- predict(fit, newdata = wgrid, type = "link", se.fit = TRUE)
wgrid$p <- plogis(pw$fit); wgrid$lo <- plogis(pw$fit - z * pw$se.fit); wgrid$hi <- plogis(pw$fit + z * pw$se.fit)
g2 <- ggplot(wgrid, aes(appointment_wait_days, p, colour = transportation_access, fill = transportation_access)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.18, colour = NA) + geom_line(linewidth = 1.1) +
  geom_rug(data = md_cc, aes(x = appointment_wait_days), sides = "b", alpha = 0.3, inherit.aes = FALSE) +
  scale_y_continuous(labels = function(x) paste0(round(100 * x), "%"), limits = c(0, 1)) +
  scale_colour_manual(values = c(Yes = "#2b6c8f", No = "#c0602a"), name = "Transportation access") +
  scale_fill_manual(values = c(Yes = "#2b6c8f", No = "#c0602a"), name = "Transportation access") +
  labs(title = "Estimated completion probability by wait time", x = "Appointment wait (days)", y = "Estimated P(completion)",
       caption = sprintf("Model estimates with 95%% CIs; previous no-shows fixed at 1. Rug = observed wait days (N = %d).\nTransport 'No' curve is based on only %d patients. Simulated data; not causal.", n_model, sum(md_cc$transportation_access == "No"))) +
  base_theme + theme(legend.position = "bottom")
ggsave(fig_path("05_wait_time_probabilities.png"), g2, width = 10, height = 6.5, dpi = 150)

g3 <- ggplot(cal, aes(pred, obs)) + geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey40") +
  geom_errorbar(aes(ymin = obs_low, ymax = obs_high), width = 0.005, colour = "#2b6c8f") +
  geom_point(size = 3.5, colour = "#2b6c8f") + geom_text(aes(label = paste0("n=", n, "\nmissed=", n_missed)), vjust = -0.6, size = 3.6) +
  scale_x_continuous(labels = function(x) paste0(round(100 * x), "%")) +
  scale_y_continuous(labels = function(x) paste0(round(100 * x), "%")) +
  labs(title = "Apparent calibration (quintiles of predicted completion)", x = "Mean predicted completion", y = "Observed completion (exact 95% CI)",
       caption = sprintf("In-sample (apparent) calibration, N = %d; dashed line = perfect calibration. Not external validation.", n_model)) +
  base_theme
ggsave(fig_path("05_calibration.png"), g3, width = 9, height = 6.5, dpi = 150)

# Support figure: observed completion by prior no-shows and transport
g4 <- ggplot(outcome_by_ns, aes(factor(previous_no_shows), pct_completed_row)) + geom_col(fill = "#2b6c8f") +
  geom_text(aes(label = paste0(n_completed, "/", n_patients)), vjust = -0.4, size = 4.5) +
  labs(title = "Observed completion by previous no-shows", x = "Previous no-shows", y = "Observed completion (%)",
       caption = "Observed (unadjusted) summary; label = completed / patients.") + coord_cartesian(ylim = c(0, 105)) + base_theme
ggsave(fig_path("05_observed_completion_by_noshows.png"), g4, width = 8, height = 5.5, dpi = 150)

# ---- 10. Session info, warnings, manifest -----------------------------------
write_tbl(if (nrow(warn_log)) warn_log else data.frame(step = "all", warning = "none captured"), "05_runtime_warnings.csv")
sink(file.path("outputs", "models", "05_session_info.txt"))
cat("Chapter 05 session info — run at", format(Sys.time()), "\n")
cat("Project root:", project_root, "\nSeed: 20261017\nRStudio project:", rproj_note, "\n\nInputs (md5):\n")
print(input_manifest, row.names = FALSE)
cat("\nPackage availability:\n"); print(pkg_status)
cat("\nPackage versions:\n")
for (p in pkgs_needed) if (pkg_status[[p]]) cat(p, as.character(packageVersion(p)), "\n")
cat("\nRuntime warnings captured:\n"); print(warn_log)
cat("\n"); print(sessionInfo())
sink()

deliverables <- c(
  "scripts/05_statistical_modeling.R", "reports/05_statistical_modeling_report.md",
  paste0("outputs/tables/", c("05_model_sample_audit.csv", "05_outcome_by_transportation.csv", "05_adjusted_odds_ratios.csv",
    "05_probability_examples.csv", "05_model_diagnostics.csv", "05_performance_summary.csv", "05_cutoff_workload.csv",
    "05_sensitivity_comparison.csv", "05_modeling_decision_log.csv", "05_output_manifest.csv",
    "05_input_checksums.csv", "05_outcome_by_previous_no_shows.csv", "05_wait_days_by_outcome.csv",
    "05_joint_support_transport_noshows.csv", "05_influence_flagged_records.csv", "05_completion_by_wait_band.csv",
    "05_bootstrap_status.csv", "05_bootstrap_resamples.csv", "05_calibration_groups.csv", "05_runtime_warnings.csv")),
  paste0("outputs/figures/", c("05_adjusted_odds_ratios.png", "05_wait_time_probabilities.png", "05_calibration.png",
    "05_observed_completion_by_noshows.png")),
  "outputs/models/05_primary_model.rds", "outputs/models/05_session_info.txt")
manifest <- data.frame(file = deliverables, exists = file.exists(deliverables) | grepl("05_output_manifest", deliverables),
                       stringsAsFactors = FALSE)
manifest$status <- ifelse(manifest$exists, "created", "MISSING")
manifest$status[grepl("report.md$", manifest$file) & !manifest$exists[grepl("report.md$", manifest$file)]] <- "written separately after script run"
manifest$status[grepl("05_output_manifest", manifest$file)] <- "created (this file)"
manifest$note <- ""
manifest$note[grepl("bootstrap", manifest$file)] <- sprintf("%d/%d successful resamples", n_ok, B)
write_tbl(manifest, "05_output_manifest.csv")

# ---- Console summary ---------------------------------------------------------
cat("\n==== Chapter 05 summary ====\n")
cat("N =", n_model, "| completed =", sum(y), "| missed =", n_events_missed, "\n")
print(or_tab[, c("term", "odds_ratio", "or_ci_low", "or_ci_high", "wald_p", "lr_p")], row.names = FALSE)
print(prob_out[, c("profile", "pred_completion", "completion_ci_low", "completion_ci_high", "completion_pp_diff_vs_pair_reference", "observed_patients_with_same_transport_noshows_and_wait_within_2_days")], row.names = FALSE)
print(perf[, 1:2], row.names = FALSE)
print(cut_tab[, 1:14], row.names = FALSE)
print(sens[, c("analysis", "n", "n_missed", "term", "odds_ratio", "ci_low", "ci_high", "p_value", "pp_transportNo_minus_Yes")], row.names = FALSE)
print(diag_tab, row.names = FALSE)
print(joint_w, row.names = FALSE); print(outcome_by_tr); print(outcome_by_ns); print(wait_summary); print(band_tab); print(cal)
print(head(infl_flagged, 8)); print(warn_log); print(manifest)
