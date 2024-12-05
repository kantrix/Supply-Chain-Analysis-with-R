# Install necessary packages if not already installed
install.packages(c("tidyverse", "skimr", "corrplot", "maps", "ggmap"))
install.packages("gridExtra")
install.packages("plotly")


# Load libraries
library(tidyverse)  # For data manipulation and visualization
library(skimr)      # For quick summary statistics
library(corrplot)   # For correlation matrix
library(scales)  # Load scales package for number formatting
library(plotly)


options(repr.plot.width = 16, repr.plot.height = 12)
options(warn=-1)

FILL_COLOR <- "#1E3E62"

# List all files in the directory
list.files("/kaggle/input/dataco-smart-supply-chain-for-big-data-analysis")

# Reading a CSV file from the directory
data <- read.csv("/kaggle/input/dataco-smart-supply-chain-for-big-data-analysis/DataCoSupplyChainDataset.csv")

# View the first few rows of the data
head(data)

tail(data)

glimpse(data)

df = tibble(data)

head(df)

summary(df)

# Total number of missing values in the dataset
sum(is.na(df))

# Count missing values column-wise
colSums(is.na(df))

print(sum(df$Order.Profit.Per.Order == df$Benefit.per.order))
print(sum(df$Sales == df$Product.Price))
print(sum(df$Order.Item.Product.Price == df$Product.Price))
print(sum(df$Sales.per.customer == df$Order.Item.Total))
print(sum(df$Sales.per.customer == df$Product.Price))

# we can also use cor()
cor(df$Order.Profit.Per.Order, df$Benefit.per.order)
cor(df$Sales, df$Product.Price)

# Remove useless columns
df <- df |>
select(-Customer.Email,
       -Customer.Password,
       -Product.Image,
       -Category.Id,
       -Customer.Fname,
       -Customer.Lname,
       -Customer.Zipcode,
       -Department.Id,
       -Order.Customer.Id,
       -Customer.Id,
       -Order.Id,
       -Order.Item.Cardprod.Id,
       -Order.Item.Id,
       -Order.Zipcode,
       -Product.Card.Id,
       -Product.Category.Id,
       -Product.Description,
       -Order.Item.Product.Price,
       -Order.Item.Total,
       -Benefit.per.order)

glimpse(df)

sum(is.na(df))

# Count missing values column-wise
colSums(is.na(df))

# Identify duplicate
duplicates <- duplicated(df)

# View duplicate
df[duplicates, ]

# Count the number of duplicate
sum(duplicates)

# Removing duplicates if any
df <- distinct(df)

# Convert date columns and calculate shipping duration
df$order_date <- mdy_hms(df$order.date..DateOrders.)
df$shipping_date <- mdy_hms(df$shipping.date..DateOrders.)

# Calculate shipping duration
df$shipping_duration <- as.numeric(difftime(df$shipping_date, df$order_date, units = "days"))

# Summary statistics of shipping duration
summary(df$shipping_duration)

# Find rows with negative or NA shipping durations
anomalies <- df %>% filter(is.na(shipping_duration) | shipping_duration < 0)
print(anomalies)

# Load ggplot2 for visualization
library(ggplot2)

# Histogram of shipping duration
ggplot(df, aes(x = shipping_duration)) +
  geom_histogram(binwidth = 1, fill = "blue", color = "black", alpha = 0.7) +
  labs(title = "Distribution of Shipping Duration", x = "Shipping Duration (days)", y = "Frequency") +
  theme_minimal()

# Boxplot of shipping duration
ggplot(df, aes(y = shipping_duration)) +
  geom_boxplot(fill = "orange", color = "black") +
  labs(title = "Boxplot of Shipping Duration", y = "Shipping Duration (days)") +
  theme_minimal()

# Average shipping duration by region
region_shipping <- df %>%
  group_by(Order.Region) %>%
  summarise(avg_shipping_duration = mean(shipping_duration, na.rm = TRUE))

print(region_shipping)

# Plot average shipping duration by region
ggplot(region_shipping, aes(x = reorder(Order.Region, avg_shipping_duration), y = avg_shipping_duration)) +
  geom_bar(stat = "identity", fill = "purple", color = "black") +
  labs(title = "Average Shipping Duration by Region", x = "Region", y = "Average Shipping Duration (days)") +
  theme_minimal() +
  coord_flip()

