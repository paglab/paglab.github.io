---
title: Physics-informed machine learning and Vision Transformer for predicting photosynthetic
  traits, biomass, and grain yield in winter wheat using UAV multispectral imagery
date: '2026-09-01'
publication_types:
- '2'
authors:
- Jingcheng Zhang
- Kang Yu
publication: European Journal of Agronomy
doi: 10.1016/j.eja.2026.128202
url: ''
abstract: Predicting crop photosynthetic traits from UAV imagery requires frameworks
  that connect canopy-level spectral observations to leaf-level physiological processes.
  Existing approaches rely on empirical vegetation indices (VIs) and standard machine
  learning models, lacking physical interpretability and appropriate deep learning
  architectures for image data. We developed a physics-informed multi-output machine
  learning framework that combines PROSAIL radiative transfer model inversion-derived
  biophysical parameters with spectral VIs and texture features (TFs), applies two
  spatial deep learning architectures, a Vision Transformer (ViT) and a 2D convolutional
  neural network (CNN), to multispectral image patches, and introduces a hybrid architecture
  that fuses PROSAIL-derived features with ViT spatial embeddings. The framework was
  evaluated for predicting CO2 assimilation rate (A), stomatal conductance (gsw),
  Photosystem II efficiency (Fv'/Fm'), aboveground biomass (AGB), and grain yield
  in a subset of seven European winter wheat varieties selected from a larger 18-variety
  field experiment across two growing seasons (2022--2024). Model performance was
  evaluated using random hold-out tests and leave-one-variety-out (LOVO) validation
  with bootstrap confidence intervals. For grain yield, the best tabular models achieved
  R2 = 0.92--0.96, and the ViT on image patches achieved a competitive R2 = 0.92.
  ViT delivered the best performance in predicting gsw. BorutaSHAP selected PROSAIL-derived
  features alongside empirical VIs, confirming that physics-informed features provide
  complementary information. The hybrid ViT+PROSAIL model matched or outperformed
  ViT-only for most traits under LOVO validation, with the clearest gain observed
  for grain yield, indicating that physics-based features can help regularize spatial
  representations for improved cultivar-level transferability. This study demonstrates
  that integrating radiative transfer model physics with spatial deep learning advances
  UAV-based high-throughput phenotyping of photosynthetic traits in breeding programs.

---

Jingcheng Zhang & Kang Yu (2026). Physics-informed machine learning and Vision Transformer for predicting photosynthetic traits, biomass, and grain yield in winter wheat using UAV multispectral imagery. *European Journal of Agronomy*, 180: 128202.
