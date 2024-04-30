#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import pandas as pd

# Load the CSV file with the relationships
data = pd.read_csv('results_D100_0814.csv')

# Load the Excel file with the countries data
data_log10 = pd.read_excel('Data_log10.xlsx')
def calculate_z_values(row):
    z1 = (1.0 * row['Internalmovement'] +
          0.576457299245557 * row['Publicevents'] +
          0.561028447280926 * row['Schoolsclosures'] +
          1.68295358079387 * row['Publicgatherings'] +
          1.37505982128743 * row['Stayathomerestrictions'] +
          1.10872547045007 * row['Publictransport'] +
          1.23407821389411 * row['Workplacesclosures'] +
          0.115737823976935 * row['Publicinformationcampaigns'] +
          0.892431200995308 * row['Personalprotection'] +
          0.506122949402411 * row['Internationaltravelcontrols'])
    
    z2 = (1.0 * row['Incomesupport'] +
          0.634380549998793 * row['Testingpolicy'] +
          -0.0598673217117192 * row['Contacttracing'])
    
    z3 = (1.0 * row['Suspectedcase'] +
          0.488055201059834 * row['Detectionandtreatment'])
    
    z4 = 1.0 * row['Medicalresources']
    
    return pd.Series([z1, z2, z3, z4], index=['Z1', 'Z2', 'Z3', 'Z4'])



z_values = data_log10.apply(calculate_z_values, axis=1)
data_with_z_values = pd.concat([data_log10[['Countries']], z_values], axis=1)

complete_data_with_z_values = pd.merge(data_log10, data_with_z_values, on='Countries', how='left')
complete_output_path = 'D100_Z.xlsx'
complete_data_with_z_values.to_excel(complete_output_path, index=False)