# Convert Product.Status to a factor for better labeling in the plot
df$Product.Status <- factor(df$Product.Status, levels = c(0, 1), labels = c("Available", "Not Available"))

# Summary of transaction types
type_summary <- df %>%
  group_by(Type) %>%
  summarise(count = n()) %>%
  mutate(percentage = round((count / sum(count)) * 100, 2))

print(type_summary)

# Bar plot for transaction types
ggplot(type_summary, aes(x = reorder(Type, -count), y = count, fill = Type)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  labs(title = "Distribution of Transaction Types", x = "Transaction Type", y = "Count") +
  theme_minimal()

# Summary of delivery status
delivery_status_summary <- df %>%
  group_by(Delivery.Status) %>%
  summarise(count = n()) %>%
  mutate(percentage = round((count / sum(count)) * 100, 2))

print(delivery_status_summary)

# Bar plot for delivery status
ggplot(delivery_status_summary, aes(x = reorder(Delivery.Status, -count), y = count, fill = Delivery.Status)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  labs(title = "Distribution of Delivery Status", x = "Delivery Status", y = "Count") +
  theme_minimal()


# Summary of shipping modes
shipping_mode_summary <- data %>%
  group_by(Shipping.Mode) %>%
  summarise(count = n()) %>%
  mutate(percentage = round((count / sum(count)) * 100, 2))

print(shipping_mode_summary)

# Bar plot for shipping modes
ggplot(shipping_mode_summary, aes(x = reorder(Shipping.Mode, -count), y = count, fill = Shipping.Mode)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  labs(title = "Distribution of Shipping Modes", x = "Shipping Mode", y = "Count") +
  theme_minimal()

# Summary statistics for numeric variables
df %>%
  select(Order.Profit.Per.Order, Sales.per.customer, Order.Item.Discount) %>%
  summary()

library(gridExtra)

# Selecting the numeric columns from the dataset
numeric_vars <- data %>% 
  select(Days.for.shipping..real., Days.for.shipment..scheduled., Benefit.per.order, 
         Sales.per.customer, Order.Item.Discount, Order.Item.Discount.Rate, 
         Order.Item.Product.Price, Order.Item.Profit.Ratio, Order.Item.Quantity, 
         Sales, Order.Item.Total, Order.Profit.Per.Order)

# Create a list to store histogram plots
hist_plots <- list()

# Loop through numeric variables and create histograms
for (var in colnames(numeric_vars)) {
  hist_plots[[var]] <- ggplot(data, aes_string(x = var)) +
    geom_density(fill = FILL_COLOR, alpha = 0.8) +
    labs(x = var,
         y = "Count") +
    theme_minimal(base_size = 14) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
          axis.title.x = element_text(face = "bold"),
          axis.title.y = element_text(face = "bold"),
          axis.text = element_text(color = "black"))
}

# Arrange histograms side by side
grid.arrange(grobs = hist_plots, ncol = 2)  # Change ncol to adjust the number of columns

# Select numeric columns
numeric_cols <- df %>%
select_if(is.numeric)

# compute the correlation matrix
cor_matrix <- cor(numeric_cols, use="complete.obs")

# plot the correlation matrix
corrplot(cor_matrix,method ="color", type = "upper", t1.cex = 0.8) 

# Summarizing late deliveries by category
category_late_deliveries <- df %>%
  group_by(Category.Name) %>%
  summarise(late_count = sum(Late_delivery_risk == 1, na.rm = TRUE))

# Plotting the data with a heatmap effect
ggplot(category_late_deliveries, aes(x = reorder(Category.Name, -late_count), y = late_count, fill = late_count)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = late_count), vjust = -0.5, size = 3) +  # Adjust text size
  labs(title = "Late Deliveries by Product Category", 
       y = "Number of Late Deliveries", 
       x = "Category Name") +
  scale_fill_gradient(low = "#AEC6CF", high = "#1E3E62") +  # Heatmap effect with gradient
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  # Rotate x-axis labels
  theme(legend.position = "none")

# Summarizing average sales by country
sales_by_country <- df %>%
  group_by(Customer.Country) %>%
  summarise(avg_sales = mean(Sales.per.customer, na.rm = TRUE))

# Plotting the data with a heatmap effect
ggplot(sales_by_country, aes(x = reorder(Customer.Country, -avg_sales), y = avg_sales, fill = avg_sales)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(avg_sales, 2)), vjust = -0.5) +
  labs(title = "Average Sales per Customer by Country", y = "Average Sales", x = "Customer Country") +
  scale_fill_gradient(low = "#AEC6CF", high = "#1E3E62") +  # Heatmap effect with gradient
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme_minimal() +
  theme(legend.position = "none")

