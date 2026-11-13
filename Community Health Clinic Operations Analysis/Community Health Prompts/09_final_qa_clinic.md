# Prompt 09 — Final QA & Packaging
## Community Health Clinic Operations Analysis

You are my R analyst, statistical reviewer, and reporting editor. Complete the final quality review of this existing simulated-data portfolio project. Work within the current clinic project only. Make justified corrections and produce a clear record of what you verified, changed, and could not verify.

## 1. Execution boundaries

- Establish the project root from the open clinic RStudio project or active workspace. Print the resolved absolute root before proceeding. If the workspace is not clearly the clinic project, stop and request the root path.
- Do not scan sibling projects, parent directories, my home folder, or unrelated repositories. Do not copy material from the food bank or homeless services projects.
- Use existing project-relative paths and here::here() where appropriate. Do not introduce colons into file or folder names.
- Preserve raw data and original analysis decisions. Do not silently change outcomes, predictors, reference groups, sample exclusions, estimators, or model specifications to improve results.
- Correct reversible code, reporting, path, and formatting errors within this project. Record every substantive change. Flag analytical changes that need my decision separately.
- Do not install packages, edit global R configuration, delete files, commit, push, or publish without explicit authorization. If a dependency is unavailable, report the specific blocked check and continue independent checks.
- Keep this review focused. Do not add new models, exercises, or analyses merely to expand the project.

## 2. Inventory and evidence

Locate the current raw and cleaned datasets, data dictionary and cleaning documentation, EDA outputs, Chapter 05 script and modeling outputs, Quarto source and rendered HTML, root README.md, and executive summary source and PDF. Use actual filenames; do not assume that every proposed deliverable exists.

Identify the current version of each report using its contents and provenance, not modification time alone. If multiple conflicting versions remain ambiguous, report the conflict before editing the affected file. Record missing items without inventing replacements for unavailable analysis evidence.

Use generated analysis outputs and reproducible scripts as numerical evidence. If reports disagree, trace the discrepancy to its source. Do not treat the values below as instructions to force the data to match.

## 3. Verify data and sample consistency

Check row counts, exact duplicate handling, outcome coding, predictor coding and reference categories, units, missingness, model exclusions, and denominators across outputs.

Previously reported values to verify:

- 303 raw rows; three exact duplicate rows removed; 300 unique patients with one appointment each.
- 270 completed appointments and 30 missed appointments; completion coded as the modeled event.
- Primary model: completion associated with appointment wait time, previous no-shows, and transportation access, each adjusted for the other two.
- All 300 records included in the primary model, if confirmed by the actual missingness and sample audit.
- Transportation access: 234 completions among 257 with access; 36 among 43 without access.

Confirm how the three age-115 records were handled in cleaning. Do not claim they were excluded from the primary model unless the actual analysis supports that statement. Explain whether age is relevant to the selected model.

## 4. Verify modeling and interpretation

Confirm the primary estimator and confidence interval method from the code and outputs. Clearly distinguish primary estimates from Firth comparisons, diagnostic exclusions, and other sensitivity checks.

Verify these previously reported results against the underlying evidence:

- Wait time: adjusted odds ratio 1.052 per additional SEVEN days, interval 0.627–1.787. Do not label it as a one-day estimate.
- Previous no-shows: adjusted odds ratio 1.065 per additional prior no-show, interval 0.732–1.607.
- Lacking versus having transportation access: adjusted odds ratio 0.481, interval 0.189–1.340. Reversing the comparison requires reversing the estimate and interval correctly.
- Apparent AUC 0.536 and bootstrap optimism-corrected AUC 0.476, subject to confirmation of the calculation and outcome orientation.
- Hypothetical profile with a seven-day wait and one previous no-show: approximately 91.0% completion with transportation and 83.0% without, a reported 8.1 percentage-point difference from unrounded predictions. Confirm intervals and rounding from outputs. Do not calculate a confidence interval for the difference by subtracting endpoints of the two probability intervals.
- Any claim about five influential records reversing the transportation estimate must identify the relevant sensitivity analysis. Do not present that exclusion as the primary result.

Ensure every interpretation distinguishes odds, probabilities, and percentage points. Confidence intervals containing 1 do not establish that an association is absent. Separate association, predictive discrimination, and causation. Do not suggest that a near-chance AUC establishes that each predictor is unrelated to completion.

Check that sensitivity analyses, limited missed-appointment counts, small subgroups, and unadjusted factors are described without overstating what was established. Do not introduce claims of cost savings, effective interventions, or real-clinic findings from simulated data.

