#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar
library("here") #project location
library("tidyverse") #data wrangling 




# Leer los datos (disponibles en https://www.kaggle.com/austinreese/craigslist-carstrucks-data?select=vehicles.csv)
dta_baseR<-read.csv(here("vehicles.csv"))
#dta_tidyverse<-read_csv(here("vehicles.csv"))
#sample<-dta_tidyverse[1:100000,]
#write_csv(sample,here("sample_vehicles.csv"))
dta<-read_csv("") #cargar desde dropbox 



# Que es "tidy" data?
  

#Today, however, Im only really going to focus on two packages:  dplyr, tidyr

# Pipes: %>% y facilida de lectura


## These next two lines of code do exactly the same thing.
sample %>% filter(manufacturer=="audi") %>% group_by(region) %>% summarise(odometer_mean = mean(odometer))
summarise(group_by(filter(sample, manufacturer=="audi"), region), odometer_mean = mean(odometer))



sample %>% 
  filter(manufacturer=="audi") %>% 
  group_by(region) %>% 
  summarise(odometer_mean = mean(odometer))


#Remember: Using vertical space costs nothing and makes for much more readable/writeable code than cramming things horizontally.


# Key dplyr verbs

# There are five key dplyr verbs that you need to learn.

# 1. `filter`: Filter (i.e. subset) rows based on their values.
# 
# 2. `arrange`: Arrange (i.e. reorder) rows based on their values.
# 
# 3. `select`: Select (i.e. subset) columns by their names: 
# 
# 4. `mutate`: Create new columns.
# 
# 5. `summarise`: Collapse multiple rows into a single summary value.<sup>1</sup>

--
  
  
#Let's practice these commands together using the `starwars` data frame that comes pre-packaged with dplyr. 



# 1) dplyr::filter

We can chain multiple filter commands with the pipe (`%>%`), or just separate them within a single filter command using commas.
```{r filter1}
starwars %>% 
  filter( 
    species == "Human", 
    height >= 190
    ) 
```



Regular expressions work well too.
```{r filter2}
starwars %>% 
  filter(grepl("Skywalker", name))
```


A very common `filter` use case is identifying (or removing) missing data cases. 
```{r filter3}
starwars %>% 
  filter(is.na(height))
```



To remove missing observations, simply use negation: `filter(!is.na(height))`. Try this yourself.



# 2) dplyr::arrange

```{r arrange1}
starwars %>% 
  arrange(birth_year)
```



*Note.* Arranging on a character-based column (i.e. strings) will sort alphabetically. Try this yourself by arranging according to the "name" column.



We can also arrange items in descending order using `arrange(desc())`.
```{r arrange2}
starwars %>% 
  arrange(desc(birth_year))
```


# 3) dplyr::select

Use commas to select multiple columns out of a data frame. (You can also use "first:last" for consecutive columns). Deselect a column with "-".
```{r select1}
starwars %>% 
  select(name:skin_color, species, -height)
```


You can also rename some (or all) of your selected variables in place.
```{r select2}
starwars %>%
  select(alias=name, crib=homeworld, sex=gender) 
```

If you just want to rename columns without subsetting them, you can use `rename`. Try this now by replacing `select(...)` in the above code chunk with `rename(...)`.



The `select(contains(PATTERN))` option provides a nice shortcut in relevant cases.
```{r select3}
starwars %>% 
  select(name, contains("color"))
```


The `select(..., everything())` option is another useful shortcut if you only want to bring some variable(s) to the "front" of a data frame.

```{r select4}
starwars %>% 
  select(species, homeworld, everything()) %>%
  head(5)
```



