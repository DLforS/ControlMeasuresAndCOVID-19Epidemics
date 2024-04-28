#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import pandas as pd

# Load the CSV file with the relationships
data = pd.read_csv('results_Half_time_0813.csv')

# Load the Excel file with the countries data
data_log10 = pd.read_excel('Data_log10.xlsx')

def calculate_z_values(row):
    z1 = (1.000000 * row['Internalmovement'] +
          0.572030 * row['Publicevents'] +
          0.558571 * row['Schoolsclosures'] +
          1.684006 * row['Publicgatherings'] +
          1.398626 * row['Stayathomerestrictions'] +
          1.113587 * row['Publictransport'] +
          1.247310 * row['Workplacesclosures'] +
          0.115071 * row['Publicinformationcampaigns'] +
          0.888014 * row['Personalprotection'] +
          0.501199 * row['Internationaltravelcontrols'])
    
    z2 = (1.000000 * row['Incomesupport'] +
          1.037244 * row['Testingpolicy'] +
          0.619469 * row['Contacttracing'])
    
    z3 = (1.000000 * row['Suspectedcase'] +
          0.440750 * row['Detectionandtreatment'])
    
    z4 = 1.000000 * row['Medicalresources']

    return pd.Series([z1, z2, z3, z4], index=['Z1', 'Z2', 'Z3', 'Z4'])



z_values = data_log10.apply(calculate_z_values, axis=1)
data_with_z_values = pd.concat([data_log10[['Countries']], z_values], axis=1)

complete_data_with_z_values = pd.merge(data_log10, data_with_z_values, on='Countries', how='left')
complete_output_path = 'Half_time_Z.xlsx'
complete_data_with_z_values.to_excel(complete_output_path, index=False)





