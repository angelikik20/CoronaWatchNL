library(tidyverse)
library(cowplot)
library(glue)
library(lubridate)
dir.create("plots")

###################
##### IC DATA #####
###################

# NICE DATA
data_nice <- read_csv("data/nice_ic_by_day.csv")

# sort data
data_nice <- data_nice %>%
  select(Datum, newIntake) %>%
  rename("Aantal" = newIntake) %>%
  mutate(meas = "Nieuw") %>%
  bind_rows(data_nice %>%
              select(Datum, intakeCount) %>%
              rename("Aantal" = intakeCount) %>%
              mutate(meas = "Actueel")) %>%
  bind_rows(data_nice %>%
              select(Datum, intakeCumulative) %>%
              rename("Aantal" = intakeCumulative) %>%
              mutate(meas = "Cumulatief")) %>%
  bind_rows(data_nice %>%
              select(Datum, survivedCumulative) %>%
              rename("Aantal" = survivedCumulative) %>%
              mutate(meas = "Overleefd")) %>%
  bind_rows(data_nice %>%
              select(Datum, diedCumulative) %>%
              rename("Aantal" = diedCumulative) %>%
              mutate(meas = "Overleden")) %>%
  bind_rows(data_nice %>%
              select(Datum, icCount) %>%
              rename("Aantal" = icCount) %>%
              mutate(meas = "icCount"))

# plot "IC opnamen"
data_nice %>%
  filter(meas == "Nieuw" |
           meas == "Actueel" |
           meas == "Cumulatief") %>%
  mutate(meas = factor(meas, c("Nieuw", "Actueel", "Cumulatief"))) %>%
  ggplot(aes(x = Datum, y = Aantal, colour = meas, group = meas)) +
  geom_line()+
  theme_minimal() +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.pos = "bottom",
        legend.title = element_blank()) +
  scale_color_manual(values=c("#E69F00", "#56B4E9", "#999999")) +
  ggtitle("NICE: Aantal IC-opnamen van COVID-19 patiënten") +
  ggsave("plots/ic_nice_intakes.png", width = 5.5, height=4)

# plot "Vrijkomst IC-bedden"
data_nice %>%
  filter(meas == "Overleefd" |
           meas == "Overleden") %>%
  ggplot(aes(x = Datum, y = Aantal, colour = meas, group = meas)) +
  geom_line()+
  theme_minimal() +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.pos = "bottom",
        legend.title = element_blank()) +
  scale_color_manual(values=c("#E69F00", "#56B4E9", "#999999")) +
  ggtitle("NICE: Vrijkomst IC-bedden COVID-19 patiënten") +
  ggsave("plots/ic_nice_vrijkomst.png", width = 5.5, height=4)

# LCPS data
data_lcps <- read_csv("data/lcps_ic.csv")
head(data_lcps)

# plot aantal opnamen
data_lcps %>%
  ggplot(aes(x = Date, y = Aantal)) +
  geom_line(colour = "#E69F00")+
  theme_minimal() +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.pos = "bottom",
        legend.title = element_blank()) +
  ggtitle("LCPS: Aantal IC-opnamen COVID-19 patiënten") +
  ggsave("plots/ic_lcps_intakes.png", width = 5.5, height=4)


# Combine nice and lcps data
data_ic <- data_lcps %>%
  rename("Datum" = Date) %>%
  mutate(meas = "Actueel",
         bron = "LCPS") %>%
  bind_rows(data_nice %>%
              mutate(bron = "NICE"))

# plot combination
data_ic %>%
  filter(meas == "Actueel") %>%
  mutate(bron = factor(bron, c("LCPS", "NICE"))) %>%
  ggplot(aes(x = Datum, y = Aantal, colour = bron)) +
  geom_line() +
  theme_minimal() +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.pos = "bottom",
        legend.title = element_blank()) +
  scale_color_manual(values=c("#E69F00", "#56B4E9", "#999999")) +
  ggtitle("LCPS vs NICE: Aantal IC-opnamen COVID-19 patiënten") +
  ggsave("plots/ic_lcps_nice.png", width = 5.5, height=4)