# Create the customer_profit dataframe
customer_profit <- df %>%
  group_by(Customer.Segment) %>%
  summarise(total_profit = sum(Order.Profit.Per.Order, na.rm = TRUE))

# Plot with a heatmap effect using a gradient
ggplot(customer_profit, aes(x = Customer.Segment, y = total_profit, fill = total_profit)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = paste("$", round(total_profit, 2), sep='')), vjust = -0.5) +
  labs(title = "Total Profit by Customer Segment", y = "Total Profit", x = "Customer Segment") +
  scale_fill_gradient(low = "#AEC6CF", high = "#1E3E62") +  # Heatmap effect with gradient
  theme_minimal()

## Summarizing average sales by customer segment
segment_sales <- df %>%
  group_by(Customer.Segment) %>%
  summarise(avg_sales = mean(Sales.per.customer, na.rm = TRUE))

# Plotting the data with a heatmap effect
ggplot(segment_sales, aes(x = Customer.Segment, y = avg_sales, fill = avg_sales)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(avg_sales, 2)), vjust = -0.5) +
  labs(title = "Average Sales per Customer by Segment", y = "", x = "") +
  scale_fill_gradient(low = "#AEC6CF", high = "#1E3E62") +  # Heatmap effect with gradient
  theme_minimal() +
  theme(axis.text.x = element_text(hjust = 1, size = 15)) +
  theme(legend.position = "none")

# Step 1: Create a conversion table for state abbreviations and full names
state_abbreviations <- data.frame(
  state = tolower(c(state.name, "puerto rico")),  # Add "Puerto Rico" to U.S. state names
  abb = c(state.abb, "PR")  # Add "PR" abbreviation for Puerto Rico
)

# Step 2: Summarizing average sales per customer by state
# Merge the conversion table with your data to get full state names
state_sales <- df %>%
  left_join(state_abbreviations, by = c("Customer.State" = "abb")) %>%  # Convert abbreviations to full names
  group_by(state) %>%  # Group by the full state name now
  summarise(avg_sales = mean(Sales.per.customer, na.rm = TRUE)) %>%
  arrange(desc(avg_sales))  # Order states by average sales

# Step 3: Create a lollipop chart
ggplot(state_sales, aes(x = reorder(state, avg_sales), y = avg_sales)) +
  geom_segment(aes(x = reorder(state, avg_sales), xend = reorder(state, avg_sales), 
                   y = 0, yend = avg_sales), color = "gray") +  # Lollipop stick
  geom_point(color = FILL_COLOR, size = 4) +  # Lollipop circle
  geom_text(aes(label = round(avg_sales, 2)), hjust = -0.3, size = 3) +  # Add text labels
  labs(title = "Average Sales per Customer by State", y = "Average Sales", x = "State") +
  coord_flip() +  # Flip the chart for better readability
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 8),  # Adjust y-axis text size for readability
    axis.title.x = element_text(size = 10, face = "bold"),  # Bold x-axis title
    axis.title.y = element_text(size = 10, face = "bold"),  # Bold y-axis title
    plot.title = element_text(size = 12, face = "bold", hjust = 0.5)  # Title centered and bold
  )

# Calculate average late delivery risk by customer segment
segment_late_risk <- df %>%
  group_by(Customer.Segment) %>%
  summarise(late_risk = mean(Late_delivery_risk, na.rm = TRUE)) %>%
  ungroup()

# Plotting the average late delivery risk with a heatmap effect
ggplot(segment_late_risk, aes(x = Customer.Segment, y = late_risk, fill = late_risk)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = scales::percent(late_risk, accuracy = 0.01)), vjust = -0.5) +  # Formatting the label as percentage
  labs(title = "Late Delivery Risk by Customer Segment", 
       y = "Average Late Risk (%)",  # Updated y-axis label
       x = "") +
  scale_y_continuous(labels = scales::percent) +  # Formatting y-axis as percentage
  scale_fill_gradient(low = "#AEC6CF", high = "#1E3E62") +  # Heatmap effect with gradient
  theme_minimal() +
  theme(axis.text.x = element_text(hjust = 1, size = 15)) +
  theme(
    legend.position = "none"
  )

