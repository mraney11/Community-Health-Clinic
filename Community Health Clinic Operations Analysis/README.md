# Community Health Clinic Operations Analysis

**Author: Michael Raney**  
An R and Quarto portfolio project using simulated appointment data.

## Project Reports

- [Executive summary (PDF)](reports/08_executive_summary_clinic.pdf)
- [Full operations report (HTML)](reports/community_health_clinic_operations_report.html)
  Download the HTML file from GitHub, then open it in your browser

## Project overview

This project examines how appointment wait time, previous missed appointments, and transportation access are associated with appointment completion. It demonstrates a complete analytical workflow: understanding the data, documenting cleaning decisions, exploring patterns, fitting a logistic regression model, checking its limitations, and communicating the results.

**Main finding:** The analysis did not establish a clear association between any of the three predictors and appointment completion. The model also did not meaningfully distinguish patients who completed their appointments from those who missed them.

**All data are simulated.** These findings describe this practice dataset and provide no evidence about the performance of a real clinic or the effectiveness of a real intervention.

## Research question

How are appointment wait time, previous no-shows, and transportation access associated with appointment completion after accounting for one another?

“After accounting for one another” means that the model estimates each association while holding the other two predictors constant. For example, the transportation comparison holds wait time and the number of previous no-shows constant. It does not adjust for every possible difference between patients.

## Data and preparation

The raw file contained 303 rows and 35 variables. Removing three exact duplicate rows left **300 patients, each represented by one scheduled appointment**:

| Appointment outcome | Patients | Percentage |
|---|---:|---:|
| Completed | 270 | 90.0% |
| Missed | 30 | 10.0% |

Cleaning included standardizing category labels, identifying implausible values, and documenting corrections. Four negative wait times were recoded to zero under a same-day booking assumption, and three records with implausible age `115` were retained with flags; sensitivity analyses examined the results with each set of records excluded. Missing values in selected demographic and clinical variables were median-imputed, but **none of those imputed variables (nor age) entered the primary model**, so all **300 patients** were included in the primary analysis. Unadjusted completion was **91.1% (234/257)** among patients with transportation access and **83.7% (36/43)** among those without access.

## Analytical approach

Exploratory analysis described patient characteristics and appointment completion across groups. One prespecified logistic regression model then estimated completion using three predictors: wait time, previous no-shows, and transportation access. Variables measured during or after the appointment were excluded from prediction to avoid using information unavailable before the visit.

Model checks examined numerical stability, overlapping predictor information, the shape of associations, and influential records. Sensitivity analyses assessed how selected cleaning and modeling decisions affected the findings. Predictive performance was evaluated separately, including internal validation with 500 bootstrap resamples.

## Main findings

### Adjusted associations remain uncertain

An odds ratio compares the odds of completion between two profiles. A value of 1 means equal odds; values above 1 indicate higher odds, and values below 1 indicate lower odds. **An odds ratio is not a probability ratio or a percentage-point difference.**

| Predictor comparison | Adjusted odds ratio | 95% confidence interval | Plain-language interpretation |
|---|---:|---:|---|
| Seven additional wait days | 1.052 | 0.627–1.787 | The estimate is close to equal odds, with substantial uncertainty in either direction. |
| One additional previous no-show | 1.065 | 0.732–1.607 | The estimate is close to equal odds; a single slope also oversimplifies the observed pattern. |
| Without vs. with transportation access | 0.481 | 0.189–1.340 | The estimate suggests lower completion odds without access, but the direction and size remain uncertain. |

Each comparison holds the other two predictors constant. All three confidence intervals include 1 and span potentially meaningful associations in both directions. **These results do not prove that the predictors have no association with completion.**

The transportation estimate requires particular caution: only 43 patients lacked transportation access, and seven of them missed their appointments. A diagnostic refit excluding five influential records changed the direction of that estimate. Those records remained in the primary analysis; the check demonstrated sensitivity to a small number of observations (excluding influential records is a diagnostic sensitivity check, not a justified primary analysis).

### A probability example makes the estimate more concrete

For a hypothetical patient profile with a seven-day wait and one previous no-show, estimated completion probability was:

| Transportation access | Estimated completion probability | 95% confidence interval |
|---|---:|---:|
| With access | 91.0% | 86.3%–94.2% |
| Without access | 83.0% | 67.3%–92.0% |

