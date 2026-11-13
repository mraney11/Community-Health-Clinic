# AI Analyst Handbook

### Building Better Analytical Thinking

Author:
Michael Raney

Developed through collaborative work with ChatGPT

Purpose

This handbook is a personal reference designed to strengthen analytical thinking for nonprofit data analytics.

Rather than teaching software alone, it emphasizes:

• analytical reasoning
• statistical thinking
• AI-assisted workflows
• interpretation of evidence
• communication of findings
• professional best practices

This handbook is intended to grow continuously through future projects and experience.


Chapter 2B.1 — From Clean Data to Analytical Thinking
The Most Important Transition in an Analytics Project
Many beginning analysts believe that once the data have been cleaned, the difficult work is finished.
Experienced analysts know the opposite is true.

Cleaning data prepares the project for analysis, but it does not answer a single research question. At the conclusion of data preparation, you possess a trustworthy dataset—not a meaningful understanding of the problem.

This transition marks the point where technical work gives way to intellectual work.

Up to this stage, the analyst has focused primarily on questions such as:

Are the data accurate?
Are missing values handled appropriately?
Are variable types correct?
Are duplicate records removed?
Are obvious errors documented?
Can the dataset be trusted?
These are essential questions because unreliable data inevitably produce unreliable conclusions.
However, once confidence in the dataset has been established, the analyst must deliberately change perspective.

The question is no longer:

"How do I improve the dataset?"
Instead, it becomes:
"What is this dataset capable of teaching me?"
That change in thinking separates data technicians from analysts.
Data Never Speaks for Itself
A common misconception is that analysts simply "look at the data and see what is there."
In reality, datasets rarely reveal meaningful insights without thoughtful questions guiding the investigation.

Imagine receiving a spreadsheet containing 300 patient visits to a community health clinic.

Without a question, the spreadsheet is simply a collection of numbers.

Once meaningful questions are introduced, however, the same dataset becomes a source of evidence.

Examples include:

Which patient groups miss appointments most frequently?
Which services require the longest appointment times?
Does insurance status relate to clinic utilization?
Which demographic characteristics appear associated with chronic disease?
Which operational bottlenecks most affect patient access?
The dataset has not changed.
Only the analyst's thinking has changed.

Analysis Begins With Curiosity
Experienced analysts approach every project with disciplined curiosity.
Curiosity differs from guessing.

Instead of asking random questions, analysts ask questions that advance the organization's mission.

For nonprofit organizations, those questions often include:

How can we serve more people?
Which services produce the greatest benefit?
Where are resources being wasted?
Which clients are most at risk?
What evidence supports future funding requests?
Which operational changes would improve outcomes?
Every statistical procedure performed later should ultimately help answer one or more of these questions.
If a graph, model, or statistical test cannot contribute to a meaningful organizational question, it probably should not be performed.

Thinking Before Computing
Modern software makes it remarkably easy to generate dozens of graphs, tables, correlations, and statistical models within minutes.
Artificial intelligence can now generate hundreds.

This creates a new challenge.

The limiting factor is no longer computational power.

It is analytical judgment.

Experienced analysts resist the temptation to produce every available output.

Instead, they ask:

What decision will this analysis support?
What question does this figure answer?
Who will use this information?
Would this result change an organizational decision?
Does this analysis increase understanding, or merely increase volume?
The goal is not to produce more output.
The goal is to produce more useful evidence.

AI Changes the Mechanics—Not the Thinking
Artificial intelligence has transformed analytics by dramatically reducing the time required to generate summaries, visualizations, statistical models, and written reports.
What AI has not replaced is the need for sound analytical reasoning.

AI can:

generate code,
summarize variables,
identify patterns,
fit statistical models,
create visualizations,
draft reports.
AI cannot determine, on its own, whether a question matters to the organization, whether an apparent pattern is meaningful in context, or whether a recommendation is appropriate for decision-makers. Those remain human responsibilities.
The strongest analyst–AI collaborations therefore divide the work thoughtfully:

The analyst defines the objectives, evaluates evidence, and exercises judgment.
The AI accelerates computation, documentation, and exploration.
Each contributes different strengths.
Learning Reflection
Before beginning any exploratory analysis, pause and ask yourself:
What decisions might this organization make using these data?
Which variables are most likely to inform those decisions?
What relationships would genuinely improve understanding?
Which analyses would simply create unnecessary output?
If I could answer only three questions with this dataset, which three would matter most?
If you cannot answer these questions, you are not yet ready to begin EDA.
That is not a weakness—it is an indication that more thinking should occur before more computing.