*Note:* The new `relocate` function coming in dplyr 1.0.0 is bringing a lot more functionality to ordering of columns. See [here](https://www.tidyverse.org/blog/2020/03/dplyr-1-0-0-select-rename-relocate/).


You can create new columns from scratch, or (more commonly) as transformations of existing columns.
```{r mutate1}
starwars %>% 
  select(name, birth_year) %>%
  mutate(dog_years = birth_year * 7) %>%
  mutate(comment = paste0(name, " is ", dog_years, " in dog years."))
```


*Note:* `mutate` is order aware. So you can chain multiple mutates in a single call.
```{r mutate2}
starwars %>% 
  select(name, birth_year) %>%
  mutate(
    dog_years = birth_year * 7, ## Separate with a comma
    comment = paste0(name, " is ", dog_years, " in dog years.")
    )
```



Boolean, logical and conditional operators all work well with `mutate` too.
```{r mutate3}
starwars %>% 
  select(name, height) %>%
  filter(name %in% c("Luke Skywalker", "Anakin Skywalker")) %>% 
  mutate(tall1 = height > 180) %>%
  mutate(tall2 = ifelse(height > 180, "Tall", "Short")) ## Same effect, but can choose labels

```



Lastly, combining `mutate` with the new `across` feature in dplyr 1.0.0 (or the development version that you should have installed) allows you to easily work on a subset of variables. For example:

```{r, mutate4}
starwars %>% 
  select(name:eye_color) %>% 
  mutate(across(is.character, toupper)) %>% #<< 
  head(5)
```

*Note:* This workflow (i.e. combining `mutate` and `across`) supersedes the old "scoped" variants of `mutate` that you might have used before. More details [here](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-colwise/) and [here](https://dplyr.tidyverse.org/dev/articles/colwise.html).

---

# 5) dplyr::summarise

Particularly useful in combination with the `group_by` command.
```{r summ1}
starwars %>% 
  group_by(species, gender) %>% 
  summarise(mean_height = mean(height, na.rm = T))
```



Note that including "na.rm = T" is usually a good idea with summarise functions. Otherwise, any missing value will propogate to the summarised value too.
```{r summ2}
## Probably not what we want
starwars %>% 
  summarise(mean_height = mean(height))
## Much better
starwars %>% 
  summarise(mean_height = mean(height, na.rm = T))
```


The same `across`-based workflow that we saw with `mutate` a few slides back also works with `summarise`. For example:

```{r, summ4}
starwars %>% 
  group_by(species) %>% 
  summarise(across(is.numeric, mean, na.rm=T)) %>% #<<
  head(5)
```



*Note:* Again, this functionality supersedes the old "scoped" variants of `summarise` and is only available with the development version of dplyr. Details [here](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-colwise/) and [here](https://dplyr.tidyverse.org/dev/articles/colwise.html).

---

# Other dplyr goodies

`group_by` and `ungroup`: For (un)grouping.
- Particularly useful with the `summarise` and `mutate` commands, as we've already seen.

--
  
  `slice`: Subset rows by position rather than filtering by values.
- E.g. `starwars %>% slice(c(1, 5))`

--
  
  `pull`: Extract a column from as a data frame as a vector or scalar.
- E.g. `starwars %>% filter(gender=="female") %>% pull(height)`

--
  
  `count` and `distinct`: Number and isolate unique observations.
- E.g. `starwars %>% count(species)`, or `starwars %>% distinct(species)`
- You could also use a combination of `mutate`, `group_by`, and `n()`, e.g. `starwars %>% group_by(species) %>% mutate(num = n())`.



There are also a whole class of [window functions](https://cran.r-project.org/web/packages/dplyr/vignettes/window-functions.html) for getting leads and lags, ranking, creating cumulative aggregates, etc.
- See `vignette("window-functions")`.

The final set of dplyr "goodies" are the family of join operations. However, these are important enough that I want to go over some concepts in a bit more depth...
- We will encounter and practice these many more times as the course progresses.



# Joining operations

One of the mainstays of the dplyr package is merging data with the family [join operations](https://cran.r-project.org/web/packages/dplyr/vignettes/two-table.html).
- `inner_join(df1, df2)`
- `left_join(df1, df2)`
- `right_join(df1, df2)`
- `full_join(df1, df2)`
- `semi_join(df1, df2)`
- `anti_join(df1, df2)`

(You find find it helpful to to see visual depictions of the different join operations [here](https://r4ds.had.co.nz/relational-data.html).)



For the simple examples that I'm going to show here, we'll need some data sets that come bundled with the [**nycflights13**](http://github.com/hadley/nycflights13) package. 
- Load it now and then inspect these data frames in your own console.

```{r flights, echo = F}
library(nycflights13)
```
```{r, eval = F}
library(nycflights13)
flights 
planes
```

Let's perform a [left join](https://stat545.com/bit001_dplyr-cheatsheet.html#left_joinsuperheroes-publishers) on the flights and planes datasets. 
- *Note*: I'm going subset columns after the join, but only to keep text on the slide.



```{r join1}
left_join(flights, planes) %>%
  select(year, month, day, dep_time, arr_time, carrier, flight, tailnum, type, model)
```


Note that dplyr made a reasonable guess about which columns to join on (i.e. columns that share the same name). It also told us its choices: 
  
  ```
*## Joining, by = c("year", "tailnum")
  ```

However, there's an obvious problem here: the variable "year" does not have a consistent meaning across our joining datasets!
- In one it refers to the *year of flight*, in the other it refers to *year of construction*.

--

Luckily, there's an easy way to avoid this problem. 
- See if you can figure it out before turning to the next slide.
- Try `?dplyr::join`.


You just need to be more explicit in your join call by using the `by = ` argument.
- You can also rename any ambiguous columns to avoid confusion. 
```{r join2}
left_join(
  flights,
  planes %>% rename(year_built = year), ## Not necessary w/ below line, but helpful
  by = "tailnum" ## Be specific about the joining column
) %>%
  select(year, month, day, dep_time, arr_time, carrier, flight, tailnum, year_built, type, model) %>%
  head(3) ## Just to save vertical space on the slide
```



Last thing I'll mention for now; note what happens if we again specify the join column... but don't rename the ambiguous "year" column in at least one of the given data frames.
```{r join3}
left_join(
  flights,
  planes, ## Not renaming "year" to "year_built" this time
  by = "tailnum"
) %>%
  select(contains("year"), month, day, dep_time, arr_time, carrier, flight, tailnum, type, model) %>%
  head(3)
```

--
  
  Make sure you know what "year.x" and "year.y" are. Again, it pays to be specific.

---
  class: inverse, center, middle
name: tidyr

# tidyr

<html><div style='float:left'></div><hr color='#EB811B' size=1px width=796px></html>
  
  ---
  
  # Key tidyr verbs
  
  1. `pivot_longer`: Pivot wide data into long format (i.e. "melt").<sup>1</sup> 
  
  2. `pivot_wider`: Pivot long data into wide format (i.e. "cast").<sup>2</sup> 
  
  3. `separate`: Separate (i.e. split) one column into multiple columns.

4. `unite`: Unite (i.e. combine) multiple columns into one.

.footnote[
  <sup>1</sup> Updated version of `tidyr::gather`.
  
  <sup>2</sup> Updated version of `tidyr::spread`.
]  

--
  
  </br>
  
  Let's practice these verbs together in class.
- Side question: Which of `pivot_longer` vs `pivot_wider` produces "tidy" data?
  
---

####  1) tidyr::pivot_longer

```{r pivot_longer1}
stocks <- data.frame( ## Could use "tibble" instead of "data.frame" if you prefer
  time = as.Date('2009-01-01') + 0:1,
  X = rnorm(2, 0, 1),
  Y = rnorm(2, 0, 2),
  Z = rnorm(2, 0, 4)
  )
stocks
stocks %>% pivot_longer(-time, names_to="stock", values_to="price")
```



Let's quickly save the "tidy" (i.e. long) stocks data frame for use on the next slide. 

```{r pivot_longer2}
## Write out the argument names this time: i.e. "names_to=" and "values_to="
tidy_stocks <- 
  stocks %>% 
  pivot_longer(-time, names_to="stock", values_to="price")
```



#### 2) tidyr::pivot_wider

```{r pivot_wider1, dependson=tidy_stocks}
tidy_stocks %>% pivot_wider(names_from=stock, values_from=price)
tidy_stocks %>% pivot_wider(names_from=time, values_from=price)
```

Note that the second example &mdash; which has combined different pivoting arguments &mdash; has effectively transposed the data.


---
  
  # Aside: Remembering the pivot_* syntax 
  
  There's a long-running joke about no-one being able to remember Stata's "reshape" command. ([Exhibit A](https://twitter.com/scottimberman/status/1036801308785864704).)

It's easy to see this happening with the `pivot_*` functions too. However, I find that I never forget the commands as long as I remember the argument order is *"names"* then *"values"*.

---

# 3) tidyr::separate

```{r sep1}
economists <- data.frame(name = c("Adam.Smith", "Paul.Samuelson", "Milton.Friedman"))
economists
economists %>% separate(name, c("first_name", "last_name")) 
```

--

</br>

This command is pretty smart. But to avoid ambiguity, you can also specify the separation character with `separate(..., sep=".")`.


A related function is `separate_rows`, for splitting up cells that contain multiple fields or observations (a frustratingly common occurence with survey data).
```{r sep2}
jobs <- data.frame(
  name = c("Jack", "Jill"),
  occupation = c("Homemaker", "Philosopher, Philanthropist, Troublemaker") 
  ) 
jobs
## Now split out Jill's various occupations into different rows
jobs %>% separate_rows(occupation)
```
---
  
  # 4) tidyr::unite
  
  ```{r unite1}
gdp <- data.frame(
  yr = rep(2016, times = 4),
  mnth = rep(1, times = 4),
  dy = 1:4,
  gdp = rnorm(4, mean = 100, sd = 2)
)
gdp 
## Combine "yr", "mnth", and "dy" into one "date" column
gdp %>% unite(date, c("yr", "mnth", "dy"), sep = "-")
```

---
  
  # 4) tidyr::unite *cont.*
  
  Note that `unite` will automatically create a character variable. You can see this better if we convert it to a tibble. 
```{r unite2}
gdp_u <- gdp %>% unite(date, c("yr", "mnth", "dy"), sep = "-") %>% as_tibble()
gdp_u
```

--
  
  If you want to convert it to something else (e.g. date or numeric) then you will need to modify it using `mutate`. See the next slide for an example, using the [lubridate](https://lubridate.tidyverse.org/) package's super helpful date conversion functions.

---

# 4) tidyr::unite *cont.*

*(continued from previous slide)*

```{r unite3, message=F}
library(lubridate)
gdp_u %>% mutate(date = ymd(date))
```

---

# Other tidyr goodies

Use `crossing` to get the full combination of a group of variables.<sup>1</sup>

```{r cross1}
crossing(side=c("left", "right"), height=c("top", "bottom"))
```

.footnote[
<sup>1</sup> Base R alternative: `expand.grid`.
]  

--

See `?expand` and `?complete` for more specialised functions that allow you to fill in (implicit) missing data or variable combinations in existing data frames.
- You'll encounter this during your next assignment.

---
  class: inverse, center, middle
name: summary

# Summary
<html><div style='float:left'></div><hr color='#EB811B' size=1px width=796px></html>
  
  ---
  
  # Key verbs
  
  ### dplyr
  1. `filter`
2. `arrange`
3. `select`
4. `mutate`
5. `summarise`

### tidyr
1. `pivot_longer`
2. `pivot_wider`
3. `separate`
4. `unite`

--
  
  Other useful items include: pipes (`%>%`), grouping (`group_by`), joining functions (`left_join`, `inner_join`, etc.).

____

# Working in R

One way to learn R is to dive right in and work through a simple example.

## Example - The U.S. Economy in the 1990s

Let's start with an analysis of the performance of the U.S. economy during the 1990s. We have annual data on GDP growth, GDP per capita growth, private consumption growth, investment growth, manufacturing labor productivity growth, unemployment rate, and inflation rate. (The data is publicly available in the statistical appendixes of the World Economic Outlook, May 2001, IMF).

The first step is to tell R where is your working directory. This means telling R where are all the files related to your project. You should do this always at the beginning of your R session. You do so by using the `setwd(path)` function. Where path is the path to the folder where you want to write and read things. For example

```{r eval=FALSE}
    # setwd("C:/ECON4676/eTA/")
```
you should note that first that I'm using the forward slash. You could also use backslash but in that case you should use double backslash (\\). Note that if you are using MAC you should omit "C:"
This command line is telling R to write and read everything in the ECON4676/eTA folder (that I assume you created before hand)

The next step is to download the data. Let's explore two ways of doing so. The first one is the "traditional" way. Go to the web page containing the data, and save it. The data is available [here](https://github.com/ECON-4676-UNIANDES/e-TA/blob/master/e-ta2_R/Data/US90.txt).
The other way to do it, is to use an R function:
  
```{r eval=FALSE}
    download.file("https://github.com/ECON-4676-UNIANDES-Fall-2021/e-TA/blob/master/e-ta2_R/Data/", "US90.txt")
```

The first argument of the `download.file` function is the url where the file is located, whereas the second argument is the name where the downloaded file is saved. To know more about this function you can type in your console `?download.file`, that will take you to the function's help file.

Now, we need to load the *.txt* file to R. To do so we use the `read.table` function.

```{r comment=NA}
US90<-read.table("data/US90.txt", sep="", header=TRUE)
```
What this function does is read the US90.txt file, names the data set as "US90" and tells R that the variables are separated by a blank space (`sep=""`) and that the first column is the header. Obviously remembering all the arguments that a specific function can take is ludicrous, by doing `?read.table` or `help(read.table)`  you can see all the options that the function can take.

Now you have an object called data frame that contains your data, to check what class is an object you can type class(<name of the object>), i.e. 
```{r comment=NA}   
class(US90) 
```

Data frames are just matrices that contains different types of data, not only numbers as we are used to. Since it is a matrix you can check it's dimension by typing 

```{r comment=NA}
    dim(US90)
``` 

Now you are ready to work with your data!!

### Basic Operations

A first thing you can do is extract each variable from the data frame to single vectors. To make the individual analysis simpler. To do so you extract them from the data frame and give them respective names.
 
```{r comment=NA}  
    year<-US90$year
    gdpgr<-US90$gdpgr
    consgr<-US90$consgr
    invgr<-US90$invgr
    unemp<-US90$unemp
    gdpcapgr<-US90$gdpcapgr
    inf<-US90$inf   
    producgr<-US90$producgr
```

Now we have created 8 objects, vectors each containing a variable.
As an alternative you could `attach()` your data frame to the R search path. This will make objects within data frames easier to access. However, the attach function does not play nice with variables in the local work space with the same names. So it is advisable to avoid using it.

A useful way to explore your data is checking the main statistics of each variable. 

```{r comment=NA}  
    summary(US90)
```   

Which gives you the minimum, 1st quartile, median, 3rd quartile, and maximum of each variable. If you also wish to know the standard deviation of a single variable, just include its name after the command

```{r comment=NA}
    summary(gdpgr)
    sd(gdpgr)
```

If you are in interested only in subset of your data, you can inspect it using filters. For example, begin by checking the dimension of the data matrix:

```{r comment=NA}
    dim(US90)
```

This means that your data matrix contains 11 rows (corresponding to the years 1992 to 2002) and 8 columns (corresponding to the variables). If you are only interested in a subset of the time periods (e.g., the years of the Clinton administration), you can select it as a new object:

```{r comment=NA}
    Clinton<-US90[2:9, ]
```

and then compute its main statistics:

```{r comment=NA}
    summary(Clinton)
```

If you are only interested in a subset of the variables (e.g., consumption and investment growth rates), you can select them by typing:

```{r comment=NA}
    VarSet1<-US90[ ,3:4]
```

and then compute its main statistics:

```{r comment=NA}
    summary(VarSet1)
```

or in a much simpler way:

```{r comment=NA}
    summary(US90[,3:4])
```

To create new variables, you can use traditional operators (+,-,*,/,^) and name new variables as follows:

* add or subtract:   `lagyear<-year-1`
* multiply:       `newgdpgr<-gdpgr*100`
* divide:         `newunemp<-unemp/100`
* exponential:    `gdpcap2<-gdpcapgr^2`
* square root:      `sqrtcons<-sqrt(consgr)`
* natural logs:     `loginv<-log(invgr)`
* base 10 logs:     `log10inf<-log10(inf)`
* exponential:    `expprod<-exp(producgr)`

 

###Exploring Graphical Resources

Suppose now you want to check the relationship among variables. For example, suppose you would like to see how much GDP growth is related with GDP per capita growth. This corresponds to a single graph that could be obtained as follows:

```{r comment=NA}
    plot(gdpgr, gdpcapgr, pch="*")
```

Another useful tool is the check on multiple graphs in a single window. For example, suppose you would like to expand your selection, and  check the pair wise relationship of GDP, Consumption, and Investment Growth. You can obtain that as follows:

```{r comment=NA}
    pairs(US90 [, 2:4], pch="*")
```


Suppose you would like to see the performance of multiple variables (e.g., GDP, GDP per capita, Consumption, and Investment growth rates) along time. The simplest way is as follows:

```{r comment=NA}
    par(mfrow=c(2,2))
    plot(year, gdpgr,    pch="*")
    plot(year, consgr,   pch="*")
    plot(year, gdpcapgr, pch="*")
    plot(year, invgr,    pch="*")
```

Here the function `par(mfrow=c(2,2))` creates a matrix with 2 rows and 2 columns in which the individual graphs will be stored, while `plot` is in charge of producing individual graphs for each selected variable. 

You can easily expand the list of variables to obtain a graphical assessment of the performance of each of them along time. You can also use the graphs to assess cross-correlations (in a pair wise sense) among variables.
 
 

###Linear Regression

Before running a regression, it is recommended you check the cross-correlations among covariates. You can do that graphically (see above) or using the following simple command:

```{r comment=NA}
    cor(US90)
```

From the matrix above you can see, for example, that GDP and GDP per capita growth rates are closely related, but each of them has a different degree of connection with unemployment rates (in fact, GDP per capita presents higher correlation with unemployment rates than total GDP). Inflation and unemployment present a reasonable degree of positive correlation (about 36%).

Now you start with simple linear regressions. For example, let's check the regression of GDP versus investment growth rates. You just type:
  
  ```{r comment=NA}
model1<-lm(gdpgr~invgr)
summary(model1)
```

Please note that you don't need to include the intercept, because R automatically includes it. In the output above you have the main regression diagnostics (F-test, adjusted R-squared, t-statistics, sample size, etc.). The same rule apply to multiple linear regressions. For example, suppose you want to find the main sources of GDP growth. The command is:

```{r comment=NA}
    model2<-lm(gdpgr~consgr+invgr+producgr+unemp+inf)
    summary(model2)
```

In the example above, despite we have a high adjusted R-squared, most of the covariates are not significant at 5% level (actually, only investment is significant in this context). There may be many problems in the regression above. During the ECON4676 classes, you will learn how to solve those problems, and how to select the best specification for your model.

You can also run log-linear regressions. To do so, you type:
```{r comment=NA}
    model3<-lm(log(gdpgr)~log(consgr)+log(invgr)+log(producgr)+log(unemp)+log(inf))
    summary(model3)
```

Finally, you can plot the vector of residuals as follows:
```{r comment=NA}
    resid3<-resid(model3)
    plot(year,resid3)
```


You can also obtain the fitted values and different plots as follows:
```{r comment=NA}
    fit3<-fitted(model3)  #   This will generate a vector of fitted values for the model 3.
    par(mfrow=c(2,2))
    plot(model3)      #     This will generate default plots of residuals vs. fitted values, Normal  Q-Q, scale-location, and Cook's distance.
```

Note here that we have added inline comments using the # symbol 

### Linear Hypothesis Testing

Suppose you want to check whether the variables investment, consumption, and productivity growth matter to GDP growth. In this context, you want to test if those variables matter simultaneously. The best way to check that in R is as follows. First, run a unrestricted model with all variables:
  
  ```{r comment=NA}
u<-lm(log(gdpgr)~log(invgr)+log(consgr)+log(producgr)+log(unemp)+log(inf))
``` 

Then run a restricted model, discarding the variables under test:
  ```{r comment=NA}
r<-lm(log(gdpgr)~log(unemp)+log(inf))
```

Now you will run a F-test comparing the unrestricted to the restricted model. To do that, you will need to write the F-test function in R, as follows:  (The theory comes from Johston and DiNardo (1997), p. 95, while the R code is a version of Greg Kordas' S code adjusted for this specific problem.)
 
```{r comment=NA}
    F.test<-function(u,r){
        #u is the unrestricted model
        k<-length(coef(u))
        n<-length(resid(u))
        eeu<-sum(resid(u)^2)
        #r is the restricted model
        kr<-length(coef(r))
        eer<-sum(resid(r)^2)
        #q is the number of restrictions
        q<-k-kr
        #F-statistic
        Fstat<-((eer-eeu)/q)/(eeu/(n-k))
        #P-value
        Fprob<-1-pf(Fstat, q, n-k)
        list(Fstat=Fstat, Fprob=Fprob)
}
``` 

After that, you can run the test and obtain the F-statistic and p-value:

```{r comment=NA}
    F.test(u,r)$Fstat
    F.test(u,r)$Fprob
```


And the conclusion is that you can reject the null hypothesis of joint non-significance at 1.13% level.
 

### Creating your own functions in R
As we mentioned previously one of the strengths of R is that you can create your own functions. Actually many of the functions in R are just functions of functions.  
The basic structure of a function is

One of the great strengths of R is the user's ability to add functions. In fact, many of the functions in R are actually functions of functions. The structure of a function is given below.


```{r eval=FALSE}
myfunction <- function(arg1, arg2, ...){
  statements
  return(object)
}
```

You already created a function for the F-test in the above example, let's try to create another one. For example obtaining the coefficients of a linear regression:

```{r }
    lr <- function(y,X){
        X<-data.matrix(X)
        y<-data.matrix(y)
        Intercept<-rep(1,dim(X)[1])
        X<-cbind(Intercept,X)
        b<-solve(t(X)%*%X)%*%t(X)%*%y
        b
    }
```
The `lr()` function returns the coefficients of a OLS regression by calculating:

$$\hat{\beta}=(X'X)^{-1}X'y$$

you can check that the function actually returns the same values as the `lm()` function.

```{r comment=NA}
    lr(US90[,2],US90[,c(3,4,5)])

    summary(lm(gdpgr~consgr+invgr+unemp))$coef
```


Another nice thing about R is that you can create your own function and create a loop. For example, 


```{r echo=FALSE}
    rm(list=ls())
```

```{r comment=NA}   
    download<-function(x,folder){
        URL<- paste("https://github.com/ECON-4676-UNIANDES-Fall-2021/e-TA/blob/master/e-ta2_R/Data/",folder,x,sep='/')
       destfile <- paste(folder, x, sep='/')
       download.file(URL,destfile)    
    }
```


I create a function that downloads a file from the ECON4676 webpage and saves it in a desired folder

```{r eval=FALSE}  
    names<-list("US90.txt", "giffen.csv") 
```

Next I created a list with the name of the files I want to download, and then run a loop with `lapply' that downloads and saves all this files in my computer in the folder "data"

```{r eval=FALSE}  
lapply(names, download, folder="Data")
```

# Final words

In this first e-TA I tried to convince you why you should use R as well to introduce you to some basic operations. The next e-TA is closely related to the first problem set and hopefully it will help you get the most out of ECON 4676 and R.

# Web Scraping



```{r comment=NA}
# Load Packages -----------------------------------------------------------
pkg<-list("rvest","tidyverse")
lapply(pkg, require, character.only=T)
rm(pkg)
```

```{r eval=FALSE, comment=NA, include=FALSE}
# Example 1: Wikipedia's counties GDP -------------------------------------
web_page<-read_html("https://en.wikipedia.org/wiki/List_of_countries_by_GDP_(nominal)")

#css selector
table1<- web_page %>% 
  html_node('table.wikitable:nth-child(15) > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(1) > table:nth-child(1)') %>% 
  html_table()
```

```{r eval=FALSE, comment=NA, include=FALSE}
#With xpath
table1<- web_page %>% 
  html_node(xpath="/html/body/div[3]/div[3]/div[5]/div[1]/table[3]/tbody/tr[2]/td[1]/table") %>% 
  html_table()
```

```{r eval=FALSE, comment=NA, include=FALSE}
# Example 2: http://books.toscrape.com/ -------------------------------------
# Inspired from https://gitlab.com/pluriza/web-scraping-with-rstudio-and-rvest/-/blob/master/webscrapingblog.R

books_page<-read_html("http://books.toscrape.com/")
books<- books_page %>% 
  html_node("li.col-xs-6:nth-child(1) > article:nth-child(1) > h3:nth-child(3) > a:nth-child(1)") %>% 
  html_table()
#doesn't work, it is not a table!!!
```

```{r eval=FALSE, comment=NA, include=FALSE}
#get some atributes from the first book
#selector = 
node<-books_page %>%  html_node("li.col-xs-6:nth-child(1) > article:nth-child(1) > h3:nth-child(3) > a:nth-child(1)")
node_text<-html_text(node)
node_links<-html_attr(node, "href")
node_links
```

```{r eval=FALSE, comment=NA, include=FALSE}
#Let's go into the first page
book_page<-read_html(paste0("http://books.toscrape.com/",node_links))
```

```{r eval=FALSE, comment=NA, include=FALSE}
#Book's name
name<- book_page %>% html_node("h1") %>% html_text()
name
```
```{r eval=FALSE, comment=NA, include=FALSE}
#Book's price
price<-book_page %>%  html_node("p.price_color") %>% html_text()
price
```

```{r eval=FALSE, comment=NA, include=FALSE}
#Review as number
reviews_node<-book_page %>% html_node("p.star-rating")
reviews_text<-html_attr(reviews_node, "class")
reviews_text = substr(reviews_text, 13, 17)
reviews_number = switch(reviews_text, "Zero" = 0,"One" = 1, "Two" = 2, "Three" = 3, "Four" = 4, "Five" = 5,)
reviews_number
```

```{r eval=FALSE, comment=NA, include=FALSE}
#book details result
one_book = c(name, price, reviews_number)
one_book
```

```{r eval=FALSE, comment=NA, include=FALSE}
#extracting product details table
#PRODUCT DETAIL
details_selector = ".table"
details_node<- book_page %>%html_node(".table") %>% html_table
```

```{r eval=FALSE, comment=NA, include=FALSE}
#get links to all books in page
links<-books_page %>% html_nodes("article > h3 > a") %>% html_attr("href")
```


#  Regression for prediction

## Introduction {#sec:introduction}

In this lab we come back to the example mentioned in the introduction.
The problem of predicting house prices is not new, but it has proven to
be a challenging one where machine learning may have some something interesting to say.


For this lab we will use the data set `matchdata` included in the
\emph{McSpatial package} [@mcmspatial] for `R`. The data contains data on 3204 sales of single-family homes on the Far North Side of Chicago in 1995 and 2005. This data set includes 18 variables/features about the home, including the price the home was sold, the number of bathrooms, bedrooms, the latitude and longitude, etc. Table \ref{tab:matchdata_char} shows all the variables included in the data, and a complete description of the data can be found in the help file by typing in  `R` `?matchdata`.



```{r include=FALSE}
require("McSpatial")
require("sf")
require("ggplot2")
require("stringr")
require("dplyr")
data(matchdata)
```

```{r echo=FALSE, results='asis'}
stargazer::stargazer(matchdata, header=FALSE, type='latex',title="Variables Included in the \\texttt{Matched} Data",label="tab:matchdata_char")

```

```{r}
data(matchdata) #loads the data
set.seed(101010) #sets a seed 
matchdata <- matchdata %>% 
  mutate(price=exp(lnprice), #transforms log prices to standard prices
         holdout= as.logical(1:nrow(matchdata) %in% sample(nrow(matchdata), nrow(matchdata)*.7)) #generates a logical indicator to divide between train and test set
  ) 
test<-matchdata[matchdata$holdout==T,]
train<-matchdata[matchdata$holdout==F,]
```

---
  
  The objective then is to be able to get the best prediction of house prices. We begin by using a simple model with no covariates, just a constant

```{r}
model1<-lm(price~1,data=train)
summary(model1)
```

In this case our prediction for the log price is the average train sample average


$$
  \hat{y}=\hat{\beta_1}=\frac{\sum y_i}{n}=m
$$
  
  ```{r}
coef(model1)
mean(train$price)
```

---
  
  But we are concernded on predicting well our of sample, so we need to evaluate our model in the testing data 

```{r}
test$model1<-predict(model1,newdata = test)
with(test,mean((price-model1)^2))
```

Then the $test\,MSE=E((y-\hat{y})^2)=E((y-m)^2)=$ `r with(test,round(mean((price-model1)^2),3))`. This is our starting point, then the question is how can we improve it.

---
  
  To improve our prediction we can start adding variables and thus *building* $f$. The standard approach to build $f$ would be using a hedonic house price function derived directly from the theory of hedonic pricing [@rosen1974hedonic]. In its basic form the hedonic price function is linear in the explanatory characteristics

$$
  y=\beta_1+\beta_2 x_2 + \dots + \beta_K x_k +u
$$
  
  where $y$ is ussually the sales price, and $x_1  \dots x_k$ are attributes of the house, like  structural characteristics and it's location. So estimating an hedonic price function seems a good idea to start with. 
However, the theory says little on what are the relevant attributes of the house. So we are going to explore the effects of adding house characteristics on our out of sample MSE.

We begin by showing that the simple inclusion of a single covariate reduces the MSE with respect to the \textit{naive} model that used the sample mean.

```{r}
model2<-lm(price~bedrooms,data=train)
test$model2<-predict(model2,newdata = test)
with(test,mean((price-model2)^2))
```

---

What about if we include more variables? 

```{r}
model3<-lm(price~bedrooms+bathrooms+centair+fireplace+brick,data=train)
test$model3<-predict(model3,newdata = test)
with(test,mean((price-model3)^2))
```

Note that the MSE is once more reduced. If we include all?

```{r}

model4<-lm(price~bedrooms+bathrooms+centair+fireplace+brick+
                lnland+lnbldg+rooms+garage1+garage2+dcbd+rr+
                yrbuilt+factor(carea)+latitude+longitude,data=train)
test$model4<-predict(model4,newdata = test)
with(test,mean((price-model4)^2))
```

Then the MSE for model 3 goes from  `r with(test,round(mean((price-model3)^2),3))` to `r with(test,round(mean((price-model4)^2),3))`. In this case the MSE keeps improving. Is there a limit to this improvement? Can we keep adding features and complexity?

---

```{r}
model5<-lm(price~poly(bedrooms,2)+poly(bathrooms,2)+centair+fireplace+brick+
                lnland+lnbldg+rooms+garage1+garage2+dcbd+rr+
                yrbuilt+factor(carea)+poly(latitude,2)+poly(longitude,2),data=train)
test$model5<-predict(model5,newdata = test)


model6<-lm(price~poly(bedrooms,2)+poly(bathrooms,2)+centair+fireplace+brick+
                lnland+lnbldg+garage1+garage2+rr+
                yrbuilt+factor(carea)+poly(latitude,2)+poly(longitude,2),data=train)
test$model6<-predict(model6,newdata = test)

model7<-lm(price~poly(bedrooms,2)+poly(bathrooms,2)+centair+fireplace+brick+
                lnland+lnbldg+garage1+garage2+rr+
                yrbuilt+factor(carea)+poly(latitude,3)+poly(longitude,3),data=train)
test$model7<-predict(model7,newdata = test)

```
 What about if we take out some of the features like: `lnbldg` (Log of building area in square feet),  `dcbd` (Distance from the central business district), 
 
```{r}
with(test,mean((price-model5)^2))
with(test,mean((price-model6)^2))
```
---


```{r echo=FALSE}
mse1<-with(test,round(mean((price-model1)^2),3))
mse2<-with(test,round(mean((price-model2)^2),3))
mse3<-with(test,round(mean((price-model3)^2),3))
mse4<-with(test,round(mean((price-model4)^2),3))
mse5<-with(test,round(mean((price-model5)^2),3))
mse6<-with(test,round(mean((price-model6)^2),3))
mse7<-with(test,round(mean((price-model7)^2),3))
mse3-mse4
mse4-mse5
```
```{r mse_plot_ch3,echo=FALSE}
mse<-c(mse1,mse2,mse3,mse4,mse5,mse6,mse7)
# features1<-dim(model1$model)[2]
# features2<-dim(model2$model)[2]
# features3<-dim(model3$model)[2]
# features4<-dim(model4$model)[2]
# features5<-dim(model5$model)[2]
# features<-c(features1,features2,features3,features4,features5)

db<-data.frame(MSE=mse,model=factor(c("model1","model2","model3","model4","model5","model6","model7"),ordered=TRUE),group="group")

ggplot(db) +
  geom_line(aes(x=model,y=mse,group=group)) +
  ylab("Estimated Prediction Error") +
  xlab("Fitted Models") +
  theme_bw()  +
  theme(legend.position = "none",
         #axis.title =element_blank(),
         panel.grid.major = element_blank(),
          panel.grid.minor = element_blank()
         )
```






