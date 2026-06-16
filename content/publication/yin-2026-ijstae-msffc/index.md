---
title: 'MSFFC: A novel dimensionality reduction method for improving maize nitrogen
  estimation from high-dimensional spectral reflectance data'
date: '2026-01-01'
publication_types:
- '2'
authors:
- Hang Yin
- Haibo Yang
- Fei Li
- Yuncai Hu
- Kang Yu
publication: IEEE Journal of Selected Topics in Applied Earth Observations and Remote
  Sensing
doi: 10.1109/jstars.2026.3698129
url: ''
abstract: Due to strong inter-band correlations and redundancy, accurately extracting
  information related to crop canopy nitrogen content (CNC) from hyperspectral data
  remains challenging. To address this issue, this study proposes a multi-strategy
  feature fusion and compression (MSFFC) method that integrates optimal band subsets
  selected by different feature selection methods and further compresses redundant
  information using an autoencoder (AE). This design improves the retention of complementary
  spectral information while alleviating the influence of feature correlation on CNC
  inversion. Based on UAV hyperspectral images and CNC data from maize under different
  nitrogen fertilizer gradients during 2020-2022, fifteen feature selection methods
  were evaluated. Subsequently, AE was employed to compress the optimal single feature
  subset and the fused feature subset to reduce redundancy. Five commonly used machine
  learning models and the Tabular Prior-data Fitted Network (TabPFN) were employed
  as evaluation functions and modeling tools for the dimensionality reduction method.
  Although the successive projection algorithm (SPA) demonstrated the best performance
  among all feature selection methods, integrating SPA with AE did not further improve
  model accuracy. In contrast, MSFFC achieved a significant reduction in model RMSE,
  ranging from 0.9\% to 38.7\% while reducing full-band hyperspectral data by 97.6\%.
  The robustness of models constructed using SPA and MSFFC features was compared on
  the external dataset, the PROSAIL-PRO simulation dataset, and the public dataset.
  The results showed that the quality of the input features has a greater impact on
  model performance than the dataset's size. MSFFC mitigates the estimation limitations
  of traditional artificial neural network models in small-sample scenarios ($<$ 100
  samples). Among all models, MSFFC-TabPFN demonstrated the best performance, achieving
  a 25.9\%-123.2\% improvement in the composite performance index (CPI). These results
  highlight the critical role of combining feature selection methods with nonlinear
  feature compression in hyperspectral research, providing essential methodological
  support for robust, generalizable crop parameter inversion models.

---

Hang Yin, Haibo Yang, Fei Li, Yuncai Hu, & Kang Yu (2026). MSFFC: A novel dimensionality reduction method for improving maize nitrogen estimation from high-dimensional spectral reflectance data. *IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing*: 1-17.