Key Takeaways
At the end of data preparation:
A clean dataset is the starting point, not the destination.
Good analysis begins with well-formulated questions.
Every graph, table, and model should serve an organizational purpose.
AI is a powerful analytical partner, but it does not replace human judgment.
The analyst's primary responsibility is to transform reliable data into reliable decisions.
End of Section 2B.1


Chapter 2B.2 — Converting Organizational Questions into Analytical Questions
Core Concept
One of the defining characteristics of experienced analysts is that they rarely begin with statistics.
They begin with questions.
More specifically, they begin by translating an organization's goals into questions that data can answer.
This translation is one of the most valuable skills an analyst develops.
Organizations speak the language of missions, programs, budgets, and clients.
Data speak the language of variables, observations, distributions, and relationships.
The analyst serves as the bridge between these two worlds.
Why This Matters
Consider two very different ways to begin an analysis.
Beginning Analyst
"Let's calculate correlations and make some graphs."
Experienced Analyst
"What decision is the organization trying to make?"
The second approach almost always produces better analysis.
Statistics are tools—not objectives.
A nonprofit executive is rarely interested in a correlation coefficient simply because it exists.
Instead, they want evidence that helps answer questions such as:
Should we expand this program?
Which clients need additional support?
Where should limited funding be invested?
Which services appear to improve outcomes?
What evidence can strengthen a grant proposal?
Only after those questions are clear should the analyst decide which analyses are appropriate.
The Translation Process
A useful habit is to move through three stages.
Stage 1 — Organizational Question
This is usually broad.
Examples include:
Why are clients leaving the program?
Can we reduce missed appointments?
Which services have the greatest impact?
Are our resources being used efficiently?
These questions are meaningful, but they cannot yet be answered statistically.
Stage 2 — Analytical Question
Now the analyst asks:
What measurable evidence would help answer this question?
For example:
Organizational question:
Why are patients missing appointments?
Analytical questions:
Does age relate to missed appointments?
Does insurance status relate to attendance?
Does travel distance appear associated with no-show rates?
Are certain appointment times associated with more missed visits?
Notice that these questions involve measurable variables.
Stage 3 — Statistical Question
Only now should statistical methods enter the discussion.
For example:
Compare appointment attendance across insurance groups.
Estimate no-show rates by age category.
Examine relationships between travel distance and attendance.
Build a predictive model identifying factors associated with missed appointments.
The progression is therefore:
Mission → Question → Evidence → Analysis
Not the reverse.
Community Health Clinic Example
Suppose the clinic director says:
"We're concerned about long patient wait times."
That statement is not yet an analytical question.
The analyst begins asking additional questions.
What does "long" mean?
Average waiting time?
Maximum waiting time?
Waiting time by provider?
Waiting time by clinic day?
Waiting time by appointment type?
Next, the analyst identifies variables.
Possible variables include:
appointment type
provider
clinic location
day of week
arrival time
appointment duration
staffing level
Finally, analytical questions emerge.
Examples:
Which providers have the longest average delays?
Are afternoon appointments delayed more frequently?
Which appointment types require the longest visits?
Does staffing level appear related to patient waiting time?
Notice how the original concern has become a series of answerable questions.
Common Beginner Mistakes
Beginning analysts often make predictable mistakes.
Mistake 1
Running every available statistical procedure.
More output rarely means more insight.
Mistake 2
Choosing statistical tests before defining the research question.
The question should determine the method—not the other way around.
Mistake 3
Assuming interesting patterns automatically matter.
A statistically significant finding that has no practical importance may not help the organization make better decisions.
Mistake 4
Confusing curiosity with purpose.
Exploration is valuable.
Random exploration without organizational objectives usually produces interesting trivia rather than actionable evidence.
Reflection Questions
Before beginning any analysis, ask yourself:
What organizational decision could this analysis support?
Which variables directly relate to that decision?
What evidence would convince a decision-maker?
Which analyses would add clarity?
Which analyses would simply add pages to the report?
If you cannot answer these questions, spend more time refining the analytical questions before opening your statistical software.
Key Takeaways
Organizations begin with missions; analysts begin with questions.
Good analytical questions are measurable.
Statistical methods should always be selected to answer specific questions.
Every graph, table, and model should have a clear decision-making purpose.
Strong analysts translate organizational goals into evidence that leaders can use.