## 5. Improve the HTML report's accessibility

The analyst has found parts of the HTML report cryptic. Improve the existing Quarto source, then render it; do not edit only the generated HTML.

- Near the beginning, provide a short plain-language overview answering: What was studied? What did we learn? How uncertain are the results? What should a reader do with them?
- Begin the principal results sections with their practical meaning before technical detail.
- Explain adjusted association as the estimated relationship for one predictor while accounting for the other two.
- Give the unit and reference group beside each principal odds ratio. Explain that 1 is the no-association reference for odds ratios and 0 for probability differences.
- Explain AUC briefly and why predicting completion for everyone would achieve 90% accuracy while identifying no missed visits in this sample.
- Explain log-odds, Wald p-values, and likelihood-ratio p-values briefly where they appear. Keep detailed statistical output available in a technical section or appendix when appropriate. State the method used for each test; do not imply that all p-values or confidence intervals must agree exactly.
- Distinguish illustrative patient profiles from actual matched pairs and from average predictions for all patients.
- Preserve necessary technical evidence and numerical precision while making the main reading path understandable.

## 6. Refine the executive summary and README

Edit the executive summary source and regenerate its PDF when the source and rendering tools are available. If only a PDF exists, report the missing editable source and offer a clearly labeled replacement source rather than silently overwriting it with a reconstruction.

Apply these previously requested editorial changes:

- Reduce the long paragraph containing all three adjusted odds ratios and intervals. Emphasize the uncertain associations in plain language; retain full numerical detail in the technical report.
- Prefer: “The model showed no useful ability to distinguish completed from missed appointments in this dataset.”
- Describe the future data need as “a larger, representative sample containing more missed appointments.” Do not imply deliberate oversampling without an appropriate design.
- Keep the distinction between proposed future work and demonstrated findings explicit.
- Aim for approximately 1.5–2 readable pages. Do not shrink text excessively to meet a page target.

Check that README links resolve, its findings agree with the final reports, and it clearly identifies the data as simulated. Preserve its concise portfolio purpose. Do not add a lengthy How to Run section unless needed to correct an existing reproducibility claim.

## 7. Reproducibility, rendering, and packaging

- Run relevant existing scripts in a clean R session when feasible. Rerun only what is needed to validate dependencies or corrections; do not replace existing results with an unverified partial run.
- Check stochastic seeds, input paths, output paths, and script execution order where relevant.
- Capture errors and warnings; assess their consequences rather than suppressing them or claiming they did not occur.
- Render the revised Quarto report and executive summary using the project's established workflow. Check tables, figures, links, tabs, headings, and relative assets. Inspect the PDF pages visually for clipping, awkward breaks, and readability. Identify any visual check you cannot perform.
- Preserve the existing data/, scripts/, outputs/, outputs/figures/, reports/, and documentation structure where present. Keep README.md at the root. Avoid unnecessary renaming, duplicate final versions, and destructive cleanup.
- Inspect repository status and tracked files if Git is available. Check whether referenced assets are included and temporary files or sensitive configuration would be exposed. Report recommendations; do not commit or push.

## 8. Required review outputs

Create these files using the existing equivalent output folders if the project uses a different established structure:

1. reports/09_final_qa_report.md — overall status, checks performed, evidence, material findings, unresolved issues, and rendering/reproducibility results.
2. outputs/09_final_qa_checklist.csv — columns: check_id, area, check, status, evidence, action_taken, remaining_issue. Use PASS, FIXED, NEEDS_REVIEW, BLOCKED, or NOT_APPLICABLE. Do not mark an unperformed check PASS.
3. reports/09_final_change_log.md — files changed, what changed, why, and validation. Include a before/after summary for substantive reporting corrections.
4. outputs/09_final_deliverable_inventory.csv — relative_path, purpose, exists, verification_status. List the actual final portfolio files and necessary assets; do not claim missing files exist.

Update the existing report sources and rendered deliverables where justified. Do not create a second README or multiple competing final reports.

## 9. Stop point and final response

Complete the authorized review and corrections, then stop before publishing. Distinguish:

- Ready for portfolio review: critical checks completed with no unresolved material issues.
- Ready with limitations: usable, with specifically disclosed noncritical limitations.
- Not ready: unresolved numerical conflicts, failed renders, missing essential assets, or other material issues.

Finish with a concise explanation for Mike: what was checked, what changed, what remains uncertain, and the exact paths of the files to review. List any decisions he needs to make. Never equate completion of this prompt with verified readiness when checks remain blocked.
