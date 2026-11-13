This is Section 2B.3 of the AI Analyst Handbook. As with 2B.1 and 2B.2, this belongs only in AI_Analyst_handbook.md—it is not appended to the Prompt 04 master prompt.
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
My thoughts
I particularly like this section because it shifts the emphasis from "what charts should I make?" to "how should I think while looking at those charts?" In my experience, that's one of the biggest differences between someone who knows statistical techniques and someone who consistently produces insightful analyses.
After you've had a chance to read and reflect on 2B.3—as you did with the earlier sections—we'll be in a strong position to continue building the EDA system. I'm interested to hear which ideas in this section resonate most with your own research experience.