============================================================
AI ANALYST HANDBOOK
Section 2B.3 — Analytical Thinking During Exploratory Data Analysis
============================================================
Purpose
Exploratory Data Analysis (EDA) is frequently misunderstood as a process of producing graphs and summary statistics. In reality, EDA is the analyst's primary opportunity to develop an accurate mental model of the dataset before formal modeling begins.
The purpose of EDA is not simply to describe the data.
Its purpose is to discover how the data behaves.
The Analyst's Mindset
An experienced analyst approaches every figure with curiosity rather than confirmation.
The analyst continually asks:
Why does this look this way?
Is this expected?
Is there another explanation?
What additional evidence would strengthen this conclusion?
What questions does this result create?
Good analysts generate new questions faster than they generate answers.
Description Before Interpretation
Always separate observation from interpretation.
For example:
Observation:
Program A has the highest average outcome score.
Interpretation:
Program A may be more effective because...
The first statement is supported directly by data.
The second is a hypothesis requiring additional evidence.
Maintaining this distinction prevents accidental overstatement throughout the analysis.
Patterns Are Clues
EDA discovers clues.
It rarely discovers proof.
Patterns may suggest:
possible relationships
hidden subgroups
nonlinear behavior
interaction effects
measurement problems
unexpected distributions
Each observation becomes a possible direction for later investigation.
Every Figure Should Answer a Question
Never create visualizations merely because they are standard.
Instead ask:
What question does this figure answer?
Examples:
Instead of:
"Histogram of Age"
Think:
"Does age appear normally distributed?"
Instead of:
"Scatterplot"
Think:
"Does increased service intensity appear associated with improved outcomes?"
The figure exists because it answers a meaningful analytical question.
Look For Exceptions
Analysts often focus on averages.
Experienced analysts focus on exceptions.
Examples include:
unusual observations
unexpected combinations
isolated clusters
missing categories
abrupt trend changes
inconsistent behavior
Outliers sometimes contain the most valuable information in the dataset.
Compare Multiple Perspectives
No single visualization tells the entire story.
A variable should often be examined several different ways.
For example:
Income may be examined using:
histogram
boxplot
summary statistics
by program type
by outcome category
by geographic location
Each view contributes additional understanding.
Relationships Matter More Than Variables
Individual variables are important.
Relationships between variables are usually more important.
EDA should emphasize:
outcome versus predictors
predictor versus predictor
continuous versus categorical
categorical versus categorical
interactions
possible confounding
The analyst gradually develops an understanding of how variables work together.
Surprising Results Deserve Attention
Unexpected findings should never be ignored.
Instead ask:
Is the result correct?
Is there a data quality issue?
Is there an explanation?
Does another variable account for the pattern?
Should this be investigated further?
Unexpected findings often become the most interesting parts of the final report.
Resist Early Conclusions
One of the greatest analytical mistakes is deciding too early what the data means.
Good analysts delay judgment.
They gather evidence from multiple sources before forming conclusions.
EDA is exploration.
Modeling is evaluation.
Reporting is communication.
These stages should remain distinct.
Think Like a Future Reader
While exploring the data, continually ask:
"If someone unfamiliar with this dataset read my report six months from now, what questions would they ask?"
Those questions should guide additional exploration.
EDA should prepare the analyst to answer future questions before they are asked.
Document Analytical Insights
EDA produces more than figures.
It produces ideas.
Important observations should be recorded as they occur.
These observations often become:
report discussion
modeling decisions
sensitivity analyses
limitations
future recommendations
Good notes during EDA frequently become excellent writing later.
Remember
EDA is not a reporting exercise.
EDA is an investigation.
The analyst's responsibility is not to prove an idea.
The analyst's responsibility is to understand the data as accurately as possible.
Curiosity, skepticism, careful observation, and disciplined reasoning remain the analyst's greatest analytical tools.
End of Section 2B.3


# 2B.4 — From Variable Understanding to Analytical Questions

## Purpose of This Section

By this point in an analysis, you should know considerably more about the dataset than you did when you first opened it.

You have examined:

* what each variable represents,
* how variables are measured and coded,
* their distributions and ranges,
* missingness,
* unusual and potentially erroneous values,
* data-quality concerns,
* relationships among variables,
* cleaning decisions,
* and limitations in what the data can support.

