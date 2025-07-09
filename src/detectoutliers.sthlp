{smcl}
{* *! version 0.5 15aug2023}{...}
{hline}
help for {bf:detectoutliers 9}
{hline}

{title:Title}

{p 4 4 2}
{bf:detectoutliers} - Detect statistical outliers using standard deviation thresholds

{title:Syntax}

{p 8 17 2}
{cmd:detectoutliers} {varlist} {cmd:,} 
{cmd:sd(}{it:#}{cmd:)} 
{cmd:addvars(}{varlist}{cmd:)} 
[{cmd:except(}{it:numlist}{cmd:)} 
{cmd:export(}{it:filename}{cmd:)} 
{cmd:replace}]

{title:Description}

{p 4 4 2}
{cmd:detectoutliers} identifies outliers in numeric variables using z-score thresholds. 
It can optionally export results to Excel with variable labels and ID information.

{p 4 4 2}
The program:
{p 6 6 2}
1. Calculates mean and standard deviation for each variable{p_end}
{p 6 6 2}
2. Flags values beyond {it:sd} standard deviations from the mean{p_end}
{p 6 6 2}
3. Preserves specified ID variables in output{p_end}
{p 6 6 2}
4. Excludes user-specified values (like -99, 999) from analysis{p_end}

{title:Options}

{phang}
{cmd:sd(}{it:#}{cmd:)} specifies the number of standard deviations from the mean to use as the outlier threshold. 
Typical values are 2.5-3. Required.

{phang}
{cmd:addvars(}{varlist}{cmd:)} specifies ID/enumerator variables to include in output. 
These typically include household IDs, enumerator codes, and survey dates. Required.

{phang}
{cmd:except(}{it:numlist}{cmd:)} specifies values to exclude from outlier detection 
(like missing value codes -99, 999, etc.). Optional.

{phang}
{cmd:export(}{it:filename}{cmd:)} saves results to an Excel file. The output includes:
{p 6 6 2}
- Original ID/addvars{p_end}
{p 6 6 2}
- Variable name and label{p_end}
{p 6 6 2}
- Outlier value{p_end}
Optional.

{phang}
{cmd:replace} overwrites existing Excel file. Only valid with {cmd:export()}.

{title:Examples}

{p 4 4 2}Basic screen output:{p_end}
{p 8 16 2}{cmd:. detectoutliers income expenditure, sd(3) addvars(hhid enum)}{p_end}

{p 4 4 2}With Excel export and exception values:{p_end}
{p 8 16 2}{cmd:. detectoutliers s3_*, sd(2.5) addvars(region supervisor) except(-99 999) export("outliers.xlsx") replace}{p_end}

{title:Saved Results}

{p 4 4 2}
The program displays results in the Results window and optionally exports to Excel. 
No matrices or scalars are returned.

{title:Author}

{p 4 4 2}
Adapted from original code by {it:Your Name}, {it:Your Organization}

{title:Also see}

{p 4 4 2}
Manual: {help summarize}, {help tabstat}, {help export excel}{p_end}
{p 4 4 2}
Related: {search outliers}{p_end}
