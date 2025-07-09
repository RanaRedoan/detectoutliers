{smcl}
{* 03jul2024}{...}
{hline}
help for {hi:biascheck}
{hline}

{title:Title}

{p 4 4 2}
{bf:biascheck} - Generate enumerator bias reports for categorical variables

{title:Syntax}

{p 8 15 2}
{cmd:biascheck} {varname} {ifin} , {cmd:enum(}{varname}{cmd:)} 
[{cmd:excel(}{it:string}{cmd:)} 
{cmd:sheet(}{it:string}{cmd:)} 
{cmd:consent(}{varname}{cmd:)}]

{title:Description}

{p 4 4 2}
{cmd:biascheck} generates Excel reports showing the distribution of responses by enumerator,
helping to identify potential interviewer bias. The command creates dummy variables for
each category of your specified variable and calculates response proportions by enumerator.

{title:Options}

{phang}
{cmd:enum(}{varname}{cmd:)} specifies the enumerator identifier variable (required).

{phang}
{cmd:excel(}{it:string}{cmd:)} specifies the output Excel filename. Default is 
"BiasCheck_YYYY-MM-DD.xlsx".

{phang}
{cmd:sheet(}{it:string}{cmd:)} specifies the worksheet name. Default is the variable name.

{phang}
{cmd:consent(}{varname}{cmd:)} specifies a consent filter variable (typically coded 0/1).

{title:Examples}

{p 4 4 2}
Basic usage:{p_end}
{phang2}{cmd:. biascheck education_level, enum(interviewer_id)}{p_end}

{p 4 4 2}
With all options:{p_end}
{phang2}{cmd:. biascheck Q12 if region==1, enum(enum_id) excel("MyReport.xlsx") sheet("Q12") consent(consent)}{p_end}

{title:Author}

{p 4 4 2}
Md. Redoan Hossain Bhuiyan, Data School 101{p_end}
{p 4 4 2}
Email: redoanhossain630@gmail.com{p_end}
{p 4 4 2}
Whatsapp: +8801675735811{p_end}

{title:Also see}

{p 4 4 2}
Online: {help tabulate}, {help putexcel}