That knowledge is not the end of data understanding.

It is the **raw material for analytical thinking**.

The next task is to transform what you know about the data into questions worth investigating.

This transition is one of the most important steps in exploratory data analysis:

> **Do not begin EDA by asking, “What plots can I make?”**
>
> Begin by asking, **“What do I need to understand?”**

A plot is not the question.

A table is not the question.

A statistical test is not the question.

They are tools used to obtain evidence about a question.

The quality of exploratory analysis therefore depends heavily on the quality of the questions that guide it.

---

## 2B.4.1 — The Fundamental EDA Reasoning Cycle

A useful mental model for exploratory analysis is:

> **What do I know?**
> ↓
> **What does that make me wonder?**
> ↓
> **What evidence would help answer that question?**
> ↓
> **What summary, comparison, or visualization would reveal that evidence?**
> ↓
> **What did I learn?**
> ↓
> **What does the result make me wonder next?**

This is an iterative process.

EDA rarely proceeds in a straight line.

One discovery generates another question.

That question produces another analysis.

That analysis may reveal something unexpected.

The unexpected result may require returning to the data dictionary, cleaning report, variable-intelligence table, or even the raw data.

This is normal.

In fact, it is often a sign of good exploratory work.

### Analyst Principle

> **EDA is a conversation with the data, not a predetermined sequence of graphs.**

---

# 2B.4.2 — Start With What You Already Know

Before generating a new analytical question, ask:

### What have I already learned about this variable?

For the Community Health Clinic project, much of this information already exists in the Chapter 02 and Chapter 03 outputs.

Useful sources include:

* the data dictionary,
* the Chapter 02 screening/readiness report,
* the variable-intelligence table,
* the data-quality issue register,
* the Chapter 03 cleaning report,
* the cleaning decision log,
* the raw-versus-clean validation results,
* and the clean dataset itself.

Do not treat these as finished files that belong only to earlier chapters.

They are **analytical resources**.

Suppose a variable appears potentially important.

Before plotting it against another variable, ask:

1. What exactly does this variable measure?
2. What is its unit?
3. What population does it apply to?
4. Are there missing values?
5. Were any values modified during cleaning?
6. Are there unusual values?
7. Is the variable continuous, ordinal, categorical, binary, count, or date/time?
8. Could its value occur before or after the outcome of interest?
9. Is it likely to represent patient characteristics, clinic operations, access, treatment, utilization, or outcomes?
10. What limitations were identified earlier?

This prevents EDA from becoming disconnected from what you already learned.

---

# 2B.4.3 — Turn Observations Into Questions

A useful analyst habit is to convert observations into questions.

Suppose you discover that a variable has a wide distribution.

Do not stop at:

> “This variable has a wide distribution.”

Ask:

> “Why is the distribution so wide?”

Then:

> “Does the variation differ across patient groups?”

Then perhaps:

> “Could the variation be associated with clinic utilization or patient outcomes?”

The analytical progression might therefore be:

**Observation**

There is substantial variation.

**Question**

What explains that variation?

**Comparison**

Does it vary by another meaningful characteristic?

**Interpretation**

What might that relationship mean operationally or clinically?

**Next question**

Does the relationship remain when another important factor is considered?

This progression is the beginning of analytical reasoning.

---

# 2B.4.4 — A Question Ladder

EDA questions often develop through increasing levels of complexity.

Think of this as a **question ladder**.

## Level 1 — What does this variable look like?

These are univariate questions.

Examples:

* What is the typical value?
* How much variation exists?
* Is the distribution symmetric or skewed?
* Are there extreme observations?
* Are there multiple clusters?
* Is one category much more common than others?
* Is missingness substantial?

Typical tools:

* frequency tables,
* descriptive statistics,
* histograms,
* density plots,
* boxplots,
* bar charts.

These questions establish the basic behavior of the variable.

But they are usually only the beginning.

---

## Level 2 — Does this variable differ across groups?

Now move from description to comparison.

Examples:

* Does waiting time differ across patient groups?
* Does utilization differ across insurance categories?
* Does an outcome differ across demographic groups?
* Does appointment behavior differ across service types?
* Are certain groups disproportionately represented?

Typical tools:

