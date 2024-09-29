
<!-- rnb-text-begin -->

---
title: "R Notebook"
output: html_notebook
---

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBydW4gdHdpY2UgXG5saWJyYXJ5KE1hdHJpeClcbmxpYnJhcnkobG1lNClcbmxpYnJhcnkobG10ZXN0KVxubGlicmFyeShkcGx5cilcbmxpYnJhcnkocGFyYWxsZWwpXG5saWJyYXJ5KGJheWVzdGVzdFIpXG5saWJyYXJ5KGdsbW1UTUIpXG5gYGAifQ== -->

```r
# run twice 
library(Matrix)
library(lme4)
library(lmtest)
library(dplyr)
library(parallel)
library(bayestestR)
library(glmmTMB)
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxub3V0cHV0X2ZpbGVfbmFtZSA8LSBcIlJfbG1lX04xMDAudHh0XCIgIyBSZXBsYWNlXG5kYXRhX3RhYmxlIDwtIHJlYWQuY3N2KFwiRDpcXFxcT0V4cE91dFxcXFxhZGFwdF9yZXNcXFxcY29tcFxcXFxOMTAwX2RhdGFUb1IuY3N2XCIpICAjIFJlcGxhY2Ugd2l0aCB5b3VyIGFjdHVhbCBmaWxlIHBhdGhcblxuIyBDb252ZXJ0IHZhcmlhYmxlcyB0byBmYWN0b3JzOlxuZGF0YV90YWJsZSRzb3YgPC0gZmFjdG9yKGRhdGFfdGFibGUkc292LCBsZXZlbHMgPSBjKCd3bicsICdOMicsICdOMycsICdSRU0nKSwgb3JkZXJlZCA9IEZBTFNFKVxuZGF0YV90YWJsZSRzdWIgPC0gZmFjdG9yKGRhdGFfdGFibGUkc3ViLCBvcmRlcmVkID0gRkFMU0UpXG5kYXRhX3RhYmxlJGNvbmQgPC0gZmFjdG9yKGRhdGFfdGFibGUkY29uZCwgbGV2ZWxzID0gYygnTmJsVDEnLCAnTmJsVDInLCAnTmJsVDMnLCAnTmJsVDQnKSwgb3JkZXJlZCA9IEZBTFNFKVxuZGF0YV90YWJsZSRjb21wX2FtcCA8LSBhcy5udW1lcmljKGRhdGFfdGFibGUkY29tcF9hbXApICAjIENvbnZlcnQgY29tcF9hbXAgdG8gbnVtZXJpY1xuXG4jIyMjIFJlbW92ZSBvdXRsaWVyczpcbnN0ZF90b19yZW1vdmVfb3V0bGllcnMgPC0gNCBcbm1lYW5fY29tcF9hbXAgPC0gbWVhbihkYXRhX3RhYmxlJGNvbXBfYW1wLCBuYS5ybSA9IFRSVUUpXG5zZF9jb21wX2FtcCA8LSBzZChkYXRhX3RhYmxlJGNvbXBfYW1wLCBuYS5ybSA9IFRSVUUpXG5vdXRsaWVycyA8LSBkYXRhX3RhYmxlW2FicyhkYXRhX3RhYmxlJGNvbXBfYW1wIC0gbWVhbl9jb21wX2FtcCkgPiBzdGRfdG9fcmVtb3ZlX291dGxpZXJzICogc2RfY29tcF9hbXAsIF1cbnByaW50KFwiRGV0YWlscyBvZiByZW1vdmVkIG91dGxpZXJzOlwiKVxuYGBgIn0= -->

```r
output_file_name <- "R_lme_N100.txt" # Replace
data_table <- read.csv("D:\\OExpOut\\adapt_res\\comp\\N100_dataToR.csv")  # Replace with your actual file path

# Convert variables to factors:
data_table$sov <- factor(data_table$sov, levels = c('wn', 'N2', 'N3', 'REM'), ordered = FALSE)
data_table$sub <- factor(data_table$sub, ordered = FALSE)
data_table$cond <- factor(data_table$cond, levels = c('NblT1', 'NblT2', 'NblT3', 'NblT4'), ordered = FALSE)
data_table$comp_amp <- as.numeric(data_table$comp_amp)  # Convert comp_amp to numeric

#### Remove outliers:
std_to_remove_outliers <- 4 
mean_comp_amp <- mean(data_table$comp_amp, na.rm = TRUE)
sd_comp_amp <- sd(data_table$comp_amp, na.rm = TRUE)
outliers <- data_table[abs(data_table$comp_amp - mean_comp_amp) > std_to_remove_outliers * sd_comp_amp, ]
print("Details of removed outliers:")
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIFwiRGV0YWlscyBvZiByZW1vdmVkIG91dGxpZXJzOlwiXG4ifQ== -->

