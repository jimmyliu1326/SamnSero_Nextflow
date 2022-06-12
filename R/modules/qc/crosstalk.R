data <- SharedData$new(combined_res)
sistr_data <- SharedData$new(sistr_df, group = data$groupName())
stats_data <- SharedData$new(stats_df, group = data$groupName())
kreport_summary_data <- SharedData$new(kreport_summary, group = data$groupName())