* grouped summaries,
* grouped boxplots,
* violin plots,
* proportional bar charts,
* faceted distributions,
* cross-tabulations.

The important shift is from:

> “What does X look like?”

to:

> **“How does X differ according to Y?”**

---

## Level 3 — Are two variables associated?

Now ask whether variables move together.

Examples:

* Does one continuous variable increase as another increases?
* Are two categorical variables related?
* Does a binary outcome become more common as another variable changes?
* Is the apparent relationship linear?
* Is there evidence of a threshold?
* Are there clusters or unusual combinations?

Typical tools:

* scatterplots,
* smoothed trends,
* correlation summaries,
* cross-tabulations,
* grouped proportions,
* boxplots,
* violin plots.

But remember:

> **Association does not establish causation.**

EDA identifies patterns worthy of investigation.

It does not automatically explain why those patterns exist.

---

## Level 4 — Does the relationship differ across subgroups?

This is where EDA often becomes substantially more informative.

Suppose X and Y appear related.

Ask:

> “Is that relationship similar for everyone?”

Perhaps the relationship differs by:

* age group,
* sex,
* insurance status,
* clinic location,
* service category,
* chronic-condition status,
* utilization level,
* or another meaningful characteristic.

Useful approaches include:

* faceting,
* color or shape grouping,
* subgroup summaries,
* stratified tables,
* interaction-style visualizations.

This is often where a simple overall pattern becomes a much more interesting analytical story.

---

## Level 5 — Could another variable explain the apparent relationship?

This is the beginning of multivariable thinking.

Suppose two variables appear strongly associated.

Before concluding that the relationship is important, ask:

> “Could both variables be related to something else?”

For example:

X may appear related to an outcome.

But perhaps X is also strongly associated with age.

And age is strongly associated with the outcome.

Now the original X–outcome relationship deserves closer investigation.

This does not mean you need to immediately fit a regression model.

You can begin with:

* stratified plots,
* faceting,
* grouped summaries,
* conditional comparisons,
* correlation examination,
* or simple sensitivity analyses.

### Analyst Principle

> **A bivariate relationship is often the beginning of the question, not the end of it.**

---

# 2B.4.5 — Move From Variables to Concepts

A dataset contains variables.

An analyst thinks about **concepts**.

This distinction is extremely important.

For example, a clinic dataset may contain variables related to:

* patient characteristics,
* socioeconomic circumstances,
* healthcare access,
* appointment behavior,
* clinic utilization,
* chronic disease burden,
* treatment,
* operational efficiency,
* continuity of care,
* and patient outcomes.

Instead of asking:

> “What can I do with variable X?”

ask:

> **“What concept does variable X help me understand?”**

Then ask:

> **“What other variables measure related parts of that concept?”**

This begins to create groups of variables that belong together analytically.

For example:

### Access

Possible indicators might reflect:

* insurance,
* appointment availability,
* transportation,
* missed appointments,
* waiting,
* or continuity of care.

### Utilization

Possible indicators might reflect:

* number of visits,
* frequency of appointments,
* service use,
* repeat visits,
* or resource consumption.

### Patient Outcomes

Possible indicators might reflect:

* clinical improvement,
* follow-up,
* treatment completion,
* disease control,
* or another meaningful endpoint.

The exact variables depend on the dataset.

The important lesson is:

> **Do not let column names determine the structure of your thinking.**

Organize variables according to the real-world concepts they represent.

---

# 2B.4.6 — Ask Questions That Matter to Someone

A technically interesting question is not automatically an important question.

For nonprofit analytics, always ask:

> **Who would care about the answer?**

Possible stakeholders might include:

* clinic leadership,
* program managers,
* clinicians,
* scheduling staff,
* funders,
* board members,
* community partners,
* patients,
* or researchers.

Consider two questions:

> “Are variables A and B correlated?”

versus:

> “Are patients experiencing longer waits also more likely to have poorer follow-up?”

The second question has a clearer connection to operations and decision-making.

A useful EDA question often connects:

**data → pattern → organizational concern → possible action**

This does not mean every exploratory analysis must immediately produce a recommendation.

It means the analyst should understand **why the question might matter**.

---

# 2B.4.7 — Separate Interesting Questions From Useful Questions

You will often discover patterns that are statistically or visually interesting.

Ask:

1. Is the relationship large enough to matter?
2. Does it involve enough observations to be meaningful?
3. Could it influence a decision?
4. Could it identify a problem?
5. Could it identify an opportunity?
6. Could it reveal inequity?
7. Could it improve service delivery?
8. Could it affect how resources are allocated?
9. Could it change what we investigate next?
10. Is the result understandable to the intended audience?

A pattern can be real but unimportant.

Conversely, a modest pattern can be important if it affects a vulnerable population or a major operational process.

### Analyst Principle

> **Statistical importance and organizational importance are not the same thing.**

---

# 2B.4.8 — Develop Operational Questions

For a community health clinic, some of the most useful questions may concern operations rather than traditional clinical outcomes.

Examples of broad operational questions include:

* Where does patient flow appear inefficient?
* Which groups experience the longest waits?
* Where are appointments most likely to be missed?
* Are certain services associated with greater resource use?
* Are there patterns suggesting scheduling problems?
* Are high-utilization patients concentrated in particular groups?
* Are there bottlenecks?
* Are certain patient groups experiencing different levels of access?
* Are clinic resources aligned with patient demand?

These are not instructions to analyze specific relationships blindly.

They are examples of **question families**.

The dataset should determine which questions can actually be supported.

---

# 2B.4.9 — Develop Equity and Access Questions Carefully

Community health data often provide opportunities to examine differences among groups.

These analyses can be important, but they require care.

Suppose one patient group has a worse outcome.

Do not immediately interpret that difference as a characteristic of the group itself.

Ask:

* Could access differ?
* Could insurance differ?
* Could disease burden differ?
* Could age distributions differ?
* Could service availability differ?
* Could socioeconomic circumstances differ?
* Could the observed difference result from sample composition?
* Could missingness differ across groups?
* Could measurement differ?

The goal is not simply to identify differences.

The goal is to understand them responsibly.

### Analyst Principle

> **Group differences should trigger investigation, not stereotypes.**

---

# 2B.4.10 — Avoid Premature Causal Language

EDA frequently reveals associations.

It rarely proves causes.

Suppose patients with characteristic X have poorer outcome Y.

Appropriate exploratory language includes:

* “was associated with,”
* “was more common among,”
* “differed across,”
* “showed a relationship with,”
* “was higher among,”
* “was lower among.”

Be cautious with:

* “caused,”
* “resulted in,”
* “led to,”
* “improved,”
* “reduced.”

Those words imply causal conclusions that observational data may not support.

A useful question is:

> **“What would have to be true for me to make a causal claim here?”**

Often the answer reveals why the exploratory result should remain an association.

---

# 2B.4.11 — Ask Temporal Questions

Time order matters.

When examining a possible predictor and outcome, ask:

> **Which happened first?**

A variable measured after an outcome cannot usually serve as a legitimate predictor of that outcome.

This becomes especially important later during modeling.

Ask:

1. When was this variable measured?
2. When did the outcome occur?
3. Could this information have been known at the time a decision would be made?
4. Is this variable partly a consequence of the outcome?
5. Could using it introduce data leakage?

EDA is an excellent place to identify these problems before modeling begins.

### Analyst Principle

> **A strong statistical relationship can still be analytically useless if the timing is wrong.**

---

# 2B.4.12 — Let Unexpected Findings Change the Analysis

Suppose you expect two variables to be related.

The plot shows almost no relationship.

That is information.

Suppose you expect a smooth relationship.

Instead, you find a threshold.

That is information.

Suppose the overall relationship is weak but becomes strong within one subgroup.

That is information.

Suppose a pattern disappears after excluding a few unusual observations.

That is information.

Do not force the analysis to confirm your expectations.

The purpose of EDA is discovery.

### Analyst Principle

> **Surprise is not a failure of EDA. Surprise is often its most valuable product.**

---

# 2B.4.13 — Ask “What Else Could Produce This Pattern?”

Whenever you find an interesting result, deliberately challenge it.

Ask:

> **What else could produce this pattern?**

Possibilities include:

* confounding,
* missing data,
* coding decisions,
* measurement error,
* outliers,
* small subgroup sizes,
* unequal group sizes,
* selection effects,
* duplicated observations,
* temporal effects,
* nonlinear relationships,
* data leakage,
* or random variation.

This habit helps protect against overinterpretation.

An analyst's job is not merely to find patterns.

It is to determine which patterns deserve trust.

---

# 2B.4.14 — Use Multiple Views of Important Questions

No single graph or statistic tells the entire story.

