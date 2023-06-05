#
# Copyright 2023 Erwan Mahe (github.com/erwanM974)
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

rm(list=ls())
# ==============================================
library(ggplot2)
library(scales)
# ==============================================

# ==============================================
read_ana_report <- function(file_path) {
  # ===
  report <- read.table(file=file_path, 
                       header = FALSE, 
                       sep = ";",
                       blank.lines.skip = TRUE, 
                       fill = TRUE)
  
  names(report) <- as.matrix(report[1, ])
  report <- report[-1, ]
  report[] <- lapply(report, function(x) type.convert(as.character(x)))
  report
}
# ==============================================

# ==============================================
prepare_ana_data <- function(mydata) {
  mydata <- data.frame( mydata )
  #
  print( sprintf("number of times the timeout is exceeded : %d",
                 nrow(mydata[mydata$hibou_verdict == "TIMEOUT",])) )
  #
  mydata$hibou_verdict[mydata$hibou_verdict=="WeakPass"]<-"Pass"
  mydata$hibou_verdict[mydata$hibou_verdict=="WeakFail"]<-"Fail"
  mydata$hibou_verdict[mydata$hibou_verdict=="Fail"]<-"Fail"
  mydata$hibou_verdict <- as.factor(mydata$hibou_verdict)
  #
  mydata$trace_length <- as.integer(mydata$trace_length)
  mydata$nfa_verdict <- as.factor(mydata$nfa_verdict)
  #
  print( sprintf("number of ACCEPTED : %d", nrow(mydata[mydata$kind == "ACP",])) )
  print( sprintf("number of ERROR : %d", nrow(mydata[mydata$kind == "ERR",])) )
  #
  mydata$kind <- as.factor(mydata$kind)
  mydata$kind <- factor(mydata$kind, # Reordering group factor levels
                         levels = c("ACP", "ERR"))
  #
  mydata$hibou_time_median <- as.double(mydata$hibou_time_median)
  mydata$nfa_time_median <- as.double(mydata$nfa_time_median)
  #
  mydata$nfa_rateR <- mydata$nfa_time_median / mydata$trace_length
  mydata$hibou_rateR <- mydata$hibou_time_median / mydata$trace_length
  mydata
}
# ==============================================


# ==============================================
geom_ptsize = 1
geom_stroke = 1
geom_shape = 19
# ===
draw_scatter_splot <- function(report_data,plot_title,is_log_scale,has_jitter) {
  g <- ggplot(data=report_data)
  # 
  if (has_jitter) {
    g <- g + geom_point(aes(x = trace_length, y = hibou_time_median),
                        size = geom_ptsize, 
                        stroke = geom_stroke, 
                        shape = geom_shape,
                        colour = "#1C1CD1",
                        position = position_jitter(w = 0.5, h = 0)) +
      geom_point(aes(x = trace_length, y = nfa_time_median),
                 size = geom_ptsize, 
                 stroke = geom_stroke, 
                 shape = geom_shape,
                 colour = "#117B32",
                 position = position_jitter(w = 0.5, h = 0)) 
  } else {
    g <- g + geom_point(aes(x = trace_length, y = hibou_time_median),
                        size = geom_ptsize, 
                        stroke = geom_stroke, 
                        shape = geom_shape,
                        colour = "#1C1CD1") +
      geom_point(aes(x = trace_length, y = nfa_time_median),
                 size = geom_ptsize, 
                 stroke = geom_stroke, 
                 shape = geom_shape,
                 colour = "#117B32")
  }
  #
  if (is_log_scale) {
    g <- g + scale_y_continuous(trans='log10') +
      labs(x = "trace length", y = "time (log scale)")
  } else {
    g <- g + labs(x = "trace length", y = "time")
  }
  g + ggtitle(plot_title)
}

# ==============================================

print_scatter_plot <- function(report_data,plot_title,file_name,is_log_scale,has_jitter) {
  bench_plot <- draw_scatter_splot(report_data,plot_title,is_log_scale,has_jitter)
  
  plot_file_name <- paste(gsub(" ", "_", file_name), "png", sep=".")
  
  ggsave(plot_file_name, bench_plot, width = 6000, height = 2750, units = "px")
}

# ==============================================
treat_benchmark_data <- function(folder_path,benchmark_name,is_log_scale,has_jitter) {
  print("")
  print(benchmark_name)
  
  file_path <- paste(folder_path, benchmark_name, ".csv", sep="")

  bench_data <- read_ana_report(file_path)
  bench_data <- prepare_ana_data(bench_data)
  
  print("hibou time")
  print(summary(bench_data$hibou_time_median))
  print(sd(bench_data$hibou_time_median))
  print("hibou mean rate ACP")
  print(mean(bench_data[bench_data$kind == "ACP",]$hibou_rateR) )
  print(mean(bench_data[bench_data$kind == "ACP",]$hibou_rate) )
  print(1.0 / mean(bench_data[bench_data$kind == "ACP",]$hibou_rateR) )
  print("hibou mean rate ERR")
  print(mean(bench_data[bench_data$kind == "ERR",]$hibou_rateR) )
  print(mean(bench_data[bench_data$kind == "ERR",]$hibou_rate) )
  print(1.0 / mean(bench_data[bench_data$kind == "ERR",]$hibou_rateR) )
  print("")
  
  print("nfa time")
  print(summary(bench_data$nfa_time_median))
  print(sd(bench_data$nfa_time_median))
  print("nfa mean rate ACP")
  print(mean(bench_data[bench_data$kind == "ACP",]$nfa_rateR) )
  print(mean(bench_data[bench_data$kind == "ACP",]$nfa_rate) )
  print(1.0 / mean(bench_data[bench_data$kind == "ACP",]$nfa_rateR) )
  print("nfa mean rate ERR")
  print(mean(bench_data[bench_data$kind == "ERR",]$nfa_rateR) )
  print(mean(bench_data[bench_data$kind == "ERR",]$nfa_rate) )
  print(1.0 / mean(bench_data[bench_data$kind == "ERR",]$nfa_rateR) )
  print("")
  
  if (is_log_scale) {
    benchmark_name <- paste(benchmark_name, "log", sep = " ")
  }
  
  acc <- bench_data[bench_data$kind == "ACP",]
  print_scatter_plot(
    acc,
    paste(benchmark_name, "accepted traces", sep = " "),
    paste(benchmark_name, "acp", sep="_"),
    is_log_scale,has_jitter)
  
  slic <- bench_data[bench_data$kind == "ERR",]
  print_scatter_plot(
    slic,
    paste(benchmark_name, "error traces", sep = " "),
    paste(benchmark_name, "err", sep="_"),
    is_log_scale,has_jitter)

}
# ==============================================

parent_folder <- "C:/Users/ErwanMahe/PyCharmProjects/hibou_nfa_trace_analysis/"
treat_benchmark_data(parent_folder,"abp",TRUE,TRUE)
treat_benchmark_data(parent_folder,"rover",TRUE,TRUE)
treat_benchmark_data(parent_folder,"hr",TRUE,TRUE)