# Create a palette based on the base color #1E3E62
base_color <- "#1E3E62"
palette <- colorRampPalette(c(base_color, "#AEC6CF", "#D9EAD3", "#FFE599", "#B6D7A8"))(10)

# Create the top_customers dataframe
top_customers <- df %>%
  group_by(Customer.City) %>%
  summarise(total_profit = sum(Order.Profit.Per.Order, na.rm = TRUE)) %>%
  arrange(desc(total_profit)) %>%
  head(10)

# Plot with a heatmap effect using a gradient
ggplot(top_customers, aes(x = reorder(Customer.City, -total_profit), y = total_profit, fill = total_profit)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(total_profit, 2)), vjust = -0.5) +
  labs(title = "Top 10 Customer Cities by Total Profit", y = "", x = "") +
  scale_fill_gradient(low = "#AEC6CF", high = base_color) +  # Heatmap effect with gradient
  theme_minimal() +
  theme(axis.text.x = element_text(hjust = 0.5, size = 14))

options(repr.plot.width = 20, repr.plot.height = 12)

# Summarize profit by category and limit to top 10
category_profit <- df %>%
  group_by(Category.Name) %>%
  summarize(Total_Profit = sum(Order.Profit.Per.Order, na.rm = TRUE)) %>%
  arrange(desc(Total_Profit)) %>%
  head(10)  # Limit to top 10

# Plot top 10 categories by profit with numbers formatted using scales
ggplot(category_profit, aes(x = reorder(Category.Name, Total_Profit), y = Total_Profit)) +
  geom_bar(stat = "identity", fill = FILL_COLOR) +  # Custom color
  geom_text(aes(label = scales::comma(Total_Profit)), hjust = -0.2, size = 4.5, color = "black") +  # Add numbers
  coord_flip() +
  theme_minimal(base_size = 15) +  # Modern theme with larger text
  labs(title = "Top 10 Categories by Profit",
       x = "", 
       y = "") +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 20),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        axis.text = element_text(color = "black"),
        plot.margin = unit(c(1, 1, 1, 1), "cm"))

options(repr.plot.width = 18, repr.plot.height = 12)

# Summarize total sales by product and limit to top 10
product_sales <- df %>%
  group_by(Product.Name) %>%
  summarize(Total_Sales = sum(Sales, na.rm = TRUE)) %>%
  arrange(desc(Total_Sales)) %>%
  head(10)  # Limit to top 10

# Plot top 10 products by sales with numbers inside bars
ggplot(product_sales, aes(x = reorder(Product.Name, Total_Sales), y = Total_Sales)) +
  geom_bar(stat = "identity", fill = FILL_COLOR) +  # Custom color
  geom_text(aes(label = scales::dollar(Total_Sales, prefix = "$", accuracy = 1)), hjust = 0.9, size = 5.5, color = "white", position = position_stack(vjust = 0.9)) +  # Labels inside bars
  coord_flip() +
  theme_minimal(base_size = 15) +  # Modern theme
  labs(title = "Top 10 Products by Sales",
       x = "", 
       y = "") +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 20),
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold"),
        axis.text = element_text(color = "black"),
        plot.margin = unit(c(1, 1, 1, 1), "cm"))

library(leaflet)
library(htmltools)

# Step 1: Prepare the customer location data
location_data <- df %>%
  select(Customer.City, Customer.Country, Latitude, Longitude, Order.Profit.Per.Order) %>%
  group_by(Customer.City, Customer.Country, Latitude, Longitude) %>%
  summarize(Total_Profit = sum(Order.Profit.Per.Order, na.rm = TRUE)) %>%
  ungroup()

# Step 2: Create a color palette based on profit bins
mybins <- quantile(location_data$Total_Profit, probs = seq(0, 1, by = 0.2), na.rm = TRUE)
mypalette <- colorBin(palette = "YlOrBr", domain = location_data$Total_Profit, na.color = "transparent", bins = mybins)

# Step 3: Prepare the text for tooltips
mytext <- paste0(
  "<strong>City: </strong>", location_data$Customer.City, "<br/>",
  "<strong>Country: </strong>", location_data$Customer.Country, "<br/>",
  "<strong>Total Profit: </strong>$", round(location_data$Total_Profit, 2)
) %>% lapply(htmltools::HTML)