If a relationship appears important, examine it in more than one way.

For example:

**Numerical summary**

How large is the difference?

**Visualization**

What does the distribution actually look like?

**Subgroup analysis**

Does the pattern hold across groups?

**Sensitivity analysis**

Does it depend on unusual observations or analytical choices?

**Context**

Does the relationship make substantive sense?

These views complement one another.

### Analyst Principle

> **Important findings deserve more than one piece of evidence.**

---

# 2B.4.15 — Know When a Question Is Too Broad

Consider:

> “What factors affect patient outcomes?”

This is probably too broad for immediate EDA.

Break it down.

For example:

* Do outcomes differ by patient characteristics?
* Do outcomes differ by utilization?
* Do outcomes differ by access indicators?
* Do outcomes differ by chronic disease burden?
* Do outcomes differ by appointment behavior?

Then break those down further.

A useful EDA question should be specific enough that you can imagine what evidence would help answer it.

If you cannot identify the evidence needed, the question probably needs refinement.

---

# 2B.4.16 — Know When a Question Is Too Narrow

The opposite problem also occurs.

For example:

> “Is the mean of X exactly 4.37?”

That may be easy to answer but analytically meaningless.

A better question might be:

> “What is the typical level of X, how much does it vary, and are there meaningful subgroups?”

Good EDA questions are neither so broad that they cannot be investigated nor so narrow that the answer has little consequence.

---

# 2B.4.17 — Build Question Families

Rather than generating isolated questions, develop **question families**.

Suppose waiting time is important.

A question family might be:

### Distribution

What does waiting time look like overall?

### Groups

Which patient groups experience longer waits?

### Operations

Does waiting time differ across service categories or clinic circumstances?

### Outcomes

Is waiting time associated with another meaningful patient or operational outcome?

### Robustness

Is the pattern driven by extreme waits?

### Equity

Are differences concentrated among particular populations?

### Action

Does the pattern suggest something the organization could investigate or improve?

This structure creates a coherent analysis instead of a collection of unrelated plots.

---

# 2B.4.18 — Distinguish Discovery From Confirmation

EDA is primarily exploratory.

You are looking for:

* patterns,
* anomalies,
* relationships,
* hypotheses,
* possible explanations,
* and promising directions.

If you examine many relationships, some will appear interesting simply by chance.

Therefore, distinguish:

> **“We discovered a possible pattern.”**

from:

> **“We have strong evidence that this relationship is reliable.”**

The first statement may be justified during EDA.

The second may require formal modeling, validation, additional data, or another study.

### Analyst Principle

> **EDA generates hypotheses more easily than it confirms them.**

---

# 2B.4.19 — Do Not Let Modeling Take Over EDA

As you become more statistically sophisticated, there is a temptation to jump quickly to regression.

Resist that temptation.

A regression coefficient cannot replace understanding the underlying data.

Before modeling, you should already have some understanding of:

* distributions,
* unusual observations,
* subgroup differences,
* plausible relationships,
* nonlinearities,
* missingness,
* measurement limitations,
* temporal ordering,
* and potential leakage.

Modeling should build upon EDA.

It should not substitute for it.

---

# 2B.4.20 — Some Important Findings Will Never Enter a Model

This is especially important in nonprofit analytics.

Suppose EDA discovers:

* a small subgroup with exceptionally long waits,
* an unusual pattern of missed appointments,
* a possible service bottleneck,
* an important data-quality problem,
* an access disparity,
* or a pattern that suggests a process needs investigation.

That finding may be extremely valuable even if it never becomes a regression predictor.

The goal is not to produce the best model.

The goal is to produce the **best understanding of the problem that the available data can support**.

---

# 2B.4.21 — Keep an EDA Question Log

As you work, maintain a simple list of questions.

For each question, consider recording:

### Question

What am I trying to understand?

### Why it matters

Why might someone care about the answer?

### Variables involved

Which variables could provide evidence?

### Evidence needed

What would help answer the question?

### Method

What table, statistic, or visualization might be useful?

### Finding

What did the analysis show?

### Confidence

How strongly do I trust the result?

### Limitations

What could make the result misleading?

### Next question

What should I investigate next?

This can become one of the most valuable records of the analytical process.

It captures **how your thinking developed**, not merely what code you executed.

---

# 2B.4.22 — A Practical Question-Development Template

