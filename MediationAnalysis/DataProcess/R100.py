#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 14 17:27:09 2023

@author: yangwuyue
"""
import pandas as pd

# Load the CSV file with the relationships
data = pd.read_csv('results_R100_0814.csv')

# Load the Excel file with the countries data
data_log10 = pd.read_excel('Data_log10.xlsx')
def calculate_z_values(row):
    z1 = (1.0 * row['Internalmovement'] +
          0.576013132704552 * row['Publicevents'] +
          0.560130858319433 * row['Schoolsclosures'] +
          1.68423664455795 * row['Publicgatherings'] +
          1.37791189995889 * row['Stayathomerestrictions'] +
          1.10997317582451 * row['Publictransport'] +
          1.23790064507896 * row['Workplacesclosures'] +
          0.116137715322982 * row['Publicinformationcampaigns'] +
          0.894655385404351 * row['Personalprotection'] +
          0.502883066253159 * row['Internationaltravelcontrols'])
    
    z2 = (1.0 * row['Incomesupport'] +
          1.02127325239433 * row['Testingpolicy'] +
          0.159065384586954 * row['Contacttracing'])
    
    z3 = (1.0 * row['Suspectedcase'] +
          0.675914727177911 * row['Detectionandtreatment'])
    
    z4 = 1.0 * row['Medicalresources']
    
    return pd.Series([z1, z2, z3, z4], index=['Z1', 'Z2', 'Z3', 'Z4'])





z_values = data_log10.apply(calculate_z_values, axis=1)
data_with_z_values = pd.concat([data_log10[['Countries']], z_values], axis=1)

complete_data_with_z_values = pd.merge(data_log10, data_with_z_values, on='Countries', how='left')
complete_output_path = 'R100_Z.xlsx'
complete_data_with_z_values.to_excel(complete_output_path, index=False)



