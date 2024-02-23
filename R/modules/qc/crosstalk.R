# create shared data objects for html widget crosstalk
data <- SharedData$new(combined_res, key = ~id)
sistr_data <- SharedData$new(sistr_df, key = ~id, data$groupName())
stats_data <- SharedData$new(stats_df, key = ~id, data$groupName())
kreport_summary_data <- SharedData$new(kreport_summary, ~id, data$groupName())
# create shared timepoint object if permitted
if (rt) { tp_SharedData <- SharedData$new(tp_data) }