When examining the Community Health Clinic data, use this sequence:

## Step 1 — What do I know?

Consult Chapter 02 and Chapter 03.

What have I already learned about the variable or concept?

## Step 2 — What does that make me wonder?

Write the question in plain English.

Do not worry about R yet.

## Step 3 — Why does the question matter?

Who might care about the answer?

What decision, concern, or understanding could it influence?

## Step 4 — What evidence would help?

Identify the variables and comparisons needed.

## Step 5 — What is the simplest useful analysis?

Start simple.

Perhaps:

* a summary,
* table,
* histogram,
* boxplot,
* scatterplot,
* proportional comparison,
* or grouped summary.

## Step 6 — What did I find?

Describe the result in words before worrying about formal reporting.

## Step 7 — What else could explain it?

Challenge the result.

## Step 8 — What should I investigate next?

Allow the evidence to generate the next question.

---

# 2B.4.23 — The Analyst's Question Test

Before spending substantial time on an EDA question, ask:

1. **Is the question clear?**
2. **Can the available data actually address it?**
3. **Do I understand the variables involved?**
4. **Is the temporal ordering sensible?**
5. **Could data leakage be involved?**
6. **Why might the answer matter?**
7. **What evidence would support or contradict the idea?**
8. **What alternative explanations should I consider?**
9. **Would a stakeholder understand why this question matters?**
10. **Will answering it improve my understanding of the data or problem?**

Not every question must pass every test perfectly.

But these questions force analytical discipline.

---

# 2B.4.24 — Community Health Clinic Practice Exercise

Before the automated Chapter 04 EDA is eventually run, spend some time manually developing questions from the Community Health Clinic materials.

Do **not** begin by opening ggplot2.

Instead, open:

* the Chapter 02 variable-intelligence table,
* the Chapter 02 screening/readiness report,
* relevant Chapter 02 output tables,
* the Chapter 03 cleaning report,
* the Chapter 03 decision log,
* and, when useful, the clean dataset.

Then select several variables or concepts that seem important.

For each one, write:

### What I know

What did Chapters 02 and 03 teach me?

### What I wonder

What question naturally follows?

### Why I care

Why might the answer matter?

### What I would examine

What variables or groups would I compare?

### What I expect

What pattern do I think I might see?

### What would surprise me

What result would challenge my expectation?

### What I would ask next

If I found the expected result—or did not find it—what would I investigate next?

Do not worry about whether every question ultimately becomes part of the final analysis.

The purpose of the exercise is to practice **thinking like an analyst**.

---

# 2B.4.25 — A Deeper Learning Exercise

Take one promising Community Health Clinic question and follow it through several levels of the question ladder.

For example:

### Level 1

Understand the primary variable.

### Level 2

Compare it across a meaningful group.

### Level 3

Examine its relationship with another important variable.

### Level 4

Determine whether that relationship differs across subgroups.

### Level 5

Ask whether another variable could explain the apparent relationship.

Then stop.

Do not immediately fit a complicated model.

Instead, write a short paragraph explaining:

> **What did I learn, what remains uncertain, and what should I investigate next?**

That paragraph is more important for your development as an analyst than producing another ten plots.

---

# 2B.4.26 — The Central Lesson

The transition from data understanding to EDA is not primarily a transition from tables to graphs.

It is a transition from:

> **knowing what the variables are**

to:

> **wondering what relationships, patterns, differences, and problems they may reveal.**

The strongest analysts are not distinguished merely by knowing more statistical techniques or more R functions.

They become valuable because they learn to ask better questions.

A useful analytical sequence is therefore:

> **Understand the data.**
>
> **Ask a meaningful question.**
>
> **Gather appropriate evidence.**
>
> **Examine the evidence critically.**
>
> **Consider alternative explanations.**
>
> **Ask the next better question.**

Repeat.

That cycle is the heart of exploratory data analysis.

---

## 2B.4 — Closing Perspective

When you first encounter a dataset, it is natural to see rows and columns.

With experience, you begin to see variables.

With more experience, you begin to see relationships among variables.

But the deeper goal is to eventually see:

* people,
* processes,
* systems,
* decisions,
* constraints,
* outcomes,
* inequities,
* opportunities,
* and unanswered questions

represented imperfectly by those variables.

That is the transition from **working with data** to **thinking analytically about the world the data represent**.

And that is the skill Chapter 04 is intended to develop.