# Step 4: Create the leaflet map
interactive_map <- leaflet(location_data) %>%
  addTiles() %>%
  setView(lat = mean(location_data$Latitude, na.rm = TRUE), 
          lng = mean(location_data$Longitude, na.rm = TRUE), 
          zoom = 2) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addCircleMarkers(~Longitude, ~Latitude,
    fillColor = ~mypalette(Total_Profit), fillOpacity = 0.7, color = "white", radius = 8, stroke = FALSE,
    label = mytext,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "13px", direction = "auto"
    )
  ) %>%
  addLegend(
    pal = mypalette, values = ~Total_Profit,
    opacity = 0.9, title = "Total Profit",
    position = "bottomright"
  )

# Step 5: Display the interactive map
interactive_map

# Group by Product Name and calculate total quantity
top_products <- df %>%
  group_by(Product.Name) %>%
  summarise(Total.Quantity = sum(Order.Item.Quantity, na.rm = TRUE)) %>%  # Handle NA values in Quantity
  arrange(desc(Total.Quantity)) %>%
  slice_head(n = 10)  # Use slice_head() instead of head() for consistency with dplyr syntax

# Create a bar plot using ggplot2
ggplot(top_products, aes(x = reorder(Product.Name, Total.Quantity), y = Total.Quantity)) +
  geom_bar(stat = "identity", fill = FILL_COLOR) +  # Bar color
  geom_text(aes(label = Total.Quantity), hjust = -0.1, size = 5, color = "black") +  # Add labels outside bars
  coord_flip() +  # Flip coordinates for better readability
  labs(
    title = "Top 10 Products by Quantity Ordered",
    x = "Product Name",
    y = "Total Quantity Ordered"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),  # Center-align title
    axis.text.y = element_text(size = 10),  # Adjust y-axis text size
    axis.text.x = element_text(size = 10),  # Adjust x-axis text size
    axis.title = element_text(size = 12)   # Adjust axis title size
  )

# Define fill color for the bar plot
FILL_COLOR <- "firebrick"

# Group by Product Name and calculate late delivery statistics
top_risk_products <- df %>%
  group_by(Product.Name) %>%
  summarise(
    Total.Orders = n(),
    Late.Orders = sum(Late_delivery_risk, na.rm = TRUE)  # Handle potential NA values in Late_delivery_risk
  ) %>%
  mutate(Percent.Late.Risk = (Late.Orders / Total.Orders) * 100) %>%
  arrange(desc(Percent.Late.Risk)) %>%
  slice_head(n = 10)  # Select top 10 products

# Visualize the top products with late delivery risk percentages
ggplot(top_risk_products, aes(x = reorder(Product.Name, Percent.Late.Risk), y = Percent.Late.Risk)) +
  geom_bar(stat = "identity", fill = FILL_COLOR, width = 0.7) +  # Add width for better bar spacing
  geom_text(
    aes(label = paste0(round(Percent.Late.Risk, 1), "%")),
    hjust = -0.2, size = 5, color = "black"
  ) +  # Show percentage labels outside the bars
  coord_flip() +  # Flip coordinates for better readability
  labs(
    title = "Top 10 Products with Highest Late Delivery Risk",
    x = "Product Name",
    y = "Late Delivery Risk (%)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    axis.title.x = element_text(size = 12, face = "bold"),
    axis.title.y = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),
    plot.margin = unit(c(1, 1, 1, 1), "cm")  # Ensure enough margin for labels
  )

# Define the color for the bars
FILL_COLOR <- "steelblue"

# Filter data for valid shipping durations
filtered_df <- df %>% 
  filter(shipping_duration >= 0)  # Exclude negative durations, if any

# Calculate the average shipping duration by product
top_shipping_duration <- filtered_df %>%
  group_by(Product.Name) %>%
  summarise(Avg.Shipping.Duration = mean(shipping_duration, na.rm = TRUE)) %>%  # Handle NA values
  arrange(desc(Avg.Shipping.Duration)) %>%  # Sort by highest average shipping duration
  slice_head(n = 10)  # Select the top 10 products