The estimated difference was **8.1 percentage points lower without transportation access**, calculated from unrounded predictions (`82.98%` vs. `91.03%`). This comparison applies to the specified illustrative profiles, rather than representing actual matched patient pairs or an average across all patients (`0.0` percentage points is the no-difference reference). No confidence interval was calculated for the difference itself (endpoints of the two separate probability intervals cannot be subtracted, and confidence interval overlap is not a formal statistical test of a probability difference), and few observed patients closely matched the profile without transportation access (`2` patients within $7 \pm 2$ wait days). It does not show that providing transportation would cause an 8.1-point improvement.

### Prediction was near chance

**The model showed no useful ability to distinguish completed from missed appointments in this dataset.** The model's apparent ROC AUC was `0.536` when evaluated on the data used to fit it. After bootstrap adjustment for optimism across 500 resamples, the AUC was **`0.476`**, near the `0.500` chance benchmark (no formal statistical comparison with chance is claimed here). Note that a near-chance AUC measures individual ranking ability and does not by itself prove that each predictor has zero association with completion.

Because 90% of patients completed their appointments, predicting “completed” for everyone would achieve 90% accuracy while identifying none of the missed appointments. Accuracy alone would therefore give a misleading impression of usefulness.

**This model does not support individual patient risk scoring or outreach targeting.**

## Limitations and practical meaning

- The records are simulated and cannot establish real clinic needs, cost savings, or intervention effects.
- Only 30 appointments were missed, limiting the precision of the estimates and the complexity of the analysis.
- Some subgroups were small. The observed pattern for previous no-shows was not a steady increase or decrease, making its single model slope provisional.
- The model adjusted for only three predictors. Clinic location, visit reason, and other factors could influence the associations.
- The analysis does not establish causation. Predictive evaluation used internal validation; no independent external dataset was evaluated.

Keeping proposed future work distinct from demonstrated findings, useful next steps for a future study with real clinic data would include collecting **a larger, representative sample containing more missed appointments** (without implying deliberate oversampling of missed visits lacking an appropriate sampling design), improving measurement of access barriers, and planning which additional factors to account for. Any proposed outreach model would need evidence of useful predictive performance before operational use.

## Project files

| Location | Contents |
|---|---|
| [`Community Health Clinic Operations Analysis.Rproj`](Community%20Health%20Clinic%20Operations%20Analysis.Rproj) | RStudio project sentinel anchoring project-relative paths (`here::i_am()`) |
| [`data/`](data/) | Raw simulated data (`community_health_clinic_raw_v2.csv`, 303 rows: 273 completed + 30 missed) and cleaned analysis data (`community_health_clinic_clean.csv`, 300 rows: 270 completed + 30 missed) |
| [`documentation/`](documentation/) | Data dictionary ([`community_health_clinic_data_dictionary_v2.xlsx`](documentation/community_health_clinic_data_dictionary_v2.xlsx)) |
| [`scripts/`](scripts/) | R scripts for screening (`02`), cleaning (`03`), exploratory analysis (`04`), and modeling (`05`) |
| [`outputs/tables/`](outputs/tables/) | Results, diagnostics, validation tables, decision logs, and current/historical input checksum manifests |
| [`outputs/figures/`](outputs/figures/) | Exploratory and modeling figures |
| [`outputs/models/`](outputs/models/) | Saved primary model (`05_primary_model.rds`), run log, and session info |
| [`outputs/archive_20261110_pre_revision/`](outputs/archive_20261110_pre_revision/) | Pre-revision archive backups of executive summary files, historical checksum manifest, and pre-revision stage files |
| [`reports/`](reports/) | Quarto technical report ([HTML](reports/community_health_clinic_operations_report.html) and [`.qmd`](reports/community_health_clinic_operations_report.qmd)), [executive summary PDF](reports/08_executive_summary_clinic.pdf) (and [`.qmd` source](reports/08_executive_summary_clinic.qmd)), and supporting stage reports (`02`, `03`, `04`, `05`, `09`) |

The main technical report is [`reports/community_health_clinic_operations_report.html`](reports/community_health_clinic_operations_report.html) (rendered from [`reports/community_health_clinic_operations_report.qmd`](reports/community_health_clinic_operations_report.qmd)), and the 2-page leadership brief is [`reports/08_executive_summary_clinic.pdf`](reports/08_executive_summary_clinic.pdf).

## Tools and skills demonstrated

R, RStudio, and Quarto; documented data cleaning; exploratory visualization; logistic regression; uncertainty interpretation; model diagnostics; sensitivity analysis; bootstrap internal validation; and clear reporting of analytical limitations.