```
[1] "Details of removed outliers:"
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucHJpbnQob3V0bGllcnMpXG5gYGAifQ== -->

```r
print(outliers)
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbImRhdGEuZnJhbWUiXSwibnJvdyI6MiwibmNvbCI6NCwic3VtbWFyeSI6eyJEZXNjcmlwdGlvbiI6WyJkZiBbMiDDlyA0XSJdfX0sInJkZiI6Ikg0c0lBQUFBQUFBQUJvMlR6VTdDUUJTRmgzYUswZ1ExOFFWY3VJVTRNK0RQem9VL0sxMFFUTmlaVW9vMmxoblNGdERYY0tWdjR3T3c5d1Y4Q2hmb2xIYncyRVRENG1iT25jNDkzNzB6MERuckNiZm5Fa0pzUW1tRjJJNld4TG5wWGpTT0NhR1dUaXFFa2xxMlB1cER1MXBRdmRiMW1uMnM1dkhyWURVS3BrR1VhTFdqWTcvWXBjbnRBUVBOUVF2UUxkQnQwSWVnajBBZmd6NzUwZXdBTkhBWmNCbHdHWEFaY0Jsd0dYQVpzRGl3T0xBNCtIUHc1K0RQd1orRFA0ZTVPTEFFc0FTd0JNd2xnQ3VBSzRBcmdDdUFLOHJQN3ZpUmw1akhYRDN4MFBOVEZXdTFnQitEblVkV2JuMFZGYlNvc0diU3FHdStVcVpSdTNOK2xSZmFYMnVockg5UXpuVS82akpNT0NZQ2s5WTZWTEtWRVUvYm41Y2Y4L243MjE3NDNINTZmU25may9SR1FWSnF4VTRtL1pWVVUzUE52cEtEUW0vNmFqUys5VWJqa2wwdFZyT21zU3ltcmh6cU9QcWpZM2ZncFY1ekdPdVN2T3RmZGh0cW5JWkthak1yK3dzN3BlSktYTnJZbnNnTVBtajQ5eFA1MEdobGdPWG5QT3JGYW9HbU9aS2F4aHh6bFlHOEMyVmdyaW55K2tGVUpGdDZ5T1dNelhFY3l0Uk1vbmVUWnFwU3o1eHpmUldabmZ4RkZ0OXd2RDVtdVFRQUFBPT0ifQ== -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["sub"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["sov"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["cond"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["comp_amp"],"name":[4],"type":["dbl"],"align":["right"]}],"data":[{"1":"s_06","2":"N3","3":"NblT2","4":"21.977660","_rn_":"310"},{"1":"s_06","2":"N3","3":"NblT3","4":"-8.206194","_rn_":"311"}],"options":{"columns":{"min":{},"max":[10],"total":[4]},"rows":{"min":[10],"max":[10],"total":[2]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuZGF0YV90YWJsZSA8LSBkYXRhX3RhYmxlW2FicyhkYXRhX3RhYmxlJGNvbXBfYW1wIC0gbWVhbl9jb21wX2FtcCkgPD0gc3RkX3RvX3JlbW92ZV9vdXRsaWVycyAqIHNkX2NvbXBfYW1wLCBdXG5gYGAifQ== -->

```r
data_table <- data_table[abs(data_table$comp_amp - mean_comp_amp) <= std_to_remove_outliers * sd_comp_amp, ]
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBZb2VscyBoZWxwP1xuIyBNb2RlbCBGaXR0aW5nIFVzaW5nIGdsbW1UTUIgd2l0aCB0d2VlZGllIERpc3RyaWJ1dGlvbi0tLVxubW9kZWxfdHdlZWRpZSA8LSBnbG1tVE1CKGNvbXBfYW1wIH4gc292ICogY29uZCArICgxIHwgc3ViKSwgZGF0YSA9IGRhdGFfdGFibGUsZmFtaWx5ID0gdHdlZWRpZShsaW5rID0gXCJsb2dcIikpXG5gYGAifQ== -->

```r
# Yoels help?
# Model Fitting Using glmmTMB with tweedie Distribution---
model_tweedie <- glmmTMB(comp_amp ~ sov * cond + (1 | sub), data = data_table,family = tweedie(link = "log"))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiV2FybmluZzogTW9kZWwgY29udmVyZ2VuY2UgcHJvYmxlbTsgc2luZ3VsYXIgY29udmVyZ2VuY2UgKDcpLiBTZWUgdmlnbmV0dGUoJ3Ryb3VibGVzaG9vdGluZycpLCBoZWxwKCdkaWFnbm9zZScpXG4ifQ== -->

```
Warning: Model convergence problem; singular convergence (7). See vignette('troubleshooting'), help('diagnose')
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubW9kZWxfbm9yIDwtIGdsbW1UTUIoY29tcF9hbXAgfiBzb3YgKiBjb25kICsgKDEgfCBzdWIpLCBkYXRhID0gZGF0YV90YWJsZSxmYW1pbHkgPSBnYXVzc2lhbilcblxuXG4jIEV4dHJhY3QgdGhlIFR3ZWVkaWUgcG93ZXIgcGFyYW1ldGVyIFxuIyB3b3VsZCBiZSBiZXR3ZWVuIDEtMiBub3Qgbm9ybWFsLiBOb3JtYWwgaXMgMFxucHJpbnQoJ21vZGVsX3R3ZWVkaWUgbG9nIG1vZGVsJylcbmBgYCJ9 -->

```r
model_nor <- glmmTMB(comp_amp ~ sov * cond + (1 | sub), data = data_table,family = gaussian)


# Extract the Tweedie power parameter 
# would be between 1-2 not normal. Normal is 0
print('model_tweedie log model')
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIFwibW9kZWxfdHdlZWRpZSBsb2cgbW9kZWxcIlxuIn0= -->

```
[1] "model_tweedie log model"
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucG93ZXJfcGFyYW0gPC0gZmFtaWx5X3BhcmFtcyhtb2RlbF90d2VlZGllKVxucHJpbnQocG93ZXJfcGFyYW0pXG5gYGAifQ== -->

```r
power_param <- family_params(model_tweedie)
print(power_param)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiVHdlZWRpZSBwb3dlciBcbiAgICAgMS4zNzQzMzQgXG4ifQ== -->

```
Tweedie power 
     1.374334 
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucHJpbnQoJ2dhdXNzaWFuIG1vZGVsJylcbmBgYCJ9 -->

```r
print('gaussian model')
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIFwiZ2F1c3NpYW4gbW9kZWxcIlxuIn0= -->

```
[1] "gaussian model"
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBFeHRyYWN0IHRoZSBHYXV1c2FpbiBwb3dlciBwYXJhbWV0ZXIgLSBzYW5pdHkgY2hlY2sgc2hvdWxkIGJlIDAgZm9yIGdhdXNzaWFuXG5wb3dlcl9wYXJhbSA8LSBmYW1pbHlfcGFyYW1zKG1vZGVsX25vcilcbnByaW50KHBvd2VyX3BhcmFtKVxuYGBgIn0= -->

```r
# Extract the Gauusain power parameter - sanity check should be 0 for gaussian
power_param <- family_params(model_nor)
print(power_param)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoibnVtZXJpYygwKVxuIn0= -->

```
numeric(0)
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucHJpbnQoc3VtbWFyeShtb2RlbF90d2VlZGllKSlcbmBgYCJ9 -->

```r
print(summary(model_tweedie))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiIEZhbWlseTogdHdlZWRpZSAgKCBsb2cgKVxuRm9ybXVsYTogICAgICAgICAgY29tcF9hbXAgfiBzb3YgKiBjb25kICsgKDEgfCBzdWIpXG5EYXRhOiBkYXRhX3RhYmxlXG5cbiAgICAgQUlDICAgICAgQklDICAgbG9nTGlrIGRldmlhbmNlIGRmLnJlc2lkIFxuICAgOTcwLjUgICAxMDUzLjIgICAtNDY2LjIgICAgOTMyLjUgICAgICA1NTUgXG5cblJhbmRvbSBlZmZlY3RzOlxuXG5Db25kaXRpb25hbCBtb2RlbDpcbiBHcm91cHMgTmFtZSAgICAgICAgVmFyaWFuY2UgU3RkLkRldi5cbiBzdWIgICAgKEludGVyY2VwdCkgMC41ODA0ICAgMC43NjE4ICBcbk51bWJlciBvZiBvYnM6IDU3NCwgZ3JvdXBzOiAgc3ViLCAzNlxuXG5EaXNwZXJzaW9uIHBhcmFtZXRlciBmb3IgdHdlZWRpZSBmYW1pbHkgKCk6IDEuMzIgXG5cbkNvbmRpdGlvbmFsIG1vZGVsOlxuICAgICAgICAgICAgICAgICBFc3RpbWF0ZSBTdGQuIEVycm9yIHogdmFsdWUgUHIoPnx6fClcbihJbnRlcmNlcHQpICAgICAgICAtMzEuNTkgICAgNDQ3OS4xMCAgLTAuMDA3ICAgIDAuOTk0XG5zb3ZOMiAgICAgICAgICAgICAgIDMxLjU5ICAgIDQ0NzkuMTAgICAwLjAwNyAgICAwLjk5NFxuc292TjMgICAgICAgICAgICAgICAzMS41MSAgICA0NDc5LjEwICAgMC4wMDcgICAgMC45OTRcbnNvdlJFTSAgICAgICAgICAgICAgMjguNjEgICAgNDQ3OS4xMCAgIDAuMDA2ICAgIDAuOTk1XG5jb25kTmJsVDIgICAgICAgICAgIDI2LjA3ICAgIDQ0NzkuMTAgICAwLjAwNiAgICAwLjk5NVxuY29uZE5ibFQzICAgICAgICAgICAyNi45OSAgICA0NDc5LjEwICAgMC4wMDYgICAgMC45OTVcbmNvbmROYmxUNCAgICAgICAgICAgMjguMDMgICAgNDQ3OS4xMCAgIDAuMDA2ICAgIDAuOTk1XG5zb3ZOMjpjb25kTmJsVDIgICAgLTI2LjI4ICAgIDQ0NzkuMTAgIC0wLjAwNiAgICAwLjk5NVxuc292TjM6Y29uZE5ibFQyICAgIC0yNy4wOCAgICA0NDc5LjEwICAtMC4wMDYgICAgMC45OTVcbnNvdlJFTTpjb25kTmJsVDIgICAtMjYuMDMgICAgNDQ3OS4xMCAgLTAuMDA2ICAgIDAuOTk1XG5zb3ZOMjpjb25kTmJsVDMgICAgLTI3LjY3ICAgIDQ0NzkuMTAgIC0wLjAwNiAgICAwLjk5NVxuc292TjM6Y29uZE5ibFQzICAgIC0yNy4zNCAgICA0NDc5LjEwICAtMC4wMDYgICAgMC45OTVcbnNvdlJFTTpjb25kTmJsVDMgICAtMjcuMjkgICAgNDQ3OS4xMCAgLTAuMDA2ICAgIDAuOTk1XG5zb3ZOMjpjb25kTmJsVDQgICAgLTI5LjU0ICAgIDQ0NzkuMTAgIC0wLjAwNyAgICAwLjk5NVxuc292TjM6Y29uZE5ibFQ0ICAgIC0yOC42NiAgICA0NDc5LjEwICAtMC4wMDYgICAgMC45OTVcbnNvdlJFTTpjb25kTmJsVDQgICAtMjguNDUgICAgNDQ3OS4xMCAgLTAuMDA2ICAgIDAuOTk1XG4ifQ== -->

```
 Family: tweedie  ( log )
Formula:          comp_amp ~ sov * cond + (1 | sub)
Data: data_table

     AIC      BIC   logLik deviance df.resid 
   970.5   1053.2   -466.2    932.5      555 

Random effects:

Conditional model:
 Groups Name        Variance Std.Dev.
 sub    (Intercept) 0.5804   0.7618  
Number of obs: 574, groups:  sub, 36

Dispersion parameter for tweedie family (): 1.32 

Conditional model:
                 Estimate Std. Error z value Pr(>|z|)
(Intercept)        -31.59    4479.10  -0.007    0.994
sovN2               31.59    4479.10   0.007    0.994
sovN3               31.51    4479.10   0.007    0.994
sovREM              28.61    4479.10   0.006    0.995
condNblT2           26.07    4479.10   0.006    0.995
condNblT3           26.99    4479.10   0.006    0.995
condNblT4           28.03    4479.10   0.006    0.995
sovN2:condNblT2    -26.28    4479.10  -0.006    0.995
sovN3:condNblT2    -27.08    4479.10  -0.006    0.995
sovREM:condNblT2   -26.03    4479.10  -0.006    0.995
sovN2:condNblT3    -27.67    4479.10  -0.006    0.995
sovN3:condNblT3    -27.34    4479.10  -0.006    0.995
sovREM:condNblT3   -27.29    4479.10  -0.006    0.995
sovN2:condNblT4    -29.54    4479.10  -0.007    0.995
sovN3:condNblT4    -28.66    4479.10  -0.006    0.995
sovREM:condNblT4   -28.45    4479.10  -0.006    0.995
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucHJpbnQoc3VtbWFyeShtb2RlbF9ub3IpKVxuYGBgIn0= -->

```r
print(summary(model_nor))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiIEZhbWlseTogZ2F1c3NpYW4gICggaWRlbnRpdHkgKVxuRm9ybXVsYTogICAgICAgICAgY29tcF9hbXAgfiBzb3YgKiBjb25kICsgKDEgfCBzdWIpXG5EYXRhOiBkYXRhX3RhYmxlXG5cbiAgICAgQUlDICAgICAgQklDICAgbG9nTGlrIGRldmlhbmNlIGRmLnJlc2lkIFxuICAxOTE3LjAgICAxOTk1LjMgICAtOTQwLjUgICAxODgxLjAgICAgICA1NTYgXG5cblJhbmRvbSBlZmZlY3RzOlxuXG5Db25kaXRpb25hbCBtb2RlbDpcbiBHcm91cHMgICBOYW1lICAgICAgICBWYXJpYW5jZSBTdGQuRGV2LlxuIHN1YiAgICAgIChJbnRlcmNlcHQpIDAuMzMxMiAgIDAuNTc1NSAgXG4gUmVzaWR1YWwgICAgICAgICAgICAgMS40MDY4ICAgMS4xODYxICBcbk51bWJlciBvZiBvYnM6IDU3NCwgZ3JvdXBzOiAgc3ViLCAzNlxuXG5EaXNwZXJzaW9uIGVzdGltYXRlIGZvciBnYXVzc2lhbiBmYW1pbHkgKHNpZ21hXjIpOiAxLjQxIFxuXG5Db25kaXRpb25hbCBtb2RlbDpcbiAgICAgICAgICAgICAgICAgRXN0aW1hdGUgU3RkLiBFcnJvciB6IHZhbHVlIFByKD58enwpICAgIFxuKEludGVyY2VwdCkgICAgICAgLTEuNjczOCAgICAgMC4yMTk3ICAtNy42MTggMi41OGUtMTQgKioqXG5zb3ZOMiAgICAgICAgICAgICAgMi43ODEyICAgICAwLjI3OTYgICA5Ljk0OCAgPCAyZS0xNiAqKipcbnNvdk4zICAgICAgICAgICAgICAyLjM2MTggICAgIDAuMjc5NiAgIDguNDQ4ICA8IDJlLTE2ICoqKlxuc292UkVNICAgICAgICAgICAgIDEuMDUxNyAgICAgMC4yNzk2ICAgMy43NjIgMC4wMDAxNjkgKioqXG5jb25kTmJsVDIgICAgICAgICAgMC4xNTA3ICAgICAwLjI3OTYgICAwLjUzOSAwLjU4OTk0NiAgICBcbmNvbmROYmxUMyAgICAgICAgICAwLjEyODQgICAgIDAuMjc5NiAgIDAuNDU5IDAuNjQ1OTkyICAgIFxuY29uZE5ibFQ0ICAgICAgICAgIDAuMjA5NyAgICAgMC4yNzk2ICAgMC43NTAgMC40NTMxNDEgICAgXG5zb3ZOMjpjb25kTmJsVDIgICAtMC40NDY4ICAgICAwLjM5NTQgIC0xLjEzMCAwLjI1ODQzOSAgICBcbnNvdk4zOmNvbmROYmxUMiAgIC0xLjg0OTMgICAgIDAuMzk2OSAgLTQuNjYwIDMuMTZlLTA2ICoqKlxuc292UkVNOmNvbmROYmxUMiAgLTAuMjc4NyAgICAgMC4zOTU0ICAtMC43MDUgMC40ODA3OTEgICAgXG5zb3ZOMjpjb25kTmJsVDMgICAtMC44MjIxICAgICAwLjM5NTQgIC0yLjA3OSAwLjAzNzU4NyAqICBcbnNvdk4zOmNvbmROYmxUMyAgIC0wLjY2NjcgICAgIDAuMzk2OSAgLTEuNjgwIDAuMDkyOTQwIC4gIFxuc292UkVNOmNvbmROYmxUMyAgLTAuMjg1MSAgICAgMC4zOTU0ICAtMC43MjEgMC40NzA4OTEgICAgXG5zb3ZOMjpjb25kTmJsVDQgICAtMS4zODEzICAgICAwLjM5NTQgIC0zLjQ5NCAwLjAwMDQ3NiAqKipcbnNvdk4zOmNvbmROYmxUNCAgIC0wLjk5NTYgICAgIDAuMzk1NCAgLTIuNTE4IDAuMDExNzk0ICogIFxuc292UkVNOmNvbmROYmxUNCAgLTAuMzQwNCAgICAgMC4zOTU0ICAtMC44NjEgMC4zODkyNDQgICAgXG4tLS1cblNpZ25pZi4gY29kZXM6ICAwIOKAmCoqKuKAmSAwLjAwMSDigJgqKuKAmSAwLjAxIOKAmCrigJkgMC4wNSDigJgu4oCZIDAuMSDigJgg4oCZIDFcbiJ9 -->

```
 Family: gaussian  ( identity )
Formula:          comp_amp ~ sov * cond + (1 | sub)
Data: data_table

     AIC      BIC   logLik deviance df.resid 
  1917.0   1995.3   -940.5   1881.0      556 

Random effects:

Conditional model:
 Groups   Name        Variance Std.Dev.
 sub      (Intercept) 0.3312   0.5755  
 Residual             1.4068   1.1861  
Number of obs: 574, groups:  sub, 36

Dispersion estimate for gaussian family (sigma^2): 1.41 

Conditional model:
                 Estimate Std. Error z value Pr(>|z|)    
(Intercept)       -1.6738     0.2197  -7.618 2.58e-14 ***
sovN2              2.7812     0.2796   9.948  < 2e-16 ***
sovN3              2.3618     0.2796   8.448  < 2e-16 ***
sovREM             1.0517     0.2796   3.762 0.000169 ***
condNblT2          0.1507     0.2796   0.539 0.589946    
condNblT3          0.1284     0.2796   0.459 0.645992    
condNblT4          0.2097     0.2796   0.750 0.453141    
sovN2:condNblT2   -0.4468     0.3954  -1.130 0.258439    
sovN3:condNblT2   -1.8493     0.3969  -4.660 3.16e-06 ***
sovREM:condNblT2  -0.2787     0.3954  -0.705 0.480791    
sovN2:condNblT3   -0.8221     0.3954  -2.079 0.037587 *  
sovN3:condNblT3   -0.6667     0.3969  -1.680 0.092940 .  
sovREM:condNblT3  -0.2851     0.3954  -0.721 0.470891    
sovN2:condNblT4   -1.3813     0.3954  -3.494 0.000476 ***
sovN3:condNblT4   -0.9956     0.3954  -2.518 0.011794 *  
sovREM:condNblT4  -0.3404     0.3954  -0.861 0.389244    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucHJpbnQoc3VtbWFyeShhbm92YShtb2RlbF90d2VlZGllLG1vZGVsX25vcikpKVxuYGBgIn0= -->

```r
print(summary(anova(model_tweedie,model_nor)))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICAgICAgIERmICAgICAgICAgICAgIEFJQyAgICAgICAgICAgICAgQklDICAgICAgICAgICBsb2dMaWsgICAgICAgICAgZGV2aWFuY2UgICAgICAgICAgQ2hpc3EgICAgICAgICAgIENoaSBEZiBcbiBNaW4uICAgOjE4LjAwICAgTWluLiAgIDogOTcwLjUgICBNaW4uICAgOjEwNTMgICBNaW4uICAgOi05NDAuNSAgIE1pbi4gICA6IDkzMi41ICAgTWluLiAgIDo5NDguNSAgIE1pbi4gICA6MSAgXG4gMXN0IFF1LjoxOC4yNSAgIDFzdCBRdS46MTIwNy4xICAgMXN0IFF1LjoxMjg5ICAgMXN0IFF1LjotODIxLjkgICAxc3QgUXUuOjExNjkuNiAgIDFzdCBRdS46OTQ4LjUgICAxc3QgUXUuOjEgIFxuIE1lZGlhbiA6MTguNTAgICBNZWRpYW4gOjE0NDMuNyAgIE1lZGlhbiA6MTUyNCAgIE1lZGlhbiA6LTcwMy40ICAgTWVkaWFuIDoxNDA2LjcgICBNZWRpYW4gOjk0OC41ICAgTWVkaWFuIDoxICBcbiBNZWFuICAgOjE4LjUwICAgTWVhbiAgIDoxNDQzLjcgICBNZWFuICAgOjE1MjQgICBNZWFuICAgOi03MDMuNCAgIE1lYW4gICA6MTQwNi43ICAgTWVhbiAgIDo5NDguNSAgIE1lYW4gICA6MSAgXG4gM3JkIFF1LjoxOC43NSAgIDNyZCBRdS46MTY4MC40ICAgM3JkIFF1LjoxNzYwICAgM3JkIFF1LjotNTg0LjggICAzcmQgUXUuOjE2NDMuOSAgIDNyZCBRdS46OTQ4LjUgICAzcmQgUXUuOjEgIFxuIE1heC4gICA6MTkuMDAgICBNYXguICAgOjE5MTcuMCAgIE1heC4gICA6MTk5NSAgIE1heC4gICA6LTQ2Ni4yICAgTWF4LiAgIDoxODgxLjAgICBNYXguICAgOjk0OC41ICAgTWF4LiAgIDoxICBcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgTkEncyAgIDoxICAgICAgIE5BJ3MgICA6MSAgXG4gICBQcig+Q2hpc3EpXG4gTWluLiAgIDowICAgXG4gMXN0IFF1LjowICAgXG4gTWVkaWFuIDowICAgXG4gTWVhbiAgIDowICAgXG4gM3JkIFF1LjowICAgXG4gTWF4LiAgIDowICAgXG4gTkEncyAgIDoxICAgXG4ifQ== -->

```
       Df             AIC              BIC           logLik          deviance          Chisq           Chi Df 
 Min.   :18.00   Min.   : 970.5   Min.   :1053   Min.   :-940.5   Min.   : 932.5   Min.   :948.5   Min.   :1  
 1st Qu.:18.25   1st Qu.:1207.1   1st Qu.:1289   1st Qu.:-821.9   1st Qu.:1169.6   1st Qu.:948.5   1st Qu.:1  
 Median :18.50   Median :1443.7   Median :1524   Median :-703.4   Median :1406.7   Median :948.5   Median :1  
 Mean   :18.50   Mean   :1443.7   Mean   :1524   Mean   :-703.4   Mean   :1406.7   Mean   :948.5   Mean   :1  
 3rd Qu.:18.75   3rd Qu.:1680.4   3rd Qu.:1760   3rd Qu.:-584.8   3rd Qu.:1643.9   3rd Qu.:948.5   3rd Qu.:1  
 Max.   :19.00   Max.   :1917.0   Max.   :1995   Max.   :-466.2   Max.   :1881.0   Max.   :948.5   Max.   :1  
                                                                                   NA's   :1       NA's   :1  
   Pr(>Chisq)
 Min.   :0   
 1st Qu.:0   
 Median :0   
 Mean   :0   
 3rd Qu.:0   
 Max.   :0   
 NA's   :1   
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYmF5ZXNfb3V0X3R3ZWVkaWUgPC0gYmF5ZXNmYWN0b3JfbW9kZWxzKG1vZGVsX3R3ZWVkaWUsIGRlbm9taW5hdG9yID0gMSlcbmJheWVzX291dF9ub3IgPC0gYmF5ZXNmYWN0b3JfbW9kZWxzKG1vZGVsX25vciwgZGVub21pbmF0b3IgPSAxKVxuXG4jIFByaW50IHRoZSBpbnZlcnNlIEJheWVzIGZhY3RvciB2YWx1ZXMgZm9yIGVhc2llciBpbnRlcnByZXRhdGlvblxucHJpbnQoMSAvIGFzLm51bWVyaWMoYmF5ZXNfb3V0X3R3ZWVkaWUpKVxuYGBgIn0= -->

```r
bayes_out_tweedie <- bayesfactor_models(model_tweedie, denominator = 1)
bayes_out_nor <- bayesfactor_models(model_nor, denominator = 1)

# Print the inverse Bayes factor values for easier interpretation
print(1 / as.numeric(bayes_out_tweedie))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDFcbiJ9 -->

```
[1] 1
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucHJpbnQoMSAvIGFzLm51bWVyaWMoYmF5ZXNfb3V0X25vcikpXG5gYGAifQ== -->

```r
print(1 / as.numeric(bayes_out_nor))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDFcbiJ9 -->

```
[1] 1
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYmF5ZXNfbW9kZWxfY29tcGFyaXNvbiA8LSBiYXllc2ZhY3Rvcl9tb2RlbHMobW9kZWxfdHdlZWRpZSxtb2RlbF9ub3IpXG5wcmludChiYXllc19tb2RlbF9jb21wYXJpc29uKVxuYGBgIn0= -->

```r
bayes_model_comparison <- bayesfactor_models(model_tweedie,model_nor)
print(bayes_model_comparison)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiQmF5ZXMgRmFjdG9ycyBmb3IgTW9kZWwgQ29tcGFyaXNvblxuXG4gICAgICAgICAgICBNb2RlbCAgICAgICAgICAgICAgICAgICAgICAgICBCRlxuW21vZGVsX25vcl0gc292ICogY29uZCArICgxIHwgc3ViKSAyLjYxZS0yMDVcblxuKiBBZ2FpbnN0IERlbm9taW5hdG9yOiBbbW9kZWxfdHdlZWRpZV0gc292ICogY29uZCArICgxIHwgc3ViKVxuKiAgIEJheWVzIEZhY3RvciBUeXBlOiBCSUMgYXBwcm94aW1hdGlvblxuIn0= -->

```
Bayes Factors for Model Comparison

            Model                         BF
[model_nor] sov * cond + (1 | sub) 2.61e-205

* Against Denominator: [model_tweedie] sov * cond + (1 | sub)
*   Bayes Factor Type: BIC approximation
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBDb21wYXJlIHRoZSBtb2RlbHMgdXNpbmcgQUlDXG5hbm92YShyb3dfZ2xtbVRNQiwgbnVtX2dsbW1UTUIsIHJvd19udW1fZ2xtbVRNQixiYXNlbGluZV9zYmpfZ2xtbVRNQilcblxuXG4jIENhbGN1bGF0ZSBCYXllcyBmYWN0b3JzIGZvciB0aGUgbW9kZWxzXG5saWJyYXJ5KGJheWVzdGVzdFIpXG5iYXllc19vdXRfZ2xtbVRNQiA8LSBiYXllc2ZhY3Rvcl9tb2RlbHMocm93X2dsbW1UTUIsIG51bV9nbG1tVE1CLCByb3dfbnVtX2dsbW1UTUIsYmFzZWxpbmVfc2JqX2dsbW1UTUIsIGRlbm9taW5hdG9yID0gNClcblxuIyBQcmludCB0aGUgaW52ZXJzZSBCYXllcyBmYWN0b3IgdmFsdWVzIGZvciBlYXNpZXIgaW50ZXJwcmV0YXRpb25cbnByaW50KDEgLyBhcy5udW1lcmljKGJheWVzX291dF9nbG1tVE1CKSlcblxuIyBNb2RlbCBGaXR0aW5nIFVzaW5nIGdsbW1UTUIgd2l0aCBHYXVzc2lhbiBEaXN0cmlidXRpb24tLS0tLS0tLS0tLS1cblxuIyBNb2RlbCAxOiBSYW5kb20gZWZmZWN0IG9mIFNCSl9pZHggb25seVxuYmFzZWxpbmVfc2JqX2dsbW1UTUJfbm9yIDwtIGdsbW1UTUIodmFyX2NvbnZleF9odWxsIH4gMSArICgxIHwgU0JKX2lkeCksIFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgZGF0YSA9IGZpbHRlcmVkX2RmLCBcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGZhbWlseSA9IGdhdXNzaWFuKVxuXG4jIE1vZGVsIDI6IEZpeGVkIGVmZmVjdCBvZiBSb3dfTnVtYmVyIChiaW4pIGFuZCByYW5kb20gZWZmZWN0IG9mIFNCSl9pZHhcbnJvd19nbG1tVE1CX25vciA8LSBnbG1tVE1CKHZhcl9jb252ZXhfaHVsbCB+IFJvd19OdW1iZXIgKyAoMSB8IFNCSl9pZHgpLCBcbiAgICAgICAgICAgICAgICAgICAgICAgICAgIGRhdGEgPSBmaWx0ZXJlZF9kZiwgXG4gICAgICAgICAgICAgICAgICAgICAgICAgICBmYW1pbHkgPSBnYXVzc2lhbilcblxuIyBNb2RlbCAzOiBGaXhlZCBlZmZlY3Qgb2YgUm93X051bWJlciAoYmluKSBhbmQgTnVtYmVyIG9mIGl0ZW1zIGFuZCByYW5kb20gZWZmZWN0IG9mIFNCSl9pZHhcbnJvd19udW1fZ2xtbVRNQl9ub3IgPC0gZ2xtbVRNQih2YXJfY29udmV4X2h1bGwgfiBSb3dfTnVtYmVyICsgbnVtX3ByZXNzZXMgKyAoMSB8IFNCSl9pZHgpLCBcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBkYXRhID0gZmlsdGVyZWRfZGYsIFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGZhbWlseSA9IGdhdXNzaWFuKVxuXG4jIE1vZGVsIDQ6IEZpeGVkIGVmZmVjdCBvZiBOdW1iZXIgb2YgaXRlbXMgYW5kIHJhbmRvbSBlZmZlY3Qgb2YgU0JKX2lkeFxubnVtX2dsbW1UTUJfbm9yIDwtIGdsbW1UTUIodmFyX2NvbnZleF9odWxsIH4gbnVtX3ByZXNzZXMgKyAoMSB8IFNCSl9pZHgpLCBcbiAgICAgICAgICAgICAgICAgICAgICAgICAgIGRhdGEgPSBmaWx0ZXJlZF9kZiwgXG4gICAgICAgICAgICAgICAgICAgICAgICAgICBmYW1pbHkgPSBnYXVzc2lhbilcblxuIyBFeHRyYWN0IHRoZSBHYXV1c2FpbiBwb3dlciBwYXJhbWV0ZXIgLSBzYW5pdHkgY2hlY2sgc2hvdWxkIGJlIHplcm8gZm9yIGdhdXNzaWFuXG5wb3dlcl9wYXJhbSA8LSBmYW1pbHlfcGFyYW1zKG51bV9nbG1tVE1CX25vcilcbnByaW50KHBvd2VyX3BhcmFtKVxuXG4jIENvbXBhcmUgdGhlIG1vZGVscyB1c2luZyBBSUNcbmFub3ZhKHJvd19nbG1tVE1CX25vciwgbnVtX2dsbW1UTUJfbm9yLCByb3dfbnVtX2dsbW1UTUJfbm9yLGJhc2VsaW5lX3Nial9nbG1tVE1CX25vcilcbmBgYCJ9 -->

```r
# Compare the models using AIC
anova(row_glmmTMB, num_glmmTMB, row_num_glmmTMB,baseline_sbj_glmmTMB)


# Calculate Bayes factors for the models
library(bayestestR)
bayes_out_glmmTMB <- bayesfactor_models(row_glmmTMB, num_glmmTMB, row_num_glmmTMB,baseline_sbj_glmmTMB, denominator = 4)

# Print the inverse Bayes factor values for easier interpretation
print(1 / as.numeric(bayes_out_glmmTMB))

# Model Fitting Using glmmTMB with Gaussian Distribution------------

# Model 1: Random effect of SBJ_idx only
baseline_sbj_glmmTMB_nor <- glmmTMB(var_convex_hull ~ 1 + (1 | SBJ_idx), 
                                    data = filtered_df, 
                                    family = gaussian)

# Model 2: Fixed effect of Row_Number (bin) and random effect of SBJ_idx
row_glmmTMB_nor <- glmmTMB(var_convex_hull ~ Row_Number + (1 | SBJ_idx), 
                           data = filtered_df, 
                           family = gaussian)

# Model 3: Fixed effect of Row_Number (bin) and Number of items and random effect of SBJ_idx
row_num_glmmTMB_nor <- glmmTMB(var_convex_hull ~ Row_Number + num_presses + (1 | SBJ_idx), 
                               data = filtered_df, 
                               family = gaussian)

# Model 4: Fixed effect of Number of items and random effect of SBJ_idx
num_glmmTMB_nor <- glmmTMB(var_convex_hull ~ num_presses + (1 | SBJ_idx), 
                           data = filtered_df, 
                           family = gaussian)

# Extract the Gauusain power parameter - sanity check should be zero for gaussian
power_param <- family_params(num_glmmTMB_nor)
print(power_param)

# Compare the models using AIC
anova(row_glmmTMB_nor, num_glmmTMB_nor, row_num_glmmTMB_nor,baseline_sbj_glmmTMB_nor)
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->





<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyMjIyBNYW51YWwgbm9ybWFsaXR5IHRlc3Rpbmcgb2YgdGhlIHJlc2lkdWFsc1xuXG5tb2RlbCA8LSBsbWVyKGNvbXBfYW1wIH4gLTEgKyBzb3YgKiBjb25kICsgKDEgfCBzdWIpLCBkYXRhID0gZGF0YV90YWJsZSlcbnFxbm9ybShyZXNpZHVhbHMobW9kZWwpKVxucXFsaW5lKHJlc2lkdWFscyhtb2RlbCkpXG5gYGAifQ== -->

```r
#### Manual normality testing of the residuals

model <- lmer(comp_amp ~ -1 + sov * cond + (1 | sub), data = data_table)
qqnorm(residuals(model))
qqline(residuals(model))
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbXX0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucGxvdChtb2RlbCwgcmVzaWQoLiwgdHlwZSA9IFwicGVhcnNvblwiKSB+IGZpdHRlZCguKSwgYWJsaW5lID0gMClcbmBgYCJ9 -->

```r
plot(model, resid(., type = "pearson") ~ fitted(.), abline = 0)
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbXX0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucHJpbnQoc2hhcGlyby50ZXN0KHJlc2lkdWFscyhtb2RlbCkpKVxuYGBgIn0= -->

```r
print(shapiro.test(residuals(model)))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5cdFNoYXBpcm8tV2lsayBub3JtYWxpdHkgdGVzdFxuXG5kYXRhOiAgcmVzaWR1YWxzKG1vZGVsKVxuVyA9IDAuOTY0MTIsIHAtdmFsdWUgPSAxLjI2NGUtMTBcbiJ9 -->

```

	Shapiro-Wilk normality test

data:  residuals(model)
W = 0.96412, p-value = 1.264e-10
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBJZiB0aGUgUS1RIHBsb3Qgc2hvd3MgcG9pbnRzIHJvdWdobHkgYWxvbmcgdGhlIHJlZmVyZW5jZSBsaW5lLCB0aGUgcmVzaWR1YWxzIGFyZSBhcHByb3hpbWF0ZWx5IG5vcm1hbGx5IGRpc3RyaWJ1dGVkLlxuIyBJZiB0aGUgcGxvdCBvZiByZXNpZHVhbHMgdmVyc3VzIGZpdHRlZCB2YWx1ZXMgc2hvd3Mgbm8gY2xlYXIgcGF0dGVybiAocmFuZG9tIHNjYXR0ZXIpLCBob21vc2NlZGFzdGljaXR5IGlzIGFzc3VtZWQuXG5cbiMgRm9yIHRoZSBTaGFwaXJvLVdpbGsgdGVzdDpcbiMgSWYgcC12YWx1ZSA+IDAuMDUsIHRoZSByZXNpZHVhbHMgYXJlIG5vcm1hbGx5IGRpc3RyaWJ1dGVkIChub3JtYWxpdHkgYXNzdW1wdGlvbiBpcyBtZXQpLlxuIyBJZiBwLXZhbHVlIDw9IDAuMDUsIHRoZSByZXNpZHVhbHMgZGV2aWF0ZSBzaWduaWZpY2FudGx5IGZyb20gbm9ybWFsaXR5IChjb25zaWRlciBkYXRhIHRyYW5zZm9ybWF0aW9uIG9yIGRpZmZlcmVudCBtb2RlbCkuXG5cbiMgVGhlIG5vcm1hbGl0eSBvZiByZXNpZHVhbHMgaXMgbW9kZWwtc3BlY2lmaWM7IGRpZmZlcmVudCBtb2RlbHMgbWlnaHQgaGF2ZSBkaWZmZXJlbnQgcmVzaWR1YWwgZGlzdHJpYnV0aW9ucy5cblxuXG5cbiMjIyMjIyMjIyMjIyMjIyBJZiBub3Qgbm9ybWFsLCB1bmRlcnN0YdeeZCB0aGUgc2hhcGUgIyMjIyMjIyMjIyMjI1xucGxvdChkZW5zaXR5KGRhdGFfdGFibGUkY29tcF9hbXApLCBtYWluID0gXCJEZW5zaXR5IG9mIGNvbXBfYW1wXCIsIHhsYWIgPSBcImNvbXBfYW1wXCIpXG5gYGAifQ== -->

```r
# If the Q-Q plot shows points roughly along the reference line, the residuals are approximately normally distributed.
# If the plot of residuals versus fitted values shows no clear pattern (random scatter), homoscedasticity is assumed.

# For the Shapiro-Wilk test:
# If p-value > 0.05, the residuals are normally distributed (normality assumption is met).
# If p-value <= 0.05, the residuals deviate significantly from normality (consider data transformation or different model).

# The normality of residuals is model-specific; different models might have different residual distributions.



############### If not normal, understaמd the shape #############
plot(density(data_table$comp_amp), main = "Density of comp_amp", xlab = "comp_amp")
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbXX0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucGxvdChkZW5zaXR5KHJlc2lkdWFscyhtb2RlbCkpLCBtYWluID0gXCJEZW5zaXR5IG9mIHRoZSBtb2RlbCByZXNpZHVhbHNcIilcblxuYGBgIn0= -->

```r
plot(density(residuals(model)), main = "Density of the model residuals")

```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbXX0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->





<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBEZWZpbmUgZnVuY3Rpb24gdG8gcGVyZm9ybSBhbmFseXNpcyBvbiB0aGUgTE1FIG1vZGVsXG5hbmFseXplX2xtZV9tb2RlbCA8LSBmdW5jdGlvbihsbWVfbW9kZWwpIHtcbiAgIyBTaGFwaXJvLVdpbGsgdGVzdCBmb3Igbm9ybWFsaXR5IG9mIHJlc2lkdWFsc1xuICBwcmludChzaGFwaXJvLnRlc3QocmVzaWR1YWxzKGxtZV9tb2RlbCkpKVxuICBcbiAgIyBGdW5jdGlvbiB0byBleHRyYWN0IHRoZSBmaXhlZCBlZmZlY3RzIGVzdGltYXRlcyBmcm9tIHRoZSBtb2RlbFxuICBmaXhlZF9lZmZlY3RzIDwtIGZ1bmN0aW9uKG1vZGVsKSB7XG4gICAgaWYgKGxlbmd0aChmaXhlZihtb2RlbCkpID09IDApIHtcbiAgICAgIHdhcm5pbmcoXCJObyBmaXhlZCBlZmZlY3RzIGZvdW5kIGluIHRoZSBtb2RlbC5cIilcbiAgICAgIHJldHVybihOVUxMKVxuICAgIH1cbiAgICBmaXhlZihtb2RlbClcbiAgfVxuICBcbiAgIyBTZXQgdXAgcGFyYWxsZWwgYmFja2VuZCB0byB1c2UgbXVsdGlwbGUgcHJvY2Vzc29yc1xuICBuX2NvcmVzIDwtIGRldGVjdENvcmVzKCkgLSAxICAjIFVzZSBvbmUgbGVzcyBjb3JlIHRoYW4gYXZhaWxhYmxlXG4gIHNldC5zZWVkKDEyMylcbiAgXG4gICMgUGVyZm9ybSBwYXJhbWV0cmljIGJvb3RzdHJhcHBpbmcgdXNpbmcgYm9vdE1lclxuICB0cnlDYXRjaCh7XG4gICAgYm9vdF9yZXN1bHRzIDwtIGJvb3RNZXIobG1lX21vZGVsLCBcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICBGVU4gPSBmaXhlZF9lZmZlY3RzLCBcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICBuc2ltID0gMTAwMCwgXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgdHlwZSA9IFwicGFyYW1ldHJpY1wiLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgIHBhcmFsbGVsID0gXCJtdWx0aWNvcmVcIiwgXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgbmNwdXMgPSBuX2NvcmVzKVxuICAgIFxuICAgICMgU3VtbWFyaXplIGJvb3RzdHJhcCByZXN1bHRzXG4gICAgcHJpbnQoc3VtbWFyeShib290X3Jlc3VsdHMpKVxuICAgIFxuICAgICMgQ2FsY3VsYXRlIGNvbmZpZGVuY2UgaW50ZXJ2YWxzIGZvciB0aGUgZml4ZWQgZWZmZWN0c1xuICAgIGNvbmZfaW50ZXJ2YWxzIDwtIGNvbmZpbnQoYm9vdF9yZXN1bHRzLCBtZXRob2QgPSBcImJvb3RcIiwgYm9vdC50eXBlID0gXCJwZXJjXCIpXG4gICAgcHJpbnQoY29uZl9pbnRlcnZhbHMpXG4gIH0sIGVycm9yID0gZnVuY3Rpb24oZSkge1xuICAgIGNhdChcIkVycm9yIGR1cmluZyBib290c3RyYXBwaW5nOiBcIiwgZSRtZXNzYWdlLCBcIlxcblwiKVxuICB9KVxufVxuXG5gYGAifQ== -->

```r
# Define function to perform analysis on the LME model
analyze_lme_model <- function(lme_model) {
  # Shapiro-Wilk test for normality of residuals
  print(shapiro.test(residuals(lme_model)))
  
  # Function to extract the fixed effects estimates from the model
  fixed_effects <- function(model) {
    if (length(fixef(model)) == 0) {
      warning("No fixed effects found in the model.")
      return(NULL)
    }
    fixef(model)
  }
  
  # Set up parallel backend to use multiple processors
  n_cores <- detectCores() - 1  # Use one less core than available
  set.seed(123)
  
  # Perform parametric bootstrapping using bootMer
  tryCatch({
    boot_results <- bootMer(lme_model, 
                            FUN = fixed_effects, 
                            nsim = 1000, 
                            type = "parametric",
                            parallel = "multicore", 
                            ncpus = n_cores)
    
    # Summarize bootstrap results
    print(summary(boot_results))
    
    # Calculate confidence intervals for the fixed effects
    conf_intervals <- confint(boot_results, method = "boot", boot.type = "perc")
    print(conf_intervals)
  }, error = function(e) {
    cat("Error during bootstrapping: ", e$message, "\n")
  })
}

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->




<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyMjIFByZWZvcm0gbW9kZWxpbmdcbnNpbmsob3V0cHV0X2ZpbGVfbmFtZSkgICMgUmVkaXJlY3QgY29uc29sZSBvdXRwdXQgdG8gYSB0ZXh0IGZpbGVcblxuIyBGaXQgdGhlIGxpbmVhciBtaXhlZC1lZmZlY3RzIG1vZGVsc1xubW9kZWxzIDwtIGxpc3QoXG4gIGxtZXIoY29tcF9hbXAgfiAtMSArICgxIHwgc3ViKSwgZGF0YSA9IGRhdGFfdGFibGUpLFxuICBsbWVyKGNvbXBfYW1wIH4gLTEgKyAoMSB8IHN1YiksIGRhdGEgPSBkYXRhX3RhYmxlKSxcbiAgbG1lcihjb21wX2FtcCB+IC0xICsgY29uZCArICgxIHwgc3ViKSwgZGF0YSA9IGRhdGFfdGFibGUsKSxcbiAgbG1lcihjb21wX2FtcCB+IC0xICsgc292ICsgKDEgfCBzdWIpLCBkYXRhID0gZGF0YV90YWJsZSksXG4gIGxtZXIoY29tcF9hbXAgfiAtMSArIHNvdiArIGNvbmQgKyAoMSB8IHN1YiksIGRhdGEgPSBkYXRhX3RhYmxlKSxcbiAgbG1lcihjb21wX2FtcCB+IC0xICsgc292ICogY29uZCArICgxIHwgc3ViKSwgZGF0YSA9IGRhdGFfdGFibGUpXG4pXG5cbiMgTWFudWFsbHkgc3BlY2lmeSBwYWlycyBvZiBtb2RlbHMgdG8gY29tcGFyZVxubW9kZWxfcGFpcnMgPC0gbGlzdChjKDEsIDIpLCBjKDEsIDMpLGMoMiwgMyksIGMoMywgNCksYygyLCA0KSxjKDQsNSkpXG5cbiMgTW9kZWwgbmFtZXMgZm9yIGNsYXJpdHlcbm1vZGVsX25hbWVzIDwtIGMoXCJNb2RlbCAxOiAoMSB8IHN1YilcIixcbiAgICAgICAgICAgICAgICAgXCJNb2RlbCAyOiBjb25kICsgKDEgfCBzdWIpXCIsXG4gICAgICAgICAgICAgICAgIFwiTW9kZWwgMzogc292ICsgKDEgfCBzdWIpXCIsXG4gICAgICAgICAgICAgICAgIFwiTW9kZWwgNDogc292ICsgY29uZCArICgxIHwgc3ViKVwiLFxuICAgICAgICAgICAgICAgICBcIk1vZGVsIDU6IHNvdiAqIGNvbmQgKyAoMSB8IHN1YilcIilcblxuXG4jIFByaW50IG1vZGVscyBcbmZvciAoaSBpbiBzZXFfYWxvbmcobW9kZWxzKSkge1xuICBjYXQobW9kZWxfbmFtZXNbaV0sIFwiXFxuXCIpXG4gIHByaW50KG1vZGVsc1tbaV1dKVxuICBjYXQoXCJcXG5cXG5cIilcbiAgcHJpbnQoc2hhcGlyby50ZXN0KHJlc2lkdWFscyhtb2RlbHNbW2ldXSkpKVxuICBjYXQoXCJcXG5cXG5cIikgICMgQWRkIHR3byBuZXdsaW5lc1xuICAjIGJvb3RfcmVzdWx0cyA8LSBhbmFseXplX2xtZV9tb2RlbChtb2RlbHNbW2ldXSlcbiAgIyBjYXQoXCJcXG5cXG5cIikgICMgQWRkIHR3byBuZXdsaW5lc1xuICBjYXQoXCI9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cXG5cXG5cIilcbn1cblxuIyBQcmludCBhbm92YSBhbmQgQmF5ZXMgbW9kZWxzIHBhaXIgY29tcGFyaXNvbiByZXN1bHRzIFxuZm9yIChwYWlyIGluIG1vZGVsX3BhaXJzKSB7XG4gIGNhdChcIkFub3ZhIENvbXBhcmluZ1wiLCBtb2RlbF9uYW1lc1twYWlyWzFdXSwgXCJ3aXRoXCIsIG1vZGVsX25hbWVzW3BhaXJbMl1dLCBcIlxcblwiKVxuICBwcmludChhbm92YShtb2RlbHNbW3BhaXJbMV1dXSwgbW9kZWxzW1twYWlyWzJdXV0pKVxuICBjYXQoXCJcXG5cXG5cIilcbiAgY2F0KFwiQmF5ZXMgQ29tcGFyaW5nXCIsIG1vZGVsX25hbWVzW3BhaXJbMV1dLCBcIndpdGhcIiwgbW9kZWxfbmFtZXNbcGFpclsyXV0sIFwiXFxuXCIpXG4gIHByaW50KGJheWVzZmFjdG9yX21vZGVscyhtb2RlbHNbW3BhaXJbMV1dXSwgbW9kZWxzW1twYWlyWzJdXV0pKVxuICBjYXQoXCJcXG5cXG5cIilcbn1cblxuIyBDb21wYXJlIGFsbCBtb2RlbHMgdG9nZXRoZXJcbmNhdChcIkFub3ZhIENvbXBhcmlzb24gb2YgYWxsIG1vZGVsczpcXG5cIilcbnByaW50KHN1bW1hcnkoZG8uY2FsbChhbm92YSwgbW9kZWxzKSkpXG5jYXQoXCJcXG5cXG5CYXllcyBDb21wYXJpc29uIG9mIGFsbCBtb2RlbHM6XFxuXCIpXG5wcmludChzdW1tYXJ5KGRvLmNhbGwoYmF5ZXNmYWN0b3JfbW9kZWxzLCBtb2RlbHMpKSlcbmNhdChcIlxcblxcblwiKVxuXG4jIHN0b3AgcmVkaXJlY3Rpbmcgb3V0cHV0XG5zaW5rKClcblxuYGBgIn0= -->

```r
### Preform modeling
sink(output_file_name)  # Redirect console output to a text file

# Fit the linear mixed-effects models
models <- list(
  lmer(comp_amp ~ -1 + (1 | sub), data = data_table),
  lmer(comp_amp ~ -1 + (1 | sub), data = data_table),
  lmer(comp_amp ~ -1 + cond + (1 | sub), data = data_table,),
  lmer(comp_amp ~ -1 + sov + (1 | sub), data = data_table),
  lmer(comp_amp ~ -1 + sov + cond + (1 | sub), data = data_table),
  lmer(comp_amp ~ -1 + sov * cond + (1 | sub), data = data_table)
)

# Manually specify pairs of models to compare
model_pairs <- list(c(1, 2), c(1, 3),c(2, 3), c(3, 4),c(2, 4),c(4,5))

# Model names for clarity
model_names <- c("Model 1: (1 | sub)",
                 "Model 2: cond + (1 | sub)",
                 "Model 3: sov + (1 | sub)",
                 "Model 4: sov + cond + (1 | sub)",
                 "Model 5: sov * cond + (1 | sub)")


# Print models 
for (i in seq_along(models)) {
  cat(model_names[i], "\n")
  print(models[[i]])
  cat("\n\n")
  print(shapiro.test(residuals(models[[i]])))
  cat("\n\n")  # Add two newlines
  # boot_results <- analyze_lme_model(models[[i]])
  # cat("\n\n")  # Add two newlines
  cat("=================================\n\n")
}

# Print anova and Bayes models pair comparison results 
for (pair in model_pairs) {
  cat("Anova Comparing", model_names[pair[1]], "with", model_names[pair[2]], "\n")
  print(anova(models[[pair[1]]], models[[pair[2]]]))
  cat("\n\n")
  cat("Bayes Comparing", model_names[pair[1]], "with", model_names[pair[2]], "\n")
  print(bayesfactor_models(models[[pair[1]]], models[[pair[2]]]))
  cat("\n\n")
}

# Compare all models together
cat("Anova Comparison of all models:\n")
print(summary(do.call(anova, models)))
cat("\n\nBayes Comparison of all models:\n")
print(summary(do.call(bayesfactor_models, models)))
cat("\n\n")

# stop redirecting output
sink()

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->



<!-- rnb-chunk-end -->