# Visualize the average shipping duration for the top products
ggplot(top_shipping_duration, aes(x = reorder(Product.Name, Avg.Shipping.Duration), y = Avg.Shipping.Duration)) +
  geom_bar(stat = "identity", fill = FILL_COLOR, width = 0.7) +  # Adjust bar width
  geom_text(
    aes(label = round(Avg.Shipping.Duration, 1)), 
    hjust = -0.2, size = 5, color = "black"
  ) +  # Add average shipping duration as labels
  coord_flip() +  # Flip coordinates for better readability
  labs(
    title = "Average Shipping Duration (Days) for Top 10 Products",
    x = "Product Name",
    y = "Average Shipping Duration (Days)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10),
    plot.margin = unit(c(1, 1, 1, 1), "cm")  # Ensure proper margins
  )

# Boxplot of Sales by Product Status
ggplot(df, aes(x = Product.Status, y = Sales)) +
  geom_boxplot(fill = "lightblue", outlier.color = "red", outlier.shape = 16, outlier.size = 3) +
  
  # Add median labels with improved alignment
  stat_summary(
    fun = median, 
    geom = "text", 
    aes(label = paste("Median:", round(..y.., 2))),
    position = position_nudge(x = 0.25), 
    size = 6, 
    color = "#FF6600", 
    fontface = "bold"
  ) +
  
  # Add mean labels for each box
  stat_summary(
    fun = mean, 
    geom = "text", 
    aes(label = paste("Mean:", round(..y.., 2))),
    position = position_nudge(x = -0.25), 
    size = 6, 
    color = "#A04747", 
    fontface = "bold"
  ) +
  
  # Add whisker labels (min and max values)
  stat_summary(
    fun.min = min, 
    fun.max = max, 
    geom = "text",
    aes(label = round(..y.., 2)),
    position = position_nudge(x = 0.35), 
    size = 5, 
    color = "blue", 
    fontface = "italic"
  ) +
  
  # Titles and labels
  labs(
    title = "Distribution of Sales by Product Status",
    subtitle = "Median, Mean, and Range Indicated",
    x = "Product Status",
    y = "Sales"
  ) +
  
  # Enhanced theme for better visualization
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold", size = 20, hjust = 0.5),
    plot.subtitle = element_text(size = 14, hjust = 0.5),
    axis.title.x = element_text(face = "bold", size = 14),
    axis.title.y = element_text(face = "bold", size = 14),
    axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
    axis.text.y = element_text(size = 12),
    plot.margin = unit(c(1, 1, 1, 1), "cm")
  )

region_summary <- df %>%
  group_by(Order.Region) %>%
  summarise(
    Total_Sales = sum(Sales, na.rm = TRUE),
    Avg_Profit_Per_Order = mean(Order.Profit.Per.Order, na.rm = TRUE),
    Total_Late_Delivery_Risk = sum(Late_delivery_risk, na.rm = TRUE)
  )

# View the summary table
region_summary

# Bar Plot for Total Sales by Region
ggplot(region_summary, aes(x = reorder(Order.Region, -Total_Sales), y = Total_Sales, fill = Total_Sales)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = label_number(scale = 1e-6, suffix = "M")(Total_Sales)), 
            vjust = -0.5, size = 4.5, color = "black") + 
  scale_fill_gradient(low = "#AEC6CF", high = "#FF5733") +  # Gradient color for sales
  scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M")) +
  labs(
    title = "Total Sales by Region",
    x = "",
    y = "Total Sales (in Millions)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    legend.position = "none"
  )

# Boxplot for Profit Distribution by Region
ggplot(df, aes(x = reorder(Order.Region, Order.Profit.Per.Order, FUN = median), 
               y = Order.Profit.Per.Order, fill = Order.Region)) +
  geom_boxplot(outlier.colour = "red", outlier.shape = 16, outlier.size = 2) +
  scale_fill_brewer(palette = "Set3") +  # Use a better color palette
  labs(
    title = "Profit Distribution by Region",
    x = "Region",
    y = "Profit Per Order"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    legend.position = "none"
  )

# Grouping the data by region and calculating positive and negative profits
profit_summary <- df %>%
  group_by(Order.Region) %>%
  summarise(
    Positive_Profit = sum(Order.Profit.Per.Order[Order.Profit.Per.Order > 0], na.rm = TRUE),
    Negative_Profit = sum(Order.Profit.Per.Order[Order.Profit.Per.Order < 0], na.rm = TRUE)
  )

# Reshaping the data for plotting
profit_long <- profit_summary %>%
  pivot_longer(cols = c(Positive_Profit, Negative_Profit), names_to = "Profit_Type", values_to = "Amount")

# Creating the interactive bar plot
library(plotly)

fig <- plot_ly(profit_long, x = ~Order.Region, y = ~Amount, color = ~Profit_Type, type = 'bar', 
               text = ~Amount, textposition = 'auto') %>%
  layout(
    title = 'Positive and Negative Profits by Region',
    xaxis = list(title = 'Region', tickangle = -45),
    yaxis = list(title = 'Profit Amount'),
    barmode = 'stack',  # Stacked bars for clear comparison
    showlegend = TRUE
  )

# Display the interactive plot
fig

# Summarize the total late delivery risk by region
region_summary <- df %>%
  group_by(Order.Region) %>%
  summarise(Total_Late_Delivery_Risk = sum(Late_delivery_risk, na.rm = TRUE))

# Calculate the total late delivery risk for all regions
total_risk <- sum(region_summary$Total_Late_Delivery_Risk)

# Calculate percentage late delivery risk for each region
region_summary <- region_summary %>%
  mutate(Percentage_Late_Delivery_Risk = (Total_Late_Delivery_Risk / total_risk) * 100)

# Visualize the Late Delivery Risk by Region
ggplot(region_summary, aes(x = reorder(Order.Region, -Percentage_Late_Delivery_Risk), 
                            y = Percentage_Late_Delivery_Risk, 
                            fill = Percentage_Late_Delivery_Risk)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = label_percent(accuracy = 0.1)(Percentage_Late_Delivery_Risk / 100)), 
            hjust = 0.5, vjust = -1.8, size = 4.5, color = "black") +  # Add percentage labels on top of bars
  scale_fill_gradient(low = "#AEC6CF", high = "darkorange") +  # Color gradient for better visual
  scale_y_continuous(labels = label_percent(scale = 1)) +  # Format the y-axis as percentages
  theme_minimal() + 
  labs(title = "Total Late Delivery Risk by Region", 
       x = "Region", 
       y = "Late Delivery Risk (%)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 0))  # Rotate x-axis labels for better readability

# Boxplot for the distribution of sales by delivery status
ggplot(df, aes(x = Delivery.Status, y = Sales)) +
  geom_boxplot(fill = "skyblue", color = "darkblue", outlier.colour = "red", outlier.size = 3) +  # Improved outlier visibility
  labs(title = "Distribution of Sales by Delivery Status", 
       x = "Delivery Status", 
       y = "Sales") +
  theme_minimal(base_size = 15) +  # Increased font size for better readability
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Adjusted angle and font size for axis labels
        axis.title.x = element_text(size = 14, face = "bold"),
        axis.title.y = element_text(size = 14, face = "bold"))  # Bold axis titles for emphasis

# Boxplot for the distribution of sales by delivery status and department
ggplot(df, aes(x = Delivery.Status, y = Sales, fill = Department.Name)) +
  geom_boxplot(outlier.colour = "red", position = position_dodge(0.8), 
               outlier.size = 3,  # Enhance visibility of outliers
               lwd = 0.8, color = "darkblue") +  # Added outline color for boxplot for better contrast
  labs(title = "Distribution of Sales by Delivery Status and Department",
       x = "Delivery Status", 
       y = "Sales") +
  theme_minimal(base_size = 16) +  # Larger base font for better readability
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Rotate x-axis labels for readability
        axis.title.x = element_text(size = 14, face = "bold"),
        axis.title.y = element_text(size = 14, face = "bold"),
        legend.title = element_text(size = 14, face = "bold"),
        legend.text = element_text(size = 12)) +  # Styled legend text
  scale_fill_brewer(palette = "Set3")  # Added color palette for better visualization

# Calculate the mean Profit Ratio per Department
department_profit_ratio <- df %>%
  group_by(Department.Name) %>%
  summarise(profit_ratio = mean(Order.Item.Profit.Ratio, na.rm = TRUE))  # Calculate mean Profit Ratio by Department

# Create a bar plot for Profit Ratio per Department
ggplot(department_profit_ratio, aes(x = reorder(Department.Name, -profit_ratio), y = profit_ratio, fill = profit_ratio)) +
  geom_bar(stat = "identity") +  # Create a bar for each department
  labs(title = "Profit Ratio per Department", x = "Department Name", y = "Profit Ratio") +  # Add labels and title
  theme_minimal() +  # Use a minimal theme for better visuals